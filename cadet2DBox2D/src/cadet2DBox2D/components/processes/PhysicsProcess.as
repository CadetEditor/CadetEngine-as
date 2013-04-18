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
	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2JointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import flash.utils.Dictionary;
	
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;


	[Event( type="cadet.box2D.events.PhysicsCollisionEvent", name="collision" )]
	public class PhysicsProcess extends Component implements ISteppableComponent
	{
		protected var _box2D				:b2World;
		
		private var _scaleFactor			:Number;
		private var _invScaleFactor			:Number;
		
		[Serializable][Inspectable( editor="NumericStepper", label="Global iterations", min="1", max="10" ) ]
		public var numIterations			:int = 2;
		[Serializable][Inspectable( editor="NumericStepper", label="Velocity Iterations", min="1", max="10" ) ]
		public var numVelocityIterations	:int = 2;
		[Serializable][Inspectable( editor="NumericStepper", label="Position Iterations", min="1", max="10" ) ]
		public var numPositionIterations	:int = 2;
		
		private var _gravity				:Number;
		
		private var behaviourTable			:Dictionary;
		private var jointTable				:Dictionary;
		
		
		public function PhysicsProcess()
		{
			init();
		}
		
		private function init():void
		{
			name = "PhysicsProcess";
			
			scaleFactor = 0.01;
			var bounds:b2AABB = new b2AABB();
			bounds.lowerBound = new b2Vec2( -10000, -10000 );
			bounds.upperBound = new b2Vec2( 10000, 10000 );
			_box2D = new b2World( bounds, new b2Vec2( 0, 0 ), true );
			_box2D.SetContactListener(new PhysicsProcessContactListener(this));
			_box2D.SetDestructionListener(new PhysicsProcessDestructionListener(this));
			
			gravity = 6;
			
			behaviourTable = new Dictionary(true);
			jointTable = new Dictionary(true);
		}
		
		public function createRigidBody( behaviour:RigidBodyBehaviour, def:b2BodyDef ):b2Body
		{
			var rigidBody:b2Body = _box2D.CreateBody(def);
			behaviourTable[rigidBody] = behaviour;
			return rigidBody
		}
		
		public function destroyRigidBody( behaviour:RigidBodyBehaviour, rigidBody:b2Body ):void
		{
			delete behaviourTable[rigidBody];
			_box2D.DestroyBody(rigidBody);
		}
		
		public function createJoint( jointDef:b2JointDef ):b2Joint
		{
			var joint:b2Joint = _box2D.CreateJoint(jointDef);
			jointTable[joint] = true;
			return joint;
		}
		
		public function destroyJoint( joint:b2Joint ):void
		{
			// Don't try to destroy the joint if Box2D has already automatically destroyed it
			// (as Box2D gets screwed up if you destroy a joint twice)
			if ( !jointTable[joint] ) return;
			delete jointTable[joint];
			_box2D.DestroyJoint(joint);
		}
		
		internal function jointDestroyed( joint:b2Joint ):void
		{
			delete jointTable[joint];
		}
		
		public function getBehaviourForRigidBody( rigidBody:b2Body ):RigidBodyBehaviour
		{
			return behaviourTable[rigidBody];
		}
		
		[Serializable][Inspectable( editor="NumericStepper", label="Gravity", stepSize="0.01" )]
		public function set gravity( value:Number ):void
		{
			_gravity = value;
			_box2D.SetGravity( new b2Vec2( 0, _gravity ) );
		}
		public function get gravity():Number { return _gravity; }
		
		
		
		public function step( dt:Number ):void
		{
			//var time:int = flash.utils.getTimer();
			for ( var i:int = 0; i < numIterations; i++ )
			{
				_box2D.Step( dt*(1/numIterations), numVelocityIterations, numPositionIterations );
			}
			//trace( flash.utils.getTimer() - time );
		}
		
		public function getGroundBody():b2Body
		{
			return _box2D.GetGroundBody();
		}
		
		[Serializable][Inspectable( editor="NumericStepper", min="0.01", max="1000", stepSize="0.01", label="Meters per pixel" )]
		public function set scaleFactor( value:Number ):void
		{
			_scaleFactor = value;
			_invScaleFactor = 1/_scaleFactor;
			invalidate("scaleFactor");
		}
		public function get scaleFactor():Number { return _scaleFactor; }
		public function get invScaleFactor():Number { return _invScaleFactor; }
	}
}