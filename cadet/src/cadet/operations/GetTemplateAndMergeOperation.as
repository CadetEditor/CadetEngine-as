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
	import core.app.util.AsynchronousUtil;
	
	import cadet.core.IComponent;
	import cadet.operations.GetTemplateOperation;
	import cadet.operations.MergeWithTemplateOperation;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.operations.IUndoableOperation;
	import core.app.events.OperationProgressEvent;

	public class GetTemplateAndMergeOperation extends EventDispatcher implements IAsynchronousOperation, IUndoableOperation
	{
		private var templatePath		:String;
		private var component			:IComponent;
		private var fileSystemProvider	:IFileSystemProvider;
		private var domTable			:Object;
		
		private var template					:IComponent;
		private var mergeWithTemplateOperation	:MergeWithTemplateOperation;
		
		public function GetTemplateAndMergeOperation( templatePath:String, component:IComponent, fileSystemProvider:IFileSystemProvider, domTable:Object = null )
		{
			this.templatePath = templatePath;
			this.component = component;
			this.fileSystemProvider = fileSystemProvider;
			this.domTable = domTable;
			
			// It's a local template
			if ( templatePath.indexOf("#") == -1 )
			{
				templatePath = "local#" + templatePath;
			}
			
			if ( !domTable )
			{
				domTable = {};
			}
		}
		
		public function execute():void
		{
			AsynchronousUtil.dispatchLater( this, new Event( Event.COMPLETE ) );
			
			// This will be true if the operation has already executed once
			// We simply skip to merging the template with the component as we've
			// already fetched the template.
			if ( mergeWithTemplateOperation )
			{
				mergeWithTemplateOperation.execute();
				
			}
			else
			{
				var getTemplateOperation:GetTemplateOperation = new GetTemplateOperation( templatePath, fileSystemProvider, domTable );
				getTemplateOperation.addEventListener(ErrorEvent.ERROR, passThroughHandler);
				getTemplateOperation.addEventListener(OperationProgressEvent.PROGRESS, passThroughHandler);
				getTemplateOperation.addEventListener(Event.COMPLETE, getTemplateCompleteHandler);
				getTemplateOperation.execute();
			}
		}
		
		private function passThroughHandler( event:Event ):void
		{
			dispatchEvent( event.clone() );
		}
		
		private function getTemplateCompleteHandler( event:Event ):void
		{
			var getTemplateOperation:GetTemplateOperation = GetTemplateOperation( event.target );
			
			template = getTemplateOperation.getResult();
			
			mergeWithTemplateOperation = new MergeWithTemplateOperation( component, template, true );
			mergeWithTemplateOperation.addEventListener(ErrorEvent.ERROR, passThroughHandler);
			mergeWithTemplateOperation.addEventListener(OperationProgressEvent.PROGRESS, passThroughHandler);
			mergeWithTemplateOperation.addEventListener(Event.COMPLETE, mergeCompleteHandler);
			mergeWithTemplateOperation.execute();
		}
		
		private function mergeCompleteHandler( event:Event ):void
		{
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function undo():void
		{
			mergeWithTemplateOperation.undo();
		}
		
		public function get label():String
		{
			return "Get template and merge";
		}
		
	}
}