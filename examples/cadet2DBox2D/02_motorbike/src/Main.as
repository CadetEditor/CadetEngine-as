package
{	
	import cadet.core.CadetScene;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.operations.Cadet2DStartUpOperation;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF( width="700", height="400", backgroundColor="0x002135", frameRate="60" )]
	public class Main extends Sprite
	{
		private var cadetScene:CadetScene;
		
		private var cadetFileURL:String = "/motorbike.cdt2d";
		
		public function Main()
		{
			// Required when loading data and assets.
			var startUpOperation:Cadet2DStartUpOperation = new Cadet2DStartUpOperation(cadetFileURL);
			startUpOperation.addManifest( startUpOperation.baseManifestURL + "Cadet2DBox2D.xml");
			startUpOperation.addEventListener(Event.COMPLETE, startUpCompleteHandler);
			startUpOperation.execute();
		}
		
		private function startUpCompleteHandler( event:Event ):void
		{
			var operation:Cadet2DStartUpOperation = Cadet2DStartUpOperation( event.target );
			
			initScene( CadetScene(operation.getResult()) );
		}
		
		private function initScene( scene:CadetScene ):void
		{
			cadetScene = scene;
			
			var renderer:Renderer2D = ComponentUtil.getChildOfType(cadetScene, Renderer2D);
			renderer.enable(this);
			
			cadetScene.validateNow();
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}