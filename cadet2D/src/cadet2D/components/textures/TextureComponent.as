// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.textures
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import cadet.core.Component;
	
	import starling.textures.Texture;
	
	public class TextureComponent extends Component
	{
		private var _bitmapData:BitmapData;
		private var _texture:Texture;
		
		public function TextureComponent()
		{
			super();
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set bitmapData( value:BitmapData ):void
		{
			if ( !value ) return;
			
			_bitmapData = value;
			_texture = Texture.fromBitmap( new Bitmap(value), false );
			trace("texture width "+_texture.width+" height "+_texture.height);
		}
		public function get bitmapData():BitmapData { return _bitmapData; }
		
		public function get texture():Texture
		{
			return _texture;
		}
	}
}