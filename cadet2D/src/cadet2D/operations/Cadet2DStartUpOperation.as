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

	public class Cadet2DStartUpOperation extends CadetStartUpOperationBase
	{		
		public function Cadet2DStartUpOperation( cadetFileURL:String = null, fileSystemType:String = "url" )
		{
			super(cadetFileURL, fileSystemType);
			
			addManifest( baseManifestURL + "Cadet2D.xml");
		}
	}
}











