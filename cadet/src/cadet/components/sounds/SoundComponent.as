package cadet.components.sounds
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import cadet.core.Component;
	
	public class SoundComponent extends Component implements ISound
	{
		private var _asset		:Sound;
		private var _channel	:SoundChannel;
		
		private var _startTime:Number = 0;
		private var _loops:uint = 0;
		private var _soundTransform:SoundTransform = null;
		
		public function SoundComponent( name:String = "SoundComponent" )
		{
			super(name);	
		}
		
		// -------------------------------------------------------------------------------------
		// INSPECTABLE API
		// -------------------------------------------------------------------------------------
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor", extensions="[mp3]")]
		public function set asset( value:Sound ):void
		{
			_asset = value;
		}
		public function get asset():Sound { return _asset; }
		
		public function play():Boolean
		{
			if (!_asset) return false;
			
			_channel = _asset.play(_startTime, _loops, _soundTransform);
			
			return true;
		}
		
		public function stop():void
		{
			if ( _channel ) {
				_channel.stop();
			}
		}
		
		[Serializable][Inspectable]
		public function set startTime( value:Number ):void
		{
			_startTime = value;
		}
		public function get startTime():Number { return _startTime; }
		
		[Serializable][Inspectable]
		public function set loops( value:Number ):void
		{
			_loops = value;
		}
		public function get loops():Number { return _loops; }
		
		// -------------------------------------------------------------------------------------
		
	}
}










