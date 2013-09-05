// Press SPACEBAR four times to step scene.
// 3rd component is removed from scene and added as child of first,
// then is removed again and re-added as child of second.

package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import cadet.components.processes.InputProcess;
	import cadet.components.processes.KeyboardInputMapping;
	import cadet.core.CadetScene;
	import cadet.core.ComponentContainer;
	import cadet.events.InputProcessEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.geom.RectangleGeometry;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.transforms.Transform2D;
	
	import components.behaviours.AnimateRotationBehaviour;
	
	[SWF( width="1024", height="768", backgroundColor="0x002135", frameRate="60" )]
	public class C2D_Tests_Transform_03 extends Sprite
	{
		private var cadetScene:CadetScene;
		private var rectangleEntity1:ComponentContainer;
		private var rectangleEntity2:ComponentContainer;
		private var rectangleEntity3:ComponentContainer;
		
		private var count:uint = 0;
		
		public function C2D_Tests_Transform_03()
		{
			var tf:TextField = new TextField();
			addChild(tf);
			tf.text = "Press SPACEBAR four times to step scene.\n3rd component is removed from scene and added as child of first, then is removed again and re-added as child of second.";
			tf.textColor = 0xFFFFFF;
			tf.autoSize = TextFieldAutoSize.LEFT;
			
			cadetScene = new CadetScene();
			
			var renderer:Renderer2D = new Renderer2D();
			renderer.viewportWidth = stage.stageWidth;
			renderer.viewportHeight = stage.stageHeight;
			cadetScene.children.addItem(renderer);
			renderer.enable(this);
			
			var inputProcess:InputProcess = new InputProcess();
			cadetScene.children.addItem(inputProcess);
			inputProcess.addEventListener(InputProcessEvent.INPUT_DOWN, inputDownHandler);
			var keyboardInput:KeyboardInputMapping = new KeyboardInputMapping("SPACE");
			keyboardInput.input = KeyboardInputMapping.SPACE;
			inputProcess.children.addItem(keyboardInput);
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			
			// Create first rectangle and add to scene
			rectangleEntity1 = createRectangleEntity(cadetScene, 200, 200, 40, 40, 0xFF0000);
			
//			var parentTransform:Transform2D = ComponentUtil.getChildOfType(rectangleEntity1, Transform2D);
//			parentTransform.scaleX = 1.5;
			
			var animateRotationBehaviour:AnimateRotationBehaviour = new AnimateRotationBehaviour();
			rectangleEntity1.children.addItem(animateRotationBehaviour);
			
			// Create second rectangle and nest within first
			rectangleEntity2 = createRectangleEntity(rectangleEntity1, 40, 40, 40, 40, 0x00FF00);
			
			// Create third rectangle and add to scene
			rectangleEntity3 = createRectangleEntity(cadetScene, 40, 40, 40, 40, 0x0000FF);
		}
		
		private function createRectangleEntity(parent:ComponentContainer, x:Number, y:Number, width:Number, height:Number, lineColour:uint = 0xFFFFFF):ComponentContainer
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
			skin.lineColor = lineColour;
			rectangleEntity.children.addItem(skin);
			
			return rectangleEntity;
		}
		
		private function inputDownHandler( event:InputProcessEvent ):void
		{
			if ( event.name == "SPACE" ) {
				if ( count == 0 ) {
					rectangleEntity3.parentComponent.children.removeItem(rectangleEntity3);
				} else if ( count == 1 ) {
					rectangleEntity1.children.addItem(rectangleEntity3);
				} else if ( count == 2 ) {
					rectangleEntity3.parentComponent.children.removeItem(rectangleEntity3);
				} else if ( count == 3 ) {
					rectangleEntity2.children.addItem(rectangleEntity3);
				}
				count ++;
			}
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}