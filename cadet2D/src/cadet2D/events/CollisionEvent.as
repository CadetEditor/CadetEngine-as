// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.events
{
	import flash.events.Event;
	
	import cadet2D.components.geom.ICollisionShape;
	
	public class CollisionEvent extends Event
	{
		public static const COLLISION	:String = "collision";
		
		private var _objectA	:ICollisionShape;
		private var _objectB	:ICollisionShape;
		
		public function CollisionEvent(type:String, objectA:ICollisionShape, objectB:ICollisionShape)
		{
			super(type, false, false);
			_objectA = objectA;
			_objectB = objectB;
		}
		
		override public function clone():Event
		{
			return new CollisionEvent( type, _objectA, _objectB );
		}
		
		public function get objectA():ICollisionShape { return _objectA; }
		public function get objectB():ICollisionShape { return _objectB; }
	}
}