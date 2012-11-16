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
	import cadet.core.CadetScene;
	import cadet.core.Component;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentReferenceUtil;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.transforms.Transform2D;
	
	import flash.events.Event;
	
	[Event( type="cadet.events.CollisionEvent", name="collision" )]
	
	public class CollisionShape extends Component implements ICollisionShape
	{
		public var _transform	:Transform2D;
		
		public function CollisionShape()
		{
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(Transform2D, "_transform");
		}
		
		public function get transform():Transform2D
		{
			return _transform;
		}
	}
}