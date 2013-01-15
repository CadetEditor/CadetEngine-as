package cadet2D.components.skins
{
	import cadet2D.util.NullBitmapTexture;
	
	import starling.display.MovieClip;
	import starling.textures.Texture;

	public class MovieClipSkin extends AbstractSkin2D
	{
		private var movieclip:MovieClip;
		
		public function MovieClipSkin(textures:Vector.<Texture> = null)
		{
			if (!textures) {
				//var textures:Vector.<Texture>
				textures = new Vector.<Texture>();
				textures.push(NullBitmapTexture.instance);
			}
			
			movieclip = new MovieClip(textures);
			_displayObject = movieclip;
		}
	}
}