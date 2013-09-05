// Tests nesting one transform2D within another

package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import cadet.core.CadetScene;
	import cadet.core.ComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.geom.RectangleGeometry;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.transforms.Transform2D;
	
	import components.behaviours.AnimateRotationBehaviour;
	
	[SWF( width="1024", height="768", backgroundColor="0x002135", frameRate="60" )]
	public class C2D_Tests_Transform_00 extends Sprite
	{
		private var cadetScene:CadetScene;
		private var rectangleEntity1:ComponentContainer;
		private var rectangleEntity2:ComponentContainer;
		
		private var count:uint = 0;
		
		public function C2D_Tests_Transform_00()
		{
			cadetScene = new CadetScene();
			
			var renderer:Renderer2D = new Renderer2D();
			renderer.viewportWidth = stage.stageWidth;
			renderer.viewportHeight = stage.stageHeight;
			cadetScene.children.addItem(renderer);
			renderer.enable(this);
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			
			rectangleEntity1 = createRectangleEntity(cadetScene, 250, 150, 100, 100);
		
			var parentTransform:Transform2D = ComponentUtil.getChildOfType(rectangleEntity1, Transform2D);
			parentTransform.scaleX = 1.5;
			
			var animateRotationBehaviour:AnimateRotationBehaviour = new AnimateRotationBehaviour();
			rectangleEntity1.children.addItem(animateRotationBehaviour);
			
			rectangleEntity2 = createRectangleEntity(rectangleEntity1, 100, 0, 100, 100);
		}
		
		private function createRectangleEntity(parent:ComponentContainer, x:Number, y:Number, width:Number, height:Number):ComponentContainer
		{
			var rectangleEntity:ComponentContainer = new ComponentContainer();
			rectangleEntity.name = "Rectangle";
			parent.children.addItem(rectangleEntity);
			
			var transform:Transform2D = new Transform2D();
			transform.x = x;
			transform.y = y;
			rectangleEntity.children.addItem(transform);
			
			var rectangleGeometry:RectangleGeometry = new RectangleGeometry();
			rectangleGeometry.width = width;
			rectangleGeometry.height = height;
			rectangleEntity.children.addItem(rectangleGeometry);
			
			var skin:GeometrySkin = new GeometrySkin();
			rectangleEntity.children.addItem(skin);
			
			return rectangleEntity;
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}