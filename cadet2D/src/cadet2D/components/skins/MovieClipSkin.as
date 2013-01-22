package cadet2D.components.skins
{
	import cadet.events.InvalidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.textures.TextureAtlasComponent;
	
	import starling.display.DisplayObjectContainer;
	import starling.display.MovieClip;
	import starling.textures.Texture;

	public class MovieClipSkin extends AbstractSkin2D
	{
		private static const TEXTURES		:String = "textures";
		private static const LOOP			:String = "loop";
		
		private var _movieclip				:MovieClip;
		
		private var _textureAtlas			:TextureAtlasComponent;
		private var _texturesPrefix			:String;
		
		private var _loop					:Boolean;
		// "dirty" vars are for when display list changes are made but Starling isn't ready yet.
		// These vars make sure it keeps on trying.
		private var _loopDirty				:Boolean;
		private var _texturesDirty			:Boolean;
		
		public function MovieClipSkin()
		{
//			movieclip = new MovieClip(textures);
//			_displayObject = movieclip;
		}
		
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
			
			invalidate( TEXTURES );
		}
		public function get textureAtlas():TextureAtlasComponent
		{
			return _textureAtlas;
		}
		
		[Serializable][Inspectable]
		public function set texturesPrefix( value:String ):void
		{
			_texturesPrefix = value;
			invalidate( TEXTURES );
		}
		public function get texturesPrefix():String
		{
			return _texturesPrefix;
		}
		
		[Serializable][Inspectable]
		public function set loop( value:Boolean ):void
		{
			_loop = value;
			
			invalidate( LOOP );
		}
		public function get loop():Boolean
		{
			return _loop;
		}
		
		override public function validateNow():void
		{
			if ( _loopDirty ) {
				invalidate(LOOP);
			}
			if ( _texturesDirty ) {
				invalidate(TEXTURES);
			}
			
			if ( isInvalid(TEXTURES) )
			{
				validateTextures();
			}
			if ( isInvalid(LOOP) )
			{
				validateAnimate();
			}
			
			super.validateNow();
		}
		
		protected function validateTextures():void
		{
			if ((_textureAtlas && !_textureAtlas.atlas) || !_texturesPrefix ) {
				_texturesDirty = true;
				return;
			}
			
			if ( displayObject is DisplayObjectContainer ) {
				var displayObjectContainer:DisplayObjectContainer = DisplayObjectContainer(displayObject);
			}
			if ( _movieclip && displayObjectContainer && displayObjectContainer.contains(_movieclip) ) {
				displayObjectContainer.removeChild(_movieclip);
			}
			
			// textureAtlas has been set to null, quit out after removing current textures
			if (!_textureAtlas) {
				return;
			}
			
			var textures:Vector.<Texture> = _textureAtlas.atlas.getTextures(_texturesPrefix);
			
			if (!textures || textures.length == 0) return;
			
			_movieclip = new MovieClip(textures);
			
			if (displayObjectContainer) {
				displayObjectContainer.addChild(_movieclip);
			}
			
			_texturesDirty = false;
		}
		
		private function validateAnimate():void
		{
			var renderer:Renderer2D = ComponentUtil.getChildOfType(scene, Renderer2D, true);
			if ( !renderer || !_movieclip ) {
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
		
		private function invalidateAtlasHandler( event:InvalidationEvent ):void
		{
			invalidate( TEXTURES );
		}
		
		public function get movieclip():MovieClip
		{
			return _movieclip;
		}
	}
}








