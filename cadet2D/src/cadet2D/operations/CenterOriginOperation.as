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
	import flash.geom.Rectangle;
	
	import cadet.components.geom.IGeometry;
	import cadet.core.IComponent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Connection;
	import cadet2D.components.geom.BezierCurve;
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	import cadet2D.util.QuadraticBezierUtil;
	import cadet2D.util.VertexUtil;
	
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	

	public class CenterOriginOperation extends UndoableCompoundOperation
	{
		private var geometry	:IGeometry;
		private var transform	:Transform2D;
		private var useCentroid	:Boolean;
		
		public function CenterOriginOperation( geometry:IGeometry, transform:Transform2D, useCentroid:Boolean = false )
		{
			this.geometry = geometry;
			this.transform = transform;
			this.useCentroid = useCentroid;
			label = "Center Origin";
			
			if ( geometry is CircleGeometry )
			{
				centerCircle( CircleGeometry(geometry) );
			}
			else if ( geometry is PolygonGeometry )
			{
				centerPolygon( PolygonGeometry(geometry) );
			}
			else if ( geometry is BezierCurve )
			{
				centerBezierCurve( BezierCurve(geometry) );
			}
		}
		
		private function centerCircle( circle:CircleGeometry ):void
		{
			addOperation( new ChangePropertyOperation( circle, "x", 0 ) );
			addOperation( new ChangePropertyOperation( circle, "y", 0 ) );
			
			var m:Matrix = new Matrix( transform.matrix.a, transform.matrix.b, transform.matrix.c, transform.matrix.d );
			var pt:Point = new Point(circle.x,circle.y);
			pt = m.transformPoint(pt);
			
			addOperation( new ChangePropertyOperation( transform, "x", transform.x+pt.x ) );
			addOperation( new ChangePropertyOperation( transform, "y", transform.y+pt.y ) );
			
			transformConnections( m );
		}
		
		private function centerPolygon( polygon:PolygonGeometry ):void
		{
			var convertToPolygonOperation:ConvertToPolygonOperation = new ConvertToPolygonOperation(polygon);
			addOperation(convertToPolygonOperation);
			
			polygon = convertToPolygonOperation.getResult();
			
			
			var centerX:Number;
			var centerY:Number;
			
			if ( useCentroid )
			{
				var center:Vertex = VertexUtil.computeCentroid(polygon.vertices);
				centerX = center.x;
				centerY = center.y;
			}
			else
			{
				var bounds:Rectangle = VertexUtil.getBounds(polygon.vertices);
				centerX = bounds.x + bounds.width*0.5;
				centerY = bounds.y + bounds.height*0.5;
			}
			
			var newVertices:Array = VertexUtil.copy(polygon.vertices);
			var m:Matrix = new Matrix( 1, 0, 0, 1, -centerX, -centerY );
			VertexUtil.transform( newVertices, m );
			
			transformConnections( m );
			
			addOperation( new ChangePropertyOperation( polygon, "vertices", newVertices ) );
			
			m = new Matrix( transform.matrix.a, transform.matrix.b, transform.matrix.c, transform.matrix.d );
			var pt:Point = new Point(centerX,centerY);
			pt = m.transformPoint(pt);
			
			
			addOperation( new ChangePropertyOperation( transform, "x", transform.x+pt.x ) );
			addOperation( new ChangePropertyOperation( transform, "y", transform.y+pt.y ) );
			
			
		}
		
		private function centerBezierCurve( bezierCurve:BezierCurve ):void
		{
			var bounds:Rectangle = QuadraticBezierUtil.getBounds( bezierCurve.segments );
			var centerX:Number = bounds.x + bounds.width*0.5;
			var centerY:Number = bounds.y + bounds.height*0.5;
			
			//var newSegments:Vector.<QuadraticBezier> = QuadraticBezierUtil.clone(bezierCurve.segments);
			var newSegments:Array = QuadraticBezierUtil.clone(bezierCurve.segments);
			var m:Matrix = new Matrix( 1, 0, 0, 1, -centerX, -centerY );
			QuadraticBezierUtil.transform( newSegments, m );
			transformConnections( m );
			
			addOperation( new ChangePropertyOperation( bezierCurve, "segments", newSegments ) );
			
			m = new Matrix( transform.matrix.a, transform.matrix.b, transform.matrix.c, transform.matrix.d );
			var pt:Point = new Point(centerX,centerY);
			pt = m.transformPoint(pt);
			
			addOperation( new ChangePropertyOperation( transform, "x", transform.x+pt.x ) );
			addOperation( new ChangePropertyOperation( transform, "y", transform.y+pt.y ) );
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