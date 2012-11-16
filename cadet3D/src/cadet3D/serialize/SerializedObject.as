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
	public class SerializedObject
	{
		public var id				:uint;
		public var setId			:uint; // currently only used by Segments
		public var containerId		:int;
		public var className		:String;
		public var instanceName 	:String;
		public var props			:Vector.<NameValuePair>;
		public var constructorArgs	:Vector.<NameValuePair>;
		public var source			:Object;
		public var type				:Class;
		
		public function SerializedObject()
		{
			props 				= new Vector.<NameValuePair>();
			constructorArgs 	= new Vector.<NameValuePair>();
		}
		
		public function getPropByName(name:String):NameValuePair
		{
			return _getPropByName(name);
		}
		public function getConstructorArgByName(name:String):NameValuePair
		{
			return _getPropByName(name);	
		}
		private function _getPropByName(name:String):NameValuePair
		{
			var vector:Vector.<NameValuePair> = props.concat(constructorArgs);
			for ( var i:uint = 0; i < vector.length; i ++ )
			{
				var nvp:NameValuePair = vector[i];
				if ( nvp.name == name ) {
					return nvp;
				}
			}
			return null;
		}
		
		public function toString(numTabs:uint = 0):String
		{
			var str:String = "";
			
			str += newLine("SerializedObject", numTabs);
			str += newLine("className : "+className, numTabs + 1);
			str += newLine("type : "+type, numTabs + 1);
			str += newLine("source : "+source, numTabs + 1);
			str += newLine("instanceName : "+instanceName, numTabs + 1);
			str += newLine("id : "+id, numTabs + 1);
			str += newLine("setId : "+setId, numTabs + 1);
			str += newLine("containerId : "+containerId, numTabs + 1);

			str += newLine("constructorArgs : length = "+constructorArgs.length, numTabs + 1);	
			str += vectorToString(constructorArgs, numTabs);		
		
			str += newLine("props : length = "+props.length, numTabs + 1);	
			str += vectorToString(props, numTabs);
			
			return str;
		}
		
		private function vectorToString(v:Vector.<NameValuePair>, numTabs:uint = 0):String
		{
			var str:String = "";
			
			for ( var i:int = 0; i < v.length; i ++ )
			{
				var nvp:NameValuePair = v[i];
				var value:Object = nvp.value.toString();
				
				if (nvp.value is SerializedObject) {
					value = nvp.value.toString(numTabs + 3);
				} else if (nvp.value is Vector.<SerializedObject>) {
					value = "";
					var v2:Vector.<SerializedObject> = Vector.<SerializedObject>(nvp.value);
					for ( var j:uint = 0; j < v2.length; j ++ )
					{
						var vSO:SerializedObject = v2[j];
						value += vSO.toString(numTabs + 3);
					}
				}
				str += newLine(nvp.name+" : "+value, numTabs + 2);
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





