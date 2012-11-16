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
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.*;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	public class ThreeJSSerializer implements ISerializer
	{
		private var _types			:Dictionary;
		
		public var addHoverCamera	:Boolean;
		
		private var _geometries		:Array;
		
		public function ThreeJSSerializer(addHoverCamera:Boolean = false)
		{
			this.addHoverCamera = addHoverCamera;
			
			_types 							= new Dictionary();
			_types[Mesh]					= writeMesh;
			_types[ObjectContainer3D]		= writeObjectContainer3D;
			
			// Geometries
			_types[ConeGeometry]			= writeConeGeometry;
			_types[CubeGeometry]			= writeCubeGeometry;
			_types[CylinderGeometry]		= writeCylinderGeometry;
			_types[PlaneGeometry]			= writePlaneGeometry;
			//_types[RegularPolygonGeometry]	= writeRegularPolygonGeometry;
			_types[SphereGeometry]			= writeSphereGeometry;
			//_types[TorusGeometry]			= writeTorusGeometry;
			
			// Wireframes
			_types[SegmentSet]				= writeSegmentSet;
			_types[WireframeCube]			= writeWireframeCube;
			//_types[WireframeCylinder]		= writeWireframeCylinder;
			_types[WireframePlane]			= writeWireframePlane;
			_types[WireframeSphere]		 	= writeWireframeSphere;
			_types[LineSegment]				= writeLineSegment;
			
			// Materials
			_types[ColorMaterial]			= writeColorMaterial;
			// Lights
			_types[DirectionalLight]		= writeDirectionalLight;
			// Cameras
			_types[Camera3D]				= writeCamera3D;
		}
		
		public function export(object3d:Object3D):String
		{
			SceneParser.parse(object3d);
			
			var containers:Array 	= SceneParser.containers;
			var meshes:Array		= SceneParser.meshes;
			var wireframes:Array	= SceneParser.wireframes;
			var segmentSets:Array	= SceneParser.segmentSets;
			var segments:Array		= SceneParser.segments;
			_geometries 			= SceneParser.geometries;
			var materials:Array 	= SceneParser.materials;
			var cameras:Array		= SceneParser.cameras;
			var lights:Array		= SceneParser.lights;
			var messages:Array		= SceneParser.messages;
			
			var str:String = "";
			
			var msg:String = "Works with three.js revision 49-11.\nOpen a text editor and save this as a html file (e.g. \"export.html\"). Run the html in the Google Chrome browser and your scene will appear. Make sure you have an Internet connection so JS resources can be loaded."; 
			if ( messages.length > 0 ) msg += "\n";
			messages.unshift(msg);
			
			// Write messages
			if ( messages.length > 0 )
			{
				str += "<!-- \n";
				for ( var i:uint = 0; i < messages.length; i ++ )
				{
					msg = messages[i];
					str += msg+"\n";;
				}
				str += "-->\n";
			}
			
			str += writeStartOfFile();
			
			var numTabs:uint = 4;
			
			addDefaultMeshValues(meshes, _geometries, materials);
			
			var obj:SerializedObject;
			
			// Write geometries
			if ( _geometries.length > 0 )
			{
				str += newLine("// Geometries", numTabs);
				
				for ( i = 0; i < _geometries.length; i ++ )
				{
					obj = _geometries[i];
					str += writeObject(obj, numTabs)+";";
					str += newLine("geometries.push("+obj.instanceName+");", numTabs);
					
					if (i != _geometries.length - 1) {
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
					//str += newLine(obj.instanceName+".lightPicker = lightPicker;", numTabs);
					str += newLine("materials.push("+obj.instanceName+");", numTabs);
					
					if (i != materials.length - 1) {
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
					str += newLine(container+".add("+obj.instanceName+");", numTabs);
					
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
					str += newLine(obj.instanceName+".position.set(1,0.5,0.5);", numTabs);
					str += newLine("lights.push("+obj.instanceName+");", numTabs);
					str += newLine(container+".add("+obj.instanceName+");", numTabs);
					
					if (i != lights.length - 1) {
						str += newLine();
					}
				}
				
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
					str += newLine(container+".add("+obj.instanceName+");", numTabs);
					
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
					str += newLine(container+".add("+obj.instanceName+");", numTabs);
					
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
					str += newLine(container+".add("+obj.instanceName+");", numTabs);
					
					if (i != wireframes.length - 1) {
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
					str += newLine(container+".add("+obj.instanceName+");", numTabs);
					
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
			var func:Function = _types[obj.type];
			
			if (func != null) {
				return func(obj, numTabs);
			} 
			else if ( obj.source is Geometry )
			{
				// Add default geometry in case geometry isn't recognised
				var geom:CubeGeometry = new CubeGeometry();
				var geomObj:SerializedObject = SceneParser.getObjectData(geom, obj.id);
				geomObj.instanceName = obj.instanceName;
				func = _types[geomObj.type];
				return func(geomObj, numTabs);
			}
			else if ( obj.source is WireframePrimitiveBase )
			{
				return writeWireframeMesh(obj, numTabs);
			}

			return null;			
		}
		
		//===== WRITE GEOMETRIES ====================================================
		
		private function writeConeGeometry(obj:SerializedObject, numTabs:uint = 0):String
		{
			var cone:ConeGeometry = ConeGeometry(obj.source);
			var geom:CylinderGeometry = new CylinderGeometry(cone.topRadius, cone.bottomRadius, cone.height, cone.segmentsW, cone.segmentsH); 
			var geomObj:SerializedObject = SceneParser.getObjectData(geom, obj.id);
			geomObj.instanceName = obj.instanceName;
			
			return writeCylinderGeometry(geomObj, numTabs);					   
		}
		private function writeCylinderGeometry(obj:SerializedObject, numTabs:uint = 0, closeConstructor:Boolean = false, includeVarDeclaration:Boolean = true):String
		{
			var str	:String = writeGeometry(obj, numTabs, 5, closeConstructor, includeVarDeclaration);
			var topClosedNvp	:NameValuePair = obj.constructorArgs[5];
			var openEnded		:Boolean = !topClosedNvp.value;
			str += ","+openEnded+")";
			
			return str;
		}
		private function writeCubeGeometry(obj:SerializedObject, numTabs:uint = 0):String
		{
			return writeGeometry(obj, numTabs, 6);			
		}
		private function writePlaneGeometry(obj:SerializedObject, numTabs:uint = 0):String
		{
			return writeGeometry(obj, numTabs, 4);
		}
		private function writeRegularPolygonGeometry(obj:SerializedObject, numTabs:uint = 0):String
		{
			return "";
		}
		private function writeSphereGeometry(obj:SerializedObject, numTabs:uint = 0):String
		{
			return writeGeometry(obj, numTabs, 3);
		}
		private function writeTorusGeometry(obj:SerializedObject, numTabs:uint = 0):String
		{
			return writeGeometry(obj, numTabs, 4);
		}
		
		private function writeGeometry(obj:SerializedObject, numTabs:uint = 0, numArgs:uint = 0, closeConstructor:Boolean = true, includeVarDeclaration:Boolean = true):String
		{
			var str	:String = "";
			var varDeclaration:String = "";
			if (includeVarDeclaration) {
				str += newLine("var "+obj.instanceName+" = ", numTabs);
			}
			
			str += "new THREE."+obj.className+"(";
			
			// Add constructor args (Limit to number of three.js constructor args)
			for ( var i:uint = 0; i < numArgs; i ++ )
			{
				var nvp	:NameValuePair = obj.constructorArgs[i];
				str += nvp.value;
				if (i < numArgs - 1) str += ",";
			}
			
			if (closeConstructor) {
				str += ")";
			}
				
			return str;
		}
		
		//===========================================================================
		
		//===== WRITE WIREFRAMES ====================================================
		
		private function writeSegmentSet(obj:SerializedObject, numTabs:uint = 0):String
		{
			/*
			var geo = new THREE.Geometry();
			geo.vertices.push( new THREE.Vector3(-23,10,-20) );
			geo.vertices.push( new THREE.Vector3(-3,10,-20) );
			var linesegment9 = new THREE.Line( geo, new THREE.LineBasicMaterial( { color: 0xffffff } ) );
			scene.add(linesegment9);
			*/
			
			var str:String = "";
			
			str += newLine("var geo"+obj.id+" = new THREE.Geometry();", numTabs);
			
			var segments:Vector.<SerializedObject> = Vector.<SerializedObject>(NameValuePair(obj.getPropByName("segments")).value);
			
			for ( var i:uint = 0; i < segments.length; i ++ )
			{
				var segObj:SerializedObject = segments[i];
				var sV:Vector3D = Vector3D(NameValuePair(segObj.getPropByName("start")).value);
				var eV:Vector3D = Vector3D(NameValuePair(segObj.getPropByName("end")).value);
				
				str += newLine("geo"+obj.id+".vertices.push( new THREE.Vector3("+sV.x+","+sV.y+","+sV.z+") );", numTabs);
				
				if ( i == segments.length - 1 ) {
					str += newLine("geo"+obj.id+".vertices.push( new THREE.Vector3("+eV.x+","+eV.y+","+eV.z+") );", numTabs);
				}
			}
			
			str += newLine();
			str += newLine("var "+obj.instanceName+" = new THREE.Line( ", numTabs);
			str += "geo"+obj.id+", new THREE.LineBasicMaterial( { color: "+NameValuePair(segObj.getPropByName("startColor")).value+" } ) );";
			
			return str;
		}
		
		private function writeLineSegment(obj:SerializedObject, numTabs:uint = 0):String
		{
			var str	:String = "";
			var varDeclarationStr:String = "";
			
			if (obj.id == 0 ) {
				varDeclarationStr = "var ";
			}
			str += newLine(varDeclarationStr+"geo = new THREE.Geometry();", numTabs);
			
			var sV:Vector3D = Vector3D(NameValuePair(obj.getPropByName("start")).value);
			var eV:Vector3D = Vector3D(NameValuePair(obj.getPropByName("end")).value);
			
			str += newLine("geo.vertices.push( new THREE.Vector3("+sV.x+","+sV.y+","+sV.z+") );", numTabs);
			str += newLine("geo.vertices.push( new THREE.Vector3("+eV.x+","+eV.y+","+eV.z+") );", numTabs);
			
			str += newLine("var "+obj.instanceName+" = new THREE.Line( ", numTabs);
			str += "geo, new THREE.LineBasicMaterial( { color: "+NameValuePair(obj.getPropByName("startColor")).value+" } ) );";
			
			return str;
		}
		
		private function writeWireframeCube(obj:SerializedObject, numTabs:uint = 0):String
		{
			obj.className = "CubeGeometry";
			var geomStr:String = writeGeometry(obj, 0, 3, true, false);
			
			return writeWireframeMesh(obj, numTabs, geomStr);
		}
		private function writeWireframeCylinder(obj:SerializedObject, numTabs:uint = 0):String
		{
			obj.className = "CylinderGeometry";
			var geomStr:String = writeCylinderGeometry(obj, 0, false, false);
			
			return writeWireframeMesh(obj, numTabs, geomStr);
		}
		private function writeWireframePlane(obj:SerializedObject, numTabs:uint = 0):String
		{
			obj.className = "PlaneGeometry";
			var geomStr:String = writeGeometry(obj, numTabs, 4, true, false);
			
			return writeWireframeMesh(obj, numTabs, geomStr);			
		}
		private function writeWireframeSphere(obj:SerializedObject, numTabs:uint = 0):String
		{
			obj.className = "SphereGeometry";
			var geomStr:String = writeGeometry(obj, numTabs, 3, true, false);
			
			return writeWireframeMesh(obj, numTabs, geomStr);			
		}
		
		private function writeWireframeMesh(obj:SerializedObject, numTabs:uint = 0, geomStr:String = null):String
		{
			obj.className = "Mesh";
			var str	:String = newLine("var "+obj.instanceName+" = new THREE."+obj.className+"(", numTabs); 
			
			var primitive:WireframePrimitiveBase = WireframePrimitiveBase(obj.source);
			var matStr:String = "new THREE.MeshBasicMaterial( { color: 0x"+primitive.color.toString(16)+", wireframe: true } )";
			
			if (!geomStr) {
				geomStr = "new THREE.CubeGeometry(100,100,100)";
			}
			
			str += geomStr+","+matStr+");";
			
			str += writeObject3DProps(obj, numTabs);
			
			return str;
		}
		
		//===========================================================================
		
		//===== WRITE CAMERAS ====================================================
		
		private function writeCamera3D(obj:SerializedObject, numTabs:uint = 0):String
		{
			var str	:String = newLine("var "+obj.instanceName+" = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 2000 );", numTabs);
			str += writeObject3DProps(obj, numTabs);
			
			return str;	
		}
		
		//===========================================================================
		
		//===== WRITE MATERIALS =====================================================
		
		private function writeColorMaterial(obj:SerializedObject, numTabs:uint = 0):String
		{
			var str	:String = newLine("var "+obj.instanceName+" = new THREE.MeshLambertMaterial(", numTabs);
			
			var colorNvp:NameValuePair = obj.getConstructorArgByName("color");
			str += " { color: "+colorNvp.value+", overdraw: true } );";
			
			return str;
		}
		
		//===========================================================================
		
		//===== WRITE LIGHTS ========================================================
		
		private function writeDirectionalLight(obj:SerializedObject, numTabs:uint = 0):String
		{
			var str	:String = newLine("var "+obj.instanceName+" = new THREE."+obj.className+"(", numTabs);
			
			var colorNvp:NameValuePair = obj.getPropByName("color");
			str += colorNvp.value +");"
				
			str += writeObject3DProps(obj, numTabs);
			
			return str;
		}
		
		//===========================================================================
		
		//===== WRITE CONTAINERS ====================================================
		
		private function writeObjectContainer3D(obj:SerializedObject, numTabs:uint = 0):String
		{
			var str	:String = newLine("var "+obj.instanceName+" = new THREE.Object3D();", numTabs); 
			
			str += writeObject3DProps(obj, numTabs);
			
			return str;			
		}
		
		private function writeMesh(obj:SerializedObject, numTabs:uint = 0):String
		{
			var str	:String = newLine("var "+obj.instanceName+" = new THREE."+obj.className+"(", numTabs); 
			
			var value:String;
			var geomNvp:NameValuePair = obj.getPropByName("geometry");
			var matNvp:NameValuePair = obj.getPropByName("material");
			
			if ( geomNvp ) {
				str += "geometries["+SerializedObject(geomNvp.value).id+"]";
			} else {
				if ( matNvp ) {
					str += "null";
				}
			}
			
			if ( matNvp ) {
				str += ", materials["+SerializedObject(matNvp.value).id+"]";
			}
			
			str += ");";
			
			str += writeObject3DProps(obj, numTabs);
			
			return str;
		}
		
		private function writeObject3DProps(obj:SerializedObject, numTabs:uint = 0):String
		{
			var str:String = "";
		
			var nvp:NameValuePair = obj.getPropByName("position");
			if (nvp) {
				var v:Vector3D = Vector3D(nvp.value);
				str += newLine(obj.instanceName+".position.set("+v.x+","+v.y+","+v.z+");", numTabs);
			}
			
			var rotXNvp:NameValuePair = obj.getPropByName("rotationX");
			var rotYNvp:NameValuePair = obj.getPropByName("rotationY");
			var rotZNvp:NameValuePair = obj.getPropByName("rotationZ");
			
			if ( rotXNvp || rotYNvp || rotZNvp ) {
				var rX:Number = rotXNvp ? Number(rotXNvp.value) : 0;
				var rY:Number = rotYNvp ? Number(rotYNvp.value) : 0;
				var rZ:Number = rotZNvp ? Number(rotZNvp.value) : 0;
				str += newLine(obj.instanceName+".rotation.set("+rX+","+rY+","+rZ+");", numTabs);
			}

			var scaleXNvp:NameValuePair = obj.getPropByName("scaleX");
			var scaleYNvp:NameValuePair = obj.getPropByName("scaleY");
			var scaleZNvp:NameValuePair = obj.getPropByName("scaleZ");
			
			if ( scaleXNvp || scaleYNvp || scaleZNvp ) {
				var scaleX:Number = scaleXNvp ? Number(scaleXNvp.value) : 0;
				var scaleY:Number = scaleYNvp ? Number(scaleYNvp.value) : 0;
				var scaleZ:Number = scaleZNvp ? Number(scaleZNvp.value) : 0;
				str += newLine(obj.instanceName+".scale.set("+scaleX+","+scaleY+","+scaleZ+");", numTabs);
			}
			
			return str;
		}
		
		//===========================================================================
		
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
					obj.props.push(new NameValuePair("geometry", geomObj));
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
			var str:String = "<!doctype html>";
			str += newLine("<html lang=\"en\">");
			str += newLine("	<head>");
			str += newLine("		<title>three.js webgl export from Away3D</title>");
			str += newLine("		<meta charset=\"utf-8\">");
			str += newLine("		<meta name=\"viewport\" content=\"width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0\">");
			str += newLine("		<style>");
			str += newLine("			body {");
			str += newLine("				font-family: Monospace;");
			str += newLine("				background-color: #000;");
			str += newLine("				margin: 0px;");
			str += newLine("				overflow: hidden;");
			str += newLine("			}");
			str += newLine("		</style>");
			str += newLine("	</head>");
			str += newLine("	<body>");
			str += newLine();
			str += newLine("		<script src=\"https://raw.github.com/mrdoob/three.js/r49/build/Three.js\"></script>");
			str += newLine("		<script src=\"https://raw.github.com/mrdoob/three.js/master/examples/js/Detector.js\"></script>");
			str += newLine("		<script src=\"https://raw.github.com/mrdoob/three.js/r49/examples/js/Stats.js\"></script>");
			str += newLine();
			str += newLine("		<script>");
			str += newLine();
			str += newLine("			if ( ! Detector.webgl ) Detector.addGetWebGLMessage();");
			str += newLine();										
			str += newLine("			var container, stats;");
			str += newLine();							
			str += newLine("			var camera, scene, renderer;");
			str += newLine();
			
			if (addHoverCamera)
			{
				str += newLine("			var mouseDown = false;");
				str += newLine("			var mouseX = 0, mouseY = 0;");
				str += newLine("			var windowHalfX = window.innerWidth / 2;");
				str += newLine("			var windowHalfY = window.innerHeight / 2;");
				str += newLine();
			}
			
			str += newLine("			init();");
			str += newLine("			animate();");
			str += newLine();
			str += newLine("			function init() {");
			
			if (addHoverCamera)
			{
				str += newLine();
				str += newLine("				document.addEventListener( 'mousemove', onDocumentMouseMove, false );");
				str += newLine("				document.addEventListener('mousedown', onDocumentMouseDown, false);");
				str += newLine("				document.addEventListener('mouseup', onDocumentMouseUp, false);");
			}
			
			str += newLine();
			str += newLine("				container = document.createElement( 'div' );");
			str += newLine("				document.body.appendChild( container );");
			str += newLine();
			str += newLine("				scene = new THREE.Scene();");
			str += newLine();
			str += newLine("				camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 2000 );");
			str += newLine("				camera.position.x = 800;");
			str += newLine("				camera.position.y = 800;");
			str += newLine("				camera.position.z = 800;");
			str += newLine("				scene.add( camera );");
			str += newLine();
			str += newLine("				var geometries = [];");
			str += newLine("				var materials = [];");
			str += newLine("				var lights = [];");
			str += newLine("				var cameras = [];");
			str += newLine("				var containers = [];");
			str += newLine("				var meshes = [];");
			str += newLine("				var wireframes = [];");
			str += newLine("				var segmentSets = [];");
			str += newLine();
			
			return str;
		}
		
		private function writeEndOfFile():String
		{
			var str:String = newLine();
			str	+= newLine("				renderer = new THREE.WebGLRenderer( { antialias: true } );");
			str += newLine("				renderer.setSize( window.innerWidth, window.innerHeight );");
			str += newLine();
			str += newLine("				container.appendChild( renderer.domElement );");
			str += newLine();
			str += newLine("				stats = new Stats();");
			str += newLine("				stats.domElement.style.position = 'absolute';");
			str += newLine("				stats.domElement.style.top = '0px';");
			str += newLine("				container.appendChild( stats.domElement );");
			str += newLine();
			str += newLine("			}");
			str += newLine();
			str += newLine("			function animate() {");
			str += newLine();
			str += newLine("				requestAnimationFrame( animate );");
			str += newLine();		
			str += newLine("				render();");
			str += newLine("				stats.update();");
			str += newLine();
			str += newLine("			}");
			str += newLine();
			
			if (addHoverCamera)
			{
				str += newLine("			function onDocumentMouseDown(event) {");
				str += newLine("				mouseDown = true;");
				str += newLine("			}");
				str += newLine();
				str += newLine("			function onDocumentMouseUp(event) {");
				str += newLine("				mouseDown = false;");
				str += newLine("			}");
				str += newLine();
				str += newLine("			function onDocumentMouseMove(event) {");
				str += newLine();
				str += newLine("				if ( mouseDown ) {");
				str += newLine("					mouseX = event.clientX - windowHalfX;");
				str += newLine("					mouseY = event.clientY - windowHalfY;");
				str += newLine("				}");
				str += newLine();
				str += newLine("			}");
				str += newLine();
			}
			
			str += newLine("			function render() {");
			str += newLine();
			
			if (addHoverCamera)
			{
				str += newLine("				if ( mouseX && mouseY ) {");
				str += newLine("					camera.position.x += ( mouseX*2 - camera.position.x ) * 0.05;");
				str += newLine("					camera.position.y += ( - mouseY*6 - camera.position.y ) * 0.05;");
				str += newLine("				}");
				str += newLine();
			}
			
			str += newLine("				camera.lookAt( scene.position );");
			str += newLine();
			str += newLine("				renderer.render( scene, camera );");
			str += newLine();		
			str += newLine("			}");
			str += newLine();	
			str += newLine("		</script>");
			str += newLine();
			str += newLine("	</body>");
			str += newLine("</html>");
			
			return str;
		}
	}
}



















