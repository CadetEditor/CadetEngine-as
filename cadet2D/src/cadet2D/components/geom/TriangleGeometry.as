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
	import cadet2D.geom.Vertex;
	
	[Serializable]
	public class TriangleGeometry extends PolygonGeometry
	{
		protected var _flipVertical		:Boolean = false
		protected var _tipRatio			:Number;
		private var _width				:Number;
		private var _height				:Number;
		
		public function TriangleGeometry()
		{
			name = "TriangleGeometry";
			width = 100;
			height = 100;
			tipRatio = 0;
			flipVertical = false;
		}
		
		override public function validateNow() : void
		{
			if ( isInvalid( "geometry" ) )
			{
				validateGeometry();
			}
			super.validateNow();
		}
				
		protected function validateGeometry():void
		{
			var v1:Vertex = new Vertex();
			v1.x = _tipRatio * _width;
			v1.y = _flipVertical ? _height : 0;
			
			var v2:Vertex = new Vertex();
			v2.x = _width;
			v2.y = _flipVertical ? 0 : _height;
			
			var v3:Vertex = new Vertex();
			v3.x = 0;
			v3.y = _flipVertical ? 0 : _height;
			
			var newVertices:Array = [];
			newVertices.push( v1, v2, v3 );
			vertices = newVertices
		}
								
		[Serializable][Inspectable]
		public function set flipVertical( value:Boolean ):void
		{
			_flipVertical = value;
			invalidate( "geometry" );
		}
		public function get flipVertical():Boolean { return _flipVertical; }
		
		[Serializable]
		public function set tipRatio( value:Number ):void
		{
			_tipRatio = value;
			invalidate( "geometry" );
		}
		public function get tipRatio():Number { return _tipRatio; }
		
		[Serializable][Inspectable]
		public function set width( value:Number ):void
		{
			_width = value;
			invalidate("geometry");
		}
		
		public function get width():Number { return _width; }
		
		[Serializable][Inspectable]
		public function set height( value:Number ):void
		{
			_height = value;
			invalidate("geometry");
		}
		public function get height():Number { return _height; }
	}
}