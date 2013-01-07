// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.util
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import cadet2D.geom.QuadraticBezier;
	import cadet2D.geom.Vertex;
	import cadet.util.Equations;
	
	
	public class QuadraticBezierUtil
	{
		private static const PRECISION:Number = 1e-10;
		
		public static function clone( segments:Vector.<QuadraticBezier> ):Vector.<QuadraticBezier>
		{
			var clonedSegments:Vector.<QuadraticBezier> = new Vector.<QuadraticBezier>();
			for ( var i:int = 0; i < segments.length; i++ )
			{
				clonedSegments.push( segments[i].clone() );
			}
			return clonedSegments;
		}
		
		public static function transform( segments:Vector.<QuadraticBezier>, matrix:Matrix ):void
		{
			var start:Point = new Point();
			var end:Point = new Point();
			var control:Point = new Point();
			
			for each ( var segment:QuadraticBezier in segments )
			{
				start.x = segment.startX;
				start.y = segment.startY;
				end.x = segment.endX;
				end.y = segment.endY;
				control.x = segment.controlX;
				control.y = segment.controlY;
				
				start = matrix.transformPoint(start);
				end = matrix.transformPoint(end);
				control = matrix.transformPoint(control);
				
				segment.startX = start.x;
				segment.startY = start.y;
				segment.endX = end.x;
				segment.endY = end.y;
				segment.controlX = control.x;
				segment.controlY = control.y;
			}
		}
		
		public static function draw( graphics:Graphics, segments:Vector.<QuadraticBezier> ):void
		{
			for ( var i:int = 0; i < segments.length; i++ )
			{
				var segment:QuadraticBezier = segments[i];
				graphics.moveTo(segment.startX, segment.startY);
				graphics.curveTo(segment.controlX, segment.controlY, segment.endX, segment.endY);
			}
		}
		
		public static function evaluatePosition( segments:Vector.<QuadraticBezier>, ratio:Number, vertex:Vertex = null ):Vertex
		{
			ratio = ratio < 0 ? 0 : ratio > 1 ? 1 : ratio;
			
			var segmentIndex:int
			if ( ratio == 1 )
			{
				segmentIndex = segments.length-1;
			}
			else
			{
				segmentIndex = ratio * segments.length;
			}
			
			var segmentRatio:Number = 1/segments.length;
			
			var localRatio:Number
			if ( ratio == 1 )
			{
				localRatio = 1;
			}
			else if ( segmentIndex == 0 )
			{
				localRatio = ratio / segmentRatio;
			}
			else
			{
				localRatio = (ratio % (segmentIndex*segmentRatio)) / segmentRatio;
			}
			
			return evaluateSegmentPosition(segments[segmentIndex], localRatio, vertex );
		}
		
		public static function makeContinuous( segmentA:QuadraticBezier, segmentB:QuadraticBezier ):void
		{
			var dx:Number = segmentA.controlX - segmentA.endX;
			var dy:Number = segmentA.controlY - segmentA.endY;
			segmentB.controlX = segmentB.startX - dx;
			segmentB.controlY = segmentB.startY - dy;
		}
				
		public static function getLength( segments:Vector.<QuadraticBezier> ):Number
		{
			var length:Number = 0;
			for each ( var segment:QuadraticBezier in segments )
			{
				length += getSegmentLength(segment);
			}
			return length;
		}
		
		public static function getBounds( segments:Vector.<QuadraticBezier> ):flash.geom.Rectangle
		{
			var xMin:Number = Number.POSITIVE_INFINITY;
			var xMax:Number = Number.NEGATIVE_INFINITY;
			var yMin:Number = Number.POSITIVE_INFINITY;
			var yMax:Number = Number.NEGATIVE_INFINITY;
			
			var segmentBounds:flash.geom.Rectangle = new flash.geom.Rectangle();
			
			for each ( var segment:QuadraticBezier in segments )
			{
				getSegmentBounds( segment, segmentBounds );
				xMin = segmentBounds.left < xMin ? segmentBounds.left:xMin;
				yMin = segmentBounds.top < yMin ? segmentBounds.top:yMin;
				xMax = segmentBounds.right > xMax ? segmentBounds.right:xMax;
				yMax = segmentBounds.bottom > yMax ? segmentBounds.bottom:yMax;
			}
			
			return new flash.geom.Rectangle(xMin,yMin,xMax-xMin,yMax-yMin);
		}
		
		public static function getClosestRatio(segments:Vector.<QuadraticBezier>, x:Number, y:Number):Number 
		{
			var closestDistance:Number = Number.POSITIVE_INFINITY;
			var closestIndex:int;
			var closestRatio:Number;
			var v:Vertex = new Vertex();
			for ( var i:int = 0; i < segments.length; i++ )
			{
				var segment:QuadraticBezier = segments[i];
				var ratio:Number = getClosestRatioOnSegment(segment, x, y);
				evaluateSegmentPosition(segment, ratio, v);
				var dx:Number = v.x - x;
				var dy:Number = v.y - y;
				var d:Number = dx*dx+dy*dy;
				if ( d < closestDistance )
				{
					closestDistance = d;
					closestRatio = ratio;
					closestIndex = i;
				}
			}
			
			var segmentRatio:Number = 1/segments.length;
			return (closestIndex * segmentRatio) + (closestRatio * segmentRatio);
		}
		
		public static function evaluateSegmentPosition(segment:QuadraticBezier, ratio:Number, vertex:Vertex = null):Vertex
		{
			//ratio = ratio < 0 ? 0 : ratio > 1 ? 1 : ratio;
			
			vertex = vertex == null ? new Vertex():vertex;
			
			const f:Number = 1 - ratio;
			vertex.x = segment.startX * f * f + segment.controlX * 2 * ratio * f + segment.endX * ratio * ratio;
			vertex.y = segment.startY * f * f + segment.controlY * 2 * ratio * f + segment.endY * ratio * ratio;
			return vertex;
		}
		
		public static function getSegmentLength( segment:QuadraticBezier, time:Number = 1 ):Number
		{
			const csX:Number = segment.controlX - segment.startX;
			const csY:Number = segment.controlY - segment.startY;
			const nvX:Number = segment.endX - segment.controlX - csX;
			const nvY:Number = segment.endY - segment.controlY - csY;
			
			// vectors: c0 = 4*(cs,cs), с1 = 8*(cs, ec-cs), c2 = 4*(ec-cs,ec-cs)
			const c0:Number = 4 * (csX * csX + csY * csY);
			const c1:Number = 8 * (csX * nvX + csY * nvY);
			const c2:Number = 4 * (nvX * nvX + nvY * nvY);
			
			var ft:Number;
			var f0:Number;
			
			if (c2 == 0) 
			{
				if (c1 == 0) 
				{
					ft = Math.sqrt(c0) * time;
					return ft;
				} 
				else 
				{
					ft = (2 / 3) * (c1 * time + c0) * Math.sqrt(c1 * time + c0) / c1;
					f0 = (2 / 3) * c0 * Math.sqrt(c0) / c1;
					return (ft - f0);
				}
			}
			
			const sqrt_0:Number = Math.sqrt(c2 * time * time + c1 * time + c0);
			const sqrt_c0:Number = Math.sqrt(c0);
			const sqrt_c2:Number = Math.sqrt(c2);
			const exp1:Number = (0.5 * c1 + c2 * time) / sqrt_c2 + sqrt_0;
					
			if (exp1 < PRECISION)
			{
				ft = 0.25 * (2 * c2 * time + c1) * sqrt_0 / c2;
			} else {
				ft = 0.25 * (2 * c2 * time + c1) * sqrt_0 / c2 + 0.5 * Math.log((0.5 * c1 + c2 * time) / sqrt_c2 + sqrt_0) / sqrt_c2 * (c0 - 0.25 * c1 * c1 / c2);
			}
			
			const exp2:Number = (0.5 * c1) / sqrt_c2 + sqrt_c0;
			if (exp2 < PRECISION)
			{
				f0 = 0.25 * (c1) * sqrt_c0 / c2;
			} 
			else
			{
				f0 = 0.25 * (c1) * sqrt_c0 / c2 + 0.5 * Math.log((0.5 * c1) / sqrt_c2 + sqrt_c0) / sqrt_c2 * (c0 - 0.25 * c1 * c1 / c2);
			}
			return ft - f0;
		}
		
		public static function getSegmentBounds( segment:QuadraticBezier, bounds:flash.geom.Rectangle ):flash.geom.Rectangle
		{
			var xMin:Number;
			var xMax:Number;
			var yMin:Number;
			var yMax:Number;
			
			bounds = bounds == null ? new flash.geom.Rectangle():bounds;
			
			const x:Number = segment.startX - 2 * segment.controlX + segment.endX;
			const extremumTimeX:Number = ((segment.startX - segment.controlX) / x) || 0;
			const extemumPointX:Vertex = evaluateSegmentPosition(segment, extremumTimeX);
			
			if (isNaN(extemumPointX.x) || extremumTimeX <= 0 || extremumTimeX >= 1) 
			{
				xMin = Math.min(segment.startX, segment.endX);
				xMax = Math.max(segment.startX, segment.endX);
			} 
			else 
			{
				xMin = Math.min(extemumPointX.x, Math.min(segment.startX, segment.endX));
				xMax = Math.max(extemumPointX.x, Math.max(segment.startX, segment.endX));
			}
			
			const y:Number = segment.startY - 2 * segment.controlY + segment.endY
			const extremumTimeY:Number = ((segment.startY - segment.controlY) / y) || 0;
			const extemumPointY:Vertex = evaluateSegmentPosition(segment, extremumTimeY);
			
			if (isNaN(extemumPointY.y) || extremumTimeY <= 0 || extremumTimeY >= 1) 
			{
				yMin = Math.min(segment.startY, segment.endY);
				yMax = Math.max(segment.startY, segment.endY);
			} 
			else 
			{
				yMin = Math.min(extemumPointY.y, Math.min(segment.startY, segment.endY));
				yMax = Math.max(extemumPointY.y, Math.max(segment.startY, segment.endY));
			}

			bounds.x = xMin;
			bounds.y = yMin;
			bounds.width = xMax - xMin;
			bounds.height = yMax - yMin;
			return bounds;
		}
		
		
		public static function getClosestRatioOnSegment(segment:QuadraticBezier, x:Number, y:Number):Number 
		{
			const sx:Number = segment.startX;
			const sy:Number = segment.startY;
			const cx:Number = segment.controlX;
			const cy:Number = segment.controlY;
			const ex:Number = segment.endX;
			const ey:Number = segment.endY;
	
			const lpx:Number = sx - x;
			const lpy:Number = sy - y;
			
			const kpx:Number = sx - 2 * cx + ex;
			const kpy:Number = sy - 2 * cy + ey;
			
			const npx:Number = -2 * sx + 2 * cx;
			const npy:Number = -2 * sy + 2 * cy;
			
			const delimiter:Number = 2 * (kpx * kpx + kpy * kpy);
			
			var A:Number;
			var B:Number;
			var C:Number;
			var extremumTimes:Array;
			
			if(delimiter) 
			{
				A = 3 * (npx * kpx + npy * kpy) / delimiter;
				B = ((npx * npx + npy * npy) + 2 * (lpx * kpx + lpy * kpy)) / delimiter;
				C = (npx * lpx + npy * lpy) / delimiter;
			
				extremumTimes = Equations.solveCubicEquation(1, A, B, C);
			} 
			else 
			{				
				B = (npx * npx + npy * npy) + 2 * (lpx * kpx + lpy * kpy);
				C = npx * lpx + npy * lpy;
								
				extremumTimes = Equations.solveLinearEquation(B, C);
			}
			
			extremumTimes.push(0);
			extremumTimes.push(1);
			
			var extremumTime:Number;
			var extremumPoint:Vertex = new Vertex();
			var extremumDistance:Number;
			
			var closestPointTime:Number;
			var closestDistance:Number;
			
			var isInside:Boolean;
			
			const len:uint = extremumTimes.length;
			for (var i:uint = 0;i < len; i++)
			{
				extremumTime = extremumTimes[i];
				evaluateSegmentPosition(segment, extremumTime, extremumPoint);
				
				var dx:Number = x - extremumPoint.x;
				var dy:Number = y - extremumPoint.y;
				
				extremumDistance = Math.sqrt(dx*dx+dy*dy);
				
				isInside = (extremumTime >= 0) && (extremumTime <= 1);
				
				if (isNaN(closestPointTime))
				{
					if (isInside) 
					{
						closestPointTime = extremumTime;
						closestDistance = extremumDistance;
					}
					continue;
				}
				
				if (extremumDistance < closestDistance) 
				{
					if (isInside) 
					{
						closestPointTime = extremumTime;
						closestDistance = extremumDistance;
					}
				}
			}
			
			return closestPointTime;
		}
	}
}