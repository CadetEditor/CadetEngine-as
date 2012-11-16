// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.components.behaviours
{
	public interface IVehicleBehaviour
	{
		function set acceleration( value:Number ):void;
		function get acceleration():Number;
		function set brake( value:Number ):void;
		function get brake():Number;
		function set steering( value:Number ):void
		function get steering():Number;
	}
}