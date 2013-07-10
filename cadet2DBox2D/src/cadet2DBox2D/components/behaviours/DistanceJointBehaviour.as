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
	import flash.events.Event;
	import flash.geom.Point;
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2Joint;
	
	import cadet.core.Component;
	import cadet.events.ComponentEvent;
	import cadet.events.ValidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Connection;
	
	import cadet2DBox2D.components.processes.PhysicsProcess;

	public class DistanceJointBehaviour extends Component implements IJoint
	{
		// Invalidation types
		private static const JOINT			:String = "joint";
		private static const BEHAVIOURS		:String = "behaviours";
		
		protected var _connection			:Connection;
		protected var _physicsProcess		:PhysicsProcess;
		
		protected var joint				:b2Joint;
		
		protected var physicsBehaviourA	:RigidBodyBehaviour;
		protected var physicsBehaviourB	:RigidBodyBehaviour;
		
		[Serializable]
		public var length				:Number = -1;
		[Serializable][Inspectable]
		public var damping				:Number = 0.5;
		[Serializable][Inspectable]
		public var collideConnected		:Boolean = true;
		
		public function DistanceJointBehaviour()
		{
			name = "DistanceJointBehaviour";
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(Connection, "connection");
			addSceneReference(PhysicsProcess, "physicsProcess");
		}
		
		override protected function removedFromScene():void
		{
			destroyJoint();
		}
		
		public function set connection( value:Connection ):void
		{
			destroyJoint();
			
			if ( _connection )
			{
				_connection.removeEventListener(ComponentEvent.ADDED_TO_PARENT, connectionChangeHandler);
				_connection.removeEventListener(ComponentEvent.REMOVED_FROM_PARENT, connectionChangeHandler);
				_connection.removeEventListener(ValidationEvent.INVALIDATE, connectionChangeHandler);
			}
			_connection = value;
			
			if ( _connection )
			{
				_connection.addEventListener(ComponentEvent.ADDED_TO_PARENT, connectionChangeHandler);
				_connection.addEventListener(ComponentEvent.REMOVED_FROM_PARENT, connectionChangeHandler);
				_connection.addEventListener(ValidationEvent.INVALIDATE, connectionChangeHandler);
			}
			
			invalidate(BEHAVIOURS);
			invalidate(JOINT);
		}
		public function get connection():Connection { return _connection; }
		
		public function set physicsProcess( value:PhysicsProcess ):void
		{
			destroyJoint();
			if ( _physicsProcess )
			{
				_physicsProcess.removeEventListener(ValidationEvent.INVALIDATE, invalidatePhysicsProcessHandler);
			}
			_physicsProcess = value;
			if ( _physicsProcess )
			{
				_physicsProcess.addEventListener(ValidationEvent.INVALIDATE, invalidatePhysicsProcessHandler);
			}
			invalidate(JOINT);
		}
		public function get physicsProcess():PhysicsProcess { return _physicsProcess; }
		
		private function invalidatePhysicsProcessHandler( event:ValidationEvent ):void
		{
			invalidate(JOINT);
		}
		
		private function connectionChangeHandler( event:Event ):void
		{
			invalidate(BEHAVIOURS);
		}
		
		
		protected function destroyJoint():void
		{
			if ( !joint ) return;
			if ( !_physicsProcess ) return;
			
			_physicsProcess.destroyJoint( joint );
			joint = null;
		}
		
		protected function validateBehaviours():void
		{
			if ( !_connection )
			{
				physicsBehaviourA = null;
				physicsBehaviourB = null;
				return;
			}
			
			if ( !_connection.transformA ) return;
			if ( !_connection.transformB ) return;
			if ( !_connection.transformA.parentComponent ) return;
			if ( !_connection.transformB.parentComponent ) return;
			
			physicsBehaviourA = ComponentUtil.getChildOfType( _connection.transformA.parentComponent, RigidBodyBehaviour );
			physicsBehaviourB = ComponentUtil.getChildOfType( _connection.transformB.parentComponent, RigidBodyBehaviour );
		}
		
		protected function validateJoint():void
		{
			if ( !_scene ) return;
			if ( !physicsBehaviourA ) return
			if ( !physicsBehaviourB ) return
			if ( !_physicsProcess ) return
			
			physicsBehaviourA.validateNow();
			physicsBehaviourB.validateNow();
			
			var jointDef:b2DistanceJointDef = new b2DistanceJointDef();
			jointDef.dampingRatio = damping;
			jointDef.collideConnected = collideConnected;
			jointDef.frequencyHz = 0.5;
			
			var pt1:Point = _connection.transformA.matrix.transformPoint( connection.localPosA.toPoint() );
			var pt2:Point = _connection.transformB.matrix.transformPoint( connection.localPosB.toPoint() );
			
			var posA:b2Vec2 = new b2Vec2( pt1.x * _physicsProcess.scaleFactor, pt1.y * _physicsProcess.scaleFactor );
			var posB:b2Vec2 = new b2Vec2( pt2.x * _physicsProcess.scaleFactor, pt2.y * _physicsProcess.scaleFactor );
			
			jointDef.Initialize( physicsBehaviourA.getBody(), physicsBehaviourB.getBody(), posA, posB );
			if ( length != -1 ) jointDef.length = length;
			joint = _physicsProcess.createJoint( jointDef );
		}

		override public function validateNow():void
		{
			if ( isInvalid( BEHAVIOURS ) )
			{
				validateBehaviours();
			}
			if ( isInvalid( JOINT ) )
			{
				validateJoint();
			}
			super.validateNow();
		}
	}
}