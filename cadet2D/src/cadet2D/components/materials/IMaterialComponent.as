package cadet2D.components.materials
{
	import flash.events.IEventDispatcher;
	
	import starling.display.materials.IMaterial;

	public interface IMaterialComponent extends IEventDispatcher
	{
		function get material():IMaterial;
	}
}