package
{
	import cadet.core.CadetScene;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.RectangleGeometry;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.transforms.Transform2D;
	
	import components.behaviours.AnimateRotationBehaviour;
	import components.behaviours.UpdateAlphaBehaviour;
	import components.skins.ShadedCircleSkin;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF( width="700", height="400", backgroundColor="0x002135", frameRate="60" )]
	public class Main extends Sprite
	{
		private var cadetScene:CadetScene;
		
		public function Main()
		{
			cadetScene = new CadetScene();
			
			var renderer:Renderer2D = new Renderer2D();
			renderer.addEventListener(RendererEvent.INITIALISED, rendererInitialisedHandler );
			renderer.viewportWidth = stage.stageWidth;
			renderer.viewportHeight = stage.stageHeight;
			cadetScene.children.addItem(renderer);
			renderer.enable(this);
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function rendererInitialisedHandler( event:Event ):void
		{
			initScene();
		}
		
		private function initScene():void
		{
			// Rectangle Entity
			var rectangleEntity:Entity = new Entity();
			rectangleEntity.name = "Rectangle";
			cadetScene.children.addItem(rectangleEntity);
			
			var transform:Transform2D = new Transform2D();
			transform.x = 250;
			transform.y = 150;
			rectangleEntity.children.addItem(transform);
			
			var rectangleGeometry:RectangleGeometry = new RectangleGeometry();
			rectangleGeometry.width = 200;
			rectangleGeometry.height = 100;
			rectangleEntity.children.addItem(rectangleGeometry);
			
			var skin:GeometrySkin = new GeometrySkin();
			rectangleEntity.children.addItem(skin);
			
			var animateRotationBehaviour:AnimateRotationBehaviour = new AnimateRotationBehaviour();
			rectangleEntity.children.addItem(animateRotationBehaviour);			
			
			var updateAlphaBehaviour:UpdateAlphaBehaviour = new UpdateAlphaBehaviour();
			rectangleEntity.children.addItem(updateAlphaBehaviour);
			
			// Circle Entity
			var circleEntity:Entity = new Entity();
			circleEntity.name = "Circle";
			cadetScene.children.addItem(circleEntity);
			
			transform = new Transform2D();
			transform.x = 550;
			transform.y = 150;
			circleEntity.children.addItem(transform);
			
			var circleGeometry:CircleGeometry = new CircleGeometry(50);
			circleEntity.children.addItem(circleGeometry);
			
			var shadedCircleSkin:ShadedCircleSkin = new ShadedCircleSkin();
			circleEntity.children.addItem(shadedCircleSkin);		
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}