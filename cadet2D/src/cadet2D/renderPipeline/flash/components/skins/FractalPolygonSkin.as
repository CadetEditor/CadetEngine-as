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
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import cadet2D.components.geom.PolygonGeometry;
	import cadet.events.InvalidationEvent;
	import cadet2D.geom.Vertex;
	
	public class FractalPolygonSkin extends AbstractSkin2D
	{
		private var _polygon		:PolygonGeometry;
		
		private var chordVertices	:Array;
		
		protected var _depth		:int = 0;
		
		public function FractalPolygonSkin()
		{
			name = "FractalPolygonSkin";
		}
		
		override protected function addedToScene():void
		{
			super.addedToScene();
			addSiblingReference(PolygonGeometry, "polygon");
		}
		
		public function set polygon( value:PolygonGeometry ):void
		{
			if ( _polygon )
			{
				_polygon.removeEventListener(InvalidationEvent.INVALIDATE, invalidatePolygonHandler);
			}
			_polygon = value;
			if ( _polygon )
			{
				_polygon.addEventListener(InvalidationEvent.INVALIDATE, invalidatePolygonHandler);
			}
			invalidate("polygon");
			invalidate("display");
		}
		public function get polygon():PolygonGeometry { return _polygon; }
		
		private function invalidatePolygonHandler( event:InvalidationEvent ):void
		{
			invalidate("polygon");
			invalidate("display");
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( "polygon" ) )
			{
				validatePolygon();
			}
			if ( isInvalid( "display" ) )
			{
				validateDisplay();
			}
			super.validateNow();
		}
		
		protected function validatePolygon():void
		{
			buildChordVertices();
		}
		
		protected function validateDisplay():void
		{
			sprite.graphics.clear();
			if ( !_polygon ) return;
			
			var vertices:Array = _polygon.vertices;
			var L:int = vertices.length;
			if ( L < 2 ) return;
			
			
			sprite.graphics.lineStyle(1,0xFFFFFF,1);
			
			var v1:Vertex = vertices[0];
			var v2:Vertex = vertices[L-1];
			sprite.graphics.moveTo(v1.x,v1.y);
			drawChord( v1.x, v1.y, v2.x, v2.y, _depth );
		}
		
		private function drawChord( v1x:Number, v1y:Number, v2x:Number, v2y:Number, depth:int ):void
		{
			var dx:Number = v2x-v1x;
			var dy:Number = v2y-v1y;
			var d:Number = Math.sqrt(dx*dx+dy*dy);
			
			var rotation:Number = Math.atan2(dy,dx);
			
			var m:Matrix = new Matrix();
			m.rotate(rotation);
			m.scale(d,d);
			m.translate(v1x,v1y);
			
			var L:int = chordVertices.length
			for ( var i:int = 0; i < L; i++ )
			{
				var chordVertex:Vertex = chordVertices[i];
				var pt:Point = m.transformPoint(chordVertex.toPoint());
				
				if ( depth > 0 && i != L-1 )
				{
					var chordVertexB:Vertex = chordVertices[i+1];
					var ptB:Point = m.transformPoint(chordVertexB.toPoint());
					drawChord( pt.x, pt.y, ptB.x, ptB.y, depth-1 );
				}
				else
				{
					sprite.graphics.lineTo(pt.x,pt.y);
				}
			}
		}
		
		private function calculateCorrectionMatrix():void
		{
			
		}
		
		private function buildChordVertices():void
		{
			if ( !_polygon ) return;
			if ( _polygon.vertices.length < 2 ) return;
			
			var correctionMatrix:Matrix = new Matrix();
			
			var v1:Vertex = _polygon.vertices[0];
			var v2:Vertex = _polygon.vertices[_polygon.vertices.length-1];
			
			var dx:Number = v2.x - v1.x;
			var dy:Number = v2.y - v1.y;
			var chordLength:Number = Math.sqrt(dx*dx+dy*dy);
			
			var rotation:Number = Math.atan2(dy,dx);
			
			correctionMatrix.translate(-v1.x,-v1.y);
			correctionMatrix.rotate(-rotation);
			correctionMatrix.scale(1/chordLength,1/chordLength);
			
			
			chordVertices = [];
			
			
			for ( var i:int = 0; i < _polygon.vertices.length; i++ )
			{
				var vertex:Vertex = _polygon.vertices[i];
				var pt:Point = correctionMatrix.transformPoint(vertex.toPoint());
				chordVertices[i] = new Vertex( pt.x, pt.y );
			}
		}
		
		[Inspectable( editor="NumericStepper", max="4" )][Serializable]
		public function set depth( value:int ):void
		{
			_depth = value;
			invalidate("display");
		}
		public function get depth():int { return _depth; }
	}
}