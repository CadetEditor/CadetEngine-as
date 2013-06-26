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
	
	import cadet.util.BitmapDataUtil;
	
	import cadet.util.NullBitmap;
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	
	import flash.geom.Point;
	
	public class BitmapTextureComponent extends AbstractTexture2DComponent
	{
		private var _bitmapTexture	:BitmapTexture
		private var _bitmapData		:BitmapData;
		private var _bitmapDataSrc	:BitmapData;
		private var _alphaChannel	:String = "alpha";
		
		public function BitmapTextureComponent()
		{
			_texture2D = _bitmapTexture = new BitmapTexture(NullBitmap.instance);
		}
		
		[Serializable][Inspectable( priority="100", editor="DropDownMenu", dataProvider="[RED,GREEN,BLUE,ALPHA]" )]
		public function set alphaChannel( value:String ):void
		{
			_alphaChannel = value;
			updateTexture();
		}
		public function get alphaChannel():String
		{
			return _alphaChannel;
		}
		
		[Serializable( type="resource" )][Inspectable( priority="101", editor="ResourceItemEditor") ]
		public function set bitmapData( value:BitmapData ):void
		{
			_bitmapDataSrc = value;
//			_bitmapTexture.bitmapData = BitmapDataUtil.makePowerOfTwo(value) || NullBitmap.instance;
			_bitmapData = value;
			updateTexture();
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		private function updateTexture():void
		{
			var channel:uint;
			if ( _alphaChannel == "RED" ) channel = 1;
			else if ( _alphaChannel == "GREEN" ) channel = 2;
			else if ( _alphaChannel == "BLUE" ) channel = 4;
			else if ( _alphaChannel == "ALPHA" ) channel = 8;
			
			if (!_bitmapData) return;
			
			var bmpd:BitmapData = _bitmapDataSrc;
			
			if ( channel ) {
				bmpd = new BitmapData(_bitmapDataSrc.width, _bitmapDataSrc.height, true, 0xFFFFFFFF);
				bmpd.copyChannel(_bitmapDataSrc, bmpd.rect, new Point(), channel, BitmapDataChannel.ALPHA);
			}
			
			_bitmapTexture.bitmapData = BitmapDataUtil.makePowerOfTwo(bmpd) || NullBitmap.instance;
			_bitmapData = bmpd;
			invalidate("*");
		}
	}
}