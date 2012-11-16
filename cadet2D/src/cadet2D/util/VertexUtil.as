// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.util
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import cadet2D.geom.Vertex;
	import cadet2D.geom.VertexList;
	
	public class VertexUtil
	{
		static public function weld( vertices:Array, minimumDistance:Number ):void
		{
			var L:int = vertices.length;
			var dis:Number = minimumDistance*minimumDistance;
			for ( var i:int = 0; i < L; i++ )
			{
				var vertexA:Vertex = vertices[i];
				
				for ( var j:int = (i+1); j < L; j++ )
				{
					var vertexB:Vertex = vertices[j];
					var dx:Number = vertexB.x - vertexA.x;
					var dy:Number = vertexB.y - vertexA.y;
					var d:Number = dx*dx + dy*dy;
					
					if ( d > dis ) continue;
					
					vertexA.x += dx*0.5;
					vertexA.y += dy*0.5;
					
					vertices.splice(j,1);
					L--
					break;
				}
			}
		}
		
		/**
		 * Selectively removes vertices from the supplied array that lie on or very near (below the tolerance) a straight line.
		 *  
		 * @param vertices
		 * @param tolerance
		 * @return 
		 * 
		 */		
		static public function simplify( vertices:Array, tolerance:Number = 1 ):Array
		{
			var marks:Array = []
			marks[0] = marks[vertices.length-1] = true;
			simplifyRecur( vertices, tolerance, 0, vertices.length-1, marks );
			
			var newVertices:Array = [];
			var m:int = 0;
			for ( var i:int = 0; i < vertices.length; i++ )
			{
				if ( !marks[i] ) continue;
				newVertices[m++] = vertices[i];
			}
			return newVertices;
		}
		
		static private function simplifyRecur( vertices:Array, tolerance:Number, j:int, k:int, marks:Array ):void
		{
			if ( k <= j+1 ) return;
			
			var maxi:int = j;
			var maxd2:Number = 0;
			var tol2:Number = tolerance*tolerance;
			
			var s0:Vertex = vertices[j];
			var s1:Vertex = vertices[k];
			var u:Vertex = new Vertex( s1.x-s0.x, s1.y-s0.y );
			var cu:Number = u.x*u.x + u.y*u.y;
			
			var w:Vertex;
			var Pb:Vertex;
			var b:Number;
			var cw:Number;
			var dv2:Number;
			var dx:Number;
			var dy:Number;
			
			for ( var i:int = j + 1; i < k; i++ )
			{
				var v:Vertex = vertices[i];
				w = new Vertex( v.x-s0.x, v.y-s0.y );
				cw = w.x*u.x + w.y*u.y;
				if ( cw <= 0 ) 
				{
					dv2 = w.x*w.x + w.y*w.y;
				}
				else if ( cu <= cw ) 
				{
					dx = v.x - s1.x;
					dy = v.y - s1.y;
					dv2 = dx*dx + dy*dy;
				}
				else 
				{
					b = cw / cu;
					Pb = new Vertex( s0.x + b*u.x, s0.y + b*u.y );
					dx = v.x-Pb.x;
					dy = v.y-Pb.y;
					dv2 = dx*dx + dy*dy;
				}
				
				if ( dv2 <= maxd2 ) continue;
				
				maxi = i;
				maxd2 = dv2;
			}
			
			if ( maxd2 > tol2 )
			{
				marks[maxi] = true;
				
				simplifyRecur( vertices, tolerance, j, maxi, marks );
				simplifyRecur( vertices, tolerance, maxi, k, marks );
			}
		}
		
		
		static public function transform(vertices:Array, matrix:Matrix):void
		{
			for each ( var vertex:Vertex in vertices ) 
			{
				var p:Point = matrix.transformPoint( new Point( vertex.x, vertex.y ) );
				vertex.x = p.x;
				vertex.y = p.y;
			}
		}
				
		static public function copy(vertices:Array):Array
		{
			var newVertices:Array = [];
			for ( var i:int = 0; i < vertices.length; i++ )
			{
				newVertices[i] = new Vertex( vertices[i].x, vertices[i].y );
			}
			return newVertices;
		}
		
		static public function getBounds( vertices:Array, rect:Rectangle = null ):Rectangle
		{
			var minX:Number = Number.POSITIVE_INFINITY;
			var minY:Number = Number.POSITIVE_INFINITY;
			var maxX:Number = Number.NEGATIVE_INFINITY;
			var maxY:Number = Number.NEGATIVE_INFINITY;
			
			for each ( var vertex:Vertex in vertices )
			{
				minX = vertex.x < minX ? vertex.x : minX;
				minY = vertex.y < minY ? vertex.y : minY;
				maxX = vertex.x > maxX ? vertex.x : maxX;
				maxY = vertex.y > maxY ? vertex.y : maxY;
			}
			
			if ( !rect ) return new Rectangle( minX, minY, maxX-minX, maxY-minY );
			
			rect.left = minX;
			rect.right = maxX;
			rect.top = minY;
			rect.bottom = maxY;
			return rect;
			
		}
		
		
		static public function hittest(px:Number, py:Number, vertices:Array):Boolean
		{
			return windingNumber(px,py,vertices) != 0
		}
		
		static public function windingNumber(px:Number, py:Number, vertices:Array):int
		{
			var wn:int = 0
			const L:int = vertices.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var vertex:Vertex = vertices[i];
				var nextVertex:Vertex = i == (L-1) ? vertices[0] : vertices[i+1];
				
				if (vertex.y <= py) 
				{
					if(nextVertex.y > py) 
					{
						if (isLeft(vertex, nextVertex, px, py) == false) 
						{
							++wn;
						}
					}
				}
				else 
				{
					if (nextVertex.y <= py) 
					{
						if (isLeft(vertex, nextVertex, px, py) == true) 
						{
							--wn;
						}
					}
				}
			}
			
			return wn;
		}
		
		static public function isConvex(vertices:Array):Boolean
		{
			return !isConcave(vertices)
		}
		
		static public function isConcave(vertices:Array, clockwise:Boolean = true):Boolean
		{
			
			var n:int = vertices.length
			if (n < 3) return false
			for (var i:int = 0; i < n; i++)	
			{
				var j:int = (i+1) % n
				var k:int = (i+2) % n
				var z:Number = (vertices[j].x - vertices[i].x) * (vertices[k].y - vertices[j].y)
				z -= (vertices[j].y - vertices[i].y) * (vertices[k].x - vertices[j].x)
				
				if (z < 0) {
					if (clockwise) {
						return true
					}
				}
				
				if (z > 0) {
					if (!clockwise) {
						return true
					}
				}	
			}
			
			return false
		}
		
		static public function getArea(vertices:Array):Number
		{
			var n:int = vertices.length
			var a:Number = 0
			for (var i:int = 0; i < n-1; i++)
			{
				a += vertices[i].x*vertices[i+1].y - vertices[i+1].x*vertices[i].y
			}
			return a * 0.5
		}
		
		static public function computeCentroid( vertices:Array ):Vertex
		{
			var c:Vertex = new Vertex();
			var area:Number = 0;
			var p1X:Number = 0;
			var p1Y:Number = 0;
			var inv3:Number=  1.0 / 3.0;
			
			var length:int = vertices.length;
			for ( var i:int = 0; i < length; i++ )
			{
				var p2:Vertex = vertices[i];
				var p3:Vertex = i + 1 >= length ? vertices[0] : vertices[i+1];
				
				var e1X:Number = p2.x - p1X;
				var e1Y:Number = p2.y - p1Y;
				var e2X:Number = p3.x - p1X;
				var e2Y:Number = p3.y - p1Y;
				var D:Number = (e1X * e2Y - e1Y * e2X);
				var triangleArea:Number = 0.5 * D;
				area += triangleArea;
				c.x += triangleArea * inv3 * (p1X + p2.x + p3.x);
				c.y += triangleArea * inv3 * (p1Y + p2.y + p3.y);
			}
			
			c.x *= 1.0 / area;
			c.y *= 1.0 / area;
			
			return c;
		}
		
		static public function getClosestVertex( x:Number, y:Number, vertices:Array ):Vertex
		{
			var closestDistance:Number = Number.MAX_VALUE;
			var closestVertex:Vertex;
			for each ( var vertex:Vertex in vertices )
			{
				var dx:Number = vertex.x - x;
				var dy:Number = vertex.y - y;
				var d:Number = dx*dx + dy*dy
				if ( d < closestDistance )
				{
					closestDistance = d;
					closestVertex = vertex;
				}
			}
			return closestVertex;
		}
		
		static public function getIntersections( verticesA:Array, verticesB:Array ):Array
		{
			var intersections:Array = [];
			for ( var i:int = 0; i < verticesA.length; i++ )
			{
				var vertexA_1:Vertex = verticesA[i];
				var vertexA_2:Vertex = verticesA[i == verticesA.length-1 ? 0 : i+1];
				
				for ( var j:int = 0; j < verticesB.length; j++ )
				{
					var vertexB_1:Vertex = verticesB[j];
					var vertexB_2:Vertex = verticesB[j == verticesB.length-1 ? 0 : j+1];
					
					var isect:Vertex = intersection( vertexA_1, vertexA_2, vertexB_1, vertexB_2 );
					if ( isect )
					{
						intersections.push(isect);
					}
				}
			}
			return intersections;
		}
		
		
		private static const EPSILON	:Number = 0.0000001
		static public function intersection( a0:Vertex, a1:Vertex, b0:Vertex, b1:Vertex, limit:Boolean = true ):Vertex
		{
			var u:Vertex = new Vertex((a1.x+EPSILON)-(a0.x+EPSILON), (a1.y+EPSILON)-(a0.y+EPSILON));
			var v:Vertex = new Vertex((b1.x+EPSILON)-(b0.x+EPSILON), (b1.y+EPSILON)-(b0.y+EPSILON));
			var w:Vertex = new Vertex((a0.x+EPSILON)-(b0.x+EPSILON), (a0.y+EPSILON)-(b0.y+EPSILON));
			var D:Number = u.x * v.y - u.y * v.x
						
			if (Math.abs(D) < EPSILON) return null
			
			var sI:Number = (v.x * w.y - v.y * w.x) / D
			if ( limit )
			{
				if (sI < 0 || sI > 1) return null
				var tI:Number = (u.x * w.y - u.y * w.x) / D
				if (tI < 0 || tI > 1) return null
			}
			
			return new Vertex(a0.x + sI * u.x, a0.y + sI * u.y)
		}
		
		
		
		/**
		 * Returns true if [px,py] is to the left of the line created by v0->v1, and false if it lies to the right
		 * @param v0
		 * @param v1
		 * @param px
		 * @param py
		 * @return 
		 * 
		 */		
		static public function isLeft(v0:Vertex, v1:Vertex, px:Number, py:Number):Boolean
		{
			return ((v1.x - v0.x)*(py - v0.y) - (px - v0.x)*(v1.y-v0.y)) < 0;
		}
				
		static internal function toVertexList(vertices:Array):VertexList
		{
			if ( vertices.length == 0 ) return null;
			
			var firstVertex:VertexList = new VertexList(vertices[0].x, vertices[0].y)
			var vertexList:VertexList = firstVertex
			for (var i:int = 1; i < vertices.length; i++)
			{
				var vertex:Vertex = vertices[i]
				vertexList = vertexList.next = new VertexList(vertex.x, vertex.y);
			}
			vertexList.next = firstVertex
			
			return firstVertex
		}
		
		
		static public function makeConvex( vertices:Array ):Array
		{
			var returnShapes:Array = [];
			
			var bounds:Rectangle = getBounds(vertices);
			var diameter:Number = Math.sqrt(bounds.width*bounds.width + bounds.height*bounds.height);
			
			var openList:Array = [toVertexList(vertices)];
			
			var ray1:Vertex = new Vertex();
			var ray2:Vertex = new Vertex();
			
			var cutoutIsect:VertexList;
			var remainingIsect:VertexList;
			
			var iter:int = 0;
			
			while ( openList.length > 0 )
			{
				iter++;
				if ( iter > 200 )
				{
					break;
				}
				
				var currentShapeStart:VertexList = openList.pop();
				var currentShape:Array = currentShapeStart.toArray();
				if ( currentShape.length < 3 ) continue;
				
				if ( currentShape.length == 3 || isConvex(currentShape) )
				{
					returnShapes.push(currentShape);
					continue;
				}
				
				var v:VertexList = currentShapeStart;
				
				do
				{
					if ( isLeft(v, v.next, v.next.next.x, v.next.next.y) == false )
					{
						v = v.next;
						continue;
					}
					
					// Found notch
					var dx:Number = (v.next.x - v.x);
					var dy:Number = (v.next.y - v.y);
					var d:Number = Math.sqrt(dx*dx+dy*dy);
					dx /= d;
					dy /= d;
					
					ray1.x = v.next.x + dx;
					ray1.y = v.next.y + dy;
					ray2.x = v.next.x + dx * diameter;
					ray2.y = v.next.y + dy * diameter;
					
					
					var isectInfo:Object = getClosestLineToShapeIntersection( ray1, ray2, currentShapeStart, 0 );
					if ( !isectInfo )
					{
						v = v.next;
						continue;
					}
					
					
					var isect:Vertex = isectInfo.isect;
					var vertexBeforeIsect:VertexList = isectInfo.v;
					var vertexAfterIsect:VertexList = vertexBeforeIsect.next;
					
					
					if ( isectInfo.d < 1 )
					{
						cutoutIsect = new VertexList(vertexBeforeIsect.x, vertexBeforeIsect.y);
						cutoutIsect.next = v.next;
						getPrevVertex(vertexBeforeIsect).next = cutoutIsect;
						openList.push(cutoutIsect);
						
						remainingIsect = new VertexList(vertexBeforeIsect.x, vertexBeforeIsect.y);
						v.next = remainingIsect;
						remainingIsect.next = vertexBeforeIsect.next;
						openList.push(remainingIsect);
					}
					else
					{
						cutoutIsect = new VertexList(isect.x, isect.y);
						cutoutIsect.next = v.next;
						vertexBeforeIsect.next = cutoutIsect;
						openList.push(cutoutIsect);
						
						remainingIsect = new VertexList(isect.x, isect.y);
						v.next = remainingIsect;
						remainingIsect.next = vertexAfterIsect;
						openList.push(remainingIsect);
					}
					
					v = currentShapeStart;
					break;				
				}
				while( v != currentShapeStart )
			}
			
			
			return returnShapes;
		}
		
		static private function cloneList( start:VertexList ):VertexList
		{
			var newList:VertexList;
			var v:VertexList = start;
			var newV:VertexList = newList;
			do
			{
				if ( !newV )
				{
					newList = newV = new VertexList(v.x, v.y);
				}
				
				v = v.next;
				if ( v != start )
				{
					newV = newV.next = new VertexList(v.x, v.y);
				}
			}
			while (v != start)
			
			newV.next = newList;
			return newList;
		}
		
		static private function getPrevVertex( vertex:VertexList ):VertexList
		{
			var v:VertexList = vertex;
			while ( v.next != vertex )
			{
				v = v.next;
			}
			return v;
		}
		
		static private function getClosestLineToShapeIntersection( v1:Vertex, v2:Vertex, shapeStart:VertexList, minDistance:Number ):Object
		{
			var v:VertexList = shapeStart;
			
			var closestDistance:Number = Number.POSITIVE_INFINITY;
			var closestIsect:Object;
			
			do
			{
				var isect:Vertex = intersection(v1, v2, v, v.next );
				if ( isect )
				{
					var dx:Number = v1.x-isect.x;
					var dy:Number = v1.y-isect.y;
					var d:Number = Math.sqrt(dx*dx+dy*dy);
					
					if ( d < closestDistance && d > minDistance )
					{
						closestDistance = d;
						closestIsect = {isect:isect, v:v, d:closestDistance};
					}
				} 
				
				v = v.next;
			}
			while ( v != shapeStart )
			
			return closestIsect;
		}
		
		
		public static function getPolygonStrip( vertices:Array, thickness:Number, offset:Number = 0 ):Array
		{
			var shapes:Array = [];
			const halfThickness:Number = thickness*0.5;
			
			const L:int = vertices.length-1;
			for ( var i:int = 0; i < L; i++ )
			{
				var vertex:Vertex = vertices[i];
				var nextVertex:Vertex = vertices[i+1];
				
				var dx:Number = nextVertex.x - vertex.x;
				var dy:Number = nextVertex.y - vertex.y;
				var d:Number = Math.sqrt(dx*dx + dy*dy);
				dx /= d;
				dy /= d;
				
				
				
				var v0:Vertex = new Vertex( vertex.x + dy * (halfThickness + offset), vertex.y - dx * (halfThickness + offset) );
				var v1:Vertex = new Vertex( nextVertex.x + dy * (halfThickness + offset), nextVertex.y - dx * (halfThickness + offset) );
				var v2:Vertex = new Vertex( nextVertex.x - dy * (halfThickness - offset), nextVertex.y + dx * (halfThickness - offset) );
				var v3:Vertex = new Vertex( vertex.x - dy * (halfThickness - offset), vertex.y + dx * (halfThickness - offset) );
				
				var shape:Array = [v0, v1, v2, v3];
				
				
				if ( i > 0 )
				{
					var prevShape:Array = shapes[i-1];
					
					var isect:Vertex = intersection( v1, v0, prevShape[0], prevShape[1], false );
					
					if ( isect )
					{
						v0.x = prevShape[1].x = isect.x;
						v0.y = prevShape[1].y = isect.y;
					}
					
					isect = intersection( v2, v3, prevShape[3], prevShape[2], false );
					if ( isect )
					{
						v3.x = prevShape[2].x = isect.x;
						v3.y = prevShape[2].y = isect.y;
					}
				}
				
				shapes.push(shape);
			}
			
			return shapes;
		}
	}
}