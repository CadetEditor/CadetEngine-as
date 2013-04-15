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
		protected var _segments		:Array;//Vector.<QuadraticBezier>;
		
		public function BezierCurve()
		{
			name = "BezierCurve";
			_segments = new Array();//Vector.<QuadraticBezier>();
		}
		
		[Serializable]
		public function set segments( value:Array ):void//Vector.<QuadraticBezier> ):void
		{
			_segments = value;
			invalidate("geometry");
		}
		public function get segments():Array//Vector.<QuadraticBezier> 
		{ 
			return _segments; 
		}

	}
}