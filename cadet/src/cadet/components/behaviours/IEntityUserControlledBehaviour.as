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
	public interface IEntityUserControlledBehaviour
	{
		function up():void;
		function down():void;
		function left():void;
		function right():void;
		function space():void;
	}
}