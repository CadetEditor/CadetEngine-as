// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.resources
{
	import core.app.controllers.IExternalResourceParser;
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.entities.URI;
	import core.app.managers.ResourceManager;
	import core.app.resources.ExternalXMLResource;
	import core.app.resources.IExternalResource;

	public class ExternalXMLResourceParser implements IExternalResourceParser
	{
		private var uri				:URI;
		private var resourceManager	:ResourceManager;
		
		public function ExternalXMLResourceParser()
		{
		}
		
		public function parse(uri:URI, assetsURI:URI, resourceManager:ResourceManager, fileSystemProvider:IFileSystemProvider):Array
		{
			this.uri = uri;
			this.resourceManager = resourceManager;
			
			var extension:String = uri.getExtension(true);
			var resourceID:String = uri.path;
			if ( resourceID.indexOf(assetsURI.path) != -1 ) {
				resourceID = resourceID.replace(assetsURI.path, "");
			}
			
			var resource:IExternalResource;
			switch ( extension )
			{
				case "pex" :
					resource = new ExternalXMLResource( resourceID, uri );
					resourceManager.addResource(resource);
					return [resource];
			}
			
			return null;
		}
	}
}