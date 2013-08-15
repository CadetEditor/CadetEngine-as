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
	import cadet2D.geom.Vertex;

	public class RectangleGeometry extends PolygonGeometry
	{
		private const SIZE		:String = "size";
		
		private var _width		:Number;
		private var _height		:Number;
		
		private var corners		:Array;
		
		public function RectangleGeometry( width:Number = 100, height:Number = 100 )
		{
			name = "RectangleGeometry";
			// corners order: TopLeft, TopRight, BottomRight, BottomLeft
			corners = [ new Vertex(0,0), new Vertex(1,0), new Vertex(1,1), new Vertex(0,1) ];
			this.width = width;
			this.height = height;
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( SIZE ) ) {
				validateSize();
			}
			if ( isInvalid( GEOMETRY ) ) {
				validateGeometry();
			}
			super.validateNow();
		}
		
		// Checks to see if the rectangle is regular or not (i.e. not distorted)
		private function isRegular():Boolean
		{	
			if ( corners[1].x != corners[2].x ) return false;
			if ( corners[0].x != corners[3].x ) return false;
			if ( corners[0].y != corners[1].y ) return false;
			if ( corners[2].y != corners[3].y ) return false;
			
			return true;
		}
		
		private function getCornersBy(filterFunc:Function):Array
		{
			var ordered:Array = [];
			trace("unordered "+corners);
			for ( var i:uint = 0; i < corners.length; i ++ ) {
				ordered[i] = corners[i];
			}
			
			ordered.sort(filterFunc);
			trace("ordered "+ordered);
			return ordered;
		}
		
		private function filterByX(a:Vertex, b:Vertex):int
		{
			if ( a.x < b.x ) return -1;
			if ( b.x < a.x ) return 1;
			return 0;
		}
		
		private function filterByY(a:Vertex, b:Vertex):int
		{
			if ( a.y < b.y ) return -1;
			if ( b.y < a.y ) return 1;
			return 0;
		}
		
		private function validateSize():void
		{
			var regular:Boolean = isRegular();
			trace("regular "+regular);
			if (regular) {
				corners[1].x = _width;
				corners[2].x = _width;
				corners[2].y = _height;
				corners[3].y = _height;
			} else {
				var xCorners:Array = getCornersBy(filterByX);
				// find the difference between the two rightMost corners
				var xDiff:Number = xCorners[3].x - xCorners[2].x;
				// set the rightMost corner to the width value
				xCorners[3].x = _width;
				// set the second rightMost corner value to the width - the xDiff
				xCorners[2].x = _width - xDiff;
				
				var yCorners:Array = getCornersBy(filterByY);
				// find the difference between the two bottomMost corners
				var yDiff:Number = yCorners[3].y - yCorners[2].y;
				// set the bottomMost corner to the height value
				yCorners[3].y = _height;
				// set the second bottomMost corner value to the height - the yDiff
				yCorners[2].y = _height - xDiff;
			}
			
			vertices = corners;
		}
		
		private function validateGeometry():void
		{
			corners = vertices;
			invalidate( SIZE );
		}
		
		[Serializable][Inspectable]
		public function set width( value:Number ):void
		{
			_width = value;
			invalidate(SIZE);
		}
		
		public function get width():Number { return _width; }
		
		[Serializable][Inspectable]
		public function set height( value:Number ):void
		{
			_height = value;
			invalidate(SIZE);
		}
		public function get height():Number { return _height; }
		
		override public function centre(transform:Transform2D, useCentroid:Boolean = false):void
		{
			//validateNow();
			super.centre(transform, useCentroid);
		}
	}
}