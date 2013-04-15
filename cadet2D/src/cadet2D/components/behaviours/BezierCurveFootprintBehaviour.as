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
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import cadet.core.Component;
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.geom.BezierCurve;
	import cadet2D.components.processes.FootprintManagerProcess;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.QuadraticBezier;
	import cadet2D.geom.Vertex;
	import cadet2D.util.QuadraticBezierUtil;
	import cadet2D.util.VertexUtil;

	public class BezierCurveFootprintBehaviour extends Component implements IFootprint
	{
		private const VALUES			:String = "values";
		
		private var _thickness			:Number;
		private var _capEnds			:Boolean = false;
		
		private var thicknessSquared	:Number;
		
		
		private var _x			:int;
		private var _y			:int;
		private var _sizeX		:int;
		private var _sizeY		:int;
		
		private var _values		:Array;
		
		private var _footprintManager		:FootprintManagerProcess;
		protected var _curve				:BezierCurve;
		
		private var _transform	:Transform2D;
		
		public function BezierCurveFootprintBehaviour()
		{
			name = "BezierCurveFootprintBehaviour";
			thickness = 20;
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference( Transform2D, "transform" );
			addSiblingReference( BezierCurve, "curve" );
			addSceneReference(FootprintManagerProcess, "footprintManager");
		}
		
		override protected function removedFromScene():void
		{
			if ( _footprintManager )
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
			invalidate(VALUES);
		}
		public function get footprintManager():FootprintManagerProcess { return _footprintManager; }
		
		
		override public function validateNow():void
		{
			if ( isInvalid(VALUES) )
			{
				validateValues();
			}
		
			super.validateNow();
		}
		
				
		private function validateValues():void
		{
			if ( !_transform ) return;
			if ( !_footprintManager ) return;
			if ( !_curve ) return;
			
			_footprintManager.removeFootprint(this);
			
			var gridSize:int = _footprintManager.gridSize;
			var bounds:Rectangle
			var x:int;
			var y:int;
			var m:Matrix = new Matrix();
			var dx:Number;
			var dy:Number;
			var d:Number;
			
			//var segments:Vector.<QuadraticBezier> = QuadraticBezierUtil.clone(_curve.segments);
			var segments:Array = QuadraticBezierUtil.clone(_curve.segments);
			QuadraticBezierUtil.transform(segments, _transform.matrix);
			bounds = QuadraticBezierUtil.getBounds(segments);
			bounds.inflate(thickness, thickness);
			_x = bounds.x / gridSize;
			_y = bounds.y / gridSize;
			
			
			_sizeX = Math.ceil(bounds.width / gridSize) + 1;
			_sizeY = Math.ceil(bounds.height / gridSize) + 1;
			
			_values = [];
			
			
			
			if ( _capEnds )
			{
				var lastSegment:QuadraticBezier = segments[segments.length-1];
				
				dx = lastSegment.endX-lastSegment.controlX;
				dy = lastSegment.endY-lastSegment.controlY;
				d = Math.sqrt(dx*dx+dy*dy);
				dx /= d;
				dy /= d;
				
				var dx2:Number = -dy;
				var dy2:Number = dx;
				
				var v1E:Vertex = new Vertex( lastSegment.endX + dx2 * _thickness, lastSegment.endY + dy2 * _thickness );
				var v2E:Vertex = new Vertex( lastSegment.endX - dx2 * _thickness, lastSegment.endY - dy2 * _thickness );
				var v3E:Vertex = new Vertex( v1E.x + dx * _thickness, v1E.y + dy * _thickness );
				var v4E:Vertex = new Vertex( v2E.x + dx * _thickness, v2E.y + dy * _thickness );
								
				var firstSegment:QuadraticBezier = segments[0];
				dx = firstSegment.startX-firstSegment.controlX;
				dy = firstSegment.startY-firstSegment.controlY;
				d = Math.sqrt(dx*dx+dy*dy);
				dx /= d;
				dy /= d;
				
				dx2 = -dy;
				dy2 = dx;
				
				var v1S:Vertex = new Vertex( firstSegment.startX + dx2 * _thickness, firstSegment.startY + dy2 * _thickness );
				var v2S:Vertex = new Vertex( firstSegment.startX - dx2 * _thickness, firstSegment.startY - dy2 * _thickness );
				var v3S:Vertex = new Vertex( v1S.x + dx * _thickness, v1S.y + dy * _thickness );
				var v4S:Vertex = new Vertex( v2S.x + dx * _thickness, v2S.y + dy * _thickness );
				
				m = new Matrix(1,0,0,1,-transform.x,-transform.y);
				VertexUtil.transform([v1E,v2E,v3E,v4E,v1S,v2S,v3S,v4S], m);
			}
			
			var p:Point = new Point();
			m = _transform.matrix.clone();
			m.invert();
			var v:Vertex = new Vertex();
			for ( x = 0; x < sizeX; x++ )
			{
				_values[x] = [];
				for ( y = 0; y < sizeY; y++ )
				{
					p.x = (x+_x) * gridSize + gridSize*0.5;
					p.y = (y+_y) * gridSize + gridSize*0.5;;
					p = m.transformPoint(p);
					
					if ( _capEnds )
					{
						var base:Boolean = VertexUtil.isLeft( v1E, v2E, p.x, p.y ) > 0
						var left:Boolean = VertexUtil.isLeft( v2E, v4E, p.x, p.y ) > 0
						var right:Boolean = VertexUtil.isLeft( v3E, v1E, p.x, p.y ) > 0
						var tip:Boolean = VertexUtil.isLeft( v4E, v3E, p.x, p.y ) > 0
						
						if ( base && left && right && tip ) continue;
						
						base = VertexUtil.isLeft( v1S, v2S, p.x, p.y ) > 0
						left = VertexUtil.isLeft( v2S, v4S, p.x, p.y ) > 0
						right = VertexUtil.isLeft( v3S, v1S, p.x, p.y ) > 0
						tip = VertexUtil.isLeft( v4S, v3S, p.x, p.y ) > 0
						
						if ( base && left && right && tip ) continue;
					}
					
					var closestRatio:Number = QuadraticBezierUtil.getClosestRatio(_curve.segments, p.x, p.y );
					v = QuadraticBezierUtil.evaluatePosition(_curve.segments, closestRatio, v);
					dx = v.x-p.x;
					dy = v.y-p.y;
					d = dx*dx+dy*dy
					_values[x][y] = d < thicknessSquared;
				}
			}
			
			_footprintManager.addFootprint(this);
		}
		
		[Serializable][Inspectable(editor="ComponentList")]
		public function set curve( value:BezierCurve ):void
		{
			if ( _curve )
			{
				_curve.removeEventListener(ValidationEvent.INVALIDATE, invalidateCurveHandler)
			}
			_curve = value;
			if ( _curve )
			{
				_curve.addEventListener(ValidationEvent.INVALIDATE, invalidateCurveHandler)
			}
			invalidate(VALUES);
		}
		public function get curve():BezierCurve { return _curve; }
		
		
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
			invalidate(VALUES);
		}
		public function get transform():Transform2D { return _transform; }
		
		[Serializable][Inspectable(editor="NumericStepper", min="1", max="999")]
		public function set thickness( value:Number ):void
		{
			_thickness = value;
			thicknessSquared = _thickness*_thickness;
			invalidate(VALUES);
		}
		public function get thickness():Number { return _thickness; }
		
		[Serializable][Inspectable]
		public function set capEnds( value:Boolean ):void
		{
			_capEnds = value;
			invalidate(VALUES);
		}
		public function get capEnds():Boolean { return _capEnds; }
		
		protected function invalidateCurveHandler( event:ValidationEvent ):void
		{
			invalidate(VALUES);
		}
		
		private function invalidateTransformHandler( event:ValidationEvent ):void
		{
			invalidate(VALUES);
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