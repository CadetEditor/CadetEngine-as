package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import cadet.core.CadetScene;
	
	import cadet2D.operations.Cadet2DStartUpOperation;
	
	import core.app.CoreApp;
	import core.app.util.AsynchronousUtil;
	import core.app.util.SerializationUtil;
	
	import model.ISceneModel;
	import model.SceneModel_Code;
	import model.SceneModel_XML;
	
	[SWF( width="800", height="600", backgroundColor="0x002135", frameRate="60" )]
	public class Lava extends Sprite
	{
		private var _sceneModel:ISceneModel;
		// Comment out either of the below to switch ISceneModels.
		// URL = SceneModel_XML, null = SceneModel_Code
		private var _cadetFileURL		:String = "/lava.cdt2d";		
//		private var _cadetFileURL:String = null;
		
		public function Lava()
		{
			// Required when loading data and assets.
			var startUpOperation:Cadet2DStartUpOperation = new Cadet2DStartUpOperation(_cadetFileURL);
			startUpOperation.addEventListener(flash.events.Event.COMPLETE, startUpCompleteHandler);
			startUpOperation.execute();
		}
		
		private function startUpCompleteHandler( event:Event ):void
		{
			var operation:Cadet2DStartUpOperation = Cadet2DStartUpOperation( event.target );
			
			// If a _cadetFileURL is specified, load the external CadetScene from XML
			// Otherwise, revert to the coded version of the CadetScene.
			if ( _cadetFileURL ) {
				_sceneModel = new SceneModel_XML();
				_sceneModel.cadetScene = CadetScene(operation.getResult());
			} else {
				_sceneModel = new SceneModel_Code( CoreApp.resourceManager );
				// Need to wait for the next frame to serialize, otherwise the manifests aren't ready
				AsynchronousUtil.callLater(serialize);
			}

			_sceneModel.init(this);
		}
		
		private function serialize():void
		{
			var eventDispatcher:EventDispatcher = SerializationUtil.serialize(_sceneModel.cadetScene);
			eventDispatcher.addEventListener(flash.events.Event.COMPLETE, serializationCompleteHandler);
		}
		
		private function serializationCompleteHandler( event:flash.events.Event ):void
		{
			trace(SerializationUtil.getResult().toXMLString());
		}
	}
}