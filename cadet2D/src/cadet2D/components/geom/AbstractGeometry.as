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
	
	import cadet.components.geom.IGeometry;
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Connection;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	
	public class AbstractGeometry extends Component implements IGeometry
	{
		public function AbstractGeometry( name:String = "AbstractGeometry" )
		{
			super( name );
		}
		
		protected function transformConnections( m:Matrix, transform:Transform2D ):void
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
					connection.localPosA = new Vertex(pt.x, pt.y);
					//addOperation( new ChangePropertyOperation( connection, "localPosA", new Vertex(pt.x,pt.y) ) );
				}
				else if ( connection.transformB == transform )
				{
					pt = connection.localPosB.toPoint();
					pt = m.transformPoint(pt);
					connection.localPosB = new Vertex(pt.x, pt.y);
					//addOperation( new ChangePropertyOperation( connection, "localPosB", new Vertex(pt.x,pt.y) ) );
				}
			}
		}
	}
}