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
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	
	import cadet.core.Component;
	import cadet.events.ComponentEvent;
	import cadet.events.ValidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Pin;
	
	import cadet2DBox2D.components.processes.PhysicsProcess;

	public class RevoluteJointBehaviour extends Component
	{
		// Invalidation types
		private static const JOINT			:String = "joint";
		private static const BEHAVIOURS		:String = "behaviours";
				
		private static const DEG_TO_RAD		:Number = Math.PI / 180;
				
		protected var _pin				:Pin;
		protected var _physicsProcess	:PhysicsProcess;
		
		protected var joint				:b2RevoluteJoint;
		
		protected var physicsBehaviourA	:RigidBodyBehaviour;
		protected var physicsBehaviourB	:RigidBodyBehaviour;
		
		[Serializable][Inspectable]
		public var collideConnected		:Boolean = false;
		
		private var _enableLimit		:Boolean = false;
		private var _lowerAngle			:Number = 0;
		private var _upperAngle			:Number = 0;
		private var _enableMotor		:Boolean = false;
		private var _maxMotorTorque		:Number = 1;
		private var _motorSpeed			:Number = 1;
				
		public function RevoluteJointBehaviour( name = "RevoluteJointBehaviour" )
		{
			super(name);
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(Pin, "pin");
			addSceneReference(PhysicsProcess, "physicsProcess");
		}
		
		[Serializable][Inspectable]
		public function set enableLimit( value:Boolean ):void
		{
			_enableLimit = value;
			if ( joint ) joint.EnableLimit(_enableLimit);
			else invalidate(JOINT);
		}
		public function get enableLimit():Boolean { return _enableLimit; }
		
		[Serializable][Inspectable]
		public function set lowerAngle( value:Number ):void
		{
			_lowerAngle = value;
			if ( joint ) joint.SetLimits(_lowerAngle * DEG_TO_RAD, _upperAngle * DEG_TO_RAD);
			else invalidate(JOINT);
		}
		public function get lowerAngle():Number { return _lowerAngle; }
		
		
		[Serializable][Inspectable]
		public function set upperAngle( value:Number ):void
		{
			_upperAngle = value;
			if ( joint ) joint.SetLimits(_lowerAngle * DEG_TO_RAD, _upperAngle * DEG_TO_RAD);
			else invalidate(JOINT);
		}
		public function get upperAngle():Number { return _upperAngle; }
		
		
		[Serializable][Inspectable]
		public function set enableMotor( value:Boolean ):void
		{
			_enableMotor = value;
			if ( joint ) joint.EnableMotor(_enableMotor);
			else invalidate(JOINT);
		}
		public function get enableMotor():Boolean { return _enableMotor; }
		
		[Serializable][Inspectable]
		public function set maxMotorTorque( value:Number ):void
		{
			_maxMotorTorque = value;
			if ( joint ) joint.SetMaxMotorTorque(_maxMotorTorque);
			else invalidate(JOINT);
		}
		public function get maxMotorTorque():Number { return _maxMotorTorque; }
		
		
		[Serializable][Inspectable]
		public function set motorSpeed( value:Number ):void
		{
			_motorSpeed = value;
			if ( joint ) joint.SetMotorSpeed(_motorSpeed);
			else invalidate(JOINT);
		}
		public function get motorSpeed():Number { return _motorSpeed; }
		
		public function set pin( value:Pin ):void
		{
			destroyJoint();
			
			if ( _pin )
			{
				_pin.removeEventListener(ComponentEvent.ADDED_TO_PARENT, connectionChangeHandler);
				_pin.removeEventListener(ComponentEvent.REMOVED_FROM_PARENT, connectionChangeHandler);
			}
			_pin = value;
			
			if ( _pin )
			{
				_pin.addEventListener(ComponentEvent.ADDED_TO_PARENT, connectionChangeHandler);
				_pin.addEventListener(ComponentEvent.REMOVED_FROM_PARENT, connectionChangeHandler);
			}
			
			invalidate(BEHAVIOURS);
			invalidate(JOINT);
		}
		public function get pin():Pin { return _pin; }
		
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
		
		public function getJoint():b2RevoluteJoint
		{
			if (!joint) validateNow();
			return joint;
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
			if ( !_pin )
			{
				physicsBehaviourA = null;
				physicsBehaviourB = null;
				return;
			}
			
			if ( !_pin.transformA ) return;
			if ( !_pin.transformB ) return;
			
			if ( !_pin.transformA.parentComponent ) return;
			if ( !_pin.transformB.parentComponent ) return;
			
			physicsBehaviourA = ComponentUtil.getChildOfType( _pin.transformA.parentComponent, RigidBodyBehaviour );
			physicsBehaviourB = ComponentUtil.getChildOfType( _pin.transformB.parentComponent, RigidBodyBehaviour );
		}
		
		protected function validateJoint():void
		{
			if ( !_scene ) return;
			if ( !physicsBehaviourA ) return
			if ( !physicsBehaviourB ) return
			if ( !_physicsProcess ) return
			
			physicsBehaviourA.validateNow();
			physicsBehaviourB.validateNow();
			
			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.collideConnected = collideConnected;
			jointDef.enableLimit = _enableLimit;
			jointDef.lowerAngle = _lowerAngle * DEG_TO_RAD;
			jointDef.upperAngle = _upperAngle * DEG_TO_RAD;
			jointDef.enableMotor = _enableMotor;
			jointDef.maxMotorTorque = _maxMotorTorque;
			jointDef.motorSpeed = _motorSpeed;
			
			var pt:Point = _pin.localPos.toPoint(); // needs to be local to the shape not world coords
			pt = _pin.transformA.matrix.transformPoint( pt ); //presumes transform = (0,0)
			var pos:b2Vec2 = new b2Vec2( pt.x * _physicsProcess.scaleFactor, pt.y * _physicsProcess.scaleFactor );
			
			jointDef.Initialize( physicsBehaviourA.getBody(), physicsBehaviourB.getBody(), pos );
			joint = b2RevoluteJoint(_physicsProcess.createJoint( jointDef ));
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