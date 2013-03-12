// Some Processes and Behaviours need to function differently in design time and run time.
// For instance, a Process may reference a list of Skins at design time which are then spawned intermittently at run time.
// These Components need to be initialised to perform these operations when the scene is running, by implementing this interface,
// the Components register to have their init() function called when the scene first steps.

package cadet.core
{
	public interface IInitOnRunComponent
	{
		function init():void
	}
}