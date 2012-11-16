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
	import cadet.core.IComponent;
	
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	
	public class RectangleGeometry extends PolygonGeometry
	{
		private var _width		:Number;
		private var _height		:Number;
		
		private var corners		:Array;
		
		public function RectangleGeometry( width:Number = 100, height:Number = 100 )
		{
			name = "RectangleGeometry";
			corners = [ new Vertex(0,0), new Vertex(1,0), new Vertex(1,1), new Vertex(0,1) ];
			this.width = width;
			this.height = height;
		}
		
		override public function validateNow():void
		{
//			if ( isInvalid( "size" ) )
//			{
//				validateSize();
//			}
			super.validateNow();
		}
		
		private function validateSize():void
		{
			corners[1].x = _width;
			corners[2].x = _width;
			corners[2].y = _height;
			corners[3].y = _height;
			vertices = corners;
		}
		
		[Serializable][Inspectable]
		public function set width( value:Number ):void
		{
			_width = value;
			//invalidate("size");
			validateSize();
		}
		
		public function get width():Number { return _width; }
		
		[Serializable][Inspectable]
		public function set height( value:Number ):void
		{
			_height = value;
			//invalidate("size");
			validateSize();
		}
		public function get height():Number { return _height; }
		
		override public function centre(transform:Transform2D, useCentroid:Boolean = false):void
		{
			//validateNow();
			super.centre(transform, useCentroid);
		}
	}
}