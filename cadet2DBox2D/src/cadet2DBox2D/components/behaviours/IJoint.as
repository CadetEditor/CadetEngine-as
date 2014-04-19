package cadet2DBox2D.components.behaviours
{
	import cadet.core.IComponent;
	
	import cadet2DBox2D.components.processes.PhysicsProcess;

	public interface IJoint extends IComponent
	{
		function set physicsProcess( value:PhysicsProcess ):void;
		function get physicsProcess():PhysicsProcess;
	}
}