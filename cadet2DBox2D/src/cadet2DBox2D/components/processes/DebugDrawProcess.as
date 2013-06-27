package cadet2DBox2D.components.processes
{
	import flash.display.Sprite;
	
	import Box2D.Dynamics.b2DebugDraw;
	
	import cadet.core.Component;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.processes.IDebugDrawProcess;
	import cadet2D.components.renderers.IRenderer2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.IRenderable;
	
	import starling.display.DisplayObject;
	
	public class DebugDrawProcess extends Component implements IDebugDrawProcess
	{
		private static const DISPLAY	:String = "display";
		private static const RENDERER	:String = "renderer";
		private static const PHYSICS	:String = "physics";
		
		private var _renderer			:Renderer2D;
		private var _physicsProcess		:PhysicsProcess;
		
		private var _dbgDraw			:b2DebugDraw;
		private var _drawScale			:Number = 100;
		private var _fillAlpha			:Number = 0.3;
		private var _lineThickness		:Number = 1;
		private var _trackCamera		:Boolean = false;
		
		private var _sprite				:Sprite;
		
		public function DebugDrawProcess(name:String="DebugDrawProcess")
		{
			super(name);
			
			_dbgDraw = new b2DebugDraw();
			_dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			
			invalidate(DISPLAY);
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(Renderer2D, "renderer");
			addSceneReference(PhysicsProcess, "physicsProcess");
		}
		
		[Serializable][Inspectable( label="Fill alpha", priority="50", editor="Slider", min="0", max="100", snapInterval="1" )]
		public function set fillAlpha( value:Number ):void
		{
			_fillAlpha = value;
			invalidate( DISPLAY );
		}
		public function get fillAlpha():Number { return _fillAlpha; }
		
		[Serializable][Inspectable( label="Line thickness", priority="51" )]
		public function set lineThickness( value:Number ):void
		{
			_lineThickness = value;
			invalidate( DISPLAY );
		}
		public function get lineThickness():Number { return _lineThickness; }
		
		[Serializable][Inspectable( label="Draw scale", priority="52", editor="Slider", min="0", max="200", snapInterval="1" )]
		public function set drawScale( value:Number ):void
		{
			_drawScale = value;
			invalidate( DISPLAY );
		}
		public function get drawScale():Number { return _drawScale; }
		
		[Serializable][Inspectable( label="Track camera", priority="53" )]
		public function set trackCamera( value:Boolean ):void
		{
			_trackCamera = value;
		}
		public function get trackCamera():Boolean { return _trackCamera; }
		
		public function set renderer( value:IRenderer2D ):void
		{
			if ( _renderer ) {
				_renderer.removeEventListener(RendererEvent.INITIALISED, rendererInitialisedHandler);
			}
			
			_renderer = Renderer2D(value);
			
			if ( _renderer && !_renderer.initialised ) {
				_renderer.addEventListener(RendererEvent.INITIALISED, rendererInitialisedHandler);
			}
			
			invalidate(RENDERER);
		}
		public function get renderer():IRenderer2D { return _renderer; }
		
		private function rendererInitialisedHandler( event:RendererEvent ):void
		{
			invalidate(RENDERER);
		}
		
		public function set physicsProcess( value:PhysicsProcess ):void
		{
			_physicsProcess = value;
			
			invalidate(PHYSICS);
		}
		public function get physicsProcess():PhysicsProcess { return _physicsProcess; }
		
		override public function validateNow():void
		{
			var physicsIsValid:Boolean = true;
			
			if ( isInvalid(RENDERER) ) {
				validateRenderer();
			}
			if ( isInvalid(PHYSICS) ) {
				physicsIsValid = validatePhysics();
			}
			if ( isInvalid(DISPLAY) ) {
				validateDisplay();
			}
			
			super.validateNow();
			
			if (!physicsIsValid) {
				invalidate(PHYSICS);
			}
		}
		
		private function validateRenderer():void
		{
			_sprite = Sprite(_renderer.getNativeParent());
			if (_renderer.initialised && _sprite) {
				_dbgDraw.SetSprite(_sprite);
			}

		}
		
		private function validatePhysics():Boolean
		{
			if (_physicsProcess ) {
				if ( _renderer && _renderer.initialised) {
					_physicsProcess.world.SetDebugDraw(_dbgDraw);
					return true;
				}
			}	
			return false;
		}
		
		private function validateDisplay():void
		{
			_dbgDraw.SetDrawScale(_drawScale);
			_dbgDraw.SetFillAlpha(_fillAlpha);
			_dbgDraw.SetLineThickness(_lineThickness);
		}
		
		public function get sprite():*
		{
			return _sprite;
		}
		
		override protected function removedFromScene():void
		{
			super.removedFromScene();
			
			_sprite.graphics.clear(); // should be its own sprite
			if (_physicsProcess) {
				_physicsProcess.world.SetDebugDraw(null);
			}
		}
	}
}











