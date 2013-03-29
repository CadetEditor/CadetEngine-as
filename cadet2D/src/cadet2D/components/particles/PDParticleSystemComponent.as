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
	import flash.geom.Matrix;
	
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.core.IInitialisableComponent;
	import cadet.events.RendererEvent;
	import cadet.util.deg2rad;
	import cadet.util.rad2deg;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.IAnimatable;
	import cadet2D.components.textures.TextureComponent;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.extensions.ColorArgb;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	
	public class PDParticleSystemComponent extends Component implements IInitialisableComponent, IAnimatable
	{
		// ITransform2D values
		protected var _x						:Number = 0;
		protected var _y						:Number = 0;
		protected var _scaleX					:Number = 1;
		protected var _scaleY					:Number = 1;
		protected var _rotation					:Number = 0;
		
		// Constants
		private const TRANSFORM						:String = "transform";
		private const RESOURCES						:String = "resources";
		private const DISPLAY						:String = "display";
		
		[Embed(source="NullParticle.png")]
		private static var NullParticle				:Class;
		
		private static var EMITTER_TYPE_GRAVITY		:String = "Gravity";
		private static var EMITTER_TYPE_RADIAL		:String = "Radial";
		
		private var _emitterType					:String = EMITTER_TYPE_GRAVITY;
		
		private var _particleSystem					:PDParticleSystem;
		
		private var _renderer						:Renderer2D;
		
		private var _addedToJuggler					:Boolean;
		private var _started						:Boolean;
		private var _initialised					:Boolean;
		private var _autoplay						:Boolean = true;
		
		private var _xml							:XML;
		
		private var _defaultTexture					:Texture;
		private var _texture						:TextureComponent;
		
		// GETTER/SETTER VALUES
		private var _emitterTypeInt					:uint = 0;
		// Start Color
		private var _startColor						:uint = 0x0000FF;
		private var _startColorAlpha				:Number = 1;
		private var _startColorVariance				:uint = 0;
		private var _startColorVarAlpha				:Number = 1;
		private var _startColorARGB					:ColorArgb = new ColorArgb(1,0,0,1);
		private var _startColorVarARGB				:ColorArgb = new ColorArgb(0,0,0,0);
		// End Color
		private var _endColor						:uint = 0x00FFFF;
		private var _endColorAlpha					:Number = 0;
		private var _endColorVariance				:uint = 0;
		private var _endColorVarAlpha				:uint = 0;
		private var _endColorARGB					:ColorArgb = new ColorArgb(0,0,1,1);
		private var _endColorVarARGB				:ColorArgb = new ColorArgb(0,0,0,0);
		
		private var _maxCapacity					:int = 8192;
		private var _emitterX						:Number = 0;
		private var _emitterY						:Number = 0;
		private var _emitterXVariance				:Number = 0;
		private var _emitterYVariance				:Number = 0;
		private var _blendFactorSource				:String = Context3DBlendFactor.SOURCE_ALPHA;
		private var _blendFactorDest				:String = Context3DBlendFactor.ONE;
		private var _maxNumParticles				:uint = 128;
		private var _lifespan						:Number = 0.4;
		private var _lifespanVariance				:Number = 0;
		private var _emissionRate					:Number = _maxNumParticles / _lifespan;
		private var _startSize						:Number = 50;
		private var _startSizeVariance				:Number = 0;
		private var _endSize						:Number = 10;
		private var _endSizeVariance				:Number = 0;
				
		private var _speed							:Number = 800;
		private var _speedVariance					:Number = 0;
		private var _gravityX						:Number = 0;
		private var _gravityY						:Number = 0;
		private var _radialAcceleration				:Number = 0;
		private var _radialAccelVar					:Number = 0;
		private var _tangentialAccel				:Number = 0;
		private var _tangentialAccelVar				:Number = 0; 
		private var _maxRadius						:Number = 100;
		private var _maxRadiusVariance				:Number = 0;
		private var _minRadius						:Number = 20;
		
		// Angles
		// All angles are stored in degrees and need to be converted to radians when passed back and forth
		// from the ParticleSystem. (Degrees make for clearer gradiation with UI)
		private var _emitAngle						:Number = 0; 
		private var _emitAngleVariance				:Number = 0; 
		private var _startRotation					:Number = 0;
		private var _startRotationVar				:Number = 0;
		private var _endRotation					:Number = 0;
		private var _endRotationVar					:Number = 0;
		private var _rotatePerSecond				:Number = 720;
		private var _rotatePerSecondVar				:Number = 0; 
		
		private var _previewAnimation				:Boolean;
		
		// IRenderable values
		private var _displayObject					:Sprite;
		protected var _indexStr						:String;	
		
		public function PDParticleSystemComponent( config:XML = null, textureComponent:TextureComponent = null )
		{
			_xml = config;
			_texture = texture;
			_displayObject = new Sprite();
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
			if (isInvalid(TRANSFORM)) {
				validateTransform();
			}
			
			if ( isInvalid( RESOURCES ) ) {
				validateResources();
			}
				
			if ( isInvalid( DISPLAY ) ) {
				validateDisplay();
			}
				
			super.validateNow();
		}
		
		protected function validateTransform():void
		{
			_displayObject.x = _x;
			_displayObject.y = _y;
			_displayObject.scaleX = _scaleX;
			_displayObject.scaleY = _scaleY;
			_displayObject.rotation = _rotation;
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
			//removeFromDisplayList(true);
			removeFromJuggler();
			
			
			if ( _particleSystem ) {
				_displayObject.removeChild(_particleSystem);
			}
			
			_particleSystem = new PDParticleSystem(config, texture);
			
			_displayObject.addChild(_particleSystem);
			
			// UPDATE VALUES
			_emitterType = emitterTypeIntToString(_particleSystem.emitterType); 
			// Start Color
			_startColor = _particleSystem.startColor.toRgb();
			_startColorAlpha = _particleSystem.startColor.alpha;
			_startColorVariance = _particleSystem.startColorVariance.toRgb();
			_startColorVarAlpha = _particleSystem.startColorVariance.alpha; 
			// End Color
			_endColor = _particleSystem.endColor.toRgb();
			_endColorAlpha = _particleSystem.endColor.alpha;
			_endColorVariance = _particleSystem.endColorVariance.toRgb();
			_endColorVarAlpha = _particleSystem.endColorVariance.alpha;
			
			_maxCapacity = _particleSystem.maxCapacity;
			_emissionRate = _particleSystem.emissionRate;
			_emitterX = _particleSystem.emitterX;
			_emitterY = _particleSystem.emitterY;
			_emitterXVariance = _particleSystem.emitterXVariance;
			_emitterYVariance = _particleSystem.emitterYVariance;
			_blendFactorSource = _particleSystem.blendFactorSource;
			_blendFactorDest = _particleSystem.blendFactorDestination;
			_maxNumParticles = _particleSystem.maxNumParticles;
			_lifespan = _particleSystem.lifespan;
			_lifespanVariance = _particleSystem.lifespanVariance;
			_startSize = _particleSystem.startSize;
			_startSizeVariance = _particleSystem.startSizeVariance;
			_endSize = _particleSystem.endSize;
			_endSizeVariance = _particleSystem.endSizeVariance;
			_speed = _particleSystem.speed;
			_speedVariance = _particleSystem.speedVariance;
			_gravityX = _particleSystem.gravityX;
			_gravityY = _particleSystem.gravityY;
			_radialAcceleration = _particleSystem.radialAcceleration;
			_radialAccelVar =_particleSystem.radialAccelerationVariance;
			_tangentialAccel = _particleSystem.tangentialAcceleration;
			_tangentialAccelVar = _particleSystem.tangentialAccelerationVariance; 
			_maxRadius = _particleSystem.maxRadius;
			_maxRadiusVariance = _particleSystem.maxRadiusVariance;
			_minRadius = _particleSystem.minRadius;
			
			// Angles
			_emitAngle = rad2deg(_particleSystem.emitAngle); 
			_emitAngleVariance = rad2deg(_particleSystem.emitAngleVariance); 
			_startRotation = rad2deg(_particleSystem.startRotation);
			_startRotationVar = rad2deg(_particleSystem.startRotationVariance);
			_endRotation = rad2deg(_particleSystem.endRotation);
			_endRotationVar = rad2deg(_particleSystem.endRotationVariance);
			_rotatePerSecond = rad2deg(_particleSystem.rotatePerSecond);
			_rotatePerSecondVar = rad2deg(_particleSystem.rotatePerSecondVariance); 
			
			_startColorARGB.copyFrom(_particleSystem.startColor);
			_startColorVarARGB.copyFrom(_particleSystem.startColorVariance);
			_endColorARGB.copyFrom(_particleSystem.endColor);
			_endColorVarARGB.copyFrom(_particleSystem.endColorVariance);			
			
			addToJuggler();
			if (_autoplay || _previewAnimation) start();
		}
		
		private function validateDisplay():void
		{
			// Set start and end colors for serializing.
			_startColorARGB = ColorArgb.fromRgb(_startColor);
			_startColorARGB.alpha = _startColorAlpha;
			_startColorVarARGB = ColorArgb.fromArgb(_startColorVariance);
			_startColorVarARGB.alpha = _startColorVarAlpha;
			_endColorARGB = ColorArgb.fromRgb(_endColor);
			_endColorARGB.alpha = _endColorAlpha;
			_endColorVarARGB = ColorArgb.fromArgb(_endColorVariance);
			_endColorVarARGB.alpha = _endColorVarAlpha;			
			
			if (!_particleSystem) return;
			
			_particleSystem.emitterType = emitterTypeInt; 
			// Start Color
			_particleSystem.startColor = ColorArgb.fromRgb(_startColor); 
			_particleSystem.startColor.alpha = _startColorAlpha;
			_particleSystem.startColorVariance = ColorArgb.fromRgb(_startColorVariance); 
			_particleSystem.startColorVariance.alpha = _startColorVarAlpha; 
			// End Color
			_particleSystem.endColor = ColorArgb.fromRgb(_endColor);
			_particleSystem.endColor.alpha = _endColorAlpha;
			_particleSystem.endColorVariance = ColorArgb.fromRgb(_endColorVariance);
			_particleSystem.endColorVariance.alpha = _endColorVarAlpha;
			
			_particleSystem.maxCapacity = _maxCapacity;
			_particleSystem.emissionRate = _emissionRate;
			_particleSystem.emitterX = _emitterX;
			_particleSystem.emitterY = _emitterY;
			_particleSystem.emitterXVariance = _emitterXVariance;
			_particleSystem.emitterYVariance = _emitterYVariance;
			_particleSystem.blendFactorSource = _blendFactorSource;
			_particleSystem.blendFactorDestination = _blendFactorDest;
			_particleSystem.maxNumParticles = _maxNumParticles;
			_particleSystem.lifespan = _lifespan;
			_particleSystem.lifespanVariance = _lifespanVariance;
			_particleSystem.startSize = _startSize;
			_particleSystem.startSizeVariance = _startSizeVariance;
			_particleSystem.endSize = _endSize;
			_particleSystem.endSizeVariance = _endSizeVariance;
			_particleSystem.speed = _speed;
			_particleSystem.speedVariance = _speedVariance;
			_particleSystem.gravityX = _gravityX;
			_particleSystem.gravityY = _gravityY;
			_particleSystem.radialAcceleration = _radialAcceleration;
			_particleSystem.radialAccelerationVariance = _radialAccelVar;
			_particleSystem.tangentialAcceleration = _tangentialAccel;
			_particleSystem.tangentialAccelerationVariance = _tangentialAccelVar; 
			_particleSystem.maxRadius = _maxRadius;
			_particleSystem.maxRadiusVariance = _maxRadiusVariance;
			_particleSystem.minRadius = _minRadius;
			
			// Angles
			_particleSystem.emitAngle = deg2rad(_emitAngle); 
			_particleSystem.emitAngleVariance = deg2rad(_emitAngleVariance); 
			_particleSystem.startRotation = deg2rad(_startRotation);
			_particleSystem.startRotationVariance = deg2rad(_startRotationVar);
			_particleSystem.endRotation = deg2rad(_endRotation);
			_particleSystem.endRotationVariance = deg2rad(_endRotationVar);
			_particleSystem.rotatePerSecond = deg2rad(_rotatePerSecond);
			_particleSystem.rotatePerSecondVariance = deg2rad(_rotatePerSecondVar); 
			
			_startColorARGB.copyFrom(_particleSystem.startColor);
			_startColorVarARGB.copyFrom(_particleSystem.startColorVariance);
			_endColorARGB.copyFrom(_particleSystem.endColor);
			_endColorVarARGB.copyFrom(_particleSystem.endColorVariance);
				
			addToJuggler();
			if (_autoplay || _previewAnimation) start();
		}
		
		// -------------------------------------------------------------------------------------
		// ITRANSFORM2D API
		// -------------------------------------------------------------------------------------
		
		[Inspectable( priority="50" )]
		public function set x( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_x = value;
			invalidate(TRANSFORM);
		}
		public function get x():Number { return _x; }
		
		[Inspectable( priority="51" )]
		public function set y( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_y = value;
			invalidate(TRANSFORM);
		}
		public function get y():Number { return _y; }
		
		[Inspectable( priority="52" )]
		public function set scaleX( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_scaleX = value;
			invalidate(TRANSFORM);
		}
		public function get scaleX():Number { return _scaleX; }
		
		[Inspectable( priority="53" )]
		public function set scaleY( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_scaleY = value;
			invalidate(TRANSFORM);
		}
		public function get scaleY():Number { return _scaleY; }
		
		[Inspectable(priority="54", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function set rotation( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_rotation = deg2rad(value);
			invalidate(TRANSFORM);
		}
		public function get rotation():Number { return rad2deg(_rotation); }
		
		public function set matrix( value:Matrix ):void
		{
			_displayObject.transformationMatrix = value;
			_x = _displayObject.x;
			_y = _displayObject.y;
			_scaleX = _displayObject.scaleX;
			_scaleY = _displayObject.scaleY;
			_rotation = _displayObject.rotation;
			
			invalidate(TRANSFORM);
		}
		public function get matrix():Matrix 
		{ 
			if (isInvalid(TRANSFORM)) {
				validateTransform();
			}
			
			return _displayObject.transformationMatrix; 
		}
		
		[Serializable(alias="matrix")]
		public function set serializedMatrix( value:String ):void
		{
			var split:Array = value.split( "," );
			matrix = new Matrix( split[0], split[1], split[2], split[3], split[4], split[5] );
		}
		
		public function get serializedMatrix():String 
		{ 
			var m:Matrix = matrix;
			return m.a + "," + m.b + "," + m.c + "," + m.d + "," + m.tx + "," + m.ty;
		}		
		
		// -------------------------------------------------------------------------------------		
		
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
		
		[Serializable( type="resource" )][Inspectable( priority="55", editor="ResourceItemEditor", extensions="[pex]")]
		public function set xml( value:XML ):void
		{
			_xml = value;
			invalidate( RESOURCES );
		}
		public function get xml():XML { return _xml; }
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="56" )]
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
		
		// -------------------------------------------------------------------------------------
		// IANIMATABLE API
		// -------------------------------------------------------------------------------------
		
		public function addToJuggler():Boolean
		{
			if (!_initialised && !_previewAnimation) return false;	// only add if in run mode or if previewing
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
		public function get isAnimating():Boolean
		{
			return _addedToJuggler;
		}
		
		// IAnimatable : Design time
		public function get previewAnimation():Boolean
		{
			return _previewAnimation;
		}
		public function set previewAnimation( value:Boolean ):void
		{
			_previewAnimation = value;
			invalidate( DISPLAY );
		}
		
		// -------------------------------------------------------------------------------------
		
		public function start(duration:Number = Number.MAX_VALUE):void
		{
			if (!_initialised && !_previewAnimation) return;
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
		
		[Serializable][Inspectable( priority="57", editor="DropDownMenu", dataProvider="[Gravity,Radial]" )]
		public function get emitterType():String 
		{ 
			return _emitterType; 
		}
		public function set emitterType(value:String):void 
		{ 
			_emitterType = value;
			invalidate( DISPLAY );
		}
		
		private function emitterTypeIntToString( value:int ):String
		{
			if ( value == 0 ) {
				return EMITTER_TYPE_GRAVITY;
			} else if ( value == 1 ) {
				return EMITTER_TYPE_RADIAL;
			}
			
			return null;
		}
		
		private function get emitterTypeInt():int
		{	
			var intType:int = 0;
			if ( _emitterType == EMITTER_TYPE_RADIAL ) {
				intType = 1;
			}
			
			return intType;
		}
		
		[Serializable][Inspectable( priority="58", editor="ColorPicker" )]
		public function get startColor():uint { return _particleSystem.startColor.toRgb(); }
		public function set startColor(value:uint):void 
		{ 
			_startColor = value;			
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable( priority="59", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get startColorAlpha():Number 
		{
			return _startColorAlpha;
		}
		public function set startColorAlpha(value:Number):void 
		{ 
			_startColorAlpha = value;
			invalidate( DISPLAY );
		}
				
		[Serializable][Inspectable( priority="60", editor="ColorPicker" )]
		public function get startColorVariance():uint 
		{ 
			return _startColorVariance;
		}
		public function set startColorVariance(value:uint):void 
		{ 
			_startColorVariance = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable( priority="61", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get startColorVarAlpha():Number 
		{ 
			return _startColorVarAlpha;
		}
		public function set startColorVarAlpha(value:Number):void 
		{
			_startColorVarAlpha = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable( priority="62", editor="ColorPicker" )]
		public function get endColor():uint { return _endColor; }
		public function set endColor(value:uint):void 
		{ 
			_endColor = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable( priority="63", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get endColorAlpha():Number 
		{
			return _endColorAlpha;
		}
		public function set endColorAlpha(value:Number):void 
		{ 
			_endColorAlpha = value;
			invalidate( DISPLAY );
		}				
		
		[Serializable][Inspectable( priority="64", editor="ColorPicker" )]
		public function get endColorVariance():uint 
		{
			return _endColorVariance;
		}
		public function set endColorVariance(value:uint):void 
		{ 
			_endColorVariance = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable( priority="65", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get endColorVarAlpha():Number 
		{ 
			return _endColorVarAlpha;
		}
		public function set endColorVarAlpha(value:Number):void 
		{
			_endColorVarAlpha = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="66") ]
		public function get maxCapacity():int 
		{
			return _maxCapacity;
		}
		public function set maxCapacity(value:int):void 
		{ 
			_maxCapacity = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="67") ]
		public function get emissionRate():Number 
		{
			return _emissionRate;
		}
		public function set emissionRate(value:Number):void 
		{ 
			_emissionRate = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="68") ]
		public function get emitterX():Number
		{
			return _emitterX;
		}
		public function set emitterX(value:Number):void
		{
			_emitterX = value;
			invalidate(DISPLAY);
		}
		
		[Serializable][Inspectable(priority="69") ]
		public function get emitterY():Number
		{
			return _emitterY;
		}
		public function set emitterY(value:Number):void
		{
			_emitterY = value;
			invalidate( DISPLAY );
		}

		[Serializable][Inspectable(priority="70") ]
		public function get emitterXVariance():Number 
		{
			return _emitterXVariance;
		}
		public function set emitterXVariance(value:Number):void 
		{
			_emitterXVariance = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="71") ]
		public function get emitterYVariance():Number 
		{ 
			return _emitterYVariance;
		}
		public function set emitterYVariance(value:Number):void 
		{
			_emitterYVariance = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="72", editor="DropDownMenu", dataProvider="[zero,one,sourceColor,oneMinusSourceColor,sourceAlpha,oneMinusSourceAlpha,destinationAlpha,oneMinusDestinationAlpha,destinationColor,oneMinusDestinationColor]") ]
		public function get blendFactorSource():String 
		{ 
			return _blendFactorSource;
		}
		public function set blendFactorSource(value:String):void 
		{ 
			_blendFactorSource = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="73", editor="DropDownMenu", dataProvider="[zero,one,sourceColor,oneMinusSourceColor,sourceAlpha,oneMinusSourceAlpha,destinationAlpha,oneMinusDestinationAlpha,destinationColor,oneMinusDestinationColor]") ]
		public function get blendFactorDest():String 
		{ 
			return _blendFactorDest;
		}
		public function set blendFactorDest(value:String):void 
		{ 
			_blendFactorDest = value;
			invalidate( DISPLAY );
		}		
		
		[Serializable][Inspectable(priority="74") ]
		public function get maxNumParticles():int 
		{ 
			return _maxNumParticles;
		}
		public function set maxNumParticles(value:int):void 
		{
			_maxNumParticles = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="75") ]
		public function get lifespan():Number 
		{ 
			return _lifespan;
		}
		public function set lifespan(value:Number):void 
		{
			_lifespan = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="76") ]
		public function get lifespanVariance():Number 
		{
			return _lifespanVariance;
		}
		public function set lifespanVariance(value:Number):void 
		{
			_lifespanVariance = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="77") ]
		public function get startSize():Number 
		{ 
			return _startSize;
		}
		public function set startSize(value:Number):void 
		{
			_startSize = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="78") ]
		public function get startSizeVariance():Number 
		{ 
			return _startSizeVariance;
		}
		public function set startSizeVariance(value:Number):void
		{
			_startSizeVariance = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="79") ]
		public function get endSize():Number 
		{ 
			return _endSize;
		}
		public function set endSize(value:Number):void 
		{
			_endSize = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="80") ]
		public function get endSizeVariance():Number 
		{
			return _endSizeVariance;
		}
		public function set endSizeVariance(value:Number):void 
		{ 
			_endSizeVariance = value;
			invalidate( DISPLAY );
		}
		
		// Degrees
		[Serializable][Inspectable(priority="81", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get emitAngle():Number 
		{ 
			return _emitAngle;
		}
		public function set emitAngle(value:Number):void
		{ 
			_emitAngle = value;
			invalidate( DISPLAY );
		}
		
		// Degrees
		[Serializable][Inspectable(priority="82", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get emitAngleVariance():Number 
		{ 
			return _emitAngleVariance;
		}
		public function set emitAngleVariance(value:Number):void 
		{
			_emitAngleVariance = value;
			invalidate( DISPLAY );
		}
		
		// Degrees
		[Serializable][Inspectable( priority="83", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get startRotation():Number 
		{ 
			return _startRotation;
		} 
		public function set startRotation(value:Number):void 
		{
			_startRotation = value;
			invalidate( DISPLAY );
		}
		
		// Degrees
		[Serializable][Inspectable( priority="84", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get startRotationVar():Number 
		{ 
			return _startRotationVar;
		} 
		public function set startRotationVar(value:Number):void 
		{
			_startRotationVar = value;
			invalidate( DISPLAY );
		}
		
		// Degrees
		[Serializable][Inspectable(priority="85", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get endRotation():Number 
		{
			return _endRotation;
		} 
		public function set endRotation(value:Number):void 
		{
			_endRotation = value;
			invalidate( DISPLAY );
		}
		
		// Degrees
		[Serializable][Inspectable(priority="86", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function get endRotationVar():Number 
		{
			return _endRotationVar;
		} 
		public function set endRotationVar(value:Number):void 
		{
			_endRotationVar = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="87") ]
		public function get speed():Number 
		{
			return _speed;
		}
		public function set speed(value:Number):void
		{
			_speed = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="88") ]
		public function get speedVariance():Number 
		{ 
			return _speedVariance;
		}
		public function set speedVariance(value:Number):void 
		{
			_speedVariance = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="89") ]
		public function get gravityX():Number 
		{
			return _gravityX;
		}
		public function set gravityX(value:Number):void 
		{
			_gravityX = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="90") ]
		public function get gravityY():Number 
		{ 
			return _gravityY;
		}
		public function set gravityY(value:Number):void 
		{
			_gravityY = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="91") ]
		public function get radialAcceleration():Number 
		{ 
			return _radialAcceleration;
		}
		public function set radialAcceleration(value:Number):void
		{
			_radialAcceleration = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="92") ]
		public function get radialAccelVar():Number 
		{ 
			return _radialAccelVar;
		}
		public function set radialAccelVar(value:Number):void
		{
			_radialAccelVar = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="93") ]
		public function get tangentialAccel():Number 
		{
			return _tangentialAccel;
		}
		public function set tangentialAccel(value:Number):void
		{
			_tangentialAccel = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="94") ]
		public function get tangentialAccelVar():Number 
		{
			return _tangentialAccelVar;
		}
		public function set tangentialAccelVar(value:Number):void 
		{
			_tangentialAccelVar = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="95") ]
		public function get maxRadius():Number 
		{ 
			return _maxRadius;
		}
		public function set maxRadius(value:Number):void 
		{
			_maxRadius = value;
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable(priority="96") ]
		public function get maxRadiusVariance():Number 
		{ 
			return _maxRadiusVariance;
		}
		public function set maxRadiusVariance(value:Number):void
		{
			_maxRadiusVariance = value;
			invalidate( DISPLAY ); 
		}
		
		[Serializable][Inspectable(priority="97") ]
		public function get minRadius():Number 
		{ 
			return _minRadius; 
		}
		public function set minRadius(value:Number):void 
		{
			_minRadius = value;
			invalidate( DISPLAY );
		}

		// Degrees
		[Serializable][Inspectable(priority="98") ]
		public function get rotatePerSecond():Number 
		{
			return _rotatePerSecond; 
		}
		public function set rotatePerSecond(value:Number):void 
		{
			trace("set rotatePerSecond "+value);
			_rotatePerSecond = value;
			invalidate( DISPLAY ); 
		}
		
		// Degrees
		[Serializable][Inspectable(priority="99") ]
		public function get rotatePerSecondVar():Number 
		{ 
			return _rotatePerSecondVar;
		}
		public function set rotatePerSecondVar(value:Number):void
		{
			_rotatePerSecondVar = value;
			invalidate( DISPLAY );
		}
		
		public function serialise():XML
		{
			// Note: XML Angles are stored in degrees
			var defaultXML:XML =
				<particleEmitterConfig>
				  <texture name="drugs_particle.png"/>
				  <sourcePosition x={emitterX} y={emitterY}/>
				  <sourcePositionVariance x={emitterXVariance} y={emitterYVariance}/>
				  <speed value={speed}/>
				  <speedVariance value={speedVariance}/>
				  <particleLifeSpan value={lifespan}/>
				  <particleLifespanVariance value={lifespanVariance}/>
				  <gravity x={gravityX} y={gravityY}/>
				  <radialAcceleration value={radialAcceleration}/>
				  <tangentialAcceleration value={tangentialAccel}/>
				  <radialAccelVariance value={radialAccelVar}/>
				  <tangentialAccelVariance value={tangentialAccelVar}/>
				  <startColor red={_startColorARGB.red} green={_startColorARGB.green} blue={_startColorARGB.blue} alpha={_startColorARGB.alpha}/>
				  <startColorVariance red={_startColorVarARGB.red} green={_startColorVarARGB.green} blue={_startColorVarARGB.blue} alpha={_startColorVarARGB.alpha}/>
				  <finishColor red={_endColorARGB.red} green={_endColorARGB.green} blue={_endColorARGB.blue} alpha={_endColorARGB.alpha}/>
				  <finishColorVariance red={_endColorVarARGB.red} green={_endColorVarARGB.green} blue={_endColorVarARGB.blue} alpha={_endColorVarARGB.alpha}/>
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
				  <blendFuncSource value={getBlendFunc(blendFactorSource)}/>
				  <blendFuncDestination value={getBlendFunc(blendFactorDest)}/>
				  <angle value={emitAngle}/>
				  <angleVariance value={emitAngleVariance}/>
				  <rotationStart value={startRotation}/>
				  <rotationStartVariance value={startRotationVar}/>
				  <rotationEnd value={endRotation}/>
				  <rotationEndVariance value={endRotationVar}/>
				  <rotatePerSecond value={rotatePerSecond}/>
				  <rotatePerSecondVariance value={rotatePerSecondVar}/>
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
		
		// -------------------------------------------------------------------------------------
		// IRENDERABLE API
		// -------------------------------------------------------------------------------------
		
		public function get displayObject():DisplayObject
		{
			return _displayObject;
		}
		
		public function get indexStr():String
		{
			// Refresh the indices
			var component:IComponent = this;
			while ( component.parentComponent ) {
				component.index = component.parentComponent.children.getItemIndex(component);
				component = component.parentComponent;
			}
			
			// Refresh the indexStr
			var indexArr:Array = [index];
			
			var parent:IComponentContainer = parentComponent;
			while (parent) {
				if (parent.index != -1) {
					indexArr.push(parent.index);
				} else {
					break;
				}
				parent = parent.parentComponent;
			}
			indexArr.reverse();
			_indexStr = indexArr.toString();
			_indexStr = _indexStr.replace(",", "_");
			
			return _indexStr;
		}
		
		// -------------------------------------------------------------------------------------
	}
}