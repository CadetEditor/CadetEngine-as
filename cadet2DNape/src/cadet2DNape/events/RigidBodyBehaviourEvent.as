// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2DNape.events
{
	import flash.events.Event;

	public class RigidBodyBehaviourEvent extends Event
	{
		public static const DESTROY_RIGID_BODY		:String = "destroyRigidBody";
				
		public function RigidBodyBehaviourEvent(type:String)
		{
			super(type);
		}
	}
}