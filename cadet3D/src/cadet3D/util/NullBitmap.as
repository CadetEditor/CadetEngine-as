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
	import flash.display.BitmapData;

	public class NullBitmap
	{
		[Embed(source="NullBitmap.png")]
		private static var NullBitmap	:Class;
		private static var _instance	:BitmapData;
		
		public static function get instance():BitmapData
		{
			if ( _instance == null )
			{
				_instance = new NullBitmap().bitmapData;
			}
			return _instance;
		}
	}
}