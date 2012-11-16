// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.renderPipeline.flash.components.skins
{
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.geom.Vertex;
	import cadet2D.util.VertexUtil;
	
	public class GeometryDebugSkin extends GeometrySkin
	{
		public function GeometryDebugSkin(lineThickness:Number=1, lineColor:uint=0xFFFFFF, lineAlpha:Number=0.7, fillColor:uint=0xFFFFFF, fillAlpha:Number=0.04)
		{
			super(lineThickness, lineColor, lineAlpha, fillColor, fillAlpha);
			name = "GeometryDebugSkin";
		}
		
		override protected function renderPolygon( polygon:PolygonGeometry, graphics:Graphics ):void
		{
			var shapes:Array = VertexUtil.makeConvex(polygon.vertices);
			
			for each ( var vertices:Array in shapes )
			{
				var firstVertex:Vertex = vertices[0];
				if ( !firstVertex ) return;
				
				graphics.lineStyle( lineThickness, lineColor, lineAlpha, false, LineScaleMode.NONE );
				graphics.beginFill( fillColor, fillAlpha );
				
				graphics.moveTo( firstVertex.x, firstVertex.y );
				for ( var i:int = 0; i < vertices.length; i++ )
				{
					var vertex:Vertex = vertices[i];
					graphics.lineTo( vertex.x, vertex.y );
				}
				graphics.lineTo( firstVertex.x, firstVertex.y );
				graphics.endFill();
			}
		}
		
	}
}