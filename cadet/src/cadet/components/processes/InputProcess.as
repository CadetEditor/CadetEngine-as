// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.components.processes
{
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	import cadet.core.IRenderer;
	import cadet.events.InputProcessEvent;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	[Event( type="cadet.events.InputProcessEvent", name="inputDown" ) ]
	[Event( type="cadet.events.InputProcessEvent", name="inputUp" ) ]

	public class InputProcess extends ComponentContainer
	{
		private var _renderer		:IRenderer;
		
		private var inputTable		:Object;
		
		public function InputProcess()
		{
			name = "InputProcess";
			inputTable = {}
		}
		
		override protected function addedToScene():void
		{
			addSceneReference( IRenderer, "renderer" );
		}
		
		public function set renderer( value:IRenderer ):void
		{
			if ( _renderer )
			{
//				_renderer.viewport.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
//				_renderer.viewport.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
//				
//				if ( _renderer.viewport.stage )
//				{
//					removedFromStageHandler();
//				}
			}
			_renderer = value;
			if ( _renderer )
			{
//				_renderer.viewport.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
//				_renderer.viewport.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
//				
//				if ( _renderer.viewport.stage )
//				{
//					addedToStageHandler();
//				}
			}
		}
		public function get renderer():IRenderer { return _renderer; }
		
		private function addedToStageHandler( event:Event = null ):void
		{
//			_renderer.viewport.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
//			_renderer.viewport.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
//			_renderer.viewport.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
//			_renderer.viewport.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
		}
		
		private function removedFromStageHandler( event:Event = null ):void
		{
//			_renderer.viewport.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
//			_renderer.viewport.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
//			_renderer.viewport.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
//			_renderer.viewport.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		
		public function isInputDown( name:String ):Boolean
		{
			return inputTable[name];
		}
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			var mapping:InputMapping = getMappingForKeyCode(event.keyCode);
			if (!mapping) return;
			inputTable[mapping.name] = true;
			
			dispatchEvent( new InputProcessEvent( InputProcessEvent.INPUT_DOWN, mapping.name ) );
		}
		
		private function keyUpHandler( event:KeyboardEvent ):void
		{
			var mapping:InputMapping = getMappingForKeyCode(event.keyCode);
			if (!mapping) return;
			inputTable[mapping.name] = null;
			
			dispatchEvent( new InputProcessEvent( InputProcessEvent.INPUT_UP, mapping.name ) );
		}
		
		private function mouseDownHandler( event:MouseEvent ):void
		{
			var mapping:InputMapping = getMappingForSymbol("LMB");
			if (!mapping) return;
			inputTable[mapping.name] = true;
			
			dispatchEvent( new InputProcessEvent( InputProcessEvent.INPUT_DOWN, mapping.name ) );
		}
		
		private function mouseUpHandler( event:MouseEvent ):void
		{
			var mapping:InputMapping = getMappingForSymbol("LMB");
			if (!mapping) return;
			inputTable[mapping.name] = null;
			
			dispatchEvent( new InputProcessEvent( InputProcessEvent.INPUT_DOWN, mapping.name ) );
		}
		
		private function getMappingForKeyCode( keyCode:int ):InputMapping
		{
			for each ( var child:InputMapping in _children )
			{
				if ( child.getKeyCode() == keyCode ) return child;
			}
			return null;
		}
		
		private function getMappingForSymbol( symbol:String ):InputMapping
		{
			for each ( var child:IComponent in _children )
			{
				if ( child is InputMapping == false ) continue
				if ( InputMapping(child).symbol == symbol ) return InputMapping(child);
			}
			return null;
		}
	}
}