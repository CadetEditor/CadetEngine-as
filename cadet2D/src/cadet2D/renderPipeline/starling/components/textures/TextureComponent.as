// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.renderPipeline.starling.components.textures
{
	import cadet.core.Component;
	
	import flash.display.Bitmap;
	
	import starling.textures.Texture;
	
	public class TextureComponent extends Component
	{
		private var _asset:Bitmap;
		private var _texture:Texture;
		
		public function TextureComponent()
		{
			super();
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set asset( value:Bitmap ):void
		{
			_asset = value;
			_texture = Texture.fromBitmap( value, false );
		}
		public function get asset():Bitmap { return _asset; }
		
		public function get texture():Texture
		{
			return _texture;
		}
	}
}