// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2DBox2D.events
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;

	public class PhysicsCollisionEvent extends Event
	{
		public static const COLLISION	:String = "collision";
		
		public var behaviourA	:RigidBodyBehaviour;
		public var behaviourB	:RigidBodyBehaviour;
		
		public var position		:Point;		// In world space
		public var normal			:Point;		// Points from A->B;
		public var normalImpulse	:Number;	// In newtons
		public var tangentImpulse	:Number;	// In newtons
		
		public function PhysicsCollisionEvent(type:String, behaviourA:RigidBodyBehaviour, behaviourB:RigidBodyBehaviour, position:Point, normal:Point, normalImpulse:Number, tangentImpulse:Number)
		{
			super(type);
			
			this.behaviourA = behaviourA;
			this.behaviourB = behaviourB;
			this.position = position;
			this.normal = normal;
			this.normalImpulse = normalImpulse;
			this.tangentImpulse = tangentImpulse;
		}
	}
}