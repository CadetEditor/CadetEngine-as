package cadet2D.components.particles
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import cadet.core.Component;
	import cadet.core.IInitOnRunComponent;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.extensions.ColorArgb;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	
	public class PDParticleSystemComponent extends Component implements IInitOnRunComponent
	{
		private const DATA							:String = "data";
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
		
		private var _startColor						:uint;
		private var _startColorVariance				:uint;
		private var _endColor						:uint;
		private var _endColorVariance				:uint;
		
		private var _xml							:XML;
		
		private var _defaultTexture					:Texture;
		private var _texture						:Texture;
		
		public function PDParticleSystemComponent( config:XML = null, texture:Texture = null )
		{
			var instance:BitmapData = new NullParticle().bitmapData;
			_defaultTexture = Texture.fromBitmap( new Bitmap(instance), false );

			_xml = config;
			_texture = texture;
			
			invalidate( DATA );
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(Renderer2D, "renderer");
		}
		
		// IInitOnRunComponent
		public function init():void
		{
			_initialised = true;
			
			invalidate( DISPLAY );
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( DATA ) ) {
				validateData();
			}
				
			if ( isInvalid( DISPLAY ) ) {
				validateDisplay();
			}
				
			super.validateNow();
		}
		
		private function validateData():void
		{
			var config:XML;
			var texture:Texture;
			
			if ( _xml ) config = _xml;
			else 		config = _defaultXML;
			
			if ( _texture ) texture = _texture;
			else			texture = _defaultTexture;
			
			stop(true);
			removeFromDisplayList(true);
			removeFromJuggler();
			
			_particleSystem = new PDParticleSystem(config, texture);
			
			addToJuggler();
			addToDisplayList();
			start();
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
			start();
		}
		
		// -------------------------------------------------------------------------------------
		// INSPECTABLE API
		// -------------------------------------------------------------------------------------
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="50" )]
		public function set targetSkin( value:AbstractSkin2D ):void
		{
			_targetSkin = value;
			
			invalidate( DISPLAY );
		}
		public function get targetSkin():AbstractSkin2D { return _targetSkin; }
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor", extensions="[pex]")]
		public function set xml( value:XML ):void
		{
			_xml = value;
			invalidate( DATA );
		}
		public function get xml():XML { return _xml; }
		
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
			
			invalidate( DISPLAY );
		}
		
		private function addToJuggler():void
		{
			if (!_initialised) return;	// only add if in run mode
			if (!renderer || !renderer.initialised) return;
			if (!_particleSystem) return;
			if (_addedToJuggler) return;
			
			Starling.juggler.add(_particleSystem);
			_addedToJuggler = true;
		}
		private function removeFromJuggler():void
		{
			if (!renderer || !renderer.initialised) return;
			if (!_particleSystem) return;
			if (!_addedToJuggler) return;
			
			Starling.juggler.remove(_particleSystem);
			_addedToJuggler = false;
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
		public function start():void
		{
			if (!_initialised) return;
			if (!_particleSystem) return;
			if (_started) return;
			
			_particleSystem.start();
			_started = true;
		}
		public function stop(clearParticles:Boolean = false):void
		{
			if (!_particleSystem) return;
			if (!_started) return;
			
			_particleSystem.stop(clearParticles);
			_started = false;
		}
		
		[Serializable][Inspectable( priority="51", editor="DropDownMenu", dataProvider="[Gravity,Radial]" )]
		public function get emitterType():String { return _emitterType; }
		public function set emitterType(value:String):void 
		{ 
			_emitterType = value;
			
			var uintType:uint = 0;
			if ( _emitterType == EMITTER_TYPE_RADIAL ) {
				uintType = 1;
			}
			
			_particleSystem.emitterType = uintType; 
		}
		
		[Serializable][Inspectable( priority="52", editor="ColorPicker" )]
		public function get startColor():uint { return _particleSystem.startColor.toRgb(); }
		public function set startColor(value:uint):void 
		{ 
			_startColor = value;
			_particleSystem.startColor = ColorArgb.fromRgb(_startColor); 
		}
		
		[Serializable][Inspectable( priority="53", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get startColorAlpha():Number { return _particleSystem.startColor.alpha; }
		public function set startColorAlpha(value:Number):void 
		{ 
			_particleSystem.startColor.alpha = value; 
		}
		
		[Serializable][Inspectable( priority="54", editor="ColorPicker" )]
		public function get startColorVariance():uint { return _particleSystem.startColorVariance.toRgb(); }
		public function set startColorVariance(value:uint):void 
		{ 
			_startColorVariance = value;
			_particleSystem.startColorVariance = ColorArgb.fromRgb(_startColorVariance); 
		}
		
		[Serializable][Inspectable( priority="55", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get startColorVarAlpha():Number { return _particleSystem.startColorVariance.alpha; }
		public function set startColorVarAlpha(value:Number):void 
		{ 
			_particleSystem.startColorVariance.alpha = value; 
		}
		
		[Serializable][Inspectable( priority="56", editor="ColorPicker" )]
		public function get endColor():uint { return _particleSystem.endColor.toRgb(); }
		public function set endColor(value:uint):void 
		{ 
			_endColor = value;
			_particleSystem.endColor = ColorArgb.fromRgb(_endColor); 
		}
		
		[Serializable][Inspectable( priority="57", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get endColorAlpha():Number { return _particleSystem.endColor.alpha; }
		public function set endColorAlpha(value:Number):void 
		{ 
			_particleSystem.endColor.alpha = value; 
		}				
		
		[Serializable][Inspectable( priority="58", editor="ColorPicker" )]
		public function get endColorVariance():uint { return _particleSystem.endColorVariance.toRgb(); }
		public function set endColorVariance(value:uint):void 
		{ 
			_endColorVariance = value;
			_particleSystem.endColorVariance = ColorArgb.fromRgb(_endColorVariance);
		}
		
		[Serializable][Inspectable( priority="59", editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function get endColorVarAlpha():Number { return _particleSystem.endColorVariance.alpha; }
		public function set endColorVarAlpha(value:Number):void 
		{ 
			_particleSystem.endColorVariance.alpha = value; 
		}
		
		[Serializable][Inspectable(priority="60") ]
		public function get emitterXVariance():Number { return _particleSystem.emitterXVariance; }
		public function set emitterXVariance(value:Number):void { _particleSystem.emitterXVariance = value; }
		
		[Serializable][Inspectable(priority="61") ]
		public function get emitterYVariance():Number { return _particleSystem.emitterYVariance; }
		public function set emitterYVariance(value:Number):void { _particleSystem.emitterYVariance = value; }
		
		[Serializable][Inspectable(priority="62") ]
		public function get maxNumParticles():int { return _particleSystem.maxNumParticles; }
		public function set maxNumParticles(value:int):void { _particleSystem.maxNumParticles = value; }
		
		[Serializable][Inspectable(priority="63") ]
		public function get lifespan():Number { return _particleSystem.lifespan; }
		public function set lifespan(value:Number):void { _particleSystem.lifespan = value; }
		
		[Serializable][Inspectable(priority="64") ]
		public function get lifespanVariance():Number { return _particleSystem.lifespanVariance; }
		public function set lifespanVariance(value:Number):void { _particleSystem.lifespanVariance = value; }
		
		[Serializable][Inspectable(priority="65") ]
		public function get startSize():Number { return _particleSystem.startSize; }
		public function set startSize(value:Number):void { _particleSystem.startSize = value; }
		
		[Serializable][Inspectable(priority="66") ]
		public function get startSizeVariance():Number { return _particleSystem.startSizeVariance; }
		public function set startSizeVariance(value:Number):void { _particleSystem.startSizeVariance = value; }
		
		[Serializable][Inspectable(priority="67") ]
		public function get endSize():Number { return _particleSystem.endSize; }
		public function set endSize(value:Number):void { _particleSystem.endSize = value; }
		
		[Serializable][Inspectable(priority="68") ]
		public function get endSizeVariance():Number { return _particleSystem.endSizeVariance; }
		public function set endSizeVariance(value:Number):void { _particleSystem.endSizeVariance = value; }
		
		[Serializable][Inspectable(priority="69") ]
		public function get emitAngle():Number { return _particleSystem.emitAngle; }
		public function set emitAngle(value:Number):void { _particleSystem.emitAngle = value; }
		
		[Serializable][Inspectable(priority="70") ]
		public function get emitAngleVariance():Number { return _particleSystem.emitAngleVariance; }
		public function set emitAngleVariance(value:Number):void { _particleSystem.emitAngleVariance = value; }
		
		[Serializable][Inspectable(priority="71") ]
		public function get startRotation():Number { return _particleSystem.startRotation; } 
		public function set startRotation(value:Number):void { _particleSystem.startRotation = value; }
		
		[Serializable][Inspectable(priority="72") ]
		public function get startRotationVariance():Number { return _particleSystem.startRotationVariance; } 
		public function set startRotationVariance(value:Number):void { _particleSystem.startRotationVariance = value; }
		
		[Serializable][Inspectable(priority="73") ]
		public function get endRotation():Number { return _particleSystem.endRotation; } 
		public function set endRotation(value:Number):void { _particleSystem.endRotation = value; }
		
		[Serializable][Inspectable(priority="74") ]
		public function get endRotationVariance():Number { return _particleSystem.endRotationVariance; } 
		public function set endRotationVariance(value:Number):void { _particleSystem.endRotationVariance = value; }
		
		[Serializable][Inspectable(priority="75") ]
		public function get speed():Number { return _particleSystem.speed; }
		public function set speed(value:Number):void { _particleSystem.speed = value; }
		
		[Serializable][Inspectable(priority="76") ]
		public function get speedVariance():Number { return _particleSystem.speedVariance; }
		public function set speedVariance(value:Number):void { _particleSystem.speedVariance = value; }
		
		[Serializable][Inspectable(priority="77") ]
		public function get gravityX():Number { return _particleSystem.gravityX; }
		public function set gravityX(value:Number):void { _particleSystem.gravityX = value; }
		
		[Serializable][Inspectable(priority="78") ]
		public function get gravityY():Number { return _particleSystem.gravityY; }
		public function set gravityY(value:Number):void { _particleSystem.gravityY = value; }
		
		[Serializable][Inspectable(priority="79") ]
		public function get radialAcceleration():Number { return _particleSystem.radialAcceleration; }
		public function set radialAcceleration(value:Number):void { _particleSystem.radialAcceleration = value; }
		
		[Serializable][Inspectable(priority="80") ]
		public function get radialAccelerationVariance():Number { return _particleSystem.radialAccelerationVariance; }
		public function set radialAccelerationVariance(value:Number):void { _particleSystem.radialAccelerationVariance = value; }
		
		[Serializable][Inspectable(priority="81") ]
		public function get tangentialAcceleration():Number { return _particleSystem.tangentialAcceleration; }
		public function set tangentialAcceleration(value:Number):void { _particleSystem.tangentialAcceleration = value; }
		
		[Serializable][Inspectable(priority="82") ]
		public function get tangentialAccelerationVariance():Number { return _particleSystem.tangentialAccelerationVariance; }
		public function set tangentialAccelerationVariance(value:Number):void { _particleSystem.tangentialAccelerationVariance = value; }
		
		[Serializable][Inspectable(priority="83") ]
		public function get maxRadius():Number { return _particleSystem.maxRadius; }
		public function set maxRadius(value:Number):void { _particleSystem.maxRadius = value; }
		
		[Serializable][Inspectable(priority="84") ]
		public function get maxRadiusVariance():Number { return _particleSystem.maxRadiusVariance; }
		public function set maxRadiusVariance(value:Number):void { _particleSystem.maxRadiusVariance = value; }
		
		[Serializable][Inspectable(priority="85") ]
		public function get minRadius():Number { return _particleSystem.minRadius; }
		public function set minRadius(value:Number):void { _particleSystem.minRadius = value; }
		
		[Serializable][Inspectable(priority="86") ]
		public function get rotatePerSecond():Number { return _particleSystem.rotatePerSecond; }
		public function set rotatePerSecond(value:Number):void { _particleSystem.rotatePerSecond = value; }
		
		[Serializable][Inspectable(priority="87") ]
		public function get rotatePerSecondVariance():Number { return _particleSystem.rotatePerSecondVariance; }
		public function set rotatePerSecondVariance(value:Number):void { _particleSystem.rotatePerSecondVariance = value; }
				
		private var _defaultXML:XML =
			<particleEmitterConfig>
			  <texture name="drugs_particle.png"/>
			  <sourcePosition x="160.00" y="211.72"/>
			  <sourcePositionVariance x="30.00" y="30.00"/>
			  <speed value="98.00"/>
			  <speedVariance value="211.00"/>
			  <particleLifeSpan value="4.0000"/>
			  <particleLifespanVariance value="4.0000"/>
			  <angle value="360.00"/>
			  <angleVariance value="190.00"/>
			  <gravity x="0.70" y="1.43"/>
			  <radialAcceleration value="0.00"/>
			  <tangentialAcceleration value="0.00"/>
			  <radialAccelVariance value="0.00"/>
			  <tangentialAccelVariance value="0.00"/>
			  <startColor red="0.32" green="0.39" blue="0.58" alpha="0.76"/>
			  <startColorVariance red="0.42" green="0.75" blue="0.88" alpha="0.08"/>
			  <finishColor red="0.79" green="0.85" blue="0.42" alpha="0.57"/>
			  <finishColorVariance red="0.45" green="0.51" blue="0.26" alpha="0.46"/>
			  <maxParticles value="600"/>
			  <startParticleSize value="50.00"/>
			  <startParticleSizeVariance value="50.00"/>
			  <finishParticleSize value="30.00"/>
			  <FinishParticleSizeVariance value="10.00"/>
			  <duration value="-1.00"/>
			  <emitterType value="0"/>
			  <maxRadius value="100.00"/>
			  <maxRadiusVariance value="0.00"/>
			  <minRadius value="0.00"/>
			  <rotatePerSecond value="0.00"/>
			  <rotatePerSecondVariance value="0.00"/>
			  <blendFuncSource value="1"/>
			  <blendFuncDestination value="1"/>
			  <rotationStart value="0.00"/>
			  <rotationStartVariance value="0.00"/>
			  <rotationEnd value="0.00"/>
			  <rotationEndVariance value="0.00"/>
			</particleEmitterConfig>;			
	}
}