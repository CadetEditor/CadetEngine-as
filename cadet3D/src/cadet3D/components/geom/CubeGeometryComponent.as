// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.components.geom
{
	import away3d.core.base.Geometry;
	import away3d.primitives.CubeGeometry;
	
	import cadet.core.Component;
	import cadet.events.InvalidationEvent;

	public class CubeGeometryComponent extends AbstractGeometryComponent
	{
		private var cubeGeom	:CubeGeometry;
		
		public function CubeGeometryComponent()
		{
			_geometry = cubeGeom = new CubeGeometry()
		}
		
		/**
		 * The size of the cube along its X-axis.
		 */
		[Serializable][Inspectable( priority="2", editor="NumberInput", min="1", max="9999", numDecimalPlaces="2" )]
		public function get width() : Number
		{
			return cubeGeom.width;
		}
		
		public function set width(value : Number) : void
		{
			cubeGeom.width = value;
			cubeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		/**
		 * The size of the cube along its Y-axis.
		 */
		[Serializable][Inspectable( priority="3", editor="NumberInput", min="1", max="9999", numDecimalPlaces="2" )]
		public function get height() : Number
		{
			return cubeGeom.height;
		}
		
		public function set height(value : Number) : void
		{
			cubeGeom.height = value;
			cubeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		/**
		 * The size of the cube along its Z-axis.
		 */
		[Serializable][Inspectable( priority="4", editor="NumberInput", min="1", max="9999", numDecimalPlaces="2" )]
		public function get depth() : Number
		{
			return cubeGeom.depth;
		}
		
		public function set depth(value : Number) : void
		{
			cubeGeom.depth = value;
			cubeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		/**
		 * The number of segments that make up the cube along the X-axis. Defaults to 1.
		 */
		[Serializable][Inspectable( priority="5", editor="NumberInput", min="1", max="128", numDecimalPlaces="0" )]
		public function get segmentsW() : Number
		{
			return cubeGeom.segmentsW;
		}
		
		public function set segmentsW(value : Number) : void
		{
			cubeGeom.segmentsW = value;
			cubeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		/**
		 * The number of segments that make up the cube along the Y-axis. Defaults to 1.
		 */
		[Serializable][Inspectable( priority="6", editor="NumberInput", min="1", max="128", numDecimalPlaces="0" )]
		public function get segmentsH() : Number
		{
			return cubeGeom.segmentsH;
		}
		
		public function set segmentsH(value : Number) : void
		{
			cubeGeom.segmentsH = value;
			cubeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		/**
		 * The number of segments that make up the cube along the Z-axis. Defaults to 1.
		 */
		[Serializable][Inspectable( priority="7", editor="NumberInput", min="1", max="128", numDecimalPlaces="0" )]
		public function get segmentsD() : Number
		{
			return cubeGeom.segmentsD;
		}
		
		public function set segmentsD(value : Number) : void
		{
			cubeGeom.segmentsD = value;
			cubeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		/**
		 * The type of uv mapping to use. When true, a texture will be subdivided in a 2x3 grid, each used for a single
		 * face. When false, the entire image is mapped on each face.
		 */
		[Serializable][Inspectable( priority="8" )]
		public function get tile6() : Boolean
		{
			return cubeGeom.tile6;
		}
		
		public function set tile6(value : Boolean) : void
		{
			cubeGeom.tile6 = value;
			cubeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
	}
}