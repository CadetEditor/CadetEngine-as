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
	import cadet2D.components.processes.CollisionDetectionProcess;
	import cadet.core.Component;
	
	public class BoundingSphere extends CollisionShape implements ICollisionShape
	{
		[Serializable][Inspectable]
		public var radius		:Number = 40;
		
		public function BoundingSphere()
		{
			name = "Bounding Sphere";
		}
	}
}