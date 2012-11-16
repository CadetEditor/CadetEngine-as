// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.behaviours
{
	import cadet.core.IComponent;

	public interface IFootprint extends IComponent
	{
		function get x():int;
		function get y():int;
		function get sizeX():int;
		function get sizeY():int;
		function get values():Array;
	}
}