//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Inspectable Priority range 50-99

package cadet2D.components.particles
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	
	import cadet.core.Component;
	import cadet.core.IInitialisableComponent;
	import cadet.events.RendererEvent;
	import cadet.util.deg2rad;
	import cadet.util.rad2deg;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.IAnimatable;
	import cadet2D.components.textures.TextureComponent;
	
	import starling.display.DisplayObjectContainer;
	import starling.extensions.ColorArgb;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	
	public class PDParticleSystemComponent extends Component implements IInitialisableComponent, IAnimatable
	{
		private const RESOURCES						:String = "resources";
		private const DISPLAY						:String = "display";
		
		[Embed(source="NullParticle.png")]
		private static var NullParticle				:Class;
		
		private static var EMITTER_TYPE_GRAVITY		:String = "Gravity";
		private static var EMITTER_TYPE_RADIAL		:String = "Radial";
		
		private var _emitterType					:String = EMITTER_TYPE_GRAVITY;
		
		private var _particleSystem					:PDParticleSystem;
		
		private var _renderer						:Renderer2D;
		private var _targetSkin						:AbstractSkin2D;
		private var _displayObjectContainer			:DisplayObjectContainer;
		
		private var _addedToDisplayList				:Boolean;
		private var _addedToJuggler					:Boolean;
		private var _started						:Boolean;
		private var _initialised					:Boolean;
		private var _autoplay						:Boolean;
		
		private var _startColor						:uint;
		private var _startColorVariance				:uint;
		private var _endColor						:uint;
		private var _endColorVariance				:uint;
		
		private var _xml							:XML;
		
		private var _defaultTexture					:Texture;
		private var _texture						:TextureComponent;
		
		// Default values
		private var _defaultStartColor				:ColorArgb = new ColorArgb(1,0,0,1);
		private var _defaultEndColor				:ColorArgb = new ColorArgb(0,0,1,1);
		private var _defaultMaxNumParticles			:uint = 128;
		private var _defaultLifeSpan				:Number = 0.4;
		private var _defaultStartSize				:Number = 50;
		private var _defaultEndSize					:Number = 10;
		private var _defaultSpeed					:Number = 800;
		private var _defaultMaxCapacity				:int = 8192;
		private var _defaultEmissionRate			:Number = _defaultMaxNumParticles / _defaultLifeSpan;
		private var _defaultBlendFactorSource		:String = Context3DBlendFactor.SOURCE_ALPHA;
		private var _defaultBlendFactorDest			:String = Context3DBlendFactor.ONE;
		
		public function PDParticleSystemComponent( config:XML = null, textureComponent:TextureComponent = null )
		{
			_xml = config;
			_texture = texture;
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(Renderer2D, "renderer");
			
			if ( renderer && renderer.initialised ) {
				createDefaultTexture();
				invalidate( RESOURCES );
			}
		}
		
		// IInitialisableComponent
		public function init():void
		{
			_initialised = true;
			
			invalidate( DISPLAY );
		}
		
		private function createDefaultTexture():void
		{
			if ( _defaultTexture ) return;
			var instance:BitmapData = new NullParticle().bitmapData;
			_defaultTexture = Texture.fromBitmap( new Bitmap(instance), false );
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( RESOURCES ) ) {
				validateResources();
			}
				
			if ( isInvalid( DISPLAY ) ) {
				validateDisplay();
			}
				
			super.validateNow();
		}
		
		private function validateResources():void
		{			
			var config:XML;
			var texture:Texture;
			
			if ( _xml ) config = _xml;
			else 		config = serialise();
			
			if ( _texture && _texture.texture) 	texture = _texture.texture;
			else								texture = _defaultTexture;
			
			// When deserializing from XML, the texture doesn't have a chance to load immediately
			// because it requires the Starling.context
			if (!texture) return;
			
			stop(true);
			removeFromDisplayList(true);
			removeFromJuggler();
			
			_particleSystem = new PDParticleSystem(config, texture);
			
			addToJuggler();
			addToDisplayList();
			if (_autoplay) start();
		}
		
		private function validateDisplay():void
		{			
			if ( _targetSkin ) {
				if ( _targetSkin.displayObject is DisplayObjectContainer ) {
					_displayObjectContainer = DisplayObjectContainer(_targetSkin.displayObject);
				}
			} else {
				// If targetSkin is deselected, revert to renderer viewport
				if ( _renderer && _renderer.initialised ) {
					_displayObjectContainer = _renderer.viewport;
				}
			}
			
			removeFromDisplayList();
			
			addToJuggler();
			addToDisplayList();
			if (_autoplay) start();
		}
		
		// -------------------------------------------------------------------------------------
		// INSPECTABLE API
		// -------------------------------------------------------------------------------------
		
		[Serializable][Inspectable]
		public function set autoplay( value:Boolean ):void
		{
			_autoplay = value;
		}
		public function get autoplay():Boolean
		{
			return _autoplay;
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="50" )]
		public function set targetSkin( value:AbstractSkin2D ):void
		{
			_targetSkin = value;
			
			invalidate( DISPLAY );
		}
		public function get targetSkin():AbstractSkin2D { return _targetSkin; }
		
		[Serializable( type="resource" )][Inspectable( priority="51", editor="ResourceItemEditor", extensions="[pex]")]
		public function set xml( value:XML ):void
		{
			_xml = value;
			invalidate( RESOURCES );
		}
		public function get xml():XML { return _xml; }
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="52" )]
		public function set texture( value:TextureComponent ):void
		{
			_texture = value;
			invalidate( RESOURCES );
		}
		public function get texture():TextureComponent { return _texture; }	
		
		// -------------------------------------------------------------------------------------
		
		public function get renderer():Renderer2D { return _renderer; }
		public function set renderer( value:Renderer2D ):void
		{
			if ( _renderer ) {
				_renderer.removeEventListener(RendererEvent.INITIALISED, rendererInitialisedHandler);
			}
			
			_renderer = value;
			
			if (!_renderer) return;
			
			if ( _renderer.initialised ) {
				invalidate( DISPLAY );
			} else {
				_renderer.addEventListener(RendererEvent.INITIALISED, rendererInitialisedHandler);
			}
		}
		
		private function rendererInitialisedHandler( event:RendererEvent ):void
		{
			_renderer.removeEventListener(RendererEvent.INITIALISED, rendererInitialisedHandler);
			
			createDefaultTexture();
			invalidate( RESOURCES );
			invalidate( DISPLAY );
		}
		
		public function addToJuggler():Boolean
		{
			if (!_initialised) return false;	// only add if in run mode
			if (!renderer || !renderer.initialised) return false;
			if (!_particleSystem) return false;
			if (_addedToJuggler) return false;
			
			renderer.addToJuggler(_particleSystem);
			_addedToJuggler = true;
			
			return true;
		}
		public function removeFromJuggler():Boolean
		{
			if (!renderer || !renderer.initialised) return false;
			if (!_particleSystem) return false;
			if (!_addedToJuggler) return false;
			
			renderer.removeFromJuggler(_particleSystem);
			_addedToJuggler = false;
			
			return true;
		}
		
		private function addToDisplayList():void
		{
			if (!_initialised) return;	// only add if in run mode
			if (!_particleSystem) return;
			if (_addedToDisplayList) return;
			if (!_displayObjectContainer) return;
			
			_displayObjectContainer.addChild(_particleSystem);
			_addedToDisplayList = true;
		}
		private function removeFromDisplayList(dispose:Boolean = false):void
		{
			if ( !_particleSystem || !_particleSystem.parent ) return;
			if (!_addedToDisplayList) return;
			
			_particleSystem.removeFromParent(dispose);
			_addedToDisplayList = false;
		}
		public function start(duration:Number = Number.MAX_VALUE):void
		{
			if (!_initialised) return;
			if (!_particleSystem) return;
			//if (_started) return;
			
			_particleSystem.start(duration);
			_started = true;
		}
		public function stop(clearParticles:Boolean = false):void
		{
			if (!_particleSystem) return;
			//if (!_started) return;
			
			_particleSystem.stop(clearParticles);
			_started = false;
		}
		
		[Serializable][Inspectable( priority="53", editor="DropDownMenu", dataProvider="[Gravity,Radial]" )]
		public function get emitterType():String 
		{ 
			var uintType:uint = _particleSystem.emitterType;
			
			if ( uintType == 0 ) {
				_emitterType = EMITTER_TYPE_GRAVITY;
			} else if ( uintType == 1 ) {
				_emitterType = EMITTER_TYPE_RADIAL;
			}
			
			return _emitterType; 
		}
		public function set emitterType(value:String):void 
		{ 
			_emitterType = value;
			
			var uintType:uint = 0;
			if ( _emitterType == EMITTER_TYPE_RADIAL ) {
				uintType = 1;
			}
			
			_particleSystem.emitterType = uintType; 
		}
		
		private function get emitterTypeInt():int
		{
			if (!_particleSystem) return 0;
			else return _particleSystem.emitterType;
		}
		
		[Serializable][Inspectable( priority="54", editor="ColorPicker" )]
		public function get startColor():uint { return _particleSystem.startColor.toRgb(); }
		public function set startColor(value:uint):void 
		{ 
			_startColor = value;
			_particleSystem.startColor = ColorArgb.fromRgb(_startColor); 
		}
		
		[Serializable][Inspectable( priority="55", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get startColorAlpha():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.startColor.alpha;
		}
		public function set startColorAlpha(value:Number):void 
		{ 
			_particleSystem.startColor.alpha = value;
		}
		
		[Serializable][Inspectable( priority="56", editor="ColorPicker" )]
		public function get startColorVariance():uint 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.startColorVariance.toRgb(); 
		}
		public function set startColorVariance(value:uint):void 
		{ 
			_startColorVariance = value;
			_particleSystem.startColorVariance = ColorArgb.fromRgb(_startColorVariance); 
		}
		
		[Serializable][Inspectable( priority="57", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get startColorVarAlpha():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.startColorVariance.alpha; 
		}
		public function set startColorVarAlpha(value:Number):void 
		{ 
			_particleSystem.startColorVariance.alpha = value; 
		}
		
		[Serializable][Inspectable( priority="58", editor="ColorPicker" )]
		public function get endColor():uint { return _particleSystem.endColor.toRgb(); }
		public function set endColor(value:uint):void 
		{ 
			_endColor = value;
			_particleSystem.endColor = ColorArgb.fromRgb(_endColor); 
		}
		
		[Serializable][Inspectable( priority="59", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get endColorAlpha():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.endColor.alpha; 
		}
		public function set endColorAlpha(value:Number):void 
		{ 
			_particleSystem.endColor.alpha = value;
		}				
		
		[Serializable][Inspectable( priority="60", editor="ColorPicker" )]
		public function get endColorVariance():uint 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.endColorVariance.toRgb(); 
		}
		public function set endColorVariance(value:uint):void 
		{ 
			_endColorVariance = value;
			_particleSystem.endColorVariance = ColorArgb.fromRgb(_endColorVariance);
		}
		
		[Serializable][Inspectable( priority="61", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get endColorVarAlpha():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.endColorVariance.alpha; 
		}
		public function set endColorVarAlpha(value:Number):void 
		{ 
			_particleSystem.endColorVariance.alpha = value; 
		}
		
		private function get startColorRGBA():ColorArgb
		{
			if (!_particleSystem) return _defaultStartColor;
			return _particleSystem.startColor;
		}
		private function get startColorVarianceRGBA():ColorArgb
		{
			if (!_particleSystem) return new ColorArgb();
			return _particleSystem.startColorVariance;
		}
		private function get endColorRGBA():ColorArgb
		{
			if (!_particleSystem) return _defaultEndColor;
			return _particleSystem.endColor;
		}
		private function get endColorVarianceRGBA():ColorArgb
		{
			if (!_particleSystem) return new ColorArgb();
			return _particleSystem.endColorVariance;
		}

		[Serializable][Inspectable(priority="62") ]
		public function get maxCapacity():int 
		{ 
			if (!_particleSystem) return _defaultMaxCapacity;
			return _particleSystem.maxCapacity; 
		}
		public function set maxCapacity(value:int):void 
		{ 
			_particleSystem.maxCapacity = value; 
		}
		
		[Serializable][Inspectable(priority="63") ]
		public function get emissionRate():Number 
		{
			if (!_particleSystem) return _defaultEmissionRate;
			return _particleSystem.emissionRate; 
		}
		public function set emissionRate(value:Number):void 
		{ 
			_particleSystem.emissionRate = value; 
		}
		
		[Serializable][Inspectable(priority="64") ]
		public function get emitterX():Number
		{
			if (!_particleSystem) return 0;
			return _particleSystem.emitterX;
		}
		public function set emitterX(value:Number):void
		{
			_particleSystem.emitterX = value;
		}
		
		[Serializable][Inspectable(priority="65") ]
		public function get emitterY():Number
		{
			if (!_particleSystem) return 0;
			return _particleSystem.emitterY;
		}
		public function set emitterY(value:Number):void
		{
			_particleSystem.emitterY = value;
		}
		
		[Serializable][Inspectable(priority="66", editor="DropDownMenu", dataProvider="[zero,one,sourceColor,oneMinusSourceColor,sourceAlpha,oneMinusSourceAlpha,destinationAlpha,oneMinusDestinationAlpha,destinationColor,oneMinusDestinationColor]") ]
		public function get blendFactorSource():String 
		{ 
			if (!_particleSystem) return _defaultBlendFactorSource;
			return _particleSystem.blendFactorSource; 
		}
		public function set blendFactorSource(value:String):void 
		{ 
			_particleSystem.blendFactorSource = value; 
		}
		
		[Serializable][Inspectable(priority="67", editor="DropDownMenu", dataProvider="[zero,one,sourceColor,oneMinusSourceColor,sourceAlpha,oneMinusSourceAlpha,destinationAlpha,oneMinusDestinationAlpha,destinationColor,oneMinusDestinationColor]") ]
		public function get blendFactorDest():String 
		{ 
			if (!_particleSystem) return _defaultBlendFactorDest;
			return _particleSystem.blendFactorDestination; 
		}
		public function set blendFactorDest(value:String):void 
		{ 
			_particleSystem.blendFactorDestination = value; 
		}
				
		
		[Serializable][Inspectable(priority="68") ]
		public function get emitterXVariance():Number 
		{
			if (!_particleSystem)	return 0;
			return _particleSystem.emitterXVariance; 
		}
		public function set emitterXVariance(value:Number):void { _particleSystem.emitterXVariance = value; }
		
		[Serializable][Inspectable(priority="69") ]
		public function get emitterYVariance():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.emitterYVariance; 
		}
		public function set emitterYVariance(value:Number):void { _particleSystem.emitterYVariance = value; }
		
		[Serializable][Inspectable(priority="70") ]
		public function get maxNumParticles():int 
		{ 
			if (!_particleSystem)	return _defaultMaxNumParticles;
			return _particleSystem.maxNumParticles; 
		}
		public function set maxNumParticles(value:int):void { _particleSystem.maxNumParticles = value; }
		
		[Serializable][Inspectable(priority="71") ]
		public function get lifespan():Number 
		{ 
			if (!_particleSystem)	return _defaultLifeSpan;
			return _particleSystem.lifespan; 
		}
		public function set lifespan(value:Number):void { _particleSystem.lifespan = value; }
		
		[Serializable][Inspectable(priority="72") ]
		public function get lifespanVariance():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.lifespanVariance; 
		}
		public function set lifespanVariance(value:Number):void { _particleSystem.lifespanVariance = value; }
		
		[Serializable][Inspectable(priority="73") ]
		public function get startSize():Number 
		{ 
			if (!_particleSystem)	return _defaultStartSize;
			return _particleSystem.startSize; 
		}
		public function set startSize(value:Number):void { _particleSystem.startSize = value; }
		
		[Serializable][Inspectable(priority="74") ]
		public function get startSizeVariance():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.startSizeVariance; 
		}
		public function set startSizeVariance(value:Number):void { _particleSystem.startSizeVariance = value; }
		
		[Serializable][Inspectable(priority="75") ]
		public function get endSize():Number 
		{ 
			if (!_particleSystem)	return _defaultEndSize;
			return _particleSystem.endSize; 
		}
		public function set endSize(value:Number):void { _particleSystem.endSize = value; }
		
		[Serializable][Inspectable(priority="76") ]
		public function get endSizeVariance():Number 
		{
			if (!_particleSystem)	return 0;
			return _particleSystem.endSizeVariance; 
		}
		public function set endSizeVariance(value:Number):void { _particleSystem.endSizeVariance = value; }
		
		[Serializable][Inspectable(priority="77", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get emitAngle():Number 
		{ 
			if (!_particleSystem)	return 0;
			return rad2deg(_particleSystem.emitAngle); 
		}
		public function set emitAngle(value:Number):void { _particleSystem.emitAngle = deg2rad(value); }
		
		[Serializable][Inspectable(priority="78", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get emitAngleVariance():Number 
		{ 
			if (!_particleSystem)	return 0;
			return rad2deg(_particleSystem.emitAngleVariance); 
		}
		public function set emitAngleVariance(value:Number):void { _particleSystem.emitAngleVariance = deg2rad(value); }
		
		[Serializable][Inspectable( priority="79", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get startRotation():Number 
		{ 
			if (!_particleSystem)	return 0;
			return rad2deg(_particleSystem.startRotation); 
		} 
		public function set startRotation(value:Number):void { _particleSystem.startRotation = deg2rad(value); }
		
		[Serializable][Inspectable( priority="80", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get startRotationVar():Number 
		{ 
			if (!_particleSystem)	return 0;
			return rad2deg(_particleSystem.startRotationVariance); 
		} 
		public function set startRotationVar(value:Number):void { _particleSystem.startRotationVariance = deg2rad(value); }
		
		[Serializable][Inspectable(priority="81", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get endRotation():Number 
		{ 
			if (!_particleSystem)	return 0;
			return rad2deg(_particleSystem.endRotation); 
		} 
		public function set endRotation(value:Number):void { _particleSystem.endRotation = deg2rad(value); }
		
		[Serializable][Inspectable(priority="82", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get endRotationVar():Number 
		{ 
			if (!_particleSystem)	return 0;
			return rad2deg(_particleSystem.endRotationVariance); 
		} 
		public function set endRotationVar(value:Number):void { _particleSystem.endRotationVariance = deg2rad(value); }
		
		[Serializable][Inspectable(priority="83") ]
		public function get speed():Number 
		{ 
			if (!_particleSystem)	return _defaultSpeed;
			return _particleSystem.speed; 
		}
		public function set speed(value:Number):void { _particleSystem.speed = value; }
		
		[Serializable][Inspectable(priority="84") ]
		public function get speedVariance():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.speedVariance; 
		}
		public function set speedVariance(value:Number):void { _particleSystem.speedVariance = value; }
		
		[Serializable][Inspectable(priority="85") ]
		public function get gravityX():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.gravityX; 
		}
		public function set gravityX(value:Number):void { _particleSystem.gravityX = value; }
		
		[Serializable][Inspectable(priority="86") ]
		public function get gravityY():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.gravityY; 
		}
		public function set gravityY(value:Number):void { _particleSystem.gravityY = value; }
		
		[Serializable][Inspectable(priority="87") ]
		public function get radialAcceleration():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.radialAcceleration; 
		}
		public function set radialAcceleration(value:Number):void { _particleSystem.radialAcceleration = value; }
		
		[Serializable][Inspectable(priority="88") ]
		public function get radialAccelVar():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.radialAccelerationVariance; 
		}
		public function set radialAccelVar(value:Number):void { _particleSystem.radialAccelerationVariance = value; }
		
		[Serializable][Inspectable(priority="89") ]
		public function get tangentialAccel():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.tangentialAcceleration; 
		}
		public function set tangentialAccel(value:Number):void { _particleSystem.tangentialAcceleration = value; }
		
		[Serializable][Inspectable(priority="90") ]
		public function get tangentialAccelVar():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.tangentialAccelerationVariance; 
		}
		public function set tangentialAccelVar(value:Number):void { _particleSystem.tangentialAccelerationVariance = value; }
		
		[Serializable][Inspectable(priority="91") ]
		public function get maxRadius():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.maxRadius; 
		}
		public function set maxRadius(value:Number):void { _particleSystem.maxRadius = value; }
		
		[Serializable][Inspectable(priority="92") ]
		public function get maxRadiusVariance():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.maxRadiusVariance; 
		}
		public function set maxRadiusVariance(value:Number):void { _particleSystem.maxRadiusVariance = value; }
		
		[Serializable][Inspectable(priority="93") ]
		public function get minRadius():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.minRadius; 
		}
		public function set minRadius(value:Number):void { _particleSystem.minRadius = value; }
		
		[Serializable][Inspectable(priority="94") ]
		public function get rotatePerSecond():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.rotatePerSecond; 
		}
		public function set rotatePerSecond(value:Number):void { _particleSystem.rotatePerSecond = value; }
		
		[Serializable][Inspectable(priority="95") ]
		public function get rotatePerSecondVar():Number 
		{ 
			if (!_particleSystem)	return 0;
			return _particleSystem.rotatePerSecondVariance; 
		}
		public function set rotatePerSecondVar(value:Number):void { _particleSystem.rotatePerSecondVariance = value; }
				
		public function serialise():XML
		{
			var defaultXML:XML =
				<particleEmitterConfig>
				  <texture name="drugs_particle.png"/>
				  <sourcePosition x={emitterX} y={emitterY}/>
				  <sourcePositionVariance x={emitterXVariance} y={emitterYVariance}/>
				  <speed value={speed}/>
				  <speedVariance value={speedVariance}/>
				  <particleLifeSpan value={lifespan}/>
				  <particleLifespanVariance value={lifespanVariance}/>
				  <angle value={emitAngle}/>
				  <angleVariance value={emitAngleVariance}/>
				  <gravity x={gravityX} y={gravityY}/>
				  <radialAcceleration value={radialAcceleration}/>
				  <tangentialAcceleration value={tangentialAccel}/>
				  <radialAccelVariance value={radialAccelVar}/>
				  <tangentialAccelVariance value={tangentialAccelVar}/>
				  <startColor red={startColorRGBA.red} green={startColorRGBA.green} blue={startColorRGBA.blue} alpha={startColorRGBA.alpha}/>
				  <startColorVariance red={startColorVarianceRGBA.red} green={startColorVarianceRGBA.green} blue={startColorVarianceRGBA.blue} alpha={startColorVarianceRGBA.alpha}/>
				  <finishColor red={endColorRGBA.red} green={endColorRGBA.green} blue={endColorRGBA.blue} alpha={endColorRGBA.alpha}/>
				  <finishColorVariance red={endColorVarianceRGBA.red} green={endColorVarianceRGBA.green} blue={endColorVarianceRGBA.blue} alpha={endColorVarianceRGBA.alpha}/>
				  <maxParticles value={maxNumParticles}/>
				  <startParticleSize value={startSize}/>
				  <startParticleSizeVariance value={startSizeVariance}/>
				  <finishParticleSize value={endSize}/>
				  <FinishParticleSizeVariance value={endSizeVariance}/>
				  <duration value="-1.00"/>
				  <emitterType value={emitterTypeInt}/>
				  <maxRadius value={maxRadius}/>
				  <maxRadiusVariance value={maxRadiusVariance}/>
				  <minRadius value={minRadius}/>
				  <rotatePerSecond value={rotatePerSecond}/>
				  <rotatePerSecondVariance value={rotatePerSecondVar}/>
				  <blendFuncSource value={getBlendFunc(blendFactorSource)}/>
				  <blendFuncDestination value={getBlendFunc(blendFactorDest)}/>
				  <rotationStart value={startRotation}/>
				  <rotationStartVariance value={startRotationVar}/>
				  <rotationEnd value={endRotation}/>
				  <rotationEndVariance value={endRotationVar}/>
				</particleEmitterConfig>;
			
			return defaultXML;
		}
		
		private function getBlendFunc(value:String):int
		{
			switch (value)
			{
				case Context3DBlendFactor.ZERO:     return 0; break;
				case Context3DBlendFactor.ONE:     return 1; break;
				case Context3DBlendFactor.SOURCE_COLOR: return 0x300; break;
				case Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR: return 0x301; break;
				case Context3DBlendFactor.SOURCE_ALPHA: return 0x302; break;
				case Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA: return 0x303; break;
				case Context3DBlendFactor.DESTINATION_ALPHA: return 0x304; break;
				case Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA: return 0x305; break;
				case Context3DBlendFactor.DESTINATION_COLOR: return 0x306; break;
				case Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR: return 0x307; break;
				default:    throw new ArgumentError("unsupported blending function: " + value);
			}
		}
	}
}