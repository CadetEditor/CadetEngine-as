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
	import flash.geom.Point;
	
	import core.app.dataStructures.ObjectPool;
	

	public class Vertex
	{
		[Serializable]
		public var x			:Number
		[Serializable]
		public var y			:Number
		
		public function Vertex(x:Number = 0, y:Number = 0)
		{
			this.x = x
			this.y = y	
		}
		
		public function setValues( x:Number, y:Number ):void
		{
			this.x = x;
			this.y = y;
		}
		
		public function toPoint():Point
		{
			return new Point( x, y );
		}
		
		public function clone():Vertex
		{
			var v:Vertex = ObjectPool.getInstance(Vertex);
			v.setValues(x,y);
			return v;
		}
	}
}