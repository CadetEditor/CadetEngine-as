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
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	import cadet.core.IRenderer;
	import cadet.events.InputProcessEvent;
	import cadet.events.RendererEvent;

	[Event( type="cadet.events.InputProcessEvent", name="inputDown" ) ]
	[Event( type="cadet.events.InputProcessEvent", name="inputUp" ) ]

	public class InputProcess extends ComponentContainer
	{
		protected var _renderer			:IRenderer;
		
		protected var inputTable		:Object;
		
		public function InputProcess()
		{
			name = "InputProcess";
			inputTable = {};
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
		
		protected function addedToStageHandler( event:Event = null ):void
		{
			var stage:Stage = _renderer.getNativeStage();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		protected function removedFromStageHandler( event:Event = null ):void
		{
			var stage:Stage = _renderer.getNativeStage();
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		public function isInputDown( name:String ):Boolean
		{
			return inputTable[name];
		}
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			var mapping:IInputMapping = getMappingForKeyCode(event.keyCode);
			if (!mapping) return;
			inputTable[mapping.name] = true;
			
			dispatchEvent( new InputProcessEvent( InputProcessEvent.INPUT_DOWN, mapping.name ) );
		}
		
		private function keyUpHandler( event:KeyboardEvent ):void
		{
			var mapping:IInputMapping = getMappingForKeyCode(event.keyCode);
			if (!mapping) return;
			inputTable[mapping.name] = null;
			
			dispatchEvent( new InputProcessEvent( InputProcessEvent.INPUT_UP, mapping.name ) );
		}
		
		protected function getMappingForKeyCode( keyCode:int ):IInputMapping
		{
			for each ( var child:IInputMapping in _children )
			{
				if ( child is KeyboardInputMapping ) {
					var kim:KeyboardInputMapping = KeyboardInputMapping(child);
					if ( kim.getKeyCode() == keyCode ) return child;
				}
			}
			return null;
		}
		
		protected function getMappingForInput( input:String ):IInputMapping
		{
			for each ( var child:IComponent in _children )
			{
				if ( child is IInputMapping == false ) continue
				if ( IInputMapping(child).input == input ) return IInputMapping(child);
			}
			return null;
		}
		
		protected function clearTouches():void
		{
			for each ( var mapping:String in TouchInputMapping.mappings ) {
				if ( inputTable[mapping] ) {
					inputTable[mapping] = false;
				}
			}
		}
	}
}