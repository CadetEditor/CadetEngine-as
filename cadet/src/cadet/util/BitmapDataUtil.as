// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.util
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public class BitmapDataUtil
	{
		/**
		 * Checks if the input bitmap is a valid texture (power of two width/height), if it it simply returns it.
		 * If not, will create a new bitmap resized to closest power of two.
		*/
		public static function makePowerOfTwo( bitmapData:BitmapData, forceSquare:Boolean = false ):BitmapData
		{
			if ( bitmapData == null ) return null;
			
			var width:int = TextureUtils.getBestPowerOf2( bitmapData.width );
			var height:int = TextureUtils.getBestPowerOf2( bitmapData.height );
			
			if ( forceSquare )
			{
				width = height = Math.max(width,height);
			}
			
			if ( bitmapData.width == width && bitmapData.height == height ) return bitmapData;
			
			var resizedBitmapData:BitmapData = new BitmapData(width, height, bitmapData.transparent, 0);
			
			var m:Matrix = new Matrix();
			m.scale( width / bitmapData.width, height / bitmapData.height );
			resizedBitmapData.draw( bitmapData, m );
			
			return resizedBitmapData;
		}
	}
}