// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Inspectable Priority range 100-149

package cadet2D.components.skins
{	
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.textures.TextureAtlasComponent;
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.events.SkinEvent;
	
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.textures.Texture;
	
	public class ImageSkin extends AbstractSkin2D
	{
		private static const TEXTURE		:String = "texture";
		
		protected var _texture				:TextureComponent;
		
		protected var _quad					:Quad;
		
		protected var _textureAtlas			:TextureAtlasComponent;
		protected var _texturesPrefix		:String;
		
		protected var _textureDirty			:Boolean;
		
		public function ImageSkin( name:String = "ImageSkin" )
		{
			super(name);
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="100" )]
		public function set textureAtlas( value:TextureAtlasComponent ):void
		{
			if ( _textureAtlas ) {
				_textureAtlas.removeEventListener(InvalidationEvent.INVALIDATE, invalidateAtlasHandler);
			}
			_textureAtlas = value;
			if ( _textureAtlas ) {
				_textureAtlas.addEventListener(InvalidationEvent.INVALIDATE, invalidateAtlasHandler);
			}
			// textureAtlas & texture are mutually exclusive values
			if (value)	_texture = null;
			invalidate( TEXTURE );
		}
		public function get textureAtlas():TextureAtlasComponent
		{
			return _textureAtlas;
		}
		
		[Serializable][Inspectable( priority="101" )]
		public function set texturesPrefix( value:String ):void
		{
			_texturesPrefix = value;
			invalidate( TEXTURE );
		}
		public function get texturesPrefix():String
		{
			return _texturesPrefix;
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="102" )]
		public function set texture( value:TextureComponent ):void
		{
			_texture = value;
			// textureAtlas & texture are mutually exclusive values
			if (value) {
				_textureAtlas = null;
				_texturesPrefix = null;
			}
			invalidate( TEXTURE );
		}
		public function get texture():TextureComponent { return _texture; }	
		
		
		override public function validateNow():void
		{
			if ( _textureDirty ) {
				invalidate(TEXTURE);
			}
			
			if ( isInvalid(TEXTURE) )
			{
				validateTexture();
			}
			
			super.validateNow();
		}
		
		override protected function validateDisplay():void
		{
			_displayObject.width = _width;
			_displayObject.height = _height;
		}
		
		protected function getTextures():Vector.<Texture>
		{
			var textures:Vector.<Texture> = new Vector.<Texture>();
			if ( _texture && _texture.texture ) {
				textures.push(_texture.texture);
			} else if ( _textureAtlas && _textureAtlas.atlas && _texturesPrefix ) {
				textures = _textureAtlas.atlas.getTextures(_texturesPrefix);
			}
			
			return textures;
		}
		
		protected function validateTexture():void
		{
			// Remove existing asset first
			if ( displayObject is DisplayObjectContainer ) {
				var displayObjectContainer:DisplayObjectContainer = DisplayObjectContainer(displayObject);
			}
			if ( _quad && displayObjectContainer && displayObjectContainer.contains(_quad) ) {
				displayObjectContainer.removeChild(_quad);
			}
			
			// If textureAtlas and texture are null, quit out having removed the quad.
			if (!_textureAtlas && !_texture) {
				return;
			}
			
			var textures:Vector.<Texture>;
			
			// If a texture has been set, check whether it's been validated,
			// if so, set textures Vector, if not, try again next time
			if (_texture) {
				if (_texture.texture) {
					textures = new Vector.<Texture>();
					textures.push(_texture.texture);	
				} else {
					_textureDirty = true;
					return;
				}
			}
			// Else if there isn't a texture set and their is a textureAtlas set, but it's not been validated,
			// or if there's no texturesPrefix, try again next time
			else if ((_textureAtlas && !_textureAtlas.atlas) || !_texturesPrefix ) {
				_textureDirty = true;
				return;
			} 
			// Else if there's both a textureAtlas and a texturesPrefix, set the textures Vector.
			else if (_textureAtlas) {
				textures = _textureAtlas.atlas.getTextures(_texturesPrefix);
			}
			
			// If the result of the above is no textures, quit out.
			if (!textures || textures.length == 0) return;
			
			//_quad = new Image(textures[0]);
			_quad = createQuad(textures);
			
			if (displayObjectContainer) {
				displayObjectContainer.addChild(_quad);
				// set default width and height
				//if (!_width) 	
				_width = _quad.width;
				//if (!_height) 	
				_height = _quad.height;				
			}
			
			_textureDirty = false;
			
			// Useful when not using editor as validation is not immediate
			dispatchEvent(new SkinEvent(SkinEvent.TEXTURE_VALIDATED));
		}

		protected function createQuad(textures:Vector.<Texture>):Quad
		{
			return new Image(textures[0]);
		}
		
		private function invalidateAtlasHandler( event:InvalidationEvent ):void
		{
			invalidate( TEXTURE );
		}
		
		override public function clone():IRenderable
		{
			var newSkin:ImageSkin = new ImageSkin();
			newSkin.rotation = _rotation;
			newSkin.scaleX = _scaleX;
			newSkin.scaleY = _scaleY;
			newSkin.texture = _texture;
			newSkin.textureAtlas = _textureAtlas;
			newSkin.texturesPrefix = _texturesPrefix;
			newSkin.touchable = _displayObject.touchable;
			newSkin.transform2D = _transform2D;
			newSkin.x = _x;
			newSkin.y = _y;
			newSkin.width = _width;
			newSkin.height = _height;
			return newSkin;
		}
		
		public function get quad():Quad
		{
			return _quad;
		}
	}
}









