// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2DBox2D.components.behaviours
{
	import flash.geom.Point;
	
	import cadet.core.Component;
	import cadet2DBox2D.components.processes.PhysicsProcess;
	import cadet2DBox2D.events.PhysicsCollisionEvent;

	/**
	 * This behaviour listens to the PhysicsProcess for COLLISION events.
	 * When one happens, it calls a virtual function passing through the details. You should extends this class and
	 * override the virtual function with custom logic.
	 * 
	 * This behaviour also makes sure that the onCollision virtual function isn't called until the validation phase.
	 * This is required because Box2D 'locks' the ability to create or destroy rigid bodies during a collision callback.
	 * Because most behaviours will probably want to make some changes to the physics scene when collisions occur, this behaviour
	 * makes sure that the onCollision function is called at a 'safe' point.
	 * @author Jonathan
	 * 
	 */	
	public class RigidBodyCollisionDetectBehaviour extends Component
	{
		private static const COLLISIONS	:String = "collisions";
		
		private var _physicsProcess	:PhysicsProcess;
		public var behaviourA		:RigidBodyBehaviour;
		
		private var collisions		:Array;
		
		protected var _collisionsEnabled	:Boolean = true;
		
		public function RigidBodyCollisionDetectBehaviour()
		{
			name = "RigidBodyCollisionDetectBehaviour";
			collisions = [];
		}
		
		override protected function addedToScene():void
		{
			addSceneReference( PhysicsProcess, "physicsProcess" );
			addSiblingReference( RigidBodyBehaviour, "behaviourA" );
		}
		
		public function set physicsProcess( value:PhysicsProcess ):void
		{
			if ( _physicsProcess && _collisionsEnabled )
			{
				_physicsProcess.removeEventListener(PhysicsCollisionEvent.COLLISION, collisionHandler);
			}
			_physicsProcess = value;
			if ( _physicsProcess && _collisionsEnabled )
			{
				_physicsProcess.addEventListener(PhysicsCollisionEvent.COLLISION, collisionHandler);
			}
		}
		
		[Serializable][Inspectable]
		public function set collisionsEnabled( value:Boolean ):void
		{
			if ( value == _collisionsEnabled ) return;
			_collisionsEnabled = value;
			if ( !_physicsProcess ) return;
			
			if ( _collisionsEnabled )
			{
				_physicsProcess.addEventListener(PhysicsCollisionEvent.COLLISION, collisionHandler);
			}
			else
			{
				_physicsProcess.removeEventListener(PhysicsCollisionEvent.COLLISION, collisionHandler);
			}
		}
		
		public function get collisionsEnabled():Boolean { return _collisionsEnabled; }
		
		private function collisionHandler( event:PhysicsCollisionEvent ):void
		{
			if ( event.behaviourA == behaviourA )
			{
				collisions.push( [event.behaviourB, event.position, event.normal, event.normalImpulse, event.tangentImpulse] );
				invalidate(COLLISIONS);
			}
			else if ( event.behaviourB == behaviourA )
			{
				collisions.push( [event.behaviourA, event.position, new Point(-event.normal.x, -event.normal.y), event.normalImpulse, event.tangentImpulse] );
				invalidate(COLLISIONS);
			}
		}
		
		override public function validateNow():void
		{
			if ( isInvalid(COLLISIONS) )
			{
				validateCollisions();
			}
			super.validateNow();
		}
		
		private function validateCollisions():void
		{
			var L:int = collisions.length;
			while (L-- > 0)
			{
				var collisionArgs:Array = collisions.pop();
				onCollision.apply(this,collisionArgs);
			}
		}
		
		protected function onCollision( behaviourB:RigidBodyBehaviour, position:Point, normal:Point, normalImpulse:Number, tangentImpulse:Number ):void
		{
			dispatchEvent( new PhysicsCollisionEvent( PhysicsCollisionEvent.COLLISION, behaviourA, behaviourB, position, normal, normalImpulse, tangentImpulse ) );
		}
	}
}