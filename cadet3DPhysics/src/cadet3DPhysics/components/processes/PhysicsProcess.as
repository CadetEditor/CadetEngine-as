// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3DPhysics.components.processes
{
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet3DPhysics.components.behaviours.RigidBodyBehaviour;
	
	import flash.utils.Dictionary;
	
	public class PhysicsProcess extends Component implements ISteppableComponent
	{
		private var _physicsWorld : AWPDynamicsWorld;
		
		private var behaviourTable : Dictionary;
		
		private var _timeStep : Number = 1.0 / 60;
		
		public function PhysicsProcess( name:String = "PhysicsProcess" )
		{
			super( name );
			init();
		}
			
		private function init():void
		{
			/*
			scaleFactor = 0.02;
			var bounds:b2AABB = new b2AABB();
			bounds.lowerBound = new b2Vec2( -10000, -10000 );
			bounds.upperBound = new b2Vec2( 10000, 10000 );
			_box2D = new b2World( bounds, new b2Vec2( 0, 0 ), true );
			_box2D.SetContactListener(new PhysicsProcessContactListener(this));
			_box2D.SetDestructionListener(new PhysicsProcessDestructionListener(this));
			
			gravity = 6;
			*/
			
			// init the physics world
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			
			behaviourTable = new Dictionary(true);
		}
		
		public function addRigidBody( behaviour:RigidBodyBehaviour, rigidBody:AWPRigidBody ):void
		{
			behaviourTable[rigidBody] = behaviour;
			_physicsWorld.addRigidBody(rigidBody);
		}
	
		public function removeRigidBody( rigidBody:AWPRigidBody ):void
		{
			delete behaviourTable[rigidBody];
			_physicsWorld.removeRigidBody( rigidBody );
		}
		
		public function step(dt:Number):void
		{
			_physicsWorld.step(_timeStep, 1, _timeStep);
		}
	}
}