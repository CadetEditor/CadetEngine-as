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
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2PrismaticJoint;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	
	import cadet.core.Component;
	import cadet.events.ComponentEvent;
	import cadet.events.ValidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Connection;
	
	import cadet2DBox2D.components.processes.PhysicsProcess;

	public class PrismaticJointBehaviour extends Component implements IJoint
	{
		// Invalidation types
		private static const JOINT			:String = "joint";
		private static const BEHAVIOURS		:String = "behaviours";
		
		protected var _connection			:Connection;
		protected var _physicsProcess		:PhysicsProcess;
		
		protected var joint				:b2PrismaticJoint
		
		protected var physicsBehaviourA	:RigidBodyBehaviour
		protected var physicsBehaviourB	:RigidBodyBehaviour
		
		private var _lowerLimit			:Number = 0;
		private var _upperLimit			:Number = 10;
		private var _enableLimit		:Boolean = true;
		private var _enableMotor		:Boolean = false;
		private var _maxMotorForce		:Number = 1;
		private var _motorSpeed			:Number = 1;
		private var _autoCalculateLimits:Boolean = true;
		private var _collideConnected	:Boolean = true;
		
		public function PrismaticJointBehaviour()
		{
			name = "PrismaticJointBehaviour";
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
		
		
		[Serializable][Inspectable]
		public function set maxMotorForce( value:Number ):void
		{
			_maxMotorForce = value;
			if ( joint ) joint.SetMaxMotorForce(_maxMotorForce);
			else invalidate(JOINT);
		}
		public function get maxMotorForce():Number { return _maxMotorForce; }
		
		
		[Serializable][Inspectable]
		public function set motorSpeed( value:Number ):void
		{
			_motorSpeed = value;
			if ( joint ) joint.SetMotorSpeed(_motorSpeed);
			else invalidate(JOINT);
		}
		public function get motorSpeed():Number { return _motorSpeed; }
		
		
		[Serializable][Inspectable]
		public function set lowerLimit( value:Number ):void
		{
			_lowerLimit = value;
			if ( autoCalculateLimits ) return;	// Ignore change if limits are auto-calculated
			if ( joint ) joint.SetLimits(_lowerLimit, _upperLimit);
			else invalidate(JOINT);
		}
		public function get lowerLimit():Number { return _lowerLimit; }
		
		
		[Serializable][Inspectable]
		public function set upperLimit( value:Number ):void
		{
			_upperLimit = value;
			if ( autoCalculateLimits ) return;	// Ignore change if limits are auto-calculated
			if ( joint ) joint.SetLimits(_lowerLimit, _upperLimit);
			else invalidate(JOINT);
		}
		public function get upperLimit():Number { return _upperLimit; }
		
		
		[Serializable][Inspectable]
		public function set enableLimit( value:Boolean ):void
		{
			_enableLimit = value;
			if ( joint ) joint.EnableLimit(_enableLimit);
			else invalidate(JOINT);
		}
		public function get enableLimit():Boolean { return _enableLimit; }
		
		
		[Serializable][Inspectable]
		public function set enableMotor( value:Boolean ):void
		{
			_enableMotor = value;
			if ( joint ) joint.EnableMotor(_enableMotor);
			else invalidate(JOINT);
		}
		public function get enableMotor():Boolean { return _enableMotor; }
		
		
		[Serializable][Inspectable]
		public function set collideConnected( value:Boolean ):void
		{
			_collideConnected = value;
			invalidate(JOINT);
		}
		public function get collideConnected():Boolean { return _collideConnected; }
		
		
		[Serializable][Inspectable]
		public function set autoCalculateLimits( value:Boolean ):void
		{
			_autoCalculateLimits = value;
			invalidate(JOINT);
		}
		public function get autoCalculateLimits():Boolean { return _autoCalculateLimits; }
		
		
		public function set connection( value:Connection ):void
		{
			destroyJoint();
			
			if ( _connection )
			{
				_connection.removeEventListener(ComponentEvent.ADDED_TO_PARENT, connectionChangeHandler);
				_connection.removeEventListener(ComponentEvent.REMOVED_FROM_PARENT, connectionChangeHandler);
			}
			_connection = value;
			
			if ( _connection )
			{
				_connection.addEventListener(ComponentEvent.ADDED_TO_PARENT, connectionChangeHandler);
				_connection.addEventListener(ComponentEvent.REMOVED_FROM_PARENT, connectionChangeHandler);
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
		
		private function connectionChangeHandler( event:ComponentEvent ):void
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
			
			if ( !_connection.transformA.parentComponent ) return;
			if ( !_connection.transformB.parentComponent ) return;
			
			physicsBehaviourA = ComponentUtil.getChildOfType( _connection.transformA.parentComponent, RigidBodyBehaviour );
			physicsBehaviourB = ComponentUtil.getChildOfType( _connection.transformB.parentComponent, RigidBodyBehaviour );
		}
		
		protected function validateJoint():void
		{
			if ( !_scene ) return;
			if ( !physicsBehaviourA ) return;
			if ( !physicsBehaviourB ) return;
			if ( !_physicsProcess ) return;
			
			physicsBehaviourA.validateNow();
			physicsBehaviourB.validateNow();
			
			var jointDef:b2PrismaticJointDef = new b2PrismaticJointDef();
			jointDef.collideConnected = _collideConnected;
			jointDef.enableMotor = _enableMotor;
			jointDef.motorSpeed = _motorSpeed;
			jointDef.maxMotorForce = _maxMotorForce;
			
			var pt1:Point = _connection.transformA.matrix.transformPoint( _connection.localPosA.toPoint() );
			var pt2:Point = _connection.transformB.matrix.transformPoint( _connection.localPosB.toPoint() );
			
			var posA:b2Vec2 = new b2Vec2( pt1.x * _physicsProcess.scaleFactor, pt1.y * _physicsProcess.scaleFactor );
			var posB:b2Vec2 = new b2Vec2( pt2.x * _physicsProcess.scaleFactor, pt2.y * _physicsProcess.scaleFactor );
			
			var axis:b2Vec2 = new b2Vec2();
			axis.x = posB.x-posA.x;
			axis.y = posB.y-posA.y;
			
			if ( _enableLimit )
			{
				jointDef.enableLimit = true;
				
				if ( !_autoCalculateLimits )
				{
					jointDef.lowerTranslation = _lowerLimit * _physicsProcess.scaleFactor;
					jointDef.upperTranslation = _upperLimit * _physicsProcess.scaleFactor;
				}
				else
				{
					jointDef.lowerTranslation = -axis.Length();
					jointDef.upperTranslation = 0;
				}
			}
			
			axis.Normalize();
			
			jointDef.Initialize( physicsBehaviourA.getBody(), physicsBehaviourB.getBody(), posA, axis );
			
			joint = b2PrismaticJoint( _physicsProcess.createJoint( jointDef ) );
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