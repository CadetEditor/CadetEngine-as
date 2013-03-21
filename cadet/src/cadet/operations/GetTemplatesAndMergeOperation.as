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
	import cadet.core.IComponent;
	import cadet.operations.GetTemplateAndMergeOperation;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.operations.IUndoableOperation;
	import core.app.operations.UndoableCompoundOperation;

	public class GetTemplatesAndMergeOperation extends UndoableCompoundOperation implements IAsynchronousOperation, IUndoableOperation
	{
		private var components			:Array;
		private var fileSystemProvider	:IFileSystemProvider;
		private var domTable			:Object;
		
		
		public function GetTemplatesAndMergeOperation( components:Array, fileSystemProvider:IFileSystemProvider, domTable:Object = null )
		{
			this.components = components;
			this.fileSystemProvider = fileSystemProvider;
			this.domTable = domTable;
			if ( !domTable ) domTable = {};
			
			for ( var i:int = 0; i < components.length; i++ )
			{
				var component:IComponent = components[i];
				if ( component.templateID == null ) continue;
				
				var operation:GetTemplateAndMergeOperation = new GetTemplateAndMergeOperation( component.templateID, component, fileSystemProvider, domTable );
				addOperation(operation);
			}
		}
		
		override public function get label():String
		{
			return "Get Templates And Merge";
		}
	}
}