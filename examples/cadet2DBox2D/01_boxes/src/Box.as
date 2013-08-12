package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import cadet.core.CadetScene;
	import cadet.core.ComponentContainer;
	
	import cadet2D.components.geom.RectangleGeometry;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.transforms.Transform2D;
	
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;
	import cadet2DBox2D.components.behaviours.RigidBodyMouseDragBehaviour;
	import cadet2DBox2D.components.processes.PhysicsProcess;
	
	[SWF( width="700", height="400", backgroundColor="0x002135", frameRate="60" )]
	public class Box extends Sprite
	{
		private var cadetScene	: CadetScene;
		
		public function Box()
		{
			cadetScene = new CadetScene();
			
			var renderer:Renderer2D = new Renderer2D();
			renderer.viewportWidth = stage.stageWidth;
			renderer.viewportHeight = stage.stageHeight;
			cadetScene.children.addItem(renderer);
			renderer.enable(this);

			var physicsProcess:PhysicsProcess = new PhysicsProcess(); 
			cadetScene.children.addItem( physicsProcess );
			
//			var debugDraw:DebugDrawProcess = new DebugDrawProcess();
//			cadetScene.children.addItem( debugDraw );
			
			var rotatingRectangle:ComponentContainer = addRectangleEntity( 300, 0, 60, 60, 46 );
			
			// Create the floor. We pass 'true' as the 'fixed' property to make the floor static.
			addRectangleEntity( -200, stage.stageHeight-50, stage.stageWidth+200, 50, 0, true );
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);			
		}
		
		private function addRectangleEntity( x:Number, y:Number, width:Number, height:Number, rotation:Number, fixed:Boolean = false ):ComponentContainer
		{
			var transform:Transform2D = new Transform2D(x, y, rotation);
			var skin:GeometrySkin = new GeometrySkin();
			
			var entity:ComponentContainer = new ComponentContainer();
			entity.children.addItem( transform );
			entity.children.addItem( skin );
			entity.children.addItem( new RectangleGeometry(width, height) );
			entity.children.addItem( new RigidBodyBehaviour(fixed) );
			entity.children.addItem( new RigidBodyMouseDragBehaviour() );
			
			cadetScene.children.addItem(entity);
			
			return entity;
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}