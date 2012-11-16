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
	import flash.events.EventDispatcher;
	
	import cadet.core.IComponent;
	import cadet.operations.GetTemplateAndMergeXMLOperation;
	
	import flox.app.core.serialization.Serializer;
	import flox.app.operations.CompoundOperation;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.operations.IAsynchronousOperation;
	import flox.app.operations.UndoableCompoundOperation;
	

	public class GetTemplatesAndMergeXMLOperation extends CompoundOperation implements IAsynchronousOperation
	{
		private var xmlToMergeInto		:XML;
		private var fileSystemProvider	:IFileSystemProvider;
		private var templateXMLTable	:Object;
		
		
		
		public function GetTemplatesAndMergeXMLOperation( xmlToMergeInto:XML, fileSystemProvider:IFileSystemProvider, templateXMLTable:Object = null )
		{
			this.xmlToMergeInto = xmlToMergeInto;
			this.fileSystemProvider = fileSystemProvider;
			this.templateXMLTable = templateXMLTable;
			if ( !templateXMLTable ) templateXMLTable = {};
			
			var x:Namespace = Serializer.x;
			var nodesWithTemplateID:XMLList = xmlToMergeInto..*.(name() == "cadet.core::ComponentContainer" && String(attribute("templateID")) != "");
						
			for ( var i:int = 0; i < nodesWithTemplateID.length(); i++ )
			{
				var node:XML = nodesWithTemplateID[i];
				var operation:GetTemplateAndMergeXMLOperation = new GetTemplateAndMergeXMLOperation( node, fileSystemProvider, templateXMLTable );
				addOperation(operation);
			}
		}
		
		
		override public function get label():String
		{
			return "Get Templates And Merge";
		}
	}
}