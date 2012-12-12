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
	import away3d.primitives.SphereGeometry;
	
	import cadet.core.Component;

	public class SphereGeometryComponent extends AbstractGeometryComponent
	{
		private var sphereGeom	:SphereGeometry;
		
		public function SphereGeometryComponent()
		{
			_geometry = sphereGeom = new SphereGeometry()
		}
		
		[Serializable][Inspectable( priority="100", editor="NumberInput", min="1", max="9999", numDecimalPlaces="2" )]
		public function get radius() : Number
		{
			return sphereGeom.radius;
		}
		
		public function set radius(value : Number) : void
		{
			sphereGeom.radius = value;
			sphereGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		[Serializable][Inspectable( priority="101", editor="NumberInput", min="4", max="256", numDecimalPlaces="0" )]
		public function get segmentsW() : Number
		{
			return sphereGeom.segmentsW;
		}
		
		public function set segmentsW(value : Number) : void
		{
			sphereGeom.segmentsW = value;
			sphereGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		[Serializable][Inspectable( priority="102", editor="NumberInput", min="4", max="256", numDecimalPlaces="0" )]
		public function get segmentsH() : Number
		{
			return sphereGeom.segmentsH;
		}
		
		public function set segmentsH(value : Number) : void
		{
			sphereGeom.segmentsH = value;
			sphereGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
	}
}