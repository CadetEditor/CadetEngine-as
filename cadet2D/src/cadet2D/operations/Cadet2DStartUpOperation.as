// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// For use when loading CadetScenes outside of the CadetEditor, e.g. in a Flash Builder project.
package cadet2D.operations
{
	import cadet.operations.CadetStartUpOperationBase;
	import cadet.operations.ReadCadetFileAndDeserializeOperation;
	
	import core.app.CoreApp;
	import core.app.controllers.ExternalResourceController;
	import core.app.entities.URI;
	import core.app.managers.fileSystemProviders.url.URLFileSystemProvider;
	import core.app.operations.LoadManifestsOperation;
	
	public class Cadet2DStartUpOperation extends CadetStartUpOperationBase
	{		
		public function Cadet2DStartUpOperation( cadetFileURL:String )
		{
			super(cadetFileURL);
			
			addManifest( baseManifestURL + "Flox.xml");
			addManifest( baseManifestURL + "Cadet.xml");
			addManifest( baseManifestURL + "Cadet2D.xml");
		}
		
		override public function execute():void
		{
			// Initialise the CoreApp (resourceManager, fileSystemProvider)
			CoreApp.init();
			
			// Register a URLFileSystemProvider with the CoreApp
			CoreApp.fileSystemProvider.registerFileSystemProvider( new URLFileSystemProvider( fspID, fspID, baseURL ) );
			
			// Create an ExternalResourceController to monitor external resources
			new ExternalResourceController( CoreApp.resourceManager, new URI(fspID+"/"+assetsURL), CoreApp.fileSystemProvider );
			
			// Specify which manifests to load
			var config:XML = createConfigXML();
			
			// Load manifests
			var loadManifestsOperation:LoadManifestsOperation = new LoadManifestsOperation(config.manifest);
			addOperation(loadManifestsOperation);
			
			// Read and deserialize the Cadet XML into a CadetScene
			var uri:URI = new URI(fspID+cadetFileURL);
			readAndDeserializeOperation = new ReadCadetFileAndDeserializeOperation( uri, CoreApp.fileSystemProvider, CoreApp.resourceManager );
			addOperation(readAndDeserializeOperation);
			
			super.execute();
		}
	}
}











