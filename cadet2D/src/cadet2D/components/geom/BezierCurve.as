// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.geom
{	
	public class BezierCurve extends AbstractGeometry
	{
		protected var _segments		:Array;
		
		public function BezierCurve()
		{
			name = "BezierCurve";
			_segments = [];
		}
		
		[Serializable]
		public function set segments( value:Array ):void
		{
			_segments = value;
			invalidate("geometry");
		}
		public function get segments():Array { return _segments; }

	}
}