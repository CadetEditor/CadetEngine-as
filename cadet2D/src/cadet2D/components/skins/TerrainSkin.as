// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.skins
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.geom.TerrainGeometry;
	import cadet2D.geom.Vertex;
	import cadet2D.util.VertexUtil;
	
	import core.app.dataStructures.ObjectPool;
	
	import starling.core.Starling;
	import starling.display.Graphics;
	import starling.display.Shape;
	
	public class TerrainSkin extends AbstractSkin2D
	{
		// Invalidation types
		public static const ALL_BUCKETS		:String = "allBuckets";
		public static const SOME_BUCKETS	:String = "someBuckets";
		
		// Sibling References
		private var _terrainGeometry		:TerrainGeometry;
		
		// Styles
		protected var _surfaceBitmap		:BitmapData;
		protected var _surfaceThickness		:int = 20;
		protected var _fillBitmap			:BitmapData;
		
		// 
		private var invalidatedBuckets		:Object;
		private var shapes					:Object;
		
		private static const m				:Matrix = new Matrix();
		
		private var _shape					:Shape;				
		
		public function TerrainSkin()
		{
			_displayObject = new Shape();
			_shape = Shape(_displayObject);
			
			init();
		}
		
		private function init():void
		{
			name = "TerrainSkin";
			
			while ( _shape.numChildren > 0 )
			{
				_shape.removeChildAt(0);
			}
			shapes = {};
			invalidatedBuckets = {};
		}
		
		override public function dispose():void
		{
			super.dispose();
			init();
		}
		
		override protected function addedToScene():void
		{
			super.addedToScene();
			addSiblingReference( TerrainGeometry, "terrainGeometry" );
		}
				
		[Serializable( type="resource" )][Inspectable( editor="ResourceItemEditor" )]
		public function set fillBitmap( value:BitmapData ):void
		{
			_fillBitmap = value;
			invalidate( ALL_BUCKETS );
			invalidate( DISPLAY );
		}
		public function get fillBitmap():BitmapData { return _fillBitmap; }
		
		[Serializable( type="resource" )][Inspectable( editor="ResourceItemEditor" )]
		public function set surfaceBitmap( value:BitmapData ):void
		{
			_surfaceBitmap = value;
			invalidate( ALL_BUCKETS );
			invalidate( DISPLAY );
		}
		public function get surfaceBitmap():BitmapData { return _surfaceBitmap; }
		
		[Serializable][Inspectable( editor="NumericStepper", min="1", max="100", stepSize="1" )]
		public function set surfaceThickness( value:Number ):void
		{
			_surfaceThickness = value;
			invalidate( ALL_BUCKETS );
			invalidate( DISPLAY );
		}
		public function get surfaceThickness():Number { return _surfaceThickness; }
		
		public function set terrainGeometry( value:TerrainGeometry ):void
		{
			if ( _terrainGeometry )
			{
				_terrainGeometry.removeEventListener(ValidationEvent.INVALIDATE, invalidateTerrainHandler);
			}
			_terrainGeometry = value;
			if ( _terrainGeometry )
			{
				_terrainGeometry.addEventListener(ValidationEvent.INVALIDATE, invalidateTerrainHandler);
			}
			invalidate(ALL_BUCKETS);
			invalidate(DISPLAY);
		}
		public function get terrainGeometry():TerrainGeometry { return _terrainGeometry; }
		
		private function invalidateTerrainHandler( event:ValidationEvent ):void
		{
			if ( event.validationType == TerrainGeometry.ALL_BUCKETS )
			{
				invalidate(ALL_BUCKETS);
				invalidate(DISPLAY);
			}
			else if ( event.validationType == TerrainGeometry.SOME_BUCKETS )
			{
				invalidate(SOME_BUCKETS);
				invalidate(DISPLAY);
			}
		}
		
		override public function validateNow():void
		{
			if (Starling.current) {
				if ( isInvalid(ALL_BUCKETS) ) {
					validateAllBuckets();
				}
				if ( isInvalid(SOME_BUCKETS) ) {
					validateSomeBuckets();
				}
			}
			
			super.validateNow();
			
			// validateDisplay will have failed in this instance
			if (!Starling.current) {
				invalidate( ALL_BUCKETS );
			}
		}
		
		private function validateAllBuckets():void
		{
			if ( !_terrainGeometry ) return;
			invalidatedBuckets = {};
			const numBuckets:int = Math.ceil(_terrainGeometry.numSamples/_terrainGeometry.bucketSize);
			for ( var i:int = 0; i < numBuckets; i++ )
			{
				invalidatedBuckets[i] = true;
			}
			
			for each ( var shape:Shape in shapes )
			{
				_shape.removeChild(shape);
			}
			shapes = {};
			
			invalidate(SOME_BUCKETS);
		}
		
		private function validateSomeBuckets():void
		{
			if ( !_terrainGeometry ) return;
			var bucketIndex:String
			
			for ( bucketIndex in invalidatedBuckets )
			{
				validateBucket( int( bucketIndex ) );
			}
			
			var terrainInvalidatedBuckets:Object = _terrainGeometry.invalidatedBuckets;
			for ( bucketIndex in terrainInvalidatedBuckets )
			{
				if ( invalidatedBuckets[bucketIndex] ) continue;
				validateBucket( int( bucketIndex ) );
			}
			invalidatedBuckets = {};
		}
		
		private function validateBucket( index:int ):void
		{
			var shape:Shape = shapes[index];
			if ( !shape )
			{
				shape = shapes[index] = ObjectPool.getInstance(Shape);
				_shape.addChild(shape);
			}
			
			const samples:Array = _terrainGeometry.samples;
			const sampleWidth:Number = _terrainGeometry.sampleWidth;
			const firstSampleIndex:int = index * _terrainGeometry.bucketSize;
			const lastSampleIndex:int = Math.min(firstSampleIndex + _terrainGeometry.bucketSize, samples.length-1);
			const length:int = lastSampleIndex-firstSampleIndex;
			
			shape.x = int(firstSampleIndex * sampleWidth);
			
			const graphics:Graphics = shape.graphics;
			graphics.clear();
			
			if ( _fillBitmap )
			{
				m.identity();
				m.tx = int(-shape.x % _fillBitmap.width);
				graphics.beginBitmapFill(_fillBitmap, m);
			}
			else
			{
				graphics.lineStyle(1, 0xFFFFFF, 0.7);//, false, "none");
			}
			
			
			var vertices:Array = [];
			
			graphics.moveTo( 0, 0 );
			for ( var i:int = 0; i <= length; i++ )
			{
				var sample:Number = samples[firstSampleIndex+i];
				graphics.lineTo( int(i * sampleWidth), -sample );
				
				vertices[i] = new Vertex( int(i * sampleWidth), -sample );
			}
			graphics.lineTo( int((i-1) * sampleWidth), 0 );
			graphics.endFill();
			
			
			if ( !_surfaceBitmap ) return;
			
			var strip:Array = VertexUtil.getPolygonStrip(vertices, _surfaceThickness, 0);
			for ( i = 0; i < length; i++ )
			{
				sample = samples[firstSampleIndex+i];
				
				var stripShape:Array = strip[i];
				
				var dx:Number = stripShape[1].x - stripShape[0].x;
				var dy:Number = stripShape[1].y - stripShape[0].y;
				var d:Number = Math.sqrt(dx*dx + dy*dy);
				dx /= d;
				dy /= d;
				
				var angle:Number = Math.PI * 0.5 -Math.atan2(dx, dy);
				
				m.identity();
				m.translate(-shape.x % _surfaceBitmap.width,0);
				m.scale(1, _surfaceThickness/_surfaceBitmap.height);
				m.rotate(angle);
				m.translate(stripShape[0].x, stripShape[0].y);
				graphics.beginBitmapFill(_surfaceBitmap, m);
				
				graphics.moveTo(stripShape[0].x, stripShape[0].y);
				graphics.lineTo(stripShape[1].x, stripShape[1].y);
				graphics.lineTo(stripShape[2].x, stripShape[2].y);
				graphics.lineTo(stripShape[3].x, stripShape[3].y);
				graphics.lineTo(stripShape[0].x, stripShape[0].y);
				graphics.endFill();
			}
		}
	}
}