package cadet.components.processes
{
	import flash.media.SoundMixer;
	
	import cadet.components.sounds.ISound;
	import cadet.components.sounds.SoundComponent;
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.core.IInitialisableComponent;
	import cadet.events.ComponentEvent;
	import cadet.util.ComponentUtil;
	
	public class SoundProcess extends Component implements IInitialisableComponent
	{
		private const SOUNDS		:String = "sounds";
		
		private var _muted			:Boolean = false;
		private var _musicPlaying	:Boolean = false;
		private var _initialised	:Boolean = false;
		private var _music			:SoundComponent;
		private var soundArray		:Array;
		
		public function SoundProcess(name:String = "SoundProcess")
		{
			soundArray = new Array();
			super(name);
		}
		
		override protected function addedToScene():void
		{
			scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedToSceneHandler);
			scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedFromSceneHandler);
			
			addSounds();
		}
		
		//IInitialisableComponent
		public function init():void
		{
			_initialised = true;
			invalidate( SOUNDS );
		}
		
		// -------------------------------------------------------------------------------------
		// INSPECTABLE API
		// -------------------------------------------------------------------------------------
		
		[Serializable][Inspectable( priority="50" )]
		public function set muted( value:Boolean ):void
		{
			_muted = value;
			
			invalidate( SOUNDS );
		}
		public function get muted():Boolean
		{
			return _muted;
		}
		
		[Serializable][Inspectable( priority="51", editor="ComponentList", scope="scene" )]
		public function set music( value:SoundComponent ):void
		{
			_music = value;
		}
		public function get music():SoundComponent
		{
			return _music;
		}
		
		// -------------------------------------------------------------------------------------
		
		override public function validateNow():void
		{
			var soundsInvalid:Boolean = false;
			if ( isInvalid(SOUNDS) ) {
				soundsInvalid = true;
				//dispatchEvent( new InvalidationEvent( InvalidationEvent.INVALIDATE ) );
			}
			
			super.validateNow();
			
			if ( soundsInvalid ) {
				validateSounds();
			}
		}
		
		private function validateSounds():void
		{
			if ( !_initialised ) return;
			
			if ( !_muted ) {
				if ( _music && !_musicPlaying ) {
					_musicPlaying = _music.play();
					if (!_musicPlaying) {
						invalidate(SOUNDS);
					}
				}				
			} else {
				if ( _music && _musicPlaying ) {
					_musicPlaying = false;
					_music.stop();
				}
			}
		}
		
		public function playSound( sound:ISound ):void
		{
			if ( muted ) return;
			if ( sound == _music ) {
				if ( _musicPlaying ) return;
				else _musicPlaying = true;
			}
			
			sound.play();
		}
		
		public function stopSound( sound:ISound ):void
		{
			sound.stop();
			
			if ( sound == music ) {
				_musicPlaying = false;
			}
		}
		
		private function addSounds():void
		{
			var allSounds:Vector.<IComponent> = ComponentUtil.getChildrenOfType( scene, ISound, true );
			for each ( var sound:ISound in allSounds )
			{
				addSound( sound );
			}
		}
		
		override public function dispose():void
		{
			SoundMixer.stopAll();
			
			for each ( var sound:ISound in soundArray ) {
				sound.stop();
			}
			
			super.dispose();
		}
		
		private function componentAddedToSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is ISound == false ) return;
			addSound( ISound( event.component ) );
		}
		
		private function componentRemovedFromSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is ISound == false ) return;
			removeSound( ISound( event.component ) );
		}
		
		private function addSound( sound:ISound ):void
		{
			var i:int = soundArray.indexOf(sound);
			if (i == -1)	soundArray.push(sound);
		}
		
		private function removeSound( sound:ISound ):void
		{
			var i:int = soundArray.indexOf(sound);
			if (i != -1)	soundArray.splice(i, 1);
		}
	}
}















