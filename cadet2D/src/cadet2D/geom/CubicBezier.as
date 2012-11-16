// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.geom
{

	/**
	 * This class wraps 2 BezierSegment classes and exposes 4 vertex positions (rather than the 6 contained within the 2 segments).
	 * This class automatically adjusts the positions of its contained segments when required.
	 * This makes dealing with the BezierSegment class much easier when describing a cubic bezier curve.
	 * @author Jonathan Pace
	 * 
	 */	
	public class CubicBezier
	{
		private var _segmentA		:QuadraticBezier;
		private var _segmentB		:QuadraticBezier;
				
		public function CubicBezier( 	startX:Number = 0, 
										startY:Number = 0, 
										controlAX:Number = 0, 
										controlAY:Number = 0, 
										controlBX:Number = 0, 
										controlBY:Number = 0, 
										endX:Number = 0, 
										endY:Number = 0 
									)
		{
			_segmentA = new QuadraticBezier( startX, startY, controlAX, controlAY );
			_segmentB = new QuadraticBezier( 0, 0, controlBX, controlBY, endX, endY );
			validate();
		}
		
		public function set segmentA( value:QuadraticBezier ):void
		{
			_segmentA = value;
			validate();
		}
		public function get segmentA():QuadraticBezier { return _segmentA; }
		
		public function set segmentB( value:QuadraticBezier ):void
		{
			_segmentB = value;
			validate();
		}
		public function get segmentB():QuadraticBezier { return _segmentB; }
		
		
		public function set startX( value:Number ):void
		{
			_segmentA.startX = value;
		}
		public function get startX():Number { return _segmentA.startX; }
		
		public function set startY( value:Number ):void
		{
			_segmentA.startY = value;
		}
		public function get startY():Number { return _segmentA.startY; }
		
		
		public function set endX( value:Number ):void
		{
			_segmentB.endX = value;
		}
		public function get endX():Number { return _segmentB.endX; }
		
		public function set endY( value:Number ):void
		{
			_segmentB.endY = value;
		}
		public function get endY():Number { return _segmentB.endY; }
		
		
		public function set controlAX( value:Number ):void
		{
			_segmentA.controlX = value;
			validate();
		}
		public function get controlAX():Number { return _segmentA.controlX; }
		
		public function set controlAY( value:Number ):void
		{
			_segmentA.controlY = value;
			validate();
		}
		public function get controlAY():Number { return _segmentA.controlY; }
		
		
		public function set controlBX( value:Number ):void
		{
			_segmentB.controlX = value;
			validate();
		}
		public function get controlBX():Number { return _segmentB.controlX; }
		
		public function set controlBY( value:Number ):void
		{
			_segmentB.controlY = value;
			validate();
		}
		public function get controlBY():Number { return _segmentB.controlY; }
		
		
		private function validate():void
		{
			var dx:Number = segmentA.controlX - _segmentB.controlX;
			var dy:Number = segmentA.controlY - _segmentB.controlY;
			
			_segmentA.endX = _segmentA.controlX - dx*0.5;
			_segmentA.endY = _segmentA.controlY - dy*0.5;
			_segmentB.startX = _segmentA.endX;
			_segmentB.startY = _segmentA.endY;
		}
	}
}