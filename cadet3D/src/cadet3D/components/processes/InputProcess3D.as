package cadet3D.components.processes
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import cadet.components.processes.IInputMapping;
	import cadet.components.processes.InputProcess;
	import cadet.components.processes.TouchInputMapping;
	
	import cadet3D.components.renderers.Renderer3D;
	
	public class InputProcess3D extends InputProcess
	{
		private var _mouseDown		:Boolean;
		
		private var _renderer3D		:Renderer3D;
		
		public function InputProcess3D()
		{
			super();
		}
		
		override protected function addedToStageHandler( event:Event = null ):void
		{
			super.addedToStageHandler(event);
			
			var stage:Stage = _renderer.getNativeStage();
			stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
		}
		
		override protected function removedFromStageHandler( event:Event = null ):void
		{
			super.removedFromStageHandler(event);
			
			var stage:Stage = _renderer.getNativeStage();
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
		}
		
		private function mouseDownHandler( event:MouseEvent ):void
		{
			clearTouches();
			
			_mouseDown = true;
			
			var mapping:IInputMapping = getMappingForInput(TouchInputMapping.BEGAN);
			if (mapping) 	inputTable[mapping.name] = true;
		}
		private function mouseUpHandler( event:MouseEvent ):void
		{
			clearTouches();
			
			_mouseDown = false;
			
			var mapping:IInputMapping = getMappingForInput(TouchInputMapping.ENDED);
			if (mapping) 	inputTable[mapping.name] = true;
		}
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			clearTouches();
			
			var mapping:IInputMapping;
			
			if (_mouseDown) {
				mapping = getMappingForInput(TouchInputMapping.MOVED);
				if (mapping) 		inputTable[mapping.name] = true;
			} else {
				mapping = getMappingForInput(TouchInputMapping.HOVER);
				if (mapping) 		inputTable[mapping.name] = true;
			}
		}
	}
}






