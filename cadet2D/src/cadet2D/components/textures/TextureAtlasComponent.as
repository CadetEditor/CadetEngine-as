package cadet2D.components.textures
{
	import cadet.core.Component;
	
	import starling.textures.TextureAtlas;
	
	public class TextureAtlasComponent extends Component
	{
		protected var ATLAS				:String = "atlas";
		
		private var _textureAtlas		:TextureAtlas;
		private var _textureComponent	:TextureComponent;
		private var _xml				:XML;
		
		private var _atlas				:TextureAtlas;
		
		public function TextureAtlasComponent()
		{
			super();
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor", extensions="[xml]")]
		public function set xml( value:XML ):void
		{
			_xml = value;
			invalidate( ATLAS );
		}
		public function get xml():XML { return _xml; }
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene" )]
		public function set texture( value:TextureComponent ):void
		{
			_textureComponent = value;
			invalidate( ATLAS );
		}
		public function get texture():TextureComponent { return _textureComponent; }
		
		
		override public function validateNow():void
		{
			if ( isInvalid(ATLAS) )
			{
				validateAtlas();
			}
			
			super.validateNow();
		}
		
		protected function validateAtlas():void
		{
			if (!_textureComponent || !_textureComponent.texture ) {
				return;
			}
			
			_atlas = new TextureAtlas(_textureComponent.texture, _xml );
		}
		
		public function get atlas():TextureAtlas
		{
			return _atlas;
		}
	}
}