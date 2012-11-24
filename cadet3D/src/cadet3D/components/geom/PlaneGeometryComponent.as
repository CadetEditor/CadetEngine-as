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
	import away3d.primitives.PlaneGeometry;
	
	import cadet.core.Component;

	public class PlaneGeometryComponent extends AbstractGeometryComponent
	{
		private var planeGeom	:PlaneGeometry;
		
		public function PlaneGeometryComponent(width:Number, height:Number)
		{
			_geometry = planeGeom = new PlaneGeometry()
			
			this.width = width;
			this.height = height;
		}
		
		[Serializable][Inspectable( priority="2", editor="NumberInput", min="1", max="9999", numDecimalPlaces="2" )]
		public function get width() : Number
		{
			return planeGeom.width;
		}
		
		public function set width(value : Number) : void
		{
			planeGeom.width = value;
			planeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		[Serializable][Inspectable( priority="3", editor="NumberInput", min="1", max="9999", numDecimalPlaces="2" )]
		public function get height() : Number
		{
			return planeGeom.height;
		}
		
		public function set height(value : Number) : void
		{
			planeGeom.height = value;
			planeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		[Serializable][Inspectable( priority="4", editor="NumberInput", min="1", max="128", numDecimalPlaces="0" )]
		public function get segmentsW() : Number
		{
			return planeGeom.segmentsW;
		}
		
		public function set segmentsW(value : Number) : void
		{
			planeGeom.segmentsW = value;
			planeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
		
		[Serializable][Inspectable( priority="5", editor="NumberInput", min="1", max="128", numDecimalPlaces="0" )]
		public function get segmentsH() : Number
		{
			return planeGeom.segmentsH;
		}
		
		public function set segmentsH(value : Number) : void
		{
			planeGeom.segmentsH = value;
			planeGeom.subGeometries;	// Trigger validatation
			invalidate( GEOMETRY );
		}
	}
}