// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Some Processes and Behaviours need to function differently in design time and run time.
// For instance, a Process may reference a list of Skins at design time which are then spawned intermittently at run time.
// These Components need to be initialised to perform these operations when the scene is running, by implementing this interface,
// the Components register to have their init() function called when the scene first steps.

package cadet.core
{
	public interface IInitialisableComponent extends IComponent
	{
		function init():void;
	}
}