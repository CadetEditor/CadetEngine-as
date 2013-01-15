package cadet2D.components.textures
{
	import cadet.core.Component;
	
	import starling.textures.TextureAtlas;
	
	public class TextureAtlasComponent extends Component
	{
		protected var ASSET				:String = "asset";
		
		private var _textureAtlas		:TextureAtlas;
		private var _textureComponent	:TextureComponent;
		private var _xml				:XML;			
		
		public function TextureAtlasComponent()
		{
			super();
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor", extensions="[xml]")]
		public function set xml( value:XML ):void
		{
			_xml = value;
			invalidate( ASSET );
		}
		public function get xml():XML { return _xml; }
		
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

		}
	}
}