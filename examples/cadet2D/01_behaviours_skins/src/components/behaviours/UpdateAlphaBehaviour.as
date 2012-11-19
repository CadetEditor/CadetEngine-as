package components.behaviours
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.renderPipeline.starling.components.renderers.Renderer2D;
	import cadet2D.renderPipeline.starling.components.skins.GeometrySkin;
	
	public class UpdateAlphaBehaviour extends Component implements ISteppableComponent
	{
		public var skin				:GeometrySkin;
		public var renderer			:Renderer2D;
		
		public function UpdateAlphaBehaviour()
		{
			super();
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(GeometrySkin, "skin");
			addSceneReference(Renderer2D, "renderer");
		}
		
		public function step( dt:Number ):void
		{
			if ( !skin ) return;
			
			skin.fillAlpha = renderer.mouseX/renderer.viewport.stage.stageWidth; 
		}
	}
}