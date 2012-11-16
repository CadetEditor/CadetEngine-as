// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.serialize
{
	import away3d.core.base.Object3D;

	public interface ISerializer
	{
		function export(object:Object3D):String
	}
}