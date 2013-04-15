// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.behaviours
{
	import cadet.components.geom.IGeometry;
	import cadet.core.Component;
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.geom.RectangleGeometry;
	import cadet2D.components.processes.FootprintManagerProcess;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.util.VertexUtil;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class GeometryFootprintBehaviour extends Component implements IFootprint
	{
		private var _x			:int;
		private var _y			:int;
		private var _sizeX		:int;
		private var _sizeY		:int;
		
		private var _values		:Array;
		
		private var _footprintManager	:FootprintManagerProcess;
		private var _geometry			:IGeometry;
		
		private var _transform	:Transform2D
		
		public function GeometryFootprintBehaviour()
		{
			name = "GeometryFootprintBehaviour";
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(Transform2D, "transform");
			addSiblingReference(IGeometry, "geometry");
			addSceneReference( FootprintManagerProcess, "footprintManager" );
		}
		
		override protected function removedFromScene():void
		{
			if ( _footprintManager  )
			{
				_footprintManager.removeFootprint(this);
			}
		}
		
		public function set footprintManager( value:FootprintManagerProcess ):void
		{
			if ( _footprintManager )
			{
				_footprintManager.removeFootprint(this);
			}
			_footprintManager = value;
			invalidate("values");
		}
		public function get footprintManager():FootprintManagerProcess { return _footprintManager; }
		
		
		override public function validateNow():void
		{
			if ( isInvalid("values") )
			{
				validateValues();
			}
		
			super.validateNow();
		}
		
				
		private function validateValues():void
		{
			if ( !_transform ) return;
			if ( !_footprintManager ) return;
			if ( !_geometry ) return;
			
			_footprintManager.removeFootprint(this);
			
			if ( _geometry is PolygonGeometry )
			{
				generatePolygonFootprint( PolygonGeometry(geometry) );
			}
			else if ( _geometry is CircleGeometry )
			{
				generateCircleFootprint( CircleGeometry(_geometry) );
			}
			
			
			_footprintManager.addFootprint(this);
		}
		
		private function generateCircleFootprint( circleGeometry:CircleGeometry ):void
		{
			var gridSize:int = _footprintManager.gridSize;
			var gridSize2:int = gridSize >> 1;
			
			var r:Number = circleGeometry.radius;
			var r2:Number = r*r;
			var position:Point = _transform.matrix.transformPoint(new Point(circleGeometry.x, circleGeometry.y));
			var bounds:Rectangle = new Rectangle(position.x-r, position.y-r, r*2, r*2);
			_x = bounds.x / gridSize;
			_y = bounds.y / gridSize;
			_sizeX = Math.ceil(bounds.width / gridSize) + 1;
			_sizeY = Math.ceil(bounds.height / gridSize) + 1;
			_values = [];
			for ( var x:int = 0; x < sizeX; x++ )
			{
				_values[x] = [];
				for ( var y:int = 0; y < sizeY; y++ )
				{
					var px:Number = (_x*gridSize) + (x*gridSize) + gridSize2;
					var py:Number = (_y*gridSize) + (y*gridSize) + gridSize2;
					var dx:Number = px-position.x;
					var dy:Number = py-position.y;
					var d:Number = dx*dx+dy*dy;
					_values[x][y] = d < r2;
				}
			}
		}
		
		private function generatePolygonFootprint( polygon:PolygonGeometry ):void
		{
			var gridSize:int = _footprintManager.gridSize;
			var bounds:Rectangle
			var x:int;
			var y:int;
			var m:Matrix = new Matrix();
			
			//var polygon:PolygonGeometry = PolygonGeometry( _geometry );
			polygon = PolygonGeometry( _geometry );
			
			var transformedVertices:Array = VertexUtil.copy(polygon.vertices);
			VertexUtil.transform(transformedVertices, _transform.matrix);
			
			bounds = VertexUtil.getBounds(transformedVertices);
			
			_x = bounds.x / gridSize;
			_y = bounds.y / gridSize;
			_sizeX = Math.ceil(bounds.width / gridSize) + 1;
			_sizeY = Math.ceil(bounds.height / gridSize) + 1;
			
			_values = [];
			
			var rectangle:RectangleGeometry = new RectangleGeometry();
			rectangle.width = gridSize;
			rectangle.height = gridSize;
			rectangle.validateNow();
			var originalSquareVertices:Array = rectangle.vertices;
			
			for ( x = 0; x < sizeX; x++ )
			{
				_values[x] = [];
				for ( y = 0; y < sizeY; y++ )
				{
					var squareVertices:Array = VertexUtil.copy(originalSquareVertices);
					m.tx = (_x*gridSize) + (x*gridSize);
					m.ty = (_y*gridSize) + (y*gridSize);
					VertexUtil.transform(squareVertices,m);
					
					var intersections:Array = VertexUtil.getIntersections( squareVertices, transformedVertices );
					if ( intersections.length == 0 )
					{
						_values[x][y] = VertexUtil.hittest(m.tx+(gridSize>>1),m.ty+(gridSize>>1),transformedVertices);
					}
					else
					{
						_values[x][y] = true;
					}
				}
			}
		}
		
		[Serializable][Inspectable(editor="ComponentList")]
		public function set geometry( value:IGeometry ):void
		{
			if ( _geometry )
			{
				_geometry.removeEventListener(ValidationEvent.INVALIDATE, invalidateGeometryHandler)
			}
			_geometry = value;
			if ( _geometry )
			{
				_geometry.addEventListener(ValidationEvent.INVALIDATE, invalidateGeometryHandler)
			}
			invalidate("values");
		}
		public function get geometry():IGeometry { return _geometry; }
		
		
		public function set transform( value:Transform2D ):void
		{
			if ( _transform )
			{
				_transform.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			_transform = value;
			if ( _transform )
			{
				_transform.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			invalidate("values");
		}
		public function get transform():Transform2D { return _transform; }
		
		
		private function invalidateGeometryHandler( event:ValidationEvent ):void
		{
			invalidate("values");
		}
		
		private function invalidateTransformHandler( event:ValidationEvent ):void
		{
			invalidate("values");
		}
		
		public function get x():int { return _x; }
		public function get y():int { return _y; }
		
		public function get sizeX():int { return _sizeX; }
		public function get sizeY():int { return _sizeY; }
		
		
		public function get values():Array
		{
			return _values;
		}
	}
}