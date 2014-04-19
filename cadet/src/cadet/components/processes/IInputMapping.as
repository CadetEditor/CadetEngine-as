package cadet.components.processes
{
	import cadet.core.IComponent;

	public interface IInputMapping extends IComponent
	{
		function set input( value:String ):void;
		function get input():String;
	}
}