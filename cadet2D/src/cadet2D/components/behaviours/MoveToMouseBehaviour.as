package cadet2D.components.behaviours
{
	import cadet.components.processes.InputMapping;
	import cadet.components.processes.InputProcess;
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.transforms.Transform2D;
	
	public class MoveToMouseBehaviour extends Component implements ISteppableComponent
	{
		public var transform		:Transform2D;
		public var inputProcess		:InputProcess;
		
		public function MoveToMouseBehaviour()
		{
			super();
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference( Transform2D, "transform" );
			addSceneReference( InputProcess, "inputProcess" );
		}
		
		public function step(dt:Number):void
		{
			if ( !transform ) return;
			if ( !inputProcess ) return;
			
			if ( inputProcess.isInputDown( InputMapping.MOUSE_MOVE ) )
			{
				var renderer:Renderer2D = ComponentUtil.getChildOfType(scene, Renderer2D, true);
				transform.x = renderer.mouseX;
				transform.y = renderer.mouseY;
			}
		}
	}
}