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
	import away3d.lights.LightBase;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.primitives.data.Segment;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	/**
	 * The SceneParser creates as simplified object model which represents the Away3D scene, with the intent of
	 * creating objects which can be generically looped through and interpreted when performing the writing part 
	 * of the serialization process. This cuts down on repetition between various serializer implementations, as
	 * each will need to know which values should be passed to constructors or set via instance properties, if the
	 * serializers are to produce 'pretty' code.
	 */
	
	public class SceneParser
	{
		static private var _meshes						:Array;
		static private var _wireframes					:Array;
		static private var _segmentSets					:Array;
		static private var _containers					:Array;
		static private var _cameras						:Array;
		// Geometries, materials, lights and segments are shared resources
		static private var _geometries					:Dictionary;
		static private var _materials					:Dictionary;
		static private var _lights						:Dictionary;
		static private var _segments					:Dictionary;
		
		static private var _numContainers				:int;
		static private var _numMeshes					:uint;
		static private var _numWireframes				:uint;
		
		static private var _numSegments					:uint;
		static private var _numSegmentSets				:uint;
		static private var _oldNumSegments				:uint;
		static private var _segmentId					:uint;
		
		static private var _numGeometries				:uint;
		static private var _numMaterials				:uint;
		static private var _numLights					:uint;
		static private var _numCameras					:uint;
		
		static private var _types						:Dictionary;
		
		static private var _rootObject					:Object3D;
		
		// feedback
		static private var _messages					:Array;
		
		static private var _defaultWireframeType		:Class = ObjectContainer3D;
		
		public function SceneParser()
		{
		}
		
		static public function get containers():Array	{  return _containers;	}
		static public function get wireframes():Array	{  return _wireframes;	}
		static public function get meshes():Array		{  return _meshes;		}
		static public function get segmentSets():Array	{  return _segmentSets;	}
		static public function get cameras():Array		{  return _cameras;  	}
		static public function get geometries():Array	{  return convertDictionaryToArray(_geometries); }
		static public function get lights():Array		{  return convertDictionaryToArray(_lights);	 }
		static public function get materials():Array	{  return convertDictionaryToArray(_materials);  }
		static public function get segments():Array		{  return convertDictionaryToArray(_segments);   }
		static public function get messages():Array		{  return _messages;  	}
		static public function get numSegmentSets():uint {  return _numSegmentSets;	  }
		
		static private function init():void
		{
			reset();
			
			_types 							= new Dictionary();
			_types[Mesh]					= getMeshData;
			_types[ObjectContainer3D]		= getObject3dData;
			// Geometries
			_types[ConeGeometry]			= getConeGeometryData;
			_types[CubeGeometry]			= getCubeGeometryData;
			_types[CylinderGeometry]		= getCylinderGeometryData;
			_types[PlaneGeometry]			= getPlaneGeometryData;
			_types[RegularPolygonGeometry]	= getRegularPolygonGeometryData;
			_types[SphereGeometry]			= getSphereGeometryData;
			//_types[TorusGeometry]		 	= getTorusGeometryData;
			
			/*
			// Wireframes
			_types[WireframeCube]			= getWireframeCubeData;
			//_types[WireframeCylinder]		= getWireframeCylinderData;
			_types[WireframePlane]			= getWireframePlaneData;
			_types[WireframeSphere]		 	= getWireframeSphereData;
			
			// SegmentSets
			_types[SegmentSet]				= getSegmentSetData;
			_types[LineSegment]				= getLineSegmentData;
			*/
			
			// Materials
			_types[ColorMaterial]			= getColorMaterialData;
			// Lights
			_types[DirectionalLight]		= getDirectionalLightData;
			// Cameras
			_types[Camera3D]				= getCamera3DData;				
		}
		
		private static function reset():void
		{
			_numContainers 		= 0;
			_numMeshes 			= 0;
			_numWireframes		= 0;
			_numGeometries 		= 0;
			_numMaterials		= 0;
			_numLights			= 0;
			_numCameras			= 0;
			
			_oldNumSegments		= 0;
			_numSegments		= 0;
			_numSegmentSets		= 0;
			_segmentId			= 0;
			
			_meshes				= [];
			_wireframes		 	= [];
			_segmentSets		= [];
			_containers		 	= [];
			_cameras			= [];
			_geometries 		= new Dictionary();
			_materials			= new Dictionary();
			_lights				= new Dictionary();
			_segments			= new Dictionary();
			
			_messages			= [];			
		}
		
		static public function parse(object3d:Object3D):void
		{
			init();
			
			_rootObject = object3d;
			parseInternal(object3d);
		}
		
		static private function parseInternal(object3d:Object3D, containerId:int = -1):void
		{
			if ( object3d is Mesh ) {
				var obj:SerializedObject = getObjectData(object3d, _numMeshes++, containerId);
				_meshes.push(obj);
			} 
			else if ( object3d is LightBase ) 
			{
				if (!_lights[object3d]) {
					obj	= getObjectData(object3d, _numLights++, containerId);
					_lights[object3d] = obj;
				}
			}
			else if ( object3d is Camera3D ) 
			{
				obj	= getObjectData(object3d, _numCameras++, containerId);
				_cameras.push(obj);
			}
			else if ( object3d is WireframePrimitiveBase ) 
			{
				obj	= getObjectData(object3d, _numWireframes, containerId);
				
				// Default wireframes have to be added here to preserve transform data for missing object
				if (!obj) {
					obj	= getObjectData(object3d, _numWireframes, containerId, _defaultWireframeType);
				}
				
				_numWireframes ++;
				
				_wireframes.push(obj);
			}
			else if ( object3d is SegmentSet ) 
			{
				obj	= getObjectData(object3d, _numSegmentSets, containerId);

				_numSegmentSets ++;
				
				_segmentSets.push(obj);
			}
			else
			{
				var container:ObjectContainer3D = (object3d as ObjectContainer3D);
				
				if ( container != _rootObject ) {
					obj	= getObjectData(object3d, _numContainers++, containerId);
					_containers.push(obj);
					
					containerId ++;
				}
				
				// loop through the objectContainer's children
				for( var i:int = 0; i < container.numChildren; i++ )
				{
					var childObj	:Object3D = container.getChildAt(i);
					parseInternal(childObj, containerId);
				}			
			} 			
		}
		
		static public function getObjectData( object:Object, uniqueId:uint = 0, containerId:int = -1, type:Class = null ):SerializedObject
		{
			if (!_types)	init();
			
			var useTypeProvided:Boolean = false;
			if (!type) {
				useTypeProvided = true;
				type = getType(object);
			}
			
			var	parseFunc	:Function = _types[type];
			
			var obj:SerializedObject;
			// get specific properties and methods for the Object (if they exist)
			if ( parseFunc != null ) {
				obj					= new SerializedObject();
				obj.id				= uniqueId;
				obj.containerId		= containerId;
				obj.className 		= getClassName(type);
				obj.instanceName 	= createInstanceName(type, uniqueId);
				obj.source			= object;
				obj.type			= type;
				obj					= parseFunc(object, obj);
			}
			
			return obj;	
		}
		
		//===== PARSE GEOMETRY =======================================================

		static private function getConeGeometryData(cone:ConeGeometry, obj:SerializedObject):SerializedObject
		{
			//new ConeGeometry(radius, height, segmentsW, segmentsH, closed, yUp);
			obj.constructorArgs.push( 
										new NameValuePair("radius", mathRound(cone.radius, 2)), 
										new NameValuePair("height", mathRound(cone.height, 2)), 
										new NameValuePair("segmentsW", cone.segmentsW), 
										new NameValuePair("segmentsH", cone.segmentsH), 
										new NameValuePair("bottomClosed", cone.bottomClosed),
										new NameValuePair("yUp", cone.yUp)
									);
			
			return obj;
		}
		static private function getCubeGeometryData(cube:CubeGeometry, obj:SerializedObject):SerializedObject
		{
			//new CubeGeometry(width, height, depth, segmentsW, segmentsH, segmentsD, tile6);
			obj.constructorArgs.push( 
										new NameValuePair("width", mathRound(cube.width, 2)), 
										new NameValuePair("height", mathRound(cube.height, 2)), 
										new NameValuePair("depth", mathRound(cube.depth, 2)), 
										new NameValuePair("segmentsW", cube.segmentsW), 
										new NameValuePair("segmentsH", cube.segmentsH), 
										new NameValuePair("segmentsD", cube.segmentsD),
										new NameValuePair("tile6", cube.tile6)
								  	);
			
			return obj;
		}
		static private function getCylinderGeometryData(cylinder:CylinderGeometry, obj:SerializedObject):SerializedObject
		{
			//new CylinderGeometry(topRadius, bottomRadius, height, segmentsW, segmentsH, topClosed, bottomClosed, surfaceClosed, yUp);
			obj.constructorArgs.push( 
										new NameValuePair("topRadius", mathRound(cylinder.topRadius, 2)),
										new NameValuePair("bottomRadius", mathRound(cylinder.bottomRadius, 2)), 
										new NameValuePair("height", mathRound(cylinder.height, 2)), 
										new NameValuePair("segmentsW", cylinder.segmentsW), 
										new NameValuePair("segmentsH", cylinder.segmentsH), 
										new NameValuePair("topClosed", cylinder.topClosed),
										new NameValuePair("bottomClosed", cylinder.bottomClosed),
										new NameValuePair("surfaceClosed", true),
										new NameValuePair("yUp", cylinder.yUp)
								  	);
			
			return obj;
		}
		static private function getPlaneGeometryData(plane:PlaneGeometry, obj:SerializedObject):SerializedObject
		{
			//new PlaneGeometry(width, height, segmentsW, segmentsH, yUp);
			obj.constructorArgs.push( 
										new NameValuePair("width", mathRound(plane.width, 2)),
										new NameValuePair("height", mathRound(plane.height, 2)),
										new NameValuePair("segmentsW", plane.segmentsW),
										new NameValuePair("segmentsH", plane.segmentsH),
										new NameValuePair("yUp", plane.yUp)
								  	);
			
			return obj;	
		}
		static private function getRegularPolygonGeometryData(regPoly:RegularPolygonGeometry, obj:SerializedObject):SerializedObject
		{
			//new RegularPolygonGeometry(radius, sides, yUp);
			var radius:Number = regPoly.radius;
			if ( radius == 0 )	radius = regPoly.topRadius;
			
			obj.constructorArgs.push( 
										new NameValuePair("radius", mathRound(radius, 2)),
										new NameValuePair("sides", regPoly.sides),
										new NameValuePair("yUp", regPoly.yUp)
								  	);
			
			return obj;				
		}
		static private function getSphereGeometryData(sphere:SphereGeometry, obj:SerializedObject):SerializedObject
		{
			//new SphereGeometry(radius, segmentsW, segmentsH, yUp);
			obj.constructorArgs.push( 
										new NameValuePair("radius", mathRound(sphere.radius, 2)),
										new NameValuePair("segmentsW", sphere.segmentsW),
										new NameValuePair("segmentsH", sphere.segmentsH),
										new NameValuePair("yUp", sphere.yUp)
								  	);
			
			return obj;		
		}
		/*
		static private function getTorusGeometryData(torus:TorusGeometry, obj:SerializedObject):SerializedObject
		{
			//new TorusGeometry(radius, tubeRadius, segmentsR, segmentsT, yUp);
			obj.constructorArgs.push(
										new NameValuePair("radius", mathRound(torus.radius, 2)),
										new NameValuePair("tubeRadius", mathRound(torus.tubeRadius, 2)),
										new NameValuePair("segmentsR", torus.segmentsR),
										new NameValuePair("segmentsT", torus.segmentsT),
										new NameValuePair("yUp", torus.yUp)
									);
			
			return obj;
		}
		*/
		//===========================================================================
		
		//===== PARSE WIREFRAMES ====================================================
		/*
		static private function getSegmentSetData(set:SegmentSet, obj:SerializedObject):SerializedObject
		{
			if (_oldNumSegments != _numSegments ) {
				_segmentId = 0;
			}
			
			_oldNumSegments = _numSegments;
			
			var segments:Vector.<SerializedObject> = new Vector.<SerializedObject>();
			for ( var i:uint = 0; i < set.lineCount; i ++ )
			{
				var segment:Segment = set.getSegment(i);
				
				if (!_segments[segment]) {
					var segObj:SerializedObject = getObjectData(segment, _numSegments);
					segObj.setId = _segmentId;
					segObj.containerId = obj.id;
					if (segObj != null) {
						_segments[segment] = segObj;
						_numSegments ++;
						_segmentId ++;
					}
				} else {
					segObj = _segments[segment];
				}				
				
				segments.push(segObj);
			}
			
			//_numSegmentSets ++;
			
			obj.props.push(new NameValuePair("segments", segments));
			
			return obj;
		}
		
		static private function getLineSegmentData(seg:LineSegment, obj:SerializedObject):SerializedObject
		{
			//TODO: seg.thickness should need "* 2"
			//new LineSegment(v0, v1, color0, color1, thickness);
			obj.constructorArgs.push( 
				new NameValuePair("start", seg.start),
				new NameValuePair("end", seg.end),
				new NameValuePair("startColor", "0x"+seg.startColor.toString(16)),
				new NameValuePair("endColor", "0x"+seg.endColor.toString(16)),
				new NameValuePair("thickness", seg.thickness * 2)
			);
			
			return obj;
		}

		static private function getWireframeCubeData(cube:WireframeCube, obj:SerializedObject):SerializedObject
		{
			//new WireframeCube(width, height, depth, color, thickness);
			obj = getObject3dData( cube, obj );
			
			obj.constructorArgs.push( 
				new NameValuePair("width", mathRound(cube.width, 2)), 
				new NameValuePair("height", mathRound(cube.height, 2)), 
				new NameValuePair("depth", mathRound(cube.depth, 2)), 
				new NameValuePair("color", "0x"+cube.color.toString(16)), 
				new NameValuePair("thickness", cube.thickness)
			);
			
			return obj;
		}
		static private function getWireframeCylinderData(cylinder:WireframeCylinder, obj:SerializedObject):SerializedObject
		{
			//new WireframeCylinder(topRadius, bottomRadius, height, segmentsW, segmentsH, color, thickness);
			obj = getObject3dData( cylinder, obj );
			
			obj.constructorArgs.push( 
				new NameValuePair("topRadius", mathRound(cylinder.topRadius, 2)), 
				new NameValuePair("bottomRadius", mathRound(cylinder.bottomRadius, 2)),
				new NameValuePair("height", mathRound(cylinder.height, 2)), 
				new NameValuePair("segmentsW", cylinder.segmentsW), 
				new NameValuePair("segmentsH", cylinder.segmentsH),
				new NameValuePair("color", "0x"+cylinder.color.toString(16)), 
				new NameValuePair("thickness", cylinder.thickness)
			);
			
			return obj;
		}
		static private function getWireframePlaneData(plane:WireframePlane, obj:SerializedObject):SerializedObject
		{
			//new WireframePlane(width, height, segmentsW, segmentsH, color, thickness, orientation);
			obj = getObject3dData( plane, obj );
			
			obj.constructorArgs.push( 
				new NameValuePair("width", mathRound(plane.width, 2)),
				new NameValuePair("height", mathRound(plane.height, 2)), 
				new NameValuePair("segmentsW", plane.segmentsW), 
				new NameValuePair("segmentsH", plane.segmentsH),
				new NameValuePair("color", "0x"+plane.color.toString(16)), 
				new NameValuePair("thickness", plane.thickness),
				new NameValuePair("orientation", "\""+plane.orientation+"\"")
			);
			
			return obj;
		}
		static private function getWireframeSphereData(sphere:WireframeSphere, obj:SerializedObject):SerializedObject
		{
			//new WireframeSphere(radius, segmentsW, segmentsH, color, thickness);
			obj = getObject3dData( sphere, obj );
			
			obj.constructorArgs.push( 
				new NameValuePair("radius", mathRound(sphere.radius, 2)),
				new NameValuePair("segmentsW", sphere.segmentsW), 
				new NameValuePair("segmentsH", sphere.segmentsH),
				new NameValuePair("color", "0x"+sphere.color.toString(16)), 
				new NameValuePair("thickness", sphere.thickness)
			);
			
			return obj;			
		}
		*/
		//===========================================================================
		
		//===== PARSE MATERIALS =====================================================
		
		static private function getColorMaterialData(colorMaterial:ColorMaterial, obj:SerializedObject):SerializedObject
		{
			obj.constructorArgs.push(
										new NameValuePair("color", "0x"+colorMaterial.color.toString(16)),
										new NameValuePair("alpha", colorMaterial.alpha)
									);
			
			return obj;			
		}
		
		//===========================================================================
		
		//===== PARSE LIGHTS ========================================================
		
		static private function getDirectionalLightData(dirLight:DirectionalLight, obj:SerializedObject):SerializedObject
		{
			if ( dirLight.ambient != 0 )
				obj.props.push(new NameValuePair("ambient", dirLight.ambient));	
			if ( dirLight.castsShadows )
				obj.props.push(new NameValuePair("castsShadows", dirLight.castsShadows));
			if ( dirLight.color )
				obj.props.push(new NameValuePair("color", "0x"+dirLight.color.toString(16)));
			if ( dirLight.ambientColor )
				obj.props.push(new NameValuePair("ambientColor", "0x"+dirLight.ambientColor.toString(16)));
			if ( dirLight.diffuse )
				obj.props.push(new NameValuePair("diffuse", dirLight.diffuse));
			if ( dirLight.specular )
				obj.props.push(new NameValuePair("specular", dirLight.specular));
			
			obj = getObject3dData( dirLight, obj );
			
			return obj;	
		}
		
		//===========================================================================
		
		//===== PARSE LIGHTS ========================================================
		
		static private function getCamera3DData(camera:Camera3D, obj:SerializedObject):SerializedObject
		{
			obj = getObject3dData( camera, obj );
			
			return obj;	
		}
		
		//===========================================================================		
		
		//===== PARSE OBJECTS =======================================================
		
		// Write all of the relevant properties and functions for the 
		// Mesh object into a data object.
		static public function getMeshData( mesh:Mesh, obj:SerializedObject ):SerializedObject
		{
			obj = getObject3dData( mesh, obj );
			
			if ( mesh.material ) {
				if (!_materials[mesh.material]) {
					var matObj:SerializedObject = getObjectData(mesh.material, _numMaterials, obj.containerId);
					if (matObj != null) {
						_materials[mesh.material] = matObj;
						_numMaterials ++;
					}
				} else {
					matObj = _materials[mesh.material];
				}
				
				if (matObj != null) {
					obj.props.push(new NameValuePair("material", matObj));
				} else {
					var msg:String = "Failed to parse Object of type "+getClassName(mesh.material)+". Type not currently supported.";
					_messages.push(msg);
				}
			}
			
			if ( mesh.geometry ) {
				if (!_geometries[mesh.geometry]) {
					var geomObj:SerializedObject = getObjectData(mesh.geometry, _numGeometries, obj.containerId);
					if (geomObj != null) {
						_geometries[mesh.geometry] = geomObj;
						_numGeometries ++;
					}
				} else {
					geomObj = _geometries[mesh.geometry];
				}
				
				if (geomObj != null) {
					obj.constructorArgs.push(new NameValuePair("geometry", geomObj));
				} else {
					msg = "Failed to parse Object of type "+getClassName(mesh.geometry)+". Type not currently supported.";
					_messages.push(msg);
				}
			}
			
			return obj;
		}
		
		// Write all of the relevant properties and functions for the 
		// Object3d into a data object.
		static public function getObject3dData( object3d:Object3D, obj:SerializedObject = null ):SerializedObject
		{
			if (!obj)	obj = new SerializedObject();
			
			if ( object3d.name != null && object3d.name != "" && object3d.name != "null" ) 
			{
				var typeName	:String = getClassName( object3d );
				if ( object3d.name != typeName.toLowerCase() )
					obj.props.push(new NameValuePair("name", object3d.name));		
			}

			// Pivot
			var px	:Number = mathRound(object3d.pivotPoint.x, 2);
			var py	:Number = mathRound(object3d.pivotPoint.y, 2);
			var pz	:Number = mathRound(object3d.pivotPoint.z, 2);
			
			if ( px != 0 || py != 0 || pz != 0 ) {
				obj.props.push(new NameValuePair("pivotPoint", new Vector3D(px, py, pz)));
			}
			
			// Position
			var x	:Number = mathRound(object3d.position.x, 2);
			var y	:Number = mathRound(object3d.position.y, 2);
			var z	:Number = mathRound(object3d.position.z, 2);
			
			if ( x != 0 || y != 0 || z != 0 ) {
				obj.props.push(new NameValuePair("position", new Vector3D(x, y, z)));
			}
			
			// Rotations
			var rotationX	:Number = mathRound(object3d.rotationX, 2);
			var rotationY	:Number = mathRound(object3d.rotationY, 2);
			var rotationZ	:Number = mathRound(object3d.rotationZ, 2);
			
			if ( Math.round(object3d.rotationX) != 0 )
				obj.props.push(new NameValuePair("rotationX", rotationX));
			if ( Math.round(object3d.rotationY) != 0 )
				obj.props.push(new NameValuePair("rotationY", rotationY));
			if ( Math.round(object3d.rotationZ) != 0 )
				obj.props.push(new NameValuePair("rotationZ", rotationZ));
			
			// Scaling
			var scaleX	:Number = mathRound(object3d.scaleX, 2);
			var scaleY	:Number = mathRound(object3d.scaleY, 2);
			var scaleZ	:Number = mathRound(object3d.scaleZ, 2);
			
			if ( scaleX != 1 )			
				obj.props.push(new NameValuePair("scaleX", scaleX));
			if ( scaleY != 1 )			
				obj.props.push(new NameValuePair("scaleY", scaleY));
			if ( scaleZ != 1 )			
				obj.props.push(new NameValuePair("scaleZ", scaleZ));				

			return obj;
		}
		
		//===========================================================================
		
		//===== UTILITY FUNCTIONS =======================================================
		
		// Create a unique name for the object based on it's Class name and the given id
		static private function createInstanceName(type:Class, id:int):String
		{
			var name	:String = getClassName(type);
			
			return name.toLowerCase()+id;
		}	
		
		static private function mathRound(value:Number, decimalPlaces:uint):Number
		{
			var factor	:uint = Math.pow(10, decimalPlaces);
			return int((value)*factor)/factor;
		}
		
		// return the Class type for the object
		static private function getType( object:Object ):Class
		{
			var classPath:String = getClassPath( object );
			return Class( getDefinitionByName( classPath ) );
		}
		
		// return the Class name for the object
		static private function getClassName( object:Object ):String
		{
			var classPath:String = flash.utils.getQualifiedClassName(object).replace("::",".");
			if ( classPath.indexOf(".") == -1 ) return classPath;
			var split:Array = classPath.split( "." );
			return split[split.length-1];
		}
		
		// return the Class path for the object
		static private function getClassPath( object:Object ):String
		{
			return flash.utils.getQualifiedClassName(object).replace("::",".");
		}
		
		static private function convertDictionaryToArray(dict:Dictionary):Array
		{
			var array:Array = [];
			for each ( var obj:Object in dict )
			{
				array.push(obj);
			}
			
			array = array.sortOn("id", Array.NUMERIC);
			
			return array;
		}
	}
}












