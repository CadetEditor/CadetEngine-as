// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Inspectable Priority range 100-149

package cadet2D.components.skins
{	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import cadet.components.geom.IGeometry;
	import cadet.events.ValidationEvent;
	import cadet.util.BitmapDataUtil;
	
	import cadet2D.components.geom.BezierCurve;
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.CompoundGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.materials.IMaterialComponent;
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.geom.QuadraticBezier;
	import cadet2D.geom.Vertex;
	
	import starling.core.Starling;
	import starling.display.Graphics;
	import starling.display.Shape;
	import starling.display.materials.IMaterial;

	public class GeometrySkin extends AbstractSkin2D implements IRenderable
	{
		private var _lineThickness		:Number;
		private var _lineColor			:uint;
		private var _lineAlpha			:Number;
		private var _fillColor			:uint;
		private var _fillAlpha			:Number;
		private var _fillBitmap			:BitmapData;
		private var _lineMaterial		:IMaterialComponent;
		private var _lineTexture		:TextureComponent;
//		private var _fillXOffset		:Number = 0;
//		private var _fillYOffset		:Number = 0;
		private var _drawVertices		:Boolean = false;
		
		private var _geometry	:IGeometry;
		
		private var _shape		:Shape;
		
		public function GeometrySkin( lineThickness:Number = 1, lineColor:uint = 0xFFFFFF, lineAlpha:Number = 0.7, fillColor:uint = 0xFFFFFF, fillAlpha:Number = 0.04 )
		{
			name = "GeometrySkin";
			this.lineThickness = lineThickness;
			this.lineColor = lineColor;
			this.lineAlpha = lineAlpha;
			this.fillColor = fillColor;
			this.fillAlpha = fillAlpha;
			
			_displayObject = new Shape();
			_shape = Shape(_displayObject);
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
				_geometry.removeEventListener(ValidationEvent.INVALIDATE, invalidateGeometryHandler);
			}
			_geometry = value;
			
			if ( _geometry )
			{
				_geometry.addEventListener(ValidationEvent.INVALIDATE, invalidateGeometryHandler);
			}
			
			invalidate(DISPLAY);
		}
		public function get geometry():IGeometry { return _geometry; }
				
		private function invalidateGeometryHandler( event:ValidationEvent ):void
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
			
			// validateDisplay will have failed in this instance
			if (!Starling.current) {
				invalidate( DISPLAY );
			}
		}
		
		override protected function validateDisplay():void
		{
			//starling.display.graphics.Graphic has a dependency on Starling.current,
			//so don't attempt to render if not found
			if (!Starling.current) return;
			
			var graphics:Graphics = _shape.graphics;
			graphics.clear();
			
			render( _geometry );
		}
		
		private function render( geometry:IGeometry ):void
		{
			if ( geometry is PolygonGeometry )
			{
				renderPolygon( PolygonGeometry( geometry ) );
			}
			else if ( geometry is CircleGeometry )
			{
				renderCircle( CircleGeometry( geometry ) );
			}
			else if ( geometry is BezierCurve )
			{
				renderBezier( BezierCurve( geometry ) );
			}
			else if ( geometry is CompoundGeometry )
			{
				var compoundGeometry:CompoundGeometry = CompoundGeometry(geometry);
				for each ( var childGeometry:IGeometry in compoundGeometry.children )
				{
					render( childGeometry );
				}
			}
		}
		
		protected function renderPolygon( polygon:PolygonGeometry ):void
		{
			var graphics:Graphics = _shape.graphics;
			
			var vertices:Array = polygon.vertices;
			var firstVertex:Vertex = vertices[0];
			if ( !firstVertex ) return;
			
			setLineStyle();
			
			if ( _fillBitmap )
			{
				var m:Matrix = new Matrix();
				//m.translate(_fillXOffset, _fillYOffset);
				try {
					graphics.beginBitmapFill(_fillBitmap, m);
				} catch ( e:Error ) {
					trace("Error: "+e.errorID+" "+e.message);
				}
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
		
		protected function renderCircle( circle:CircleGeometry ):void
		{
			var graphics:Graphics = _shape.graphics;
			
			setLineStyle();
			
			if ( _fillBitmap )
			{
				var m:Matrix = new Matrix();
				//m.translate(_fillXOffset, _fillYOffset);
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
		
		protected function renderBezier( bezierCurve:BezierCurve ):void
		{
			var graphics:Graphics = _shape.graphics;
			
			if ( !setLineStyle() ) return;
			
			//QuadraticBezierUtil.draw(graphics, bezierCurve.segments);

			if (bezierCurve.segments.length == 0) return;
			
			var segment:QuadraticBezier = bezierCurve.segments[0];
			graphics.moveTo(segment.startX, segment.startY);
			
			for ( var i:int = 0; i < bezierCurve.segments.length; i++ )
			{
				segment = bezierCurve.segments[i];
				graphics.curveTo(segment.controlX, segment.controlY, segment.endX, segment.endY);
			}
		}
		
		private function setLineStyle():Boolean
		{
			var graphics:Graphics = _shape.graphics;
			
			if ( _lineThickness != 0 ) {
				if ( _lineMaterial ) {
					if ( _lineMaterial.material.textures && _lineMaterial.material.textures.length > 0 ) {
						graphics.lineMaterial( _lineThickness, _lineMaterial.material );
						return true;
					}
				} else if ( _lineTexture ) {
					if ( _lineTexture.texture ) {
						graphics.lineTexture( _lineThickness, _lineTexture.texture );
						return true;
					}
				} else {
					graphics.lineStyle( _lineThickness, _lineColor, _lineAlpha );//, false, LineScaleMode.NONE );	
					return true;
				}
			}
			
			return false;
		}
		
		[Serializable][Inspectable( label="Line alpha", priority="100", editor="Slider", min="0", max="1" )]
		public function set lineAlpha( value:Number ):void
		{
			_lineAlpha = value;
			invalidate( DISPLAY );
		}
		public function get lineAlpha():Number { return _lineAlpha; }
		
		[Serializable][Inspectable( label="Line thickness", priority="101" )]//, editor="Slider", min="0.1", max="100", snapInterval="0.1" )]
		public function set lineThickness( value:Number ):void
		{
			_lineThickness = value;
			invalidate( DISPLAY );
		}
		public function get lineThickness():Number { return _lineThickness; }
		
		[Serializable][Inspectable( label="Line colour", priority="102", editor="ColorPicker" )]
		public function set lineColor( value:uint ):void
		{
			_lineColor = value;
			invalidate( DISPLAY );
		}
		public function get lineColor():uint { return _lineColor; }
		
		
		[Serializable][Inspectable( label="Fill alpha", priority="103", editor="Slider", min="0", max="1" )]
		public function set fillAlpha( value:Number ):void
		{
			_fillAlpha = value;
			invalidate( DISPLAY );
		}
		public function get fillAlpha():Number { return _fillAlpha; }
		
		[Serializable][Inspectable( label="Fill colour", priority="104", editor="ColorPicker" )]
		public function set fillColor( value:uint ):void
		{
			_fillColor = value;
			invalidate( DISPLAY );
		}
		public function get fillColor():uint { return _fillColor; }
		
		[Serializable( type="resource" )][Inspectable( label="Fill bitmap", priority="105", editor="ResourceItemEditor")]
		public function set fillBitmap( value:BitmapData ):void
		{
			// Needs to be a power of two in order to be tileable
			_fillBitmap = BitmapDataUtil.makePowerOfTwo(value);
			invalidate( DISPLAY );
		}
		public function get fillBitmap():BitmapData { return _fillBitmap; }
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="106" )]
		public function set lineMaterial( value:IMaterialComponent ):void
		{
			if ( _lineMaterial ) {
				_lineMaterial.removeEventListener( ValidationEvent.VALIDATED, lineTextureValidatedHandler );
			}
			
			_lineMaterial = value;	
			
			if ( _lineMaterial ) {
				lineTexture = null; 	// Mutually exclusive values
				_lineMaterial.addEventListener( ValidationEvent.VALIDATED, lineTextureValidatedHandler );
			}
			
			invalidate( DISPLAY );
		}
		public function get lineMaterial():IMaterialComponent
		{
			return _lineMaterial;
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="107" )]
		public function set lineTexture( value:TextureComponent ):void
		{
			if ( _lineTexture ) {
				_lineTexture.removeEventListener( ValidationEvent.VALIDATED, lineTextureValidatedHandler );
			}
			
			_lineTexture = value;	
			
			if ( _lineTexture ) {
				lineMaterial = null;	// Mutually exclusive values
				_lineTexture.addEventListener( ValidationEvent.VALIDATED, lineTextureValidatedHandler );
			}
			
			invalidate( DISPLAY );
		}
		public function get lineTexture():TextureComponent
		{
			return _lineTexture;
		}
		
/*		[Serializable][Inspectable( priority="106")]
		public function set fillXOffset( value:Number ):void
		{
			_fillXOffset = value;
			invalidate( DISPLAY );
		}
		public function get fillXOffset():Number { return _fillXOffset; }
		
		[Serializable][Inspectable( priority="107")]
		public function set fillYOffset( value:Number ):void
		{
			_fillYOffset = value;
			invalidate( DISPLAY );
		}
		public function get fillYOffset():Number { return _fillYOffset; }*/			
		
		[Serializable][Inspectable( label="Draw vertices", priority="108" )]
		public function set drawVertices( value:Boolean ):void
		{
			_drawVertices = value;
			invalidate( DISPLAY );
		}
		public function get drawVertices():Boolean { return _drawVertices; }
		
		private function lineTextureValidatedHandler( event:ValidationEvent ):void
		{
			invalidate( DISPLAY );
		}
	}
}






