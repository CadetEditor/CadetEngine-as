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
	import cadet.components.geom.IGeometry;
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.geom.BezierCurve;
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.CompoundGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.geom.Vertex;
	import cadet2D.util.QuadraticBezierUtil;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.geom.Matrix;
	
	public class GeometrySkin extends AbstractSkin2D implements ISkin2D
	{
		private var _lineThickness	:Number;
		private var _lineColor		:uint;
		private var _lineAlpha		:Number;
		private var _fillColor		:uint;
		private var _fillAlpha		:Number;
		private var _fillBitmap		:BitmapData;
		private var _fillXOffset	:Number = 0;
		private var _fillYOffset	:Number = 0;
		private var _drawVertices	:Boolean = false;
		
		private var _geometry	:IGeometry;
		
		public function GeometrySkin( lineThickness:Number = 1, lineColor:uint = 0xFFFFFF, lineAlpha:Number = 0.7, fillColor:uint = 0xFFFFFF, fillAlpha:Number = 0.04 )
		{
			name = "GeometrySkin";
			this.lineThickness = lineThickness;
			this.lineColor = lineColor;
			this.lineAlpha = lineAlpha;
			this.fillColor = fillColor;
			this.fillAlpha = fillAlpha;
		}
		
		override protected function addedToScene():void
		{
			super.addedToScene();
			addSiblingReference(IGeometry, "geometry");
		}
		
		public function set geometry( value:IGeometry ):void
		{
			if ( _geometry )
			{
				_geometry.removeEventListener(InvalidationEvent.INVALIDATE, invalidateGeometryHandler);
			}
			_geometry = value;
			
			if ( _geometry )
			{
				_geometry.addEventListener(InvalidationEvent.INVALIDATE, invalidateGeometryHandler);
			}
			
			invalidate(DISPLAY);
		}
		public function get geometry():IGeometry { return _geometry; }
				
		private function invalidateGeometryHandler( event:InvalidationEvent ):void
		{
			invalidate(DISPLAY);
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( DISPLAY ) )
			{
				validateDisplay();
			}
			
			super.validateNow();
		}
		
		protected function validateDisplay():void
		{
			var graphics:Graphics = sprite.graphics;
			graphics.clear();
			render( _geometry, graphics );
		}
		
		private function render( geometry:IGeometry, graphics:Graphics ):void
		{
			if ( geometry is PolygonGeometry )
			{
				renderPolygon( PolygonGeometry( geometry ), graphics );
			}
			else if ( geometry is CircleGeometry )
			{
				renderCircle( CircleGeometry( geometry ), graphics );
			}
			else if ( geometry is BezierCurve )
			{
				renderBezier( BezierCurve( geometry ), graphics );
			}
			else if ( geometry is CompoundGeometry )
			{
				var compoundGeometry:CompoundGeometry = CompoundGeometry(geometry);
				for each ( var childGeometry:IGeometry in compoundGeometry.children )
				{
					render( childGeometry, graphics );
				}
			}
		}
		
		protected function renderPolygon( polygon:PolygonGeometry, graphics:Graphics ):void
		{
			var vertices:Array = polygon.vertices;
			var firstVertex:Vertex = vertices[0];
			if ( !firstVertex ) return;
			
			if ( _lineThickness != 0 ) graphics.lineStyle( _lineThickness, _lineColor, _lineAlpha, false, LineScaleMode.NONE );
			
			if ( _fillBitmap )
			{
				var m:Matrix = new Matrix();
				m.translate(_fillXOffset, _fillYOffset);
				graphics.beginBitmapFill(_fillBitmap, m);
			}
			else if ( _fillAlpha > 0 )
			{
				graphics.beginFill( _fillColor, _fillAlpha );
			}
			graphics.moveTo( firstVertex.x, firstVertex.y );
			for ( var i:int = 1; i < vertices.length; i++ )
			{
				var vertex:Vertex = vertices[i];
				graphics.lineTo( vertex.x, vertex.y );
			}
			graphics.lineTo( firstVertex.x, firstVertex.y );
			graphics.endFill();
			
			if ( !_drawVertices ) return;
			graphics.beginFill(0xFF0000,1);
			for each ( vertex in vertices )
			{
				graphics.drawCircle(vertex.x, vertex.y, 2);
			}
		}
		
		protected function renderCircle( circle:CircleGeometry, graphics:Graphics ):void
		{
			if ( _lineThickness != 0 ) graphics.lineStyle( _lineThickness, _lineColor, _lineAlpha, false, LineScaleMode.NONE );
			
			if ( _fillBitmap )
			{
				var m:Matrix = new Matrix();
				m.translate(_fillXOffset, _fillYOffset);
				graphics.beginBitmapFill(_fillBitmap, m);
			}
			else if ( _fillAlpha > 0 )
			{
				graphics.beginFill( _fillColor, _fillAlpha );
			}
			graphics.drawCircle( circle.x, circle.y, circle.radius );
			graphics.endFill();
			
			graphics.moveTo(circle.x, circle.y);
			graphics.lineTo(circle.x+circle.radius, circle.y);
		}
		
		protected function renderBezier( bezierCurve:BezierCurve, graphics:Graphics ):void
		{
			if ( _lineThickness != 0 ) graphics.lineStyle( _lineThickness, _lineColor, _lineAlpha, false, LineScaleMode.NONE );
			QuadraticBezierUtil.draw(graphics, bezierCurve.segments);
		}
		
		
		[Serializable][Inspectable( label="Line thickness", priority="1", editor="Slider", min="0.1", max="100", snapInterval="0.1" )]
		public function set lineThickness( value:Number ):void
		{
			_lineThickness = value;
			invalidate( DISPLAY );
		}
		public function get lineThickness():Number { return _lineThickness; }
		
		[Serializable][Inspectable( label="Line colour", priority="2", editor="ColorPicker" )]
		public function set lineColor( value:uint ):void
		{
			_lineColor = value;
			invalidate( DISPLAY );
		}
		public function get lineColor():uint { return _lineColor; }
		
		
		[Serializable][Inspectable( label="Line alpha", priority="3", editor="Slider", min="0", max="1" )]
		public function set lineAlpha( value:Number ):void
		{
			_lineAlpha = value;
			invalidate( DISPLAY );
		}
		public function get lineAlpha():Number { return _lineAlpha; }
		
		[Serializable][Inspectable( label="Fill colour", priority="4", editor="ColorPicker" )]
		public function set fillColor( value:uint ):void
		{
			_fillColor = value;
			invalidate( DISPLAY );
		}
		public function get fillColor():uint { return _fillColor; }
		
		[Serializable][Inspectable( label="Fill alpha", priority="5", editor="Slider", min="0", max="1" )]
		public function set fillAlpha( value:Number ):void
		{
			_fillAlpha = value;
			invalidate( DISPLAY );
		}
		public function get fillAlpha():Number { return _fillAlpha; }
		
		[Serializable][Inspectable]
		public function set fillXOffset( value:Number ):void
		{
			_fillXOffset = value;
			invalidate( DISPLAY );
		}
		public function get fillXOffset():Number { return _fillXOffset; }
		
		[Serializable][Inspectable]
		public function set fillYOffset( value:Number ):void
		{
			_fillYOffset = value;
			invalidate( DISPLAY );
		}
		public function get fillYOffset():Number { return _fillYOffset; }			
		
		[Serializable( type="resource" )][Inspectable( label="Fill bitmap", priority="6", editor="ResourceItemEditor")]
		public function set fillBitmap( value:BitmapData ):void
		{
			_fillBitmap = value;
			invalidate( DISPLAY );
		}
		public function get fillBitmap():BitmapData { return _fillBitmap; }
		
		[Serializable][Inspectable( label="Draw vertices", priority="7" )]
		public function set drawVertices( value:Boolean ):void
		{
			_drawVertices = value;
			invalidate( DISPLAY );
		}
		public function get drawVertices():Boolean { return _drawVertices; }
	}
}