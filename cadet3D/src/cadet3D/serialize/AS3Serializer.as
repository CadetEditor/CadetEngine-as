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
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.WireframeCube;
	
	import flash.geom.Vector3D;

	public class AS3Serializer implements ISerializer
	{
		public var addHoverCamera	:Boolean;
		
		public function AS3Serializer(addHoverCamera:Boolean = false)
		{
			this.addHoverCamera = addHoverCamera;
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
			
			var msg:String = "Works with Away3D \"Gold\" release (revision 7).\n//Save this file as \"ExportedScene.as\" within an ActionScript project which has access to the Away3D library.\n// Publish the file as the project's main application and your scene will appear."; 
			if ( messages.length > 0 ) msg += "\n";
			messages.unshift(msg);
			
			// Write messages
			if ( messages.length > 0 )
			{
				for ( var i:uint = 0; i < messages.length; i ++ )
				{
					msg = messages[i];
					str += "// "+msg+"\n";;
				}
			}
			
			str += writeStartOfFile();
			
			var numTabs:uint = 3;
			
			addDefaultMeshValues(meshes, geometries, materials);
			//addDefaultWireframes(wireframes);
			
			var obj:SerializedObject;
			
			// Write geometries
			if ( geometries.length > 0 )
			{
				str += newLine("// Geometries", numTabs);
				
				for ( i = 0; i < geometries.length; i ++ )
				{
					obj = geometries[i];
					str += writeObject(obj, numTabs);
					str += newLine("geometries.push("+obj.instanceName+");", numTabs);
					
					if (i != geometries.length - 1) {
						str += newLine();
					}
				}
				
				str += newLine();
			}
			
			// Write materials
			if ( materials.length > 0 )
			{
				str += newLine("// Materials", numTabs);
				
				for ( i = 0; i < materials.length; i ++ )
				{
					obj = materials[i];
					str += writeObject(obj, numTabs);
					str += newLine(obj.instanceName+".lightPicker = lightPicker;", numTabs);
					str += newLine("materials.push("+obj.instanceName+");", numTabs);
					
					if (i != materials.length - 1) {
						str += newLine();
					}
				}
				
				str += newLine();			
			}
			
			// Write segments
			if ( segments.length > 0 )
			{
				str += newLine("// Segments", numTabs);
			
				for ( i = 0; i < numSegmentSets; i ++ )
				{
					str += newLine("segmentSets["+i+"] = [];", numTabs);
				}
				
				str += newLine();
	
				for ( i = 0; i < segments.length; i ++ )
				{
					obj = segments[i];
					str += writeObject(obj, numTabs);
					str += newLine("segmentSets["+obj.containerId+"].push("+obj.instanceName+");", numTabs);
					
					if (i != segments.length - 1) {
						str += newLine();
					}
				}
				
				str += newLine();
			}
			
			// Write containers
			if ( containers.length > 0 )
			{
				str += newLine("// Containers", numTabs);
				
				for ( i = 0; i < containers.length; i ++ )
				{
					obj = containers[i];
					
					var container:String = "containers["+obj.containerId+"]";
					if ( obj.containerId == -1) {
						container = "scene";
					}
					
					str += writeObject(obj, numTabs);
					str += newLine("containers.push("+obj.instanceName+");", numTabs);
					str += newLine(container+".addChild("+obj.instanceName+");", numTabs);
					
					if (i != containers.length - 1) {
						str += newLine();
					}
				}
				
				str += newLine();
			}
			
			// Write lights
			if ( lights.length > 0 )
			{
				str += newLine("// Lights", numTabs);
				
				for ( i = 0; i < lights.length; i ++ )
				{
					obj = lights[i];
					
					container = "containers["+obj.containerId+"]";
					if ( obj.containerId == -1) {
						container = "scene";
					}
					
					str += writeObject(obj, numTabs);
					str += newLine("lights.push("+obj.instanceName+");", numTabs);
					str += newLine(container+".addChild("+obj.instanceName+");", numTabs);
					
					if (i != lights.length - 1) {
						str += newLine();
					}
				}
				
				str += newLine();
				str += newLine("lightPicker.lights = lights.slice();", numTabs);
				str += newLine();
			}
			
			// Write cameras
			if ( cameras.length > 0 )
			{
				str += newLine("// Cameras", numTabs);
				
				for ( i = 0; i < cameras.length; i ++ )
				{
					obj = cameras[i];
					
					container = "containers["+obj.containerId+"]";
					if ( obj.containerId == -1) {
						container = "scene";
					}
					
					str += writeObject(obj, numTabs);
					str += newLine("cameras.push("+obj.instanceName+");", numTabs);
					str += newLine(container+".addChild("+obj.instanceName+");", numTabs);
					
					if (i != cameras.length - 1) {
						str += newLine();
					}
				}
				
				str += newLine();
			}
			
			// Write wireframes
			if ( wireframes.length > 0 )
			{
				str += newLine("// Wireframes", numTabs);
				
				for ( i = 0; i < wireframes.length; i ++ )
				{
					obj = wireframes[i];
					
					container = "containers["+obj.containerId+"]";
					if ( obj.containerId == -1) {
						container = "scene";
					}
					
					str += writeObject(obj, numTabs);
					str += newLine("wireframes.push("+obj.instanceName+");", numTabs);
					str += newLine(container+".addChild("+obj.instanceName+");", numTabs);
					
					if (i != wireframes.length - 1) {
						str += newLine();
					}
				}
				
				str += newLine();
			}
			
			// Write segmentSets
			if ( segmentSets.length > 0 )
			{
				str += newLine("// SegmentSets", numTabs);
				
				for ( i = 0; i < segmentSets.length; i ++ )
				{
					obj = segmentSets[i];
					
					container = "containers["+obj.containerId+"]";
					if ( obj.containerId == -1) {
						container = "scene";
					}
					
					str += writeObject(obj, numTabs);
					str += newLine("segmentSets.push("+obj.instanceName+");", numTabs);
					str += newLine(container+".addChild("+obj.instanceName+");", numTabs);
					
					if (i != segmentSets.length - 1) {
						str += newLine();
					}
				}
				
				str += newLine();
			}			
			
			// Write meshes
			if ( meshes.length > 0 )
			{
				str += newLine("// Meshes", numTabs);
				
				for ( i = 0; i < meshes.length; i ++ )
				{
					obj = meshes[i];
					
					container = "containers["+obj.containerId+"]";
					if ( obj.containerId == -1) {
						container = "scene";
					}
					
					str += writeObject(obj, numTabs);
					str += newLine("meshes.push("+obj.instanceName+");", numTabs);
					str += newLine(container+".addChild("+obj.instanceName+");", numTabs);
					
					if (i != meshes.length - 1) {
						str += newLine();
					}
				}
			}
			
			str += writeEndOfFile();
			
			return str;
		}		
		
		private function writeObject(obj:SerializedObject, numTabs:uint = 0):String
		{
			// Add variable instantiation
			var str	:String = newLine("var "+obj.instanceName+":"+obj.className+" = new "+obj.className+"(", numTabs);
			
			// Add constructor args
			for ( var i:uint = 0; i < obj.constructorArgs.length; i ++ )
			{
				var nvp	:NameValuePair = obj.constructorArgs[i];
				var nvps:Vector.<NameValuePair>	= convertNVP(nvp);

				for ( var j:uint = 0; j < nvps.length; j ++ )
				{
					nvp = nvps[j];	
					str += nvp.value;
					
					if (i < obj.constructorArgs.length - 1) str += ",";					
				}
			}
			// Close constructor
			str += ");"
			
			// Add instance properties
			for ( i = 0; i < obj.props.length; i ++ ) {
				nvp = obj.props[i];
				nvps = convertNVP(nvp);
				
				for ( j = 0; j < nvps.length; j ++ )
				{
					nvp = nvps[j];
					
					if ( nvp.value ) {
						str += newLine(obj.instanceName+"."+nvp.name+" = "+nvp.value+";", numTabs);
					} else {
						str += newLine(obj.instanceName+"."+nvp.name+";", numTabs);
					}
				}
			}
			
			return str;			
		}
		
		private function convertNVP(nvp:NameValuePair):Vector.<NameValuePair>
		{
			var name:String = nvp.name;
			var value:Object = nvp.value;
			var nvps:Vector.<NameValuePair> = new Vector.<NameValuePair>();
			
			if ( nvp.value is Vector.<SerializedObject>)
			{
				if (nvp.name == "segments") {
					var segments:Vector.<SerializedObject> = Vector.<SerializedObject>(nvp.value);
					for ( var j:uint = 0; j < segments.length; j ++ )
					{
						var segObj:SerializedObject = segments[j];
						var newNvp:NameValuePair = new NameValuePair("addSegment(segmentSets["+segObj.containerId+"]["+segObj.setId+"])", null);
						nvps.push(newNvp);
					}
				}
				return nvps;
			}
			
			if (nvp.value is SerializedObject )
			{
				if (nvp.name == "geometry") {
					value = "geometries["+SerializedObject(nvp.value).id+"]";
				} else if (nvp.name == "material") {
					value = "materials["+SerializedObject(nvp.value).id+"]";
				}
			}
			else if (nvp.value is Vector3D)
			{
				value = "new "+Vector3D(nvp.value).toString();
			}
			
			nvp.name = name;
			nvp.value = value;
			
			nvps.push(nvp);
			
			return nvps;
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
		
		private function addDefaultMeshValues(meshes:Array, geometries:Array, materials:Array):void
		{
			var defaultGeomRequired:Boolean = false;
			var defaultMatRequired:Boolean = false;
			
			// Add default geometry in case any meshes don't have geometries
			var geom:CubeGeometry = new CubeGeometry();
			var geomObj:SerializedObject = SceneParser.getObjectData(geom, geometries.length);
			geomObj.instanceName = "defaultGeometry";
			
			// Add default material in case any meshes don't have materials
			var mat:ColorMaterial = new ColorMaterial();
			var matObj:SerializedObject = SceneParser.getObjectData(mat, materials.length);
			matObj.instanceName = "defaultMaterial";
			
			
			for ( var i:uint = 0; i < meshes.length; i ++ )
			{
				var obj:SerializedObject = meshes[i];
				if (obj.getPropByName("material") == null) {
					obj.props.push(new NameValuePair("material", matObj));
					defaultMatRequired	= true;
				}
				if (obj.getPropByName("geometry") == null) {
					obj.constructorArgs.push(new NameValuePair("geometry", geomObj));
					defaultGeomRequired = true;
				}
			}
			
			if (defaultGeomRequired)
				geometries.push(geomObj);
			if (defaultMatRequired)	
				materials.push(matObj);			
		}

		private function writeStartOfFile():String
		{
			var str:String = "package";
			str += newLine("{");
			str += newLine("	import away3d.cameras.Camera3D;");
			str += newLine("	import away3d.containers.*;");
			
			if (addHoverCamera) 
				str += newLine("	import away3d.controllers.HoverController;");
			
			str += newLine("	import away3d.entities.*;");
			str += newLine("	import away3d.lights.*;");
			str += newLine("	import away3d.materials.*;");
			str += newLine("	import away3d.materials.lightpickers.StaticLightPicker;");
			str += newLine("	import away3d.primitives.*;");
			str += newLine();
			str += newLine("	import flash.display.Sprite;");
			str += newLine("	import flash.display.StageAlign;");
			str += newLine("	import flash.display.StageScaleMode;");
			str += newLine("	import flash.events.*;");
			str += newLine("	import flash.geom.Vector3D;");
			str += newLine();
			str += newLine("	public class ExportedScene extends Sprite");
			str += newLine("	{");
			str += newLine("		private var scene:Scene3D;");
			str += newLine("		private var view:View3D;");		
			str += newLine();
			str += newLine("		private var camera:Camera3D;");
			
			if (addHoverCamera) 
			{
				str += newLine("		private var cameraController:HoverController;");
				str += newLine();
				str += newLine("		//navigation variables");
				str += newLine("		private var move:Boolean = false;");
				str += newLine("		private var lastPanAngle:Number;");
				str += newLine("		private var lastTiltAngle:Number;");
				str += newLine("		private var lastMouseX:Number;");
				str += newLine("		private var lastMouseY:Number;");
				str += newLine("		private var tiltSpeed:Number = 2;");
				str += newLine("		private var panSpeed:Number = 2;");
				str += newLine("		private var distanceSpeed:Number = 1000;");
				str += newLine("		private var tiltIncrement:Number = 0;");
				str += newLine("		private var panIncrement:Number = 0;");
				str += newLine("		private var distanceIncrement:Number = 0;");
			}
			
			str += newLine("");
			str += newLine("		public function ExportedScene()");
			str += newLine("		{");
			str += newLine("			stage.scaleMode = StageScaleMode.NO_SCALE;");
			str += newLine("			stage.align = StageAlign.TOP_LEFT;");
			str += newLine();
			str += newLine("			view = new View3D();");
			str += newLine("			scene = view.scene;");
			str += newLine("			addChild(view);");
			str += newLine();
			str += newLine("			camera = view.camera;");
			str += newLine("			camera.position = new Vector3D(800,800,800);");
			str += newLine("			camera.lookAt(new Vector3D(0,0,0));");
			
			if (addHoverCamera)
				str += newLine("			cameraController = new HoverController(camera);");
			
			str += newLine();
			str += newLine("			addEventListener(Event.ENTER_FRAME, onEnterFrame);");
			
			if (addHoverCamera)
			{
				str += newLine("			view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);");
				str += newLine("			view.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);");
			}
			
			str += newLine("			stage.addEventListener(Event.RESIZE, onResize);");
			str += newLine("			onResize();");
			str += newLine();
			str += newLine("			var geometries:Array = [];");
			str += newLine("			var materials:Array = [];");
			str += newLine("			var segmentSets:Array = [];");
			str += newLine("			var lights:Array = [];");
			str += newLine("			var cameras:Array = [];");
			str += newLine("			var containers:Array = [];");
			str += newLine("			var meshes:Array = [];");
			str += newLine("			var wireframes:Array = [];");
			str += newLine();
			str += newLine("			var lightPicker:StaticLightPicker = new StaticLightPicker(lights);");
			str += newLine();
			
			return str;
		}
		private function writeEndOfFile():String
		{
			var str:String = newLine("		}");
			str += newLine();
			str += newLine("		private function onEnterFrame(event:Event):void");
			str += newLine("		{");
			
			if (addHoverCamera)
			{
				str += newLine("			if (move) {");
				str += newLine("			cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;");
				str += newLine("			cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;");
				str += newLine("			}");
				str += newLine();
				str += newLine("			cameraController.panAngle += panIncrement;");
				str += newLine("			cameraController.tiltAngle += tiltIncrement;");
				str += newLine("			cameraController.distance += distanceIncrement;");
				str += newLine();
			}
			
			str += newLine("			view.render();");
			str += newLine("		}");
			str += newLine();
			str += newLine("		private function onResize(event:Event = null):void");
			str += newLine("		{");
			str += newLine("			view.width = stage.stageWidth;");
			str += newLine("			view.height = stage.stageHeight;");
			str += newLine("		}");
			
			if (addHoverCamera) 
			{
				str += newLine();
				str += newLine("		private function onMouseDown(event:MouseEvent):void");
				str += newLine("		{");
				str += newLine("			move = true;");
				str += newLine("			lastPanAngle = cameraController.panAngle;");
				str += newLine("			lastTiltAngle = cameraController.tiltAngle;");
				str += newLine("			lastMouseX = stage.mouseX;");
				str += newLine("			lastMouseY = stage.mouseY;");
				str += newLine("			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);");
				str += newLine("		}");
				str += newLine();
				str += newLine("		private function onMouseUp(event:MouseEvent):void");
				str += newLine("		{");
				str += newLine("			move = false;");
				str += newLine("			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);");
				str += newLine("		}");
				str += newLine();
				str += newLine("		private function onStageMouseLeave(event:Event):void");
				str += newLine("		{");
				str += newLine("			move = false;");
				str += newLine("			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);");
				str += newLine("		}");			
			}
			
			str += newLine("	}");
			str += newLine("}");
			
			return str;
		}
	}
}





