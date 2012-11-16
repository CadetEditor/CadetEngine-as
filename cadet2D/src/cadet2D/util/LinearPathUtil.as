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
	import cadet2D.geom.Vertex;
	
	public class LinearPathUtil
	{
		static public function weld( vertices:Array, minimumDistance:Number ):void
		{
			var L:int = vertices.length;
			if ( L < 3 ) return;
			var dis:Number = minimumDistance*minimumDistance;
			
			while ( true )
			{
				if ( L < 3 ) break
				var found:Boolean = false;
				for ( var i:int = 0; i < L-2; i++ )
				{
					var vertexA:Vertex = vertices[i];
					var vertexB:Vertex = vertices[i+1];
					var dx:Number = vertexB.x - vertexA.x;
					var dy:Number = vertexB.y - vertexA.y;
					var d:Number = dx*dx + dy*dy;
					if ( d > dis ) continue;
					found = true;
					vertexA.x += dx*0.5;
					vertexA.y += dy*0.5;
					vertices.splice(i+1,1);
					L--;
				}
				if ( !found ) break;
			}
		}
		
		static public function getLength( vertices:Array ):Number
		{
			if ( vertices.length < 2 ) return 0;
			
			var d:Number = 0;
			var prevPos:Vertex = vertices[0];
			for ( var i:int = 1; i < vertices.length; i++ )
			{
				var pos:Vertex = vertices[i];
				var dx:Number = pos.x - prevPos.x;
				var dy:Number = pos.y - prevPos.y;
				d += Math.sqrt(dx*dx + dy*dy);
				prevPos = pos;
			}
			
			return d;
		}
		
		static public function evaluate( vertices:Array, t:Number, output:Vertex ):Vertex
		{
			var L:int = vertices.length;
			
			if ( L == 1 )
			{
				output.x = vertices[0].x;
				output.y = vertices[0].y;
				return output;
			}
			
			var ratio:Number = (t * (L-1)) % 1
			var index:int = t * (L-1);
			
			var vertexA:Vertex = vertices[index];
			var vertexB:Vertex = vertices[index+1];
			
			output.x = (1-ratio) * vertexA.x + ratio * vertexB.x;
			output.y = (1-ratio) * vertexA.y + ratio * vertexB.y;
			
			return output;
		}
	}
}