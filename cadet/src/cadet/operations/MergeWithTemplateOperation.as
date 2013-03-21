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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.operations.IUndoableOperation;
	import core.app.events.OperationProgressEvent;
	import core.app.operations.AddItemOperation;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.CloneOperation;
	import core.app.operations.RemoveItemOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.app.util.AsynchronousUtil;
	import core.app.util.IntrospectionUtil;

	public class MergeWithTemplateOperation extends EventDispatcher implements IUndoableOperation, IAsynchronousOperation
	{
		private var component	:IComponent;
		private var template	:IComponent;
		private var clone		:Boolean;
		
		private var operation	:UndoableCompoundOperation;
		
		public function MergeWithTemplateOperation( component:IComponent, template:IComponent, clone:Boolean = false )
		{
			this.component = component;
			this.template = template;
			this.clone = clone;
		}
		
		public function execute():void
		{
			AsynchronousUtil.dispatchLater(this, new Event( Event.COMPLETE ) );
			return;
			
			if ( clone )
			{
				var cloneOperation:CloneOperation = new CloneOperation(template);
				cloneOperation.addEventListener(OperationProgressEvent.PROGRESS, passThroughHandler);
				cloneOperation.addEventListener(ErrorEvent.ERROR, passThroughHandler);
				cloneOperation.addEventListener(Event.COMPLETE, cloneCompleteHandler);
				cloneOperation.execute();
			}
			else
			{
				performMerge();
			}
		}
		
		private function cloneCompleteHandler( event:Event ):void
		{
			var cloneOperation:CloneOperation = CloneOperation(event.target);
			template = IComponent( cloneOperation.getResult() );
			performMerge();
		}
		
		private function passThroughHandler( event:Event ):void
		{
			dispatchEvent( event.clone() );
		}
		
		private function performMerge():void
		{
			var parent:IComponentContainer = component.parentComponent;
			
			operation = new UndoableCompoundOperation();
			
			var index:int = parent.children.getItemIndex(component);
			operation.addOperation( new RemoveItemOperation( component, parent.children ) );
			operation.addOperation( new AddItemOperation( template, parent.children, index ) );
			
			operation.addOperation( new ChangePropertyOperation( template, "templateID", component.templateID ) );
			operation.addOperation( new ChangePropertyOperation( template, "exportTemplateID", null ) );
			
			if ( template is IComponentContainer && component is IComponentContainer )
			{
				var templateAsContainer:IComponentContainer = IComponentContainer(template);
				var componentAsContainer:IComponentContainer = IComponentContainer(component);
				
				// Now loop through the new component's children and handle any marked with [Cadet( inheritFromTemplate='false' )]
				for ( var i:int = 0; i < templateAsContainer.children.length; i++ )
				{
					var child:IComponent = templateAsContainer.children[i];
					
					var inheritFromTemplateValue:String = IntrospectionUtil.getMetadataByNameAndKey(child, "Cadet", "inheritFromTemplate");
					if ( inheritFromTemplateValue == null ) continue;
					if ( inheritFromTemplateValue != "false" ) continue;
															
					var existingChild:IComponent = ComponentUtil.getChildByName( componentAsContainer, child.name );
					if ( !existingChild ) continue;
					
					templateAsContainer.children.removeItem(child);
					templateAsContainer.children.addItemAt(existingChild,i);
				}
			}
			
			operation.execute();
			AsynchronousUtil.dispatchLater(this, new Event( Event.COMPLETE ) );
		}
		
		public function undo():void
		{
			operation.undo();
			AsynchronousUtil.dispatchLater(this, new Event( Event.COMPLETE ) );
		}
		
		public function get label():String
		{
			return "Merge with template";
		}
	}
}