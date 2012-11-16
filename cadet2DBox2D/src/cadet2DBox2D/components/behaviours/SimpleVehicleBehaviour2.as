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
	import cadet.components.behaviours.IVehicleBehaviour;
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	public class SimpleVehicleBehaviour2 extends Component implements ISteppableComponent, IVehicleBehaviour
	{
		public function SimpleVehicleBehaviour2()
		{
			super();
		}
		
		public function step(dt:Number):void
		{
		}
		
		
		
		public function set acceleration(value:Number):void
		{
		}
		
		public function get acceleration():Number
		{
			return 0;
		}
		
		public function set brake(value:Number):void
		{
		}
		
		public function get brake():Number
		{
			return 0;
		}
		
		public function set steering(value:Number):void
		{
		}
		
		public function get steering():Number
		{
			return 0;
		}
	}
}