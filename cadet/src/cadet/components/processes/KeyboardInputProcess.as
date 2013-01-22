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
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	import cadet.core.IRenderer;
	import cadet.events.InputProcessEvent;
	import cadet.events.RendererEvent;

	[Event( type="cadet.events.InputProcessEvent", name="inputDown" ) ]
	[Event( type="cadet.events.InputProcessEvent", name="inputUp" ) ]

	public class KeyboardInputProcess extends ComponentContainer
	{
		private var _renderer		:IRenderer;
		
		private var inputTable		:Object;
		
		public function KeyboardInputProcess()
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
				if ( _renderer.initialised ) {
					removedFromStageHandler();
				}
			}
			_renderer = value;
			if ( _renderer )
			{
				if ( _renderer.initialised ) {
					addedToStageHandler();
				} else {
					_renderer.addEventListener( RendererEvent.INITIALISED, rendererInitialisedHandler );
				}
			}
		}
		public function get renderer():IRenderer { return _renderer; }
		
		private function rendererInitialisedHandler( event:RendererEvent ):void
		{
			addedToStageHandler();
		}
		
		private function addedToStageHandler( event:Event = null ):void
		{
			var parent:DisplayObjectContainer = _renderer.getParent();
			parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			parent.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		private function removedFromStageHandler( event:Event = null ):void
		{
			var parent:DisplayObjectContainer = _renderer.getParent();
			parent.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			parent.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		
		public function isInputDown( name:String ):Boolean
		{
			return inputTable[name];
		}
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			var mapping:KeyboardInputMapping = getMappingForKeyCode(event.keyCode);
			if (!mapping) return;
			inputTable[mapping.name] = true;
			
			dispatchEvent( new InputProcessEvent( InputProcessEvent.INPUT_DOWN, mapping.name ) );
		}
		
		private function keyUpHandler( event:KeyboardEvent ):void
		{
			var mapping:KeyboardInputMapping = getMappingForKeyCode(event.keyCode);
			if (!mapping) return;
			inputTable[mapping.name] = null;
			
			dispatchEvent( new InputProcessEvent( InputProcessEvent.INPUT_UP, mapping.name ) );
		}
		
		private function getMappingForKeyCode( keyCode:int ):KeyboardInputMapping
		{
			for each ( var child:KeyboardInputMapping in _children )
			{
				if ( child.getKeyCode() == keyCode ) return child;
			}
			return null;
		}
		
		private function getMappingForInput( input:String ):KeyboardInputMapping
		{
			for each ( var child:IComponent in _children )
			{
				if ( child is KeyboardInputMapping == false ) continue
				if ( KeyboardInputMapping(child).input == input ) return KeyboardInputMapping(child);
			}
			return null;
		}
	}
}