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
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	
	import cadet.core.Component;
	import cadet.core.IComponentContainer;
	import cadet.core.ISteppableComponent;
	import cadet.util.ComponentReferenceUtil;
	import cadet.components.behaviours.IVehicleBehaviour;

	public class MotorbikeBehaviour extends Component implements ISteppableComponent, IVehicleBehaviour
	{
		private var _acceleration			:Number = 0;
		private var _brake					:Number = 0;
		private var _steering				:Number = 0;
		
		[Serializable][Inspectable]
		public var maxTorque				:Number = 2;
		
		[Serializable][Inspectable]
		public var brakeTorque				:Number = 1;
		
		[Serializable][Inspectable]
		public var maxSpeed					:Number = 30;
		
		[Serializable][Inspectable]
		public var maxChasisTorque			:Number = 1;
		
		
		
		private var _driveWheel				:IComponentContainer;
		private var _frontWheel				:IComponentContainer;
		private var _chasis					:IComponentContainer
		
		public var driveWheelJoint			:RevoluteJointBehaviour;
		public var frontWheelJoint			:RevoluteJointBehaviour;
		public var chasisRigidBody			:RigidBodyBehaviour;
		
		public function MotorbikeBehaviour()
		{
			name = "MotorbikeBehaviour";
		}
		
		public function set acceleration( value:Number ):void { _acceleration = value; }
		public function get acceleration():Number { return _acceleration; }
		public function set brake( value:Number ):void { _brake = value; }
		public function get brake():Number { return _brake; }
		public function set steering( value:Number ):void { _steering = value; }
		public function get steering():Number { return _steering; }
		
		[Serializable][Inspectable( editor="ComponentList" )]
		public function set driveWheel( value:IComponentContainer ):void
		{
			if ( _driveWheel )
			{
				ComponentReferenceUtil.removeReferenceByType(  _driveWheel, RevoluteJointBehaviour, this, "driveWheelJoint" );
			}
			_driveWheel = value;
			if ( _driveWheel )
			{
				ComponentReferenceUtil.addReferenceByType( _driveWheel, RevoluteJointBehaviour, this, "driveWheelJoint" );
			}
		}
		public function get driveWheel():IComponentContainer { return _driveWheel; }
		
		[Serializable][Inspectable( editor="ComponentList" )]
		public function set frontWheel( value:IComponentContainer ):void
		{
			if ( _frontWheel )
			{
				ComponentReferenceUtil.removeReferenceByType(  _frontWheel, RevoluteJointBehaviour, this, "frontWheelJoint" );
			}
			_frontWheel = value;
			if ( _frontWheel )
			{
				ComponentReferenceUtil.addReferenceByType( _frontWheel, RevoluteJointBehaviour, this, "frontWheelJoint" );
			}
		}
		public function get frontWheel():IComponentContainer { return _frontWheel; }
		
		[Serializable][Inspectable( editor="ComponentList" )]
		public function set chasis( value:IComponentContainer ):void
		{
			trace("set chasis : " + (value ? value.name : "null"));
			if ( _chasis )
			{
				ComponentReferenceUtil.removeReferenceByType(  _chasis, RigidBodyBehaviour, this, "chasisRigidBody" );
			}
			_chasis = value;
			if ( _chasis )
			{
				ComponentReferenceUtil.addReferenceByType( _chasis, RigidBodyBehaviour, this, "chasisRigidBody" );
			}
		}
		public function get chasis():IComponentContainer { return _chasis; }
		
		
		public function step( dt:Number ):void
		{
			if ( !driveWheelJoint ) return;
			if ( !chasisRigidBody ) return;
			if ( !frontWheelJoint ) return;
			
			driveWheelJoint.enableMotor = true;
			frontWheelJoint.enableMotor = true
			
			var torque:Number = (_acceleration * maxTorque) + (_brake * brakeTorque);
			var speed:Number = -(1-_brake) * maxSpeed;
			
			driveWheelJoint.maxMotorTorque = -torque;
			driveWheelJoint.motorSpeed = speed
			
			frontWheelJoint.maxMotorTorque = torque * 0.5;
			frontWheelJoint.motorSpeed = -speed * 0.5;
			
			// Apply an equal and opposite force to the chasis to simulate a downforce, keeping the motorcycle stuck to the ground
			var _driveWheelJoint:b2RevoluteJoint = driveWheelJoint.getJoint();
			if ( _driveWheelJoint )
			{
				chasisRigidBody.applyTorque( _driveWheelJoint.GetMotorTorque() * 1 );
			}
			
			driveWheelJoint.motorSpeed *= 1-_brake; 
			frontWheelJoint.motorSpeed *= 1-_brake; 
			
			var ratio:Number = Math.abs(chasisRigidBody.getBody().GetAngularVelocity() / 2.5);
			ratio = ratio < 0 ? 0 : ratio > 1 ? 1 : ratio;
			ratio = 1-ratio;
			chasisRigidBody.applyTorque( _steering * maxChasisTorque * ratio );
		}
	}
}