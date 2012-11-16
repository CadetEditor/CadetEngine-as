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
	
	import cadet2D.geom.Vertex;
	import cadet2D.util.VertexUtil;
	
	import flox.core.data.ArrayCollection;
	
	import flox.app.dataStructures.ObjectPool;
	
	public class TerrainGeometry extends CompoundGeometry
	{
		// Invalidation Types
		public static const GEOMETRY		:String = "geometry";
		public static const SAMPLES			:String = "samples";
		
		public static const ALL_BUCKETS		:String = "allBuckets";
		public static const SOME_BUCKETS	:String = "someBuckets";
		
		private var _sampleWidth			:int;
		private var _numSamples				:int;
		private var _bucketSize				:int;
		
		private var _samples				:Array;
		private var _buckets				:Array;
		
		private var _invalidatedBuckets		:Object;
		
		public function TerrainGeometry()
		{
			
			init();
		}
		
		private function init():void
		{
			name = "TerrainGeometry";
			sampleWidth = 80;
			numSamples = 10;
			bucketSize = 10;
			_buckets = [];
			_invalidatedBuckets = {};
			_samples = [];
		}
		
		override public function dispose():void
		{
			super.dispose();
			init();
		}
		
		public function get buckets():Array { return _buckets; }
		public function get invalidatedBuckets():Object { return _invalidatedBuckets; }
		
		
		public function set samples( value:Array ):void
		{
			_samples = value;
			invalidate(ALL_BUCKETS);
		}
		public function get samples():Array { return _samples; }
		
		[Serializable(alias="samples")]
		public function set serializedSamples( value:String ):void
		{
			var split:Array = value.split(",");
			samples = [];
			const L:int = split.length;
			for ( var i:int = 0; i < L; i++ )
			{
				_samples[i] = int( split[i] );
			}
		}
		public function get serializedSamples():String
		{
			return _samples.toString();
		}
		
		[Serializable][Inspectable( editor="NumericStepper", min="1", max="100", stepSize="1" )]
		public function set sampleWidth( value:int ):void
		{
			_sampleWidth = value;
			invalidate(ALL_BUCKETS);	
		}
		public function get sampleWidth():int { return _sampleWidth; }
		
		[Serializable][Inspectable( editor="NumericStepper", min="1", max="99999999", stepSize="1" )]
		public function set numSamples( value:int ):void
		{
			_numSamples = value;
			invalidate(ALL_BUCKETS);
			invalidate(SAMPLES);
		}
		public function get numSamples():int { return _numSamples; }
		
		[Serializable][Inspectable( editor="NumericStepper", min="1", max="1000", stepSize="1" )]
		public function set bucketSize( value:int ):void
		{
			_bucketSize = value;
			invalidate(ALL_BUCKETS);
		}
		public function get bucketSize():int { return _bucketSize; }
		
		public function setHeight( index:int, value:Number ):void
		{
			index = index < 0 ? 0 : index;
			value = value < 0 ? 0 : value;
			
			if ( index >= _numSamples )
			{
				numSamples = (index+1);
				validateNow();
			}
			
			_samples[index] = value;
			
			// Determine which bucket(s) have been invalidated.
			// Usually only one bucket will be invalidated, but its
			// possible that 2 have, if a sample on the edge between
			// 2 buckets has been changed.
			var bucketIndex:int = index / _bucketSize;
			_invalidatedBuckets[bucketIndex] = true;
			if ( bucketIndex > 0 && index % _bucketSize == 0 )
			{
				_invalidatedBuckets[bucketIndex-1] = true;
			}
			invalidate(SOME_BUCKETS);
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( SAMPLES ) )
			{
				validateSamples();
			}
			if ( isInvalid( ALL_BUCKETS ) )
			{
				validateAllBuckets();
			}
			if ( isInvalid( SOME_BUCKETS ) )
			{
				validateSomeBuckets();
			}
			
			super.validateNow();
		}
		
		private function validateAllBuckets():void
		{
			for each ( var bucket:Array in _buckets )
			{
				for each ( var polygon:PolygonGeometry in bucket )
				{
					ObjectPool.returnInstances(polygon.vertices, true);
					ObjectPool.returnInstance(polygon, PolygonGeometry);
					children.removeItem(polygon);
					polygon.dispose();
				}
			}
			_buckets = [];
			
			const numBuckets:int = Math.ceil((_numSamples/_bucketSize));
			for ( var i:int = 0; i < numBuckets; i++ )
			{
				_invalidatedBuckets[i] = true;
				_buckets[i] == [];
			}
			invalidate(SOME_BUCKETS);
		}
		
		private function validateSomeBuckets():void
		{
			for ( var bucketIndex:String in _invalidatedBuckets )
			{
				validateBucket( int(bucketIndex) );
			}
			_invalidatedBuckets = {};
		}
		
		private function validateBucket( bucketIndex:int ):void
		{
			var bucket:Array = _buckets[bucketIndex];
			for each ( var polygon:PolygonGeometry in bucket )
			{
				ObjectPool.returnInstances(polygon.vertices, true);
				ObjectPool.returnInstance(polygon, PolygonGeometry);
				children.removeItem(polygon);
				polygon.dispose();
			}
			bucket = _buckets[bucketIndex] = [];
			
			const firstSampleIndex:int = bucketIndex * _bucketSize;
			const lastSampleIndex:int = Math.min(firstSampleIndex + _bucketSize, _samples.length-1);
			
			var lowestPoint:Number = Number.POSITIVE_INFINITY;
			for ( var i:int = firstSampleIndex; i <=  lastSampleIndex; i++ )
			{
				var sample:Number = _samples[i];
				if ( sample < lowestPoint )
				{
					lowestPoint = sample;
				}
			}
			
			var left:Number = firstSampleIndex * _sampleWidth;
			var right:Number = lastSampleIndex * _sampleWidth;
			
			if ( lowestPoint != 0 )
			{
				var baseRect:PolygonGeometry = ObjectPool.getInstance(PolygonGeometry);
				baseRect.vertices = ObjectPool.getInstances( Vertex, 4 );
				baseRect.vertices[0].setValues( left, -lowestPoint );
				baseRect.vertices[1].setValues( right, -lowestPoint );
				baseRect.vertices[2].setValues( right, 0 );
				baseRect.vertices[3].setValues( left, 0 );
				bucket.push(baseRect);
				children.addItem(baseRect);
			}
			
			var prevVertex:Vertex;
			polygon = ObjectPool.getInstance(PolygonGeometry);
			for ( i = firstSampleIndex; i <= lastSampleIndex; i++ )
			{
				sample = _samples[i];
				var vertex:Vertex = ObjectPool.getInstance(Vertex);
				vertex.setValues(i*_sampleWidth, -sample);
				
				if ( vertex.y == -lowestPoint )
				{
					if ( polygon.vertices.length > 0 && polygon.vertices[polygon.vertices.length-1].y != -lowestPoint )
					{
						polygon.vertices.push(vertex.clone());
						finishShape(polygon, lowestPoint);
						bucket.push(polygon);
						children.addItem(polygon);
						polygon = ObjectPool.getInstance(PolygonGeometry);
						polygon.vertices.push( vertex.clone() );
					}
					else
					{
						polygon.vertices = [vertex.clone()];
					}
				}
				else if ( i == lastSampleIndex )
				{
					if ( polygon.vertices.length > 0 && polygon.vertices[polygon.vertices.length-1].y != -lowestPoint )
					{
						polygon.vertices.push(vertex.clone());
						finishShape( polygon, lowestPoint );
						bucket.push(polygon);
						children.addItem(polygon);
					}
				}
				else if ( prevVertex )
				{
					var nextSample:Number = _samples[i+1];
					var nextVertex:Vertex = ObjectPool.getInstance(Vertex);
					nextVertex.setValues((i+1) * _sampleWidth, -nextSample);
										
					if ( vertex.y == prevVertex.y && nextVertex.y == vertex.y )
					{
						prevVertex = vertex.clone();
						continue;
					}
					
					polygon.vertices.push(vertex.clone());
					
					if ( VertexUtil.isLeft( prevVertex, vertex, nextVertex.x, nextVertex.y ) )
					{
						if ( polygon.vertices.length <= 1 ) continue;
						finishShape( polygon, lowestPoint );
						bucket.push(polygon);
						children.addItem(polygon);
						polygon = ObjectPool.getInstance(PolygonGeometry);
						polygon.vertices = [ vertex.clone() ];
					}
					
					//ObjectPool.returnInstance(nextVertex, Vertex);
				}
				else
				{
					polygon.vertices.push( vertex.clone() );
				}
				
				prevVertex = vertex.clone();
				
			}
		}
		
		
		
		private function finishShape( polygon:PolygonGeometry, y:Number ):void
		{
			var firstVertex:Vertex = polygon.vertices[0];
			var lastVertex:Vertex = polygon.vertices[polygon.vertices.length-1];
			var v:Vertex;
			if ( lastVertex.y != -y ) 
			{	
				v = ObjectPool.getInstance(Vertex);
				v.setValues( lastVertex.x, -y );
				polygon.vertices.push( v );
			}
			if ( firstVertex.y != -y ) 
			{
				v = ObjectPool.getInstance(Vertex);
				v.setValues( firstVertex.x, -y );
				polygon.vertices.push( v );
			}
		}
		
		private function validateSamples():void
		{
			var diff:int = _numSamples - _samples.length;
			// Need to expand vertices array
			if ( diff > 0 )
			{
				for ( var i:int = 0; i < diff; i++ )
				{
					_samples.push(0);
				}
			}
			else if ( diff < 0 )
			{
				diff *= -1;
				for ( i = 0; i < diff; i++ )
				{
					var index:int = (_samples.length-1) - diff;
					_samples.length--;
				}
			}
		}
		
		// Override the get/set children method, and override the [Serializable] metadata.
		// Because this Component is a CompoundGeometry, and all its children are derived from the sample
		// data, there's no need to serialize all the generated polygon data too, as it can be regenerated
		// during validation.
		[Serializable( inherit="false" )]
		override public function set children( value:ArrayCollection ):void
		{
			super.children = value;
		}
		override public function get children():ArrayCollection { return _children; }
	}
}