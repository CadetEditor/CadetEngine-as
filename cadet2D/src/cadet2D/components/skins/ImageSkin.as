// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.skins
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.util.NullBitmapTexture;
	
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class ImageSkin extends AbstractSkin2D
	{
		protected var ASSET				:String = "asset";
		
		private var _textureComponent		:TextureComponent;
		private var _fillXOffset		:Number = 0;
		private var _fillYOffset		:Number = 0;
		
		private var image		:Image;
		// DEPRECATED
		private var _fillBitmap			:BitmapData;
		
		public function ImageSkin()
		{
			name = "AssetSkin";
			
//			image = new Image(NullBitmapTexture.instance);
//			_displayObject = image;
		}		
		
		[Serializable][Inspectable]
		public function set fillXOffset( value:Number ):void
		{
			_fillXOffset = value;
			invalidate( ASSET );
		}
		public function get fillXOffset():Number { return _fillXOffset; }
		
		[Serializable][Inspectable]
		public function set fillYOffset( value:Number ):void
		{
			_fillYOffset = value;
			invalidate( ASSET );
		}
		public function get fillYOffset():Number { return _fillYOffset; }
		
		//TODO: This needs to be deprecated in favour of "fillTexture"
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set fillBitmap( value:BitmapData ):void
		{
			_fillBitmap = value;
			invalidate( ASSET );
		}
		public function get fillBitmap():BitmapData { return _fillBitmap; }	
		
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene" )]
		public function set textureComponent( value:TextureComponent ):void
		{
			_textureComponent = value;
			invalidate( ASSET );
		}
		public function get textureComponent():TextureComponent { return _textureComponent; }	
		
		
		override public function validateNow():void
		{
			if ( isInvalid(ASSET) )
			{
				validateAsset();
			}
			
			super.validateNow();
		}
		
		protected function validateAsset():void
		{
			if ( displayObject is DisplayObjectContainer ) {
				var displayObjectContainer:DisplayObjectContainer = DisplayObjectContainer(displayObject);
			}
			if ( image && displayObjectContainer && displayObjectContainer.contains(image) ) {
				displayObjectContainer.removeChild(image);
			}
			
			if (!Starling.context) return;
			
			var texture:Texture;
			if ( _textureComponent ) {
				texture = _textureComponent.texture;
			}
			else if ( _fillBitmap ) {
				texture = Texture.fromBitmap( new Bitmap(_fillBitmap), false );
			}
			
			if (!texture) return;
			
//			image.texture = texture;
//			image.width = texture.width;
//			image.height = texture.height;
			
			image = new Image(texture);
			image.x = _fillXOffset;
			image.y = _fillYOffset;
			
			if (displayObjectContainer) {
				displayObjectContainer.addChild(image);
			}
		}		
	}
}









