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
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.geom.RectangleGeometry;
	import cadet2D.components.textures.TextureComponent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class AssetSkin extends AbstractSkin2D
	{
		protected var ASSET				:String = "asset";
		
		private var _fillTexture		:TextureComponent;
		private var _fillXOffset		:Number = 0;
		private var _fillYOffset		:Number = 0;
		
		private var image		:Image;
		// DEPRECATED
		private var _fillBitmap			:BitmapData;
		
		public function AssetSkin()
		{
			name = "AssetSkin";
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
		public function set fillTexture( value:TextureComponent ):void
		{
			_fillTexture = value;
			invalidate( ASSET );
		}
		public function get fillTexture():TextureComponent { return _fillTexture; }	
		
		
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
			if ( image && displayObjectContainer.contains(image) ) {
				displayObjectContainer.removeChild(image);
			}
			
			if (!Starling.context) return;
			
			var texture:Texture;
			if ( _fillTexture ) {
				texture = _fillTexture.texture;
			}
			else if ( _fillBitmap ) {
				texture = Texture.fromBitmap( new Bitmap(_fillBitmap), false );
			}
			
			if (!texture) return;
			
			image = new Image(texture);
			image.x = _fillXOffset;
			image.y = _fillYOffset;
			displayObjectContainer.addChild(image);
		}		
	}
}









