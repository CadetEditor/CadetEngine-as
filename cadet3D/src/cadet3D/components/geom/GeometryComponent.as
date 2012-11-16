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
	
	import cadet.core.Component;
	
	import flash.events.Event;
	
	public class GeometryComponent extends AbstractGeometryComponent
	{
		public function GeometryComponent()
		{
			
		}
		
		[Serializable( type="resource" )][Inspectable( editor="ResourceItemEditor" )]
		public function set geometry( value:Geometry ):void
		{
			if ( value == _geometry ) return;
			_geometry = value || new Geometry();
			dispatchEvent( new Event( Event.CHANGE ) );
		}
	}
}