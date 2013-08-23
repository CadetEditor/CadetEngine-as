// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.operations
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import cadet.components.geom.IGeometry;
	import cadet.core.IComponent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Connection;
	import cadet2D.components.geom.BezierCurve;
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.CompoundGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	import cadet2D.util.QuadraticBezierUtil;
	import cadet2D.util.VertexUtil;
	
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;

	public class CollapseTransformOperation extends UndoableCompoundOperation
	{
		private var geometry	:IGeometry;
		private var transform	:Transform2D;
		
		public function CollapseTransformOperation( geometry:IGeometry, transform:Transform2D )
		{
			this.geometry = geometry;
			this.transform = transform;
			
			label = "Collapse Transform";
			
			collapseGeometry(geometry);
		}
		
		private function collapseGeometry( geometry:IGeometry ):void
		{
			if ( geometry is CircleGeometry )
			{
				collapseCircle( CircleGeometry(geometry) );
			}
			else if ( geometry is PolygonGeometry )
			{
				collapsePolygon( PolygonGeometry(geometry) );
			}
			else if ( geometry is BezierCurve )
			{
				collapseBezierCurve( BezierCurve(geometry) );
			}
			else if ( geometry is CompoundGeometry )
			{
				collapseCompoundGeometry( CompoundGeometry(geometry) );
			}
		}
		
		private function collapseCompoundGeometry( compoundGeometry:CompoundGeometry ):void
		{
			for each ( var childGeometry:IGeometry in compoundGeometry.children )
			{
				collapseGeometry( childGeometry );
			}
		}
		
		private function collapseCircle( circle:CircleGeometry ):void
		{
			var m:Matrix = transform.matrix;
			m.tx = 0;
			m.ty = 0;
			
			var pt:Point = new Point( circle.x, circle.y );
			pt = m.transformPoint(pt);
			
			addOperation( new ChangePropertyOperation( circle, "x", pt.x ) );
			addOperation( new ChangePropertyOperation( circle, "y", pt.y ) );
			
			addOperation( new ChangePropertyOperation( transform, "matrix", new Matrix(1,0,0,1,transform.x,transform.y ) ) );
			
			transformConnections( m );
		}
		
		private function collapsePolygon( polygon:PolygonGeometry ):void
		{
			var convertToPolygonOperation:ConvertToPolygonOperation = new ConvertToPolygonOperation(polygon);
			addOperation(convertToPolygonOperation);
			
			polygon = convertToPolygonOperation.getResult();
			
			var m:Matrix = transform.matrix;
			m.tx = 0;
			m.ty = 0;
			
			var newVertices:Array = VertexUtil.copy(polygon.vertices);
			VertexUtil.transform( newVertices, m );
			
			addOperation( new ChangePropertyOperation( polygon, "vertices", newVertices ) );
			addOperation( new ChangePropertyOperation( transform, "matrix", new Matrix(1,0,0,1,transform.x,transform.y ) ) );
			
			transformConnections( m );
		}
		
		private function collapseBezierCurve( bezierCurve:BezierCurve ):void
		{
			var m:Matrix = transform.matrix;
			m.tx = 0;
			m.ty = 0;
			
			//var newSegments:Vector.<QuadraticBezier> = QuadraticBezierUtil.clone(bezierCurve.segments);
			var newSegments:Array = QuadraticBezierUtil.clone(bezierCurve.segments);
			QuadraticBezierUtil.transform( newSegments, m );
			
			addOperation( new ChangePropertyOperation( bezierCurve, "segments", newSegments ) );
			addOperation( new ChangePropertyOperation( transform, "matrix", new Matrix(1,0,0,1,transform.x,transform.y ) ) );
			
			transformConnections( m );
		}
		
		private function transformConnections( m:Matrix ):void
		{
			if ( transform.scene == null ) return;
			
			var connections:Vector.<IComponent> = ComponentUtil.getChildrenOfType(transform.scene, Connection, true);
			for each ( var connection:Connection in connections )
			{
				var pt:Point;
				if ( connection.transformA == transform )
				{
					pt = connection.localPosA.toPoint();
					pt = m.transformPoint(pt);
					addOperation( new ChangePropertyOperation( connection, "localPosA", new Vertex(pt.x,pt.y) ) );
				}
				else if ( connection.transformB == transform )
				{
					pt = connection.localPosB.toPoint();
					pt = m.transformPoint(pt);
					addOperation( new ChangePropertyOperation( connection, "localPosB", new Vertex(pt.x,pt.y) ) );
				}
			}
		}
	}
}