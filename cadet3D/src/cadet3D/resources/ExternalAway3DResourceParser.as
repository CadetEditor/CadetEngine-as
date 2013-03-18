// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadet3D.resources
{
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.Loader3D;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.MaterialBase;

	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import flox.app.controllers.IExternalResourceParser;
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import flox.app.entities.URI;
	import flox.app.managers.ResourceManager;
	import flox.app.resources.IFactoryResource;
	
	public class ExternalAway3DResourceParser implements IExternalResourceParser
	{
		private var idPrefix			:String;
		private var resourceArray		:Array;
		private var resourceManager		:ResourceManager;
		
		public function ExternalAway3DResourceParser()
		{
			Parsers.enableAllBundled();
		}
		
		public function parse(uri:URI, assetsURI:URI, resourceManager:ResourceManager, fileSystemProvider:IFileSystemProvider):Array
		{
			idPrefix = uri.getFilename(true);
			this.resourceManager = resourceManager;
			resourceArray = [];
			
			var readFileOperation:IReadFileOperation = fileSystemProvider.readFile(uri);
			readFileOperation.addEventListener(Event.COMPLETE, readFileCompleteHandler);
			readFileOperation.execute();
			
			return resourceArray;
		}
		
		private function readFileCompleteHandler( event:Event ):void
		{
			var readFileOperation:IReadFileOperation = IReadFileOperation(event.target);
			
			var bytes:ByteArray = readFileOperation.bytes;
			
			
			var context:AssetLoaderContext = new AssetLoaderContext(false);
			var loader:Loader3D = new Loader3D(false);
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, assetCompleteHandler);
			loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, loadCompleteHandler);
			loader.loadData(bytes, context, null);
		}
		
		private function assetCompleteHandler( event:AssetEvent ):void
		{
			var resource:IFactoryResource;
			var id:String = idPrefix + "." + event.asset.name;
			switch ( event.asset.assetType )
			{
				case AssetType.GEOMETRY :
					resource = new Away3DGeometryResource(id, Geometry(event.asset));
					break;
				case AssetType.MATERIAL :
					resource = new Away3DMaterialResource(id, MaterialBase( event.asset ));
					break;
				case AssetType.MESH :
					resource = new Away3DMeshResource( id, Mesh(event.asset) );
					break;
			}
			
			if ( resource )
			{
				resourceArray.push( resource );
				resourceManager.addResource(resource);
			}
		}
		
		private function loadCompleteHandler( event:LoaderEvent ):void
		{
			var loader:Loader3D = Loader3D( event.target );
			
			var resource:Away3DContainer3DResource = new Away3DContainer3DResource( idPrefix, loader );
			resourceArray.push( resource );
			resourceManager.addResource(resource);
			
			resourceManager = null;
			resourceArray = null;
		}
	}
}