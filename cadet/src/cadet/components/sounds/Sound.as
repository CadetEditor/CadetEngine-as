package cadet.components.sounds
{
	import cadet.core.Component;
	
	public class Sound extends Component
	{
		private var _asset	:Object;
		
		public function Sound()
		{
			super();
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor", extensions="[mp3]")]
		public function set asset( value:Object ):void
		{
			_asset = value;
			//invalidate( ATLAS );
		}
		public function get asset():Object { return _asset; }
	}
}