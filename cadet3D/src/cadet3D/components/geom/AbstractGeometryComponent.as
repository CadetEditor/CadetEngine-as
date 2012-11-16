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
	
	import cadet.components.geom.IGeometry;
	import cadet.core.Component;
	
	public class AbstractGeometryComponent extends Component implements IGeometry
	{
		// Invalidation types;
		protected const GEOMETRY	:String = "geometry";
		
		protected var _geometry		:Geometry;
		
		public function AbstractGeometryComponent()
		{
			_geometry = new Geometry();
		}
		
		public function get geometry():Geometry
		{
			return _geometry;
		}
	}
}