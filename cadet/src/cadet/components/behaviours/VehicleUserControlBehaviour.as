// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.components.behaviours
{
	import cadet.components.processes.KeyboardInputProcess;
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;

	public class VehicleUserControlBehaviour extends Component implements ISteppableComponent
	{
		[Serializable][Inspectable]
		public var accelerateMapping		:String = "ACCELERATE";
		[Serializable][Inspectable]
		public var brakeMapping				:String = "BRAKE";
		[Serializable][Inspectable]
		public var steerLeftMapping			:String = "STEER LEFT";
		[Serializable][Inspectable]
		public var steerRightMapping		:String = "STEER RIGHT";
		
		public var inputProcess		:KeyboardInputProcess;
		public var vehicleBehaviour	:IVehicleBehaviour;
		
		[Serializable][Inspectable]
		public var steeringEaseUp	:Number = 0.5;
		[Serializable][Inspectable]
		public var steeringEaseDown	:Number = 0.5;
		[Serializable][Inspectable]
		public var accelerationEaseUp:Number = 0.5;
		[Serializable][Inspectable]
		public var accelerationEaseDown:Number = 0.5;
		[Serializable][Inspectable]
		public var brakeEaseUp		:Number = 0.5;
		[Serializable][Inspectable]
		public var breakEaseDown	:Number = 0.5;
		
		public function VehicleUserControlBehaviour()
		{
			name = "VehicleUserControlBehaviour";
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(IVehicleBehaviour, "vehicleBehaviour");
			addSceneReference( KeyboardInputProcess, "inputProcess" );
		}
		
		public function step(dt:Number):void
		{
			if ( !vehicleBehaviour ) return;
			if ( !inputProcess ) return;
			
			if ( inputProcess.isInputDown( accelerateMapping ) )
			{
				vehicleBehaviour.acceleration += (1-vehicleBehaviour.acceleration) * steeringEaseUp;
			}
			else
			{
				vehicleBehaviour.acceleration -= vehicleBehaviour.acceleration * steeringEaseDown;
			}
			
			if ( inputProcess.isInputDown( brakeMapping ) )
			{
				vehicleBehaviour.brake += (1-vehicleBehaviour.brake) * brakeEaseUp;
			}
			else
			{
				vehicleBehaviour.brake -= vehicleBehaviour.brake * breakEaseDown;
			}
			
			if ( inputProcess.isInputDown( steerLeftMapping ) )
			{
				vehicleBehaviour.steering += (-1-vehicleBehaviour.steering) * steeringEaseUp;
			}
			else if ( inputProcess.isInputDown( steerRightMapping ) )
			{
				vehicleBehaviour.steering += (1-vehicleBehaviour.steering) * steeringEaseUp;
			}
			else
			{
				vehicleBehaviour.steering -= vehicleBehaviour.steering * steeringEaseDown;
			}
		}
		
	}
}