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
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	import cadet2D.util.VertexUtil;
	
	/**
	 * This class serves a base class for all geometry consisting of a series of points. 
	 * @author Jonathan
	 * 
	 */	
	public class PolygonGeometry extends AbstractGeometry
	{
		protected const GEOMETRY		:String = "geometry";
		protected var _vertices			:Array;
		
		public function PolygonGeometry( name:String = "PolygonGeometry" )
		{
			super( name );
			
			init();
		}
		
		private function init():void
		{
			_vertices = [];
		}
		
		override public function dispose():void
		{
			super.dispose();
			init();
		}
		
		public function set vertices(value:Array):void
		{
			_vertices = value;
			invalidate(GEOMETRY);
		}
		public function get vertices():Array { return _vertices }
				
		[Serializable(alias="vertices")]
		public function set serializedVertices(value:String):void
		{
			var newVertices:Array = new Array();
			var split:Array = value.split(":");
			var L:int = split.length;
			for (var i:int = 0; i < L; i++)
			{
				var subSplit:Array = split[i].split(",")
				newVertices[i] = new Vertex(Number(subSplit[0]), Number(subSplit[1]));
			}
			vertices = newVertices;
		}
		
		public function get serializedVertices():String
		{
			var output:String = ""
			var L:int = vertices.length;
			for (var i:int = 0; i < L; i++)
			{
				output += vertices[i].x + "," + vertices[i].y
				if (i != L-1) {
					output += ":"
				}
			}
			return output
		}
		
		public function centre(transform:Transform2D, useCentroid:Boolean = false):void
		{
			//var convertToPolygonOperation:ConvertToPolygonOperation = new ConvertToPolygonOperation(polygon);
			//addOperation(convertToPolygonOperation);
			
			//polygon = convertToPolygonOperation.getResult();
			//var clonedVertices:Array = VertexUtil.copy(polygon.vertices);
			//result.vertices = clonedVertices;
			
			var centerX:Number;
			var centerY:Number;
			
			if ( useCentroid )
			{
				var center:Vertex = VertexUtil.computeCentroid(vertices);
				centerX = center.x;
				centerY = center.y;
			}
			else
			{
				var bounds:Rectangle = VertexUtil.getBounds(vertices);
				centerX = bounds.x + bounds.width*0.5;
				centerY = bounds.y + bounds.height*0.5;
			}
			
			var newVertices:Array = VertexUtil.copy(vertices);
			var m:Matrix = new Matrix( 1, 0, 0, 1, -centerX, -centerY );
			VertexUtil.transform( newVertices, m );
			
			transformConnections( m, transform );
			
			//addOperation( new ChangePropertyOperation( polygon, "vertices", newVertices ) );
			vertices = newVertices;
			
			m = new Matrix( transform.matrix.a, transform.matrix.b, transform.matrix.c, transform.matrix.d );
			var pt:Point = new Point(centerX,centerY);
			pt = m.transformPoint(pt);
			
			//addOperation( new ChangePropertyOperation( transform, "x", transform.x+pt.x ) );
			//addOperation( new ChangePropertyOperation( transform, "y", transform.y+pt.y ) );
			transform.x = transform.x+pt.x;
			transform.y = transform.y+pt.y;
		}
	}
}