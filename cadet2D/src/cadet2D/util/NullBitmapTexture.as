package cadet2D.util
{
	import flash.display.Bitmap;
	
	import cadet.util.NullBitmap;
	
	import starling.textures.Texture;

	public class NullBitmapTexture
	{
		private static var _instance	:Texture;
		
		public static function get instance():Texture
		{
			if ( _instance == null )
			{
				_instance = Texture.fromBitmap( new Bitmap(NullBitmap.instance), false );
			}
			return _instance;
		}
	}
}