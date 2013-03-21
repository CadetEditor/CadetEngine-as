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
	import core.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import core.app.core.serialization.Serializer;
	import core.app.entities.URI;
	import core.app.util.AsynchronousUtil;
	
	import cadet.core.IComponent;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.operations.IUndoableOperation;
	import core.app.events.OperationProgressEvent;

	public class GetTemplateAndMergeXMLOperation extends EventDispatcher implements IAsynchronousOperation
	{
		private var templatePath		:String;
		private var templateID			:String;
		private var domTableID			:String;
		private var xmlToMergeInto		:XML;
		private var fileSystemProvider	:IFileSystemProvider;
		private var templateXMLTable	:Object;
		
		private var xmlContainingTemplate:XML;
		private var templateXML			:XML;
		
		private var template					:IComponent;
		private var mergeWithTemplateOperation	:MergeWithTemplateOperation;
		
		public function GetTemplateAndMergeXMLOperation( xmlToMergeInto:XML, fileSystemProvider:IFileSystemProvider, templateXMLTable:Object = null )
		{
			this.xmlToMergeInto = xmlToMergeInto;
			this.fileSystemProvider = fileSystemProvider;
			this.templateXMLTable = templateXMLTable;
			if ( !templateXMLTable )
			{
				templateXMLTable = {};
			}
			
			templatePath = xmlToMergeInto.@templateID;
			
			if ( templatePath == "" || templatePath == null )
			{
				throw( new Error( "The node supplied does not have a templateID" ) );
				return;
			}
		}
		
		public function execute():void
		{
			// It's a local template
			if ( templatePath.indexOf("#") == -1 )
			{
				templatePath = "local#" + templatePath;
			}
			
			var uri:URI;
			// It's a local template
			if ( templatePath.indexOf("#") == -1 )
			{
				domTableID = "local";
				templateID = templatePath;
			}
			else
			{
				var split:Array = templatePath.split("#");
				uri = new URI( split[0] );
				domTableID = uri.path;
				templateID = split[1];
			}
			
			if ( templateXMLTable[domTableID] )
			{
				var xmlContainingTemplate:XML = templateXMLTable[domTableID];
				templateXML = xmlContainingTemplate..*.(name() == "cadet.core::ComponentContainer" && String(attribute("exportTemplateID")) == templateID)[0];
				performMerge();
			}
			else if ( uri )
			{
				var operation:IReadFileOperation = fileSystemProvider.readFile(uri);
				operation.addEventListener(OperationProgressEvent.PROGRESS, passThroughHandler);
				operation.addEventListener(ErrorEvent.ERROR, passThroughHandler);
				operation.addEventListener(Event.COMPLETE, readFileCompleteHandler);
				operation.execute();
			}
			else
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "Cannot find local DOM for a local template" ) );
			}
		}
		
		private function readFileCompleteHandler( event:Event ):void
		{
			var readFileOperation:IReadFileOperation = IReadFileOperation(event.target);
			var xmlString:String = readFileOperation.bytes.readUTFBytes(readFileOperation.bytes.length);
			var xmlContainingTemplate:XML = XML(xmlString);
			
			
			// We now need to modify all x:id attributes in the template XML to pre-pend them with an unique string.
			// This is to avoid clashes with x:id's in the xml we're merging into. As all x:id's should be unique.
			// This ensures the Deserializer doesn't get confused when deserializing Refs.
			var x:Namespace = Serializer.x;
			xmlContainingTemplate.@x::id = domTableID + xmlContainingTemplate.@x::id;
			var allNodes:XMLList = xmlContainingTemplate.descendants();
			for ( var i:int = 0 ; i < allNodes.length(); i++ )
			{
				var node:XML = allNodes[i];
				node.@x::id = domTableID + node.@x::id;
			}
			
			templateXMLTable[domTableID] = xmlContainingTemplate;
			templateXML = xmlContainingTemplate..*.(name() == "cadet.core::ComponentContainer" && String(attribute("exportTemplateID")) == templateID)[0];
			
			performMerge();
		}
		
		private function performMerge():void
		{
			var x:Namespace = Serializer.x;
			var templateChildren:XML = templateXML.children().(@x::name == "children")[0];
			var xmlToMergeIntoChildren:XML = xmlToMergeInto.children().(@x::name == "children")[0];
			for ( var i:int = 0; i < templateChildren.children().length(); i++ )
			{
				var templateChild:XML = templateChildren.children()[i];
				var matchingChildren:XMLList = xmlToMergeIntoChildren.*.(@name == templateChild.@name);
				// Ignore any children already present. These children were marked with [Cadet( inheritFromTemplate="false")]
				if ( matchingChildren.length() > 0 ) continue;
				xmlToMergeIntoChildren.appendChild( templateChild.copy() );
			}
			
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		private function passThroughHandler( event:Event ):void
		{
			dispatchEvent( event.clone() );
		}
		
		public function get label():String
		{
			return "Get template and merge";
		}
		
	}
}