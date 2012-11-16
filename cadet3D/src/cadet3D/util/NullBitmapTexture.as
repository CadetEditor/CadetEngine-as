// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.util
{
	import away3d.textures.BitmapTexture;

	public class NullBitmapTexture
	{
		private static var _instance	:BitmapTexture;
		
		public static function get instance():BitmapTexture
		{
			if ( _instance == null )
			{
				_instance = new BitmapTexture( NullBitmap.instance );
			}
			return _instance;
		}
	}
}