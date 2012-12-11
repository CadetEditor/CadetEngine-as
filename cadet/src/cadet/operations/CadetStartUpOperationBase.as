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
	import cadet.core.ICadetScene;
	
	import flox.app.operations.CompoundOperation;
	
	public class CadetStartUpOperationBase extends CompoundOperation
	{
		protected var readAndDeserializeOperation:ReadCadetFileAndDeserializeOperation;
		
		protected var fspID:String = "cadet.url"; // FileSystemProvider ID: URL FSP assumed. 
		public var baseURL:String = "files";
		public var assetsURL:String = "assets/";
		public var cadetFileURL:String;
		public var baseManifestURL:String = "extensions/manifests/";
		
		private var _manifests:Array;
		
		public function CadetStartUpOperationBase( cadetFileURL:String )
		{
			this.cadetFileURL = cadetFileURL;
			
			_manifests = [];
		}
		
		public function addManifest( url:String ):void
		{
			_manifests.push( url );
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
			return readAndDeserializeOperation.getResult();
		}
	}
}