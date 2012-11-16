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
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import cadet.components.behaviours.IVehicleBehaviour;
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	import cadet2DBox2D.components.processes.PhysicsProcess;

	public class SimpleVehicleBehaviour extends Component implements ISteppableComponent, IVehicleBehaviour
	{
		private var _rigidBodyBehaviour	:RigidBodyBehaviour;
		private var _physicsProcess		:PhysicsProcess;
		
		private var _acceleration		:Number = 0;
		private var _brake				:Number = 0;
		private var _steering			:Number = 0;
		
		private var _forces				:Array;
		
		[Serializable][Inspectable]
		public var accelerationForce	:Number = 4;
		[Serializable][Inspectable]
		public var brakeForce			:Number = 4;
		[Serializable][Inspectable]
		public var grip					:Number = 0.15;
		[Serializable][Inspectable]
		public var maxGrip				:Number = 0.12;
		[Serializable][Inspectable]
		public var topSpeed				:Number = 6.0;
		[Serializable][Inspectable]
		public var maxSteeringAngle		:Number = 30;
		[Serializable][Inspectable]
		public var steeringStrength		:Number = 0.5;
		
		private var _carLength			:Number;
		
		private var longAxis			:b2Vec2;
		private var latAxis				:b2Vec2;
		private var velocity			:b2Vec2;
		private var vMag				:Number;
		private var velocityLong		:Number;
		private var velocityLat			:Number;
		
		
		// Read only values
		private var _frontTirePos		:b2Vec2;
		private var _rearTirePos			:b2Vec2;
		
		public function SimpleVehicleBehaviour()
		{
			name = "SimpleVehicleBehaviour";
			carLength = 25;
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(RigidBodyBehaviour, "rigidBodyBehaviour");
			addSceneReference( PhysicsProcess, "physicsProcess" );
		}
		
		[Serializable][Inspectable]
		public function set carLength( value:Number ):void
		{
			_carLength = value;
		}
		public function get carLength():Number { return _carLength; }
				
		public function set rigidBodyBehaviour( value:RigidBodyBehaviour ):void
		{
			_rigidBodyBehaviour = value;
		}
		public function get rigidBodyBehaviour():RigidBodyBehaviour { return _rigidBodyBehaviour; }
		
		
		public function set physicsProcess( value:PhysicsProcess ):void
		{
			_physicsProcess = value;
		}
		public function get physicsProcess():PhysicsProcess { return _physicsProcess; }
		
		
		public function get frontTirePosition():b2Vec2
		{
			return _frontTirePos;
		}
		
		public function get rearTirePosition():b2Vec2
		{
			return _rearTirePos;
		}
		
		public function step(dt:Number):void
		{
			if (!_rigidBodyBehaviour) return;
			if ( !_physicsProcess ) return;
			
			_forces = [];
			
			var body:b2Body = _rigidBodyBehaviour.getBody();
			var mass:Number = body.GetMass();
			
			if ( !body ) return;
			
			_frontTirePos = body.GetWorldPoint( new b2Vec2( ( _carLength >> 1) * _physicsProcess.scaleFactor, 0 ) );
			_rearTirePos  = body.GetWorldPoint( new b2Vec2( (-_carLength >> 1) * _physicsProcess.scaleFactor, 0 ) );
			
			var angle:Number = body.GetAngle();
			var cos:Number = Math.cos( angle );
			var sin:Number = Math.sin( angle );
			
			longAxis = new b2Vec2( cos, sin );
			latAxis = new b2Vec2( -sin, cos );
			
			velocity = body.GetLinearVelocity();
			vMag = Math.sqrt( velocity.x*velocity.x + velocity.y*velocity.y );
			var dot:Number = velocity.x*longAxis.x + velocity.y*longAxis.y;
			var angleBetween:Number = Math.acos( dot / vMag );
			if ( isNaN( angleBetween ) ) angleBetween = 0;
			velocityLong = Math.cos( angleBetween ) * vMag;
			dot = velocity.x*latAxis.x + velocity.y*latAxis.y;
			angleBetween = Math.acos( dot / vMag );
			if ( isNaN( angleBetween ) ) angleBetween = 0;
			velocityLat = Math.cos( angleBetween ) * vMag;
			
			simulateTire( _rearTirePos, false, true );
			simulateTire( _frontTirePos, true, false );
			
			
			// Apply braking force
			var brakingForce:b2Vec2 = longAxis.Copy();
			brakingForce.Multiply( -Math.min( velocityLong*20, _brake * brakeForce * mass ) );
			body.ApplyForce( brakingForce, body.GetPosition() );
			
			_forces.push([brakingForce,body.GetPosition()]);
			
			// Apply top-speed damping force
			var speedRatio:Number = velocityLong / topSpeed;
			if ( speedRatio > 1 )
			{
				var ratio:Number = speedRatio - 1;
				
				var topSpeedDampingForce:b2Vec2 = velocity.Copy();
				topSpeedDampingForce.Multiply(-ratio);
				body.ApplyImpulse(topSpeedDampingForce, body.GetPosition());
				
				forces.push( [topSpeedDampingForce, body.GetPosition()] );
			}
			
			body.SetLinearDamping(0.1);
			body.SetAngularDamping(0.05);
			
			// Finally apply air resitance
			//var airResistance:b2Vec2 = longAxis.Copy();
			//airResistance.Multiply( -velocityLong * airResistanceRatio );
			//body.ApplyForce( airResistance, body.GetPosition() );
		}
		
		private function simulateTire( pos:b2Vec2, isSteeringWheel:Boolean, isDriveWheel:Boolean ):void
		{
			var body:b2Body = _rigidBodyBehaviour.getBody();
			var angle:Number = body.GetAngle();
			var mass:Number = body.GetMass();
			
			if ( isSteeringWheel )
			{
				var steeringRatio:Number = velocityLong / 1.5;
				steeringRatio = steeringRatio < 0 ? 0 : steeringRatio > 1 ? 1 : steeringRatio;
				steeringRatio = (1-steeringRatio) * 1 + steeringRatio*0.7;
				angle += _steering * Math.PI * maxSteeringAngle * 0.0175 * steeringRatio;
			}
			var sin:Number = Math.sin( angle );
			var cos:Number = Math.cos( angle );
			var tireLongAxis:b2Vec2 = new b2Vec2( cos, sin );
			var tireLatAxis:b2Vec2 = new b2Vec2( -sin, cos );
			
			var tireVelocityLong:b2Vec2 = body.GetLinearVelocityFromWorldPoint( pos );
			var tireSpeedLong:Number = tireVelocityLong.Length();
			
			var dot:Number = tireVelocityLong.x*tireLatAxis.x + tireVelocityLong.y*tireLatAxis.y;
			var angleBetween:Number = Math.acos( dot / tireSpeedLong );
			if ( isNaN( angleBetween ) ) angleBetween = 0;
			var tireSpeedLat:Number = Math.cos( angleBetween ) * tireSpeedLong;
			
			// Drive force
			if ( isDriveWheel )
			{
				var driveForce:b2Vec2 = tireLongAxis.Copy();
				driveForce.Multiply( _acceleration * accelerationForce * 0.01 * mass );
				body.ApplyImpulse(driveForce,pos);
				_forces.push([driveForce,pos]);
			}
			
			// Lateral friction (the force stopping tyres from moving sideways)
			var lateralFrictionForce:Number = tireSpeedLat * (isSteeringWheel ? -(grip*steeringStrength) : -grip) * mass;
			var lateralFrictionForceVec:b2Vec2 = latAxis.Copy();
			lateralFrictionForceVec.Multiply( lateralFrictionForce );
			var ratio:Number = lateralFrictionForceVec.Length() / maxGrip;
			if ( ratio > 1 )
			{
				lateralFrictionForceVec.Multiply(1/ratio);
			}
			body.ApplyImpulse(lateralFrictionForceVec, pos);
			_forces.push([lateralFrictionForceVec,pos]);
		}
		
		public function set acceleration( value:Number ):void { _acceleration = value; }
		public function get acceleration():Number { return _acceleration; }
		public function set brake( value:Number ):void { _brake = value; }
		public function get brake():Number { return _brake; }
		public function set steering( value:Number ):void { _steering = value; }
		public function get steering():Number { return _steering; }
		public function get forces():Array { return _forces; }
	}
}