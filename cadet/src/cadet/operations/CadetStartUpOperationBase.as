// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// ABSTRACT CLASS
package cadet.operations
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import cadet.core.ICadetScene;
	import core.app.util.FileSystemTypes;
	
	import core.app.CoreApp;
	import core.app.controllers.ExternalResourceController;
	import core.app.entities.URI;
	import core.app.managers.fileSystemProviders.local.LocalFileSystemProvider;
	import core.app.managers.fileSystemProviders.url.URLFileSystemProvider;
	import core.app.operations.CompoundOperation;
	import core.app.operations.LoadManifestsOperation;
	import core.app.resources.IResource;
	
	public class CadetStartUpOperationBase extends CompoundOperation
	{
		protected var readAndDeserializeOperation:ReadCadetFileAndDeserializeOperation;
		
		protected var fspURLID:String = "cadet.url"; 
		protected var fspLocalID:String = "cadet.local";
		protected var fspLocalFolder:String ="Cadet";
		public var baseURL:String = "files";
		public var cadetFileURL:String;
		public var baseManifestURL:String = "extensions/manifests/";
		
		public var fileSystemType:String = FileSystemTypes.URL;
		
		private var _manifests:Array;
		
		private var _externalResourceController		:ExternalResourceController;
		
		public function CadetStartUpOperationBase( cadetFileURL:String, fileSystemType:String = "url" )
		{
			this.cadetFileURL = cadetFileURL;
			this.fileSystemType = fileSystemType;
			
			// Initialise the CoreApp (resourceManager, fileSystemProvider)
			CoreApp.init();
			
			_manifests = [];
			
			addManifest( baseManifestURL + "Core.xml");
			addManifest( baseManifestURL + "Cadet.xml");
		}
		
		public function addManifest( url:String ):void
		{
			_manifests.push( url );
		}
		
		public function addResource( resource:IResource ):void
		{
			CoreApp.resourceManager.addResource( resource );
		}
		
		override public function execute():void
		{
			var assetsURI:URI;
			
			if ( fileSystemType == FileSystemTypes.LOCAL ) {
				CoreApp.fileSystemProvider.registerFileSystemProvider( new LocalFileSystemProvider(fspLocalID, fspLocalID, File.applicationDirectory, File.applicationDirectory ) );
				assetsURI = new URI(fspLocalID+"/"+baseURL+"/"+CoreApp.externalResourceFolderName);
			}
			else if ( fileSystemType == FileSystemTypes.URL ) {
				CoreApp.fileSystemProvider.registerFileSystemProvider( new URLFileSystemProvider( fspURLID, fspURLID, baseURL ) );
				assetsURI = new URI(fspURLID+"/"+CoreApp.externalResourceFolderName);			
			}	
			
			// Create an ExternalResourceController to monitor external resources
			_externalResourceController = new ExternalResourceController( CoreApp.resourceManager, assetsURI, CoreApp.fileSystemProvider );
			_externalResourceController.addEventListener( Event.COMPLETE, resourcesAddedHandler );
		}
		
		private function resourcesAddedHandler( event:Event ):void
		{
			// Specify which manifests to load
			var config:XML = createConfigXML();
			
			// Load manifests
			var loadManifestsOperation:LoadManifestsOperation = new LoadManifestsOperation(config.manifest);
			addOperation(loadManifestsOperation);
			
			if ( cadetFileURL ) {
				// Read and deserialize the Cadet XML into a CadetScene
				var uri:URI = new URI(fspURLID+cadetFileURL);
				readAndDeserializeOperation = new ReadCadetFileAndDeserializeOperation( uri, CoreApp.fileSystemProvider, CoreApp.resourceManager );
				addOperation(readAndDeserializeOperation);
			}
			super.execute();
		}
		
		protected function createConfigXML():XML
		{
			var configXMLStr:String = "<xml>"
			
			for ( var i:uint = 0; i < _manifests.length; i ++ ) {
				var manifestURL:String = _manifests[i];
				configXMLStr += "<manifest><url><![CDATA["+manifestURL+"]]></url></manifest>";
			}
			configXMLStr += "</xml>";
			var config:XML = new XML(configXMLStr);
			
			return config;
		}
		
		public function getResult():ICadetScene
		{
			return readAndDeserializeOperation ? readAndDeserializeOperation.getResult() : null;
		}
	}
}