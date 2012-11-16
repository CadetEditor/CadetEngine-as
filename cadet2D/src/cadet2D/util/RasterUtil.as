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
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import cadet2D.geom.Vertex;
	
	public class RasterUtil
	{
		private static var labelTable		:Array;
		private static var loops			:Array
		private static const UNLABELED		:int = 0;
		private static const VISITED_WHITE	:int = -1;
		
		private static var offsetTableX		:Object;
		private static var offsetTableY		:Object;
		private static var nextPosTable		:Object;
		
		
		public static function bitmapToVertices( bmpData:BitmapData ):Array
		{
			if ( !offsetTableX )
			{
				offsetTableX = {};
				offsetTableY = {};
				nextPosTable = {};
				
				offsetTableX[0] = 1;
				offsetTableY[0] = 0;
				
				offsetTableX[1] = 1;
				offsetTableY[1] = 1;
				
				offsetTableX[2] = 0;
				offsetTableY[2] = 1;
				
				offsetTableX[3] = -1;
				offsetTableY[3] = 1;
				
				offsetTableX[4] = -1;
				offsetTableY[4] = 0;
				
				offsetTableX[5] = -1;
				offsetTableY[5] = -1;
				
				offsetTableX[6] = 0;
				offsetTableY[6] = -1;
				
				offsetTableX[7] = 1;
				offsetTableY[7] = -1;
				
				nextPosTable[0] = 4;
				nextPosTable[1] = 5;
				nextPosTable[2] = 6;
				nextPosTable[3] = 7;
				nextPosTable[4] = 0;
				nextPosTable[5] = 1;
				nextPosTable[6] = 2;
				nextPosTable[7] = 3;
			}
			
			
			
			
			//var startTime:int = flash.utils.getTimer();
			
			var bitmap:BitmapData = new BitmapData( bmpData.width+2, bmpData.height+2, false, 0xFFFFFF );
			bitmap.draw( bmpData, new Matrix(1,0,0,1,1,1), new ColorTransform(0,0,0) );
			
			var w:int = bitmap.width;
			var h:int = bitmap.height;
			
			labelTable = [];
			loops = [];
			
			var C:int = 1;
			for ( var y:int = 1; y < h; y++ )
			{
				for ( var x:int = 0; x < w; x++ )
				{
					var isBlack:Boolean = bitmap.getPixel(x,y) == 0;
					if ( !isBlack ) continue;
					
					var currentLabel:int = UNLABELED;
					if ( labelTable[x] != null )
					{
						currentLabel = labelTable[x][y];
					}
					
					var isPixelAboveBlack:Boolean = bitmap.getPixel(x,y-1) == 0;
					var isContour:Boolean = false;
					// Step 1
					if ( currentLabel == UNLABELED && isPixelAboveBlack == false)
					{
						if ( labelTable[x] == null ) labelTable[x] = [];
						labelTable[x][y] = C;
						traceContour( x, y, C, bitmap, true );
						C++;
						isContour = true;
					}
					
					var isPixelBelowBlack:Boolean = bitmap.getPixel(x,y+1) == 0;
					var pixelBelowLabel:int = labelTable[x][y];
					
					if ( isPixelBelowBlack == false && pixelBelowLabel == UNLABELED )
					{
						if ( currentLabel == UNLABELED )
						{
							if ( labelTable[x] == null ) labelTable[x] = [];
							labelTable[x][y] = labelTable[x-1][y];
						}
						
						traceContour( x, y, C, bitmap, false );
						C++;
						isContour = true;
					}
					
					if ( !isContour )
					{
						if ( labelTable[x] == null ) labelTable[x] = [];
						labelTable[x][y] = labelTable[x-1][y];
					}
				}
			}
			
			//trace(flash.utils.getTimer() - startTime);
			
			return loops;
		}
		
		private static function traceContour( x:int, y:int, C:int, bitmap:BitmapData, contourType:Boolean ):void
		{
			var loop:Array = [];
			var s:Vertex = new Vertex(x,y);
			loop.push(s);
			var loopLength:int = 1;
			var t:Vertex;
			var pos:int = contourType ? 7 : 3;
			
			var sx:Number = s.x;
			var sy:Number = s.y;
			do
			{
				var i:int = 8;
				while ( i-- > -1 )
				{
					var localX:int = x;
					var localY:int = y;
					
					localX += offsetTableX[pos];
					localY += offsetTableY[pos];
					
					var isLocalBlack:Boolean = bitmap.getPixel(localX, localY) == 0;
					
					if ( isLocalBlack )
					{
						if ( labelTable[localX] == null ) labelTable[localX] = [];
						labelTable[localX][localY] = C;
						t = new Vertex( localX, localY );
						loop[loopLength++] = t;
						
						pos = (nextPosTable[pos] + 2) % 8;
						
						x = localX;
						y = localY;
						
						break;
					}
					else
					{
						if ( labelTable[localX] == null ) labelTable[localX] = [];
						labelTable[localX][localY] = VISITED_WHITE;
					}
					
					pos = (pos+1) % 8;
				}
				if ( !t )
				{
					t = new Vertex(s.x,s.y);
				}
			}
			while( t.x != sx || t.y != sy )
			
			if ( loop.length > 2 )
			{
				loops.push(loop);
			}
		}
	}
}