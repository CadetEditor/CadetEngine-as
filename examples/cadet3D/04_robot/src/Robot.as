package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import cadet.core.CadetScene;
	import cadet.util.ComponentUtil;
	
	import cadet3D.components.renderers.Renderer3D;
	import cadet3D.operations.Cadet3DStartUpOperation;
	
	[SWF( width="700", height="400", backgroundColor="0x002135", frameRate="60" )]
	public class Robot extends Sprite
	{
		private var cadetScene:CadetScene;
		
		private var cadetFileURL:String = "/robot.cdt3d";
		
		public function Robot()
		{
			// Required when loading data and assets.
			var startUpOperation:Cadet3DStartUpOperation = new Cadet3DStartUpOperation(cadetFileURL);
			startUpOperation.addEventListener(Event.COMPLETE, startUpCompleteHandler);
			startUpOperation.execute();
		}
		
		private function startUpCompleteHandler( event:Event ):void
		{
			var operation:Cadet3DStartUpOperation = Cadet3DStartUpOperation( event.target );
			
			initScene( CadetScene(operation.getResult()) );
		}
		
		private function initScene( scene:CadetScene ):void
		{
			cadetScene = scene;
			
			var renderer:Renderer3D = ComponentUtil.getChildOfType(cadetScene, Renderer3D);
			renderer.enable(this);
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}