package cadet.components.processes
{
	import cadet.components.sounds.ISound;
	import cadet.components.sounds.SoundComponent;
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.core.IInitialisableComponent;
	import cadet.events.ComponentEvent;
	import cadet.util.ComponentUtil;
	
	public class SoundProcess extends Component implements IInitialisableComponent
	{
		private var _music			:SoundComponent;
		private var soundArray		:Array;
		
		public function SoundProcess()
		{
			soundArray = new Array();
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
			if ( _music ) {
				_music.play();
			}
		}
		
		// -------------------------------------------------------------------------------------
		// INSPECTABLE API
		// -------------------------------------------------------------------------------------
		
		[Serializable][Inspectable( priority="50", editor="ComponentList", scope="scene" )]
		public function set music( value:SoundComponent ):void
		{
			_music = value;
		}
		public function get music():SoundComponent
		{
			return _music;
		}
		
		// -------------------------------------------------------------------------------------
		
		private function addSounds():void
		{
			var allSounds:Vector.<IComponent> = ComponentUtil.getChildrenOfType( scene, ISound, true );
			for each ( var skin:ISound in allSounds )
			{
				addSound( skin );
			}
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















