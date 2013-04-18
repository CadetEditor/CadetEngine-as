package model
{
	import flash.display.DisplayObject;
	
	import cadet.core.CadetScene;
	
	public interface ISceneModel
	{
		function init( parent:DisplayObject ):void
		
		function get cadetScene():CadetScene
		function set cadetScene( value:CadetScene ):void
	}
}