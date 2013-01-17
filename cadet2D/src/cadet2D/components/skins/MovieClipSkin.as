package cadet2D.components.skins
{
	import cadet.events.InvalidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.textures.TextureAtlasComponent;
	import cadet2D.util.NullBitmapTexture;
	
	import starling.display.DisplayObjectContainer;
	import starling.display.MovieClip;
	import starling.textures.Texture;

	public class MovieClipSkin extends AbstractSkin2D
	{
		private static const TEXTURES		:String = "textures";
		private static const ANIMATE		:String = "animate";
		
		private var _movieclip				:MovieClip;
		
		private var _textureAtlas			:TextureAtlasComponent;
		private var _texturesPrefix			:String;
		
		private var _animate				:Boolean;
		private var _animateDirty			:Boolean;
		
		public function MovieClipSkin(textures:Vector.<Texture> = null)
		{
			if (!textures) {
				//var textures:Vector.<Texture>
				textures = new Vector.<Texture>();
				textures.push(NullBitmapTexture.instance);
			}
			
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
		public function set animate( value:Boolean ):void
		{
			_animate = value;
			
			invalidate( ANIMATE );
		}
		public function get animate():Boolean
		{
			return _animate;
		}
		
		override public function validateNow():void
		{
			if ( _animateDirty ) {
				invalidate( ANIMATE );
			}
			
			if ( isInvalid(TEXTURES) )
			{
				validateTextures();
			}
			if ( isInvalid(ANIMATE) )
			{
				validateAnimate();
			}
			
			super.validateNow();
		}
		
		protected function validateTextures():void
		{
			if (!_textureAtlas || !_textureAtlas.atlas || !_texturesPrefix ) {
				return;
			}
			
			if ( displayObject is DisplayObjectContainer ) {
				var displayObjectContainer:DisplayObjectContainer = DisplayObjectContainer(displayObject);
			}
			if ( _movieclip && displayObjectContainer && displayObjectContainer.contains(_movieclip) ) {
				displayObjectContainer.removeChild(_movieclip);
			}
			
			var textures:Vector.<Texture> = _textureAtlas.atlas.getTextures(_texturesPrefix);
			
			if (!textures || textures.length == 0) return;
			
			_movieclip = new MovieClip(textures);
			
			if (displayObjectContainer) {
				displayObjectContainer.addChild(_movieclip);
			}
		}
		
		private function validateAnimate():void
		{
			var renderer:Renderer2D = ComponentUtil.getChildOfType(scene, Renderer2D, true);
			if ( !renderer || !_movieclip ) {
				_animateDirty = true;
				return;
			}
			
			if ( _animate ) {
				renderer.addToJuggler( this );
			} else {
				renderer.removeFromJuggler( this );
			}
			
			_animateDirty = false;
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








