package cadet.components.processes
{
	import cadet.components.sounds.ISound;
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.events.ComponentEvent;
	import cadet.util.ComponentUtil;
	
	public class SoundProcess extends Component
	{
		private var soundArray		:Array;
		
		public function SoundProcess()
		{
			soundArray = new Array();
		}
		
		override protected function addedToScene():void
		{
			scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedToSceneHandler);
			scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedFromSceneHandler);
		}
		
		private function addSkins():void
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















