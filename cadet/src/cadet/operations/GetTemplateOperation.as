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
	import cadet.core.ICadetScene;
	import cadet.core.IComponent;
	import cadet.util.ComponentUtil;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.entities.URI;
	import core.app.events.OperationProgressEvent;
	import core.app.operations.ReadFileAndDeserializeOperation;
	import core.app.util.AsynchronousUtil;

	[Event(type="core.app.events.OperationProgressEvent", name="progress")]
	[Event(type="flash.events.Event", name="complete")]
	[Event(type="flash.events.ErrorEvent", name="error")]

	/**
	 * This operation wraps up a ReadFileAndDeserializeOperation to read a file from the URI portion of a templatePath. After
	 * reading the file, it then inspects the loaded dom to find a template with a matching ID. It then stores a reference to
	 * this template in 'result' (obtainable via getResult()) and completes.
	 * @author Jonathan
	 * 
	 */	
	public class GetTemplateOperation extends EventDispatcher implements IAsynchronousOperation
	{
		public var templatePath	:String;
			private var uri			:URI;
			private var templateID	:String;
		
		private var fileSystemProvider	:IFileSystemProvider;
		private var sceneTable			:Object;
		
		private var result		:IComponent;
		
		public function GetTemplateOperation( templatePath:String, fileSystemProvider:IFileSystemProvider, domTable:Object = null )
		{
			this.templatePath = templatePath;
			this.fileSystemProvider = fileSystemProvider;
			this.sceneTable = domTable;
			if ( !this.sceneTable ) this.sceneTable = {};
		}
		
		public function execute():void
		{
			var sceneTableID:String;
			
			// It's a local template
			if ( templatePath.indexOf("#") == -1 )
			{
				sceneTableID = "local";
				templateID = templatePath;
			}
			else
			{
				var split:Array = templatePath.split("#");
				uri = new URI( split[0] );
				sceneTableID = uri.path;
				templateID = split[1];
			}
			
			if ( sceneTable[sceneTableID] )
			{
				getTemplateFromScene(sceneTable[sceneTableID]);
			}
			else if ( uri )
			{
				var operation:ReadFileAndDeserializeOperation = new ReadFileAndDeserializeOperation(uri, fileSystemProvider);
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
		
		private function getTemplateFromScene( scene:ICadetScene ):void
		{
			var template:IComponent = ComponentUtil.getChildWithExportTemplateID(scene, templateID, true);
			if ( !template )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "Template with exportID " + templateID + " could not be found" ) );
				return;
			}
			
			result = template;
			
			AsynchronousUtil.dispatchLater(this, new Event(Event.COMPLETE));
		}
		
		private function readFileCompleteHandler( event:Event ):void
		{
			var operation:ReadFileAndDeserializeOperation = ReadFileAndDeserializeOperation(event.target);
			
			var scene:ICadetScene;
			try
			{
				scene = ICadetScene( operation.getResult() );
			}
			catch (e:Error)
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.message ) );
				return;
			}
			
			sceneTable[operation.getURI().path] = scene;
			getTemplateFromScene(scene);
		}
		
		private function passThroughHandler( event:Event ):void
		{
			dispatchEvent( event.clone() );
		}
		
		public function get label():String
		{
			return "Get Template : " + templatePath;
		}
		
		public function getResult():IComponent { return result; }
		
	}
}