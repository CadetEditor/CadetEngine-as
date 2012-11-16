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
	import away3d.textures.BitmapCubeTexture;
	
	public class NullBitmapCubeTexture
	{
		private static var _instance		:BitmapCubeTexture;
		
		public static function get instance():BitmapCubeTexture
		{
			if ( _instance == null )
			{
				_instance = getCopy();
			}
			return _instance;
		}
		
		public static function getCopy():BitmapCubeTexture
		{
			return new BitmapCubeTexture( NullBitmap.instance, NullBitmap.instance, NullBitmap.instance, NullBitmap.instance, NullBitmap.instance, NullBitmap.instance );
		}
	}
}