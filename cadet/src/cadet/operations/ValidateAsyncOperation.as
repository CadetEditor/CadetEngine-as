// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.operations
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import flox.app.core.operations.IAsynchronousOperation;
	import flox.app.events.OperationProgressEvent;
	import flox.app.util.AsynchronousUtil;

	public class ValidateAsyncOperation extends EventDispatcher implements IAsynchronousOperation
	{
		private var scene			:IComponentContainer;
		private var components		:Vector.<IComponent>;
		private var totalComponents	:int;
		
		public function ValidateAsyncOperation(scene:IComponentContainer)
		{
			this.scene = scene;
		}
		
		public function execute():void
		{
			components = ComponentUtil.getChildren(scene, true);
			components = components.reverse();
			totalComponents = components.length;
			checkQueue();
		}
		
		private function checkQueue():void
		{
			if ( components.length == 0 )
			{
				dispatchEvent( new Event( Event.COMPLETE ) );
				return;
			}
			
			var start:int = getTimer();
			while ( components.length > 0 )
			{
				var component:IComponent = IComponent(components.pop());
				component.validateNow();
				if ( (getTimer() - start) > 15 ) break;
			}
			
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, (totalComponents-components.length) / totalComponents ) );
			
			AsynchronousUtil.callLater(checkQueue);
		}
		
		public function get label():String
		{
			return "Validate Async";
		}
	}
}