// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.geom
{
	import cadet.core.IComponent;
	
	import cadet2D.components.transforms.Transform2D;
	
	public interface ICollisionShape extends IComponent
	{
		function get transform():Transform2D;
	}
}