package cadet2D.components.processes
{
	import flash.events.Event;
	
	import cadet.components.processes.IInputMapping;
	import cadet.components.processes.InputProcess;
	
	import cadet2D.components.renderers.Renderer2D;
	
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;

	// InputProcess with a notion of Touches (via Starling)
	public class InputProcess2D extends InputProcess
	{
		private var _renderer2D	:Renderer2D;
		
		public function InputProcess2D()
		{
			
		}
		
		override protected function addedToStageHandler( event:Event = null ):void
		{
			super.addedToStageHandler(event);
			_renderer2D	= Renderer2D(_renderer);
			_renderer2D.viewport.stage.addEventListener( TouchEvent.TOUCH, touchEventHandler );
		}
		
		override protected function removedFromStageHandler( event:Event = null ):void
		{
			super.removedFromStageHandler(event);
			_renderer2D	= Renderer2D(_renderer);
			_renderer2D.viewport.stage.removeEventListener( TouchEvent.TOUCH, touchEventHandler );
		}
		
		protected function touchEventHandler( event:TouchEvent ):void
		{
			if ( !_renderer ) return;
			
			// Clear touches
			clearTouches();
			
			_renderer2D	= Renderer2D(_renderer);
			var dispObj:DisplayObject = DisplayObject(_renderer2D.viewport.stage);
			var touches:Vector.<Touch> = event.getTouches(dispObj);
			
			for each (var touch:Touch in touches)
			{
				var mapping:IInputMapping = getMappingForInput(touch.phase);
				if (mapping) {
					inputTable[mapping.name] = true;
				}
			}
		}
	}
}









