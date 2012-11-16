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
	import __AS3__.vec.Vector;
	
	public class VertexBooleanUtil
	{
		/*
		static public function union( verticesA:Vector.<Vertex>, verticesB:Vector.<Vertex> ):Vector.<Vector.<Vertex>>
		{
			var listA:VertexList = PolyShapeUtils.convertToVertexList( verticesA );
			var listB:VertexList = PolyShapeUtils.convertToVertexList( verticesB );
			intersectShapes( listA, listB );
			markOutsideEdges( listA, listB );
			markOutsideEdges( listB, listA );
			return mergeShapes( listA, listB );
		}
		
		static public function subtract( verticesA:Vector.<Vertex>, verticesB:Vector.<Vertex> ):Vector.<Vector.<Vertex>>
		{
			var listA:VertexList = PolyShapeUtils.convertToVertexList( verticesA );
			var listB:VertexList = PolyShapeUtils.convertToVertexList( verticesB );
			intersectShapes( listA, listB );
			markOutsideEdges( listA, listB );
			markInsideEdges( listB, listA );
			return mergeShapes( listA, listB );
		}
		
		static public function intersect( verticesA:Vector.<Vertex>, verticesB:Vector.<Vertex> ):Vector.<Vector.<Vertex>>
		{
			var listA:VertexList = PolyShapeUtils.convertToVertexList( verticesA );
			var listB:VertexList = PolyShapeUtils.convertToVertexList( verticesB );
			intersectShapes( listA, listB );
			markInsideEdges( listA, listB );
			markInsideEdges( listB, listA );
			return mergeShapes( listA, listB );
		}


		
		// Private methods //////////////////////////////////////////////////
		
		static private function intersectShapes( listA:VertexList, listB:VertexList ):void
		{
			var vertexA:VertexList = listA;
			while ( vertexA )
			{
				var vertexB:VertexList = listB;
				while( vertexB )
				{
					var isect:Vertex = PolyShapeIntersections.intersection( vertexA, vertexA.next, vertexB, vertexB.next );
					
					if ( isect )
					{
						var i1:VertexList = vertexA.insertAfter( new VertexList( isect.x, isect.y ) );
						var i2:VertexList = vertexB.insertAfter( new VertexList( isect.x, isect.y ) );
						i1.intersect = true;
						i2.intersect = true;
						i1.neighbour = i2;
						i2.neighbour = i1;
					}
					
					vertexB = vertexB.next;
					if ( vertexB == listB ) break;
				}
				
				vertexA = vertexA.next;
				if ( vertexA == listA ) break;
			}
		}
		
		static private function markOutsideEdges( listA:VertexList, listB:VertexList ):void
		{
			var vertex:VertexList = listA;
			var inside:Boolean = PolyShapeUtils.windingNumberVL( vertex.x, vertex.y, listB ) > 0;
			while ( vertex )
			{
				if ( vertex.intersect ) 
				{
					vertex.entry = inside;
					inside = !inside;
				}
				vertex = vertex.next;
				if ( vertex == listA ) break;
			}
		}
		
		static private function markInsideEdges( listA:VertexList, listB:VertexList ):void
		{
			var vertex:VertexList = listA;
			var inside:Boolean = PolyShapeUtils.windingNumberVL( vertex.x, vertex.y, listB ) > 0;
			while ( vertex )
			{
				if ( vertex.intersect ) 
				{
					vertex.entry = !inside;
					inside = !inside;
				}
				vertex = vertex.next;
				if ( vertex == listA ) break;
			}
		}
		
		static private function getUnprocessedIsectVertex( startVertex:VertexList ):VertexList
		{
			var current:VertexList = startVertex;
			while ( current )
			{
				if ( current.intersect && current.processed == false && current.entry ) 
				{
					return current;
				}
				current = current.next;
				if ( current == startVertex ) break;
			}
			return null;
		}
		
		static private function mergeShapes( listA:VertexList, listB:VertexList ):Vector.<Vector.<Vertex>>
		{
			var polys:Vector.<Vector.<Vertex>> = new Vector.<Vector.<Vertex>>();
			while( true )
			{
				var startVertex:VertexList = getUnprocessedIsectVertex( listA );
				if (startVertex == null) break
				
				var current:VertexList = startVertex;
				current.processed = true;
				
				var poly:Vector.<Vertex> = new Vector.<Vertex>();
				polys.push( poly );
				poly.push( new Vertex( current.x, current.y ) );
				
				while( true )
				{
					if ( current.entry )
					{
						while( true )
						{
							current = current.next;
							current.processed = true;
							poly.push( new Vertex( current.x, current.y ) );						
							if ( current.intersect ) break;
						}
					}
					else
					{
						while( true )
						{
							current = current.prev;
							poly.push( new Vertex( current.x, current.y ) );
							if ( current.intersect ) break;
						}
					}
					
					current.processed = true;
					current = current.neighbour;
					if ( current == startVertex || current.neighbour == startVertex ) break;
				}
			}
			
			return polys;
		}
		*/
	}
}