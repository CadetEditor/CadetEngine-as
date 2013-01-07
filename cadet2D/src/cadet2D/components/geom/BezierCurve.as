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
	import cadet2D.geom.QuadraticBezier;

	public class BezierCurve extends AbstractGeometry
	{
		protected var _segments		:Vector.<QuadraticBezier>;
		
		public function BezierCurve()
		{
			name = "BezierCurve";
			_segments = new Vector.<QuadraticBezier>();
		}
		
		[Serializable]
		public function set segments( value:Vector.<QuadraticBezier> ):void
		{
			_segments = value;
			invalidate("geometry");
		}
		public function get segments():Vector.<QuadraticBezier> { return _segments; }

	}
}