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
	
	import cadet2D.components.textures.TextureAtlasComponent;
	import cadet2D.components.textures.TextureComponent;
	
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class ImageSkin extends AbstractSkin2D
	{
		private static const TEXTURE	:String = "texture";
		
		private var _textureComponent		:TextureComponent;
/*		private var _fillXOffset		:Number = 0;
		private var _fillYOffset		:Number = 0;*/
		
		private var image					:Image;
		
		private var _textureAtlas			:TextureAtlasComponent;
		private var _texturesPrefix			:String;
		
		// DEPRECATED
		//private var _fillBitmap			:BitmapData;
		private var _imageDirty				:Boolean;
		
		public function ImageSkin()
		{
			name = "ImageSkin";
			
//			image = new Image(NullBitmapTexture.instance);
//			_displayObject = image;
		}		
/*		
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
*/		
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene" )]
		public function set textureAtlas( value:TextureAtlasComponent ):void
		{
			if ( _textureAtlas ) {
				_textureAtlas.removeEventListener(InvalidationEvent.INVALIDATE, invalidateAtlasHandler);
			}
			_textureAtlas = value;
			if ( _textureAtlas ) {
				_textureAtlas.addEventListener(InvalidationEvent.INVALIDATE, invalidateAtlasHandler);
			}
			
			invalidate( TEXTURE );
		}
		public function get textureAtlas():TextureAtlasComponent
		{
			return _textureAtlas;
		}
		
		[Serializable][Inspectable]
		public function set texturesPrefix( value:String ):void
		{
			_texturesPrefix = value;
			invalidate( TEXTURE );
		}
		public function get texturesPrefix():String
		{
			return _texturesPrefix;
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene" )]
		public function set texture( value:TextureComponent ):void
		{
			_textureComponent = value;
			invalidate( TEXTURE );
		}
		public function get texture():TextureComponent { return _textureComponent; }	
		
		
		override public function validateNow():void
		{
			if ( _imageDirty ) {
				invalidate(TEXTURE);
			}
			
			if ( isInvalid(TEXTURE) )
			{
				validateTexture();
			}
			
			super.validateNow();
		}
		
		protected function validateTexture():void
		{
			var texture:Texture;
			
			if ( _textureAtlas && _textureAtlas.atlas ) {
				var textures:Vector.<Texture> = _textureAtlas.atlas.getTextures(_texturesPrefix);
				if (textures.length > 0)	texture = textures[0];
			} else if ( _textureComponent ) {
				texture = _textureComponent.texture;
			}
			
			// If Starling isn't ready, wait until it is, then try and validateAsset() again.
			// Else, if the user has selected a TextureComponent and that TextureComponent doesn't have a Texture,
			// Assume that the Texture is yet to load its BitmapData in order to initialise, so the ImageSkin should
			// wait for this to happen before validateAsset().
			if (!Starling.context || (_textureComponent && !texture)) {
				_imageDirty = true;
				return;
			}
			
			if ( displayObject is DisplayObjectContainer ) {
				var displayObjectContainer:DisplayObjectContainer = DisplayObjectContainer(displayObject);
			}
			if ( image && displayObjectContainer && displayObjectContainer.contains(image) ) {
				displayObjectContainer.removeChild(image);
			}

//			else if ( _fillBitmap ) {
//				texture = Texture.fromBitmap( new Bitmap(_fillBitmap), false );
//			}
			
//			image.texture = texture;
//			image.width = texture.width;
//			image.height = texture.height;
			
			if (texture) {
				image = new Image(texture);
	//			image.x = _fillXOffset;
	//			image.y = _fillYOffset;
				
				if (displayObjectContainer) {
					displayObjectContainer.addChild(image);
				}
			}
			
			_imageDirty = false;
		}
		
		private function invalidateAtlasHandler( event:InvalidationEvent ):void
		{
			invalidate( TEXTURE );
		}
	}
}









