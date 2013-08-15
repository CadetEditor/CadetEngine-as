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
	import cadet2D.components.transforms.Transform2D;
	
	import flash.geom.Matrix;
	import flash.geom.Point;

	[Serializable]
	public class CircleGeometry extends AbstractGeometry
	{
		[Serializable]
		public var x:Number = 0;
		[Serializable]
		public var y:Number = 0;
		private var _radius		:Number;
		
		public function CircleGeometry( radius:Number = 50 )
		{
			super("Circle");
			
			this.radius = radius;
		}
				
		[Serializable][Inspectable]
		public function set radius( value:Number ):void
		{
			_radius = value;
			invalidate("geometry");
		}
		public function get radius():Number { return _radius; }
		
		public function centre(transform:Transform2D):void
		{
			//addOperation( new ChangePropertyOperation( circle, "x", 0 ) );
			//addOperation( new ChangePropertyOperation( circle, "y", 0 ) );
			x = 0;
			y = 0;
			
			var m:Matrix = new Matrix( transform.matrix.a, transform.matrix.b, transform.matrix.c, transform.matrix.d );
			var pt:Point = new Point(x, y);
			pt = m.transformPoint(pt);
			
			//addOperation( new ChangePropertyOperation( transform, "x", transform.x+pt.x ) );
			//addOperation( new ChangePropertyOperation( transform, "y", transform.y+pt.y ) );
			transform.x = transform.x+pt.x;
			transform.y = transform.y+pt.y;
			
			transformConnections( m, transform );
		}
	}
}