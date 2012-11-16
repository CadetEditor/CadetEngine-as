// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.serialize
{
	import away3d.core.base.Object3D;
	
	public class TraceSerializer implements ISerializer
	{
		public function TraceSerializer()
		{
		}
		
		public function export(object3d:Object3D):String
		{
			SceneParser.parse(object3d);
			
			var containers:Array 	= SceneParser.containers;
			var meshes:Array		= SceneParser.meshes;
			var wireframes:Array	= SceneParser.wireframes;
			var segmentSets:Array	= SceneParser.segmentSets;
			var segments:Array		= SceneParser.segments;
			var geometries:Array 	= SceneParser.geometries;
			var materials:Array 	= SceneParser.materials;
			var cameras:Array		= SceneParser.cameras;
			var lights:Array		= SceneParser.lights;
			var messages:Array		= SceneParser.messages;
			var numSegmentSets:uint = SceneParser.numSegmentSets;
			
			var str:String = "";
			
			// Write messages
			if ( messages.length > 0 )
			{
				for ( var i:uint = 0; i < messages.length; i ++ )
				{
					var msg:String = messages[i];
					str += "// "+msg+"\n";;
				}
			}
			
			str += writeObjects("Geometries", geometries);
			str += writeObjects("Materials", materials);
			str += writeObjects("Segments", segments);
			str += writeObjects("Containers", containers);
			str += writeObjects("Lights", lights);
			str += writeObjects("Cameras", cameras);
			str += writeObjects("Wireframes", wireframes);
			str += writeObjects("SegmentSets", segmentSets);
			str += writeObjects("Meshes", meshes);
			
			return str;
		}
		
		private function writeObjects(title:String, array:Array):String
		{
			var str:String = "";
			
			if ( array.length > 0 )
			{
				str += newLine("// "+title, 0);
				
				for ( var i:uint = 0; i < array.length; i ++ )
				{
					var obj:SerializedObject = array[i];
					str += obj.toString();
					
					if (i != array.length - 1) {
						str += newLine();
					}
				}
				
				str += newLine();
			}
			
			return str;
		}
		
		private function newLine(value:String = "", numTabs:uint = 0):String
		{
			var str:String = "\n";
			
			for ( var i:uint = 0; i < numTabs; i ++ )
			{
				str += "\t";
			}
			
			str += value;
			
			return str;
		}		
	}
}








