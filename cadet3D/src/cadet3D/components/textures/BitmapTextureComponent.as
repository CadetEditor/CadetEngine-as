// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.components.textures
{
	import away3d.textures.BitmapTexture;
	import away3d.tools.utils.TextureUtils;
	
	import cadet.core.Component;
	
	import cadet3D.util.BitmapDataUtil;
	import cadet3D.util.NullBitmap;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import spark.utils.BitmapUtil;
	
	public class BitmapTextureComponent extends AbstractTexture2DComponent
	{
		private var _bitmapTexture	:BitmapTexture
		private var _bitmapData		:BitmapData;
		
		public function BitmapTextureComponent()
		{
			_texture2D = _bitmapTexture = new BitmapTexture(NullBitmap.instance);
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set bitmapData( value:BitmapData ):void
		{
			_bitmapTexture.bitmapData = BitmapDataUtil.makePowerOfTwo(value) || NullBitmap.instance;
			_bitmapData = value;
			invalidate("*");
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
	}
}