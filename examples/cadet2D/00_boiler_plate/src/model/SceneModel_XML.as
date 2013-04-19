package model
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import cadet.core.CadetScene;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	
	public class SceneModel_XML implements ISceneModel
	{
		private var _parent			:DisplayObject;
		private var _cadetScene		:CadetScene;
		
		public function SceneModel_XML()
		{
		}
		
		public function init(parent:DisplayObject):void
		{
			_parent = parent;
			
			// Grab a reference to the Renderer2D and enable it
			var renderer:Renderer2D = ComponentUtil.getChildOfType(_cadetScene, Renderer2D);
			renderer.enable(parent);
			
			_parent.addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		public function get cadetScene():CadetScene
		{
			return _cadetScene;
		}
		
		public function set cadetScene(value:CadetScene):void
		{
			_cadetScene = value;
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			_cadetScene.step();
		}
	}
}