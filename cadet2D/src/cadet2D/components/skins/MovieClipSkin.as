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
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.textures.TextureAtlasComponent;
	
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.textures.Texture;

	public class MovieClipSkin extends ImageSkin
	{
		private static const LOOP			:String = "loop";
		
		private var _textureAtlas			:TextureAtlasComponent;
		
		private var _loop					:Boolean;
		private var _fps					:uint;
		// "dirty" vars are for when display list changes are made but Starling isn't ready yet.
		// These vars make sure it keeps on trying.
		private var _loopDirty				:Boolean;
		
		public function MovieClipSkin()
		{
			
		}
		
		[Serializable][Inspectable( priority="100" )]
		public function set loop( value:Boolean ):void
		{
			_loop = value;
			
			invalidate( LOOP );
		}
		public function get loop():Boolean
		{
			return _loop;
		}
		
/*		[Serializable][Inspectable( priority="101" )]
		public function set fps( value:uint ):void
		{
			_fps = value;
			
			invalidate( DISPLAY );
		}
		public function get fps():uint
		{
			return _fps;
		}*/
		
		override public function validateNow():void
		{
			var isInvalidLoop:Boolean = isInvalid(LOOP);
			// clears the invalidationTable
			super.validateNow();
			
			if ( _loopDirty ) {
				invalidate(LOOP);
				isInvalidLoop = true;
			}
			
			if ( isInvalidLoop ) {
				validateLoop();
			}
		}
		
		override protected function createQuad(textures:Vector.<Texture>):Quad
		{
			return new MovieClip(textures);
		}
		
		private function validateLoop():void
		{
			var renderer:Renderer2D = ComponentUtil.getChildOfType(scene, Renderer2D, true);
			if ( !renderer || !_quad ) {
				_loopDirty = true;
				return;
			}
			
			if ( _loop ) {
				renderer.addToJuggler( this );
			} else {
				renderer.removeFromJuggler( this );
			}
			
			_loopDirty = false;
		}
		
		public function get movieclip():MovieClip
		{
			return MovieClip(_quad);
		}
		
		override public function clone():IRenderable
		{
			var newSkin:MovieClipSkin = new MovieClipSkin();
			newSkin.loop = _loop;
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
	}
}








