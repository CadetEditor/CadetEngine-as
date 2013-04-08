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
	import cadet.operations.GetTemplatesAndMergeXMLOperation;
	import cadet.operations.ValidateAsyncOperation;
	import cadet.util.ComponentUtil;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.serialization.ISerializationPlugin;
	import core.app.core.serialization.ResourceSerializerPlugin;
	import core.app.entities.URI;
	import core.app.events.OperationProgressEvent;
	import core.app.managers.ResourceManager;
	import core.app.operations.DeserializeOperation;
	import core.app.operations.ReadFileAndDeserializeOperation;

	public class ReadCadetFileAndDeserializeOperation extends EventDispatcher implements IAsynchronousOperation
	{
		private var uri						:URI;
		private var fileSystemProvider		:IFileSystemProvider;
		private var resourceManager			:ResourceManager;
		private var xml						:XML;
		private var scene					:ICadetScene;
		
		public function ReadCadetFileAndDeserializeOperation( uri:URI, fileSystemProvider:IFileSystemProvider, resourceManager:ResourceManager )
		{
			this.uri = uri;
			this.fileSystemProvider = fileSystemProvider;
			this.resourceManager = resourceManager;
		}
		
		public function execute():void
		{
			var readFileOperation:IReadFileOperation = fileSystemProvider.readFile( uri );
			readFileOperation.addEventListener(Event.COMPLETE, readFileCompleteHandler);
			readFileOperation.addEventListener(OperationProgressEvent.PROGRESS, readFileProgressHandler);
			readFileOperation.addEventListener(ErrorEvent.ERROR, passThroughHandler);
			readFileOperation.execute();
		}
		
		private function passThroughHandler( event:Event ):void
		{
			dispatchEvent( event );
		}
		
		private function readFileProgressHandler( event:OperationProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, event.progress * 0.1 ) );
		}
		
		private function getTemplatesAndMergeProgressHandler( event:OperationProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, 0.1 + event.progress * 0.2 ) );
		}
		
		private function deserializeProgressHandler( event:OperationProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, 0.3 + event.progress * 0.3 ) );
		}
		
		private function validateProgressHandler( event:OperationProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, 0.9 + event.progress * 0.1 ) );
		}
		
		private function readFileCompleteHandler( event:Event ):void
		{
			var readFileOperation:IReadFileOperation = IReadFileOperation(event.target);
			if ( readFileOperation.bytes.length == 0 )
			{
				dispatchEvent( new Event( Event.COMPLETE ) );
				return;
			}
			
/*			try
			{*/
				var xmlString:String = readFileOperation.bytes.readUTFBytes( readFileOperation.bytes.length );
				xml = XML( xmlString );
				
				if ( xml == null )
				{
					throw( new Error( "Invalid xml" ) )
				}
/*			}
			catch ( e:Error )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.message ) )
				return;
			}*/
			
			var getTemplatesAndMergeOperation:GetTemplatesAndMergeXMLOperation = new GetTemplatesAndMergeXMLOperation( xml, fileSystemProvider );
			getTemplatesAndMergeOperation.addEventListener(OperationProgressEvent.PROGRESS, getTemplatesAndMergeProgressHandler);
			getTemplatesAndMergeOperation.addEventListener(ErrorEvent.ERROR, passThroughHandler);
			getTemplatesAndMergeOperation.addEventListener(Event.COMPLETE, getTemplatesAndMergeCompleteHandler);
			getTemplatesAndMergeOperation.execute();
		}
		
		private function getTemplatesAndMergeCompleteHandler( event:Event ):void
		{
			var plugins:Vector.<ISerializationPlugin> = new Vector.<ISerializationPlugin>();
			if ( resourceManager )
			{
				plugins.push( new ResourceSerializerPlugin( resourceManager ) );
			}
			
			var deserializeOperation:DeserializeOperation = new DeserializeOperation(xml, plugins);
			deserializeOperation.addEventListener(OperationProgressEvent.PROGRESS, deserializeProgressHandler);
			deserializeOperation.addEventListener(ErrorEvent.ERROR, passThroughHandler);
			deserializeOperation.addEventListener(Event.COMPLETE, deserializeCompleteHandler);
			deserializeOperation.execute();
		}
		
		private function deserializeCompleteHandler( event:Event ):void
		{
			var deserializeOperation:DeserializeOperation = DeserializeOperation(event.target);
			
			try
			{
				scene = ICadetScene( deserializeOperation.getResult() );
			}
			catch( e:Error )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.message ) );
				return;
			}
			
			
			var validateAsyncOperation:ValidateAsyncOperation = new ValidateAsyncOperation( scene );
			validateAsyncOperation.addEventListener(OperationProgressEvent.PROGRESS, validateProgressHandler);
			validateAsyncOperation.addEventListener(ErrorEvent.ERROR, passThroughHandler);
			validateAsyncOperation.addEventListener(Event.COMPLETE, validateCompleteHandler);
			validateAsyncOperation.execute();
		}
		
		private function validateCompleteHandler( event:Event ):void
		{
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function getResult():ICadetScene
		{
			return scene;
		}
		
		public function get label():String { return "Read Cadet File : " + uri.path; }
	}
}