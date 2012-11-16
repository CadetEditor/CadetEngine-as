// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2DBox2D.components.processes
{
	import Box2D.Dynamics.Contacts.b2ContactResult;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactListener;
	
	import flash.geom.Point;
	
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;
	import cadet2DBox2D.events.PhysicsCollisionEvent;

	public class PhysicsProcessContactListener extends b2ContactListener
	{
		private var physicsProcess	:PhysicsProcess;
		
		public function PhysicsProcessContactListener( physicsProcess:PhysicsProcess )
		{
			this.physicsProcess = physicsProcess;
		}
		
		override public function Result(result:b2ContactResult):void
		{
			var bodyA:b2Body = result.shape1.GetBody();
			var bodyB:b2Body = result.shape2.GetBody();
			
			var behaviourA:RigidBodyBehaviour = physicsProcess.getBehaviourForRigidBody(bodyA);
			var behaviourB:RigidBodyBehaviour = physicsProcess.getBehaviourForRigidBody(bodyB);
			
			
			physicsProcess.dispatchEvent( new PhysicsCollisionEvent( PhysicsCollisionEvent.COLLISION, 
																	 behaviourA,
																	 behaviourB,
																	 new Point( result.position.x * physicsProcess.invScaleFactor, result.position.y * physicsProcess.invScaleFactor ),
																	 new Point( result.normal.x, result.normal.y ), 
																	 result.normalImpulse, 
																	 result.normalImpulse ) );
		}
	}
}