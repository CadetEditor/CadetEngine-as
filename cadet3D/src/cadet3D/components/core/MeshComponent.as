// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.components.core
{
	import away3d.core.base.Geometry;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	
	import cadet.core.Component;
	
	import cadet3D.components.geom.AbstractGeometryComponent;
	import cadet3D.components.geom.GeometryComponent;
	import cadet3D.components.materials.AbstractMaterialComponent;
	
	import flash.events.Event;
	
	public class MeshComponent extends ObjectContainer3DComponent
	{
		private var _mesh		:Mesh;
		
		private var _geometryComponent	:AbstractGeometryComponent
		private var _materialComponent	:AbstractMaterialComponent;
		
		public function MeshComponent()
		{
			_object3D = _mesh = new Mesh(new Geometry());
			_mesh.material = new ColorMaterial(0xFF00FF);
			_mesh.geometry = new Geometry();
			_mesh.mouseEnabled = true;
			//_mesh.mouseHitMethod = MouseHitMethod.MESH_CLOSEST_HIT;
			_mesh.pickingCollider = PickingColliderType.AUTO_BEST_HIT;
		}
		
		override public function dispose():void
		{
			super.dispose();
			_mesh.dispose();
			materialComponent = null;
		}
		
		public function get mesh():Mesh
		{
			return _mesh;
		}
		
		[Serializable][Inspectable( priority="150", editor="ComponentList", scope="scene" )]
		public function set geometryComponent( value:AbstractGeometryComponent ):void
		{
			if ( _geometryComponent == value ) return;
			
			if ( _geometryComponent )
			{
				_geometryComponent.removeEventListener(Event.CHANGE, onChangeGeometry);
			}
			
			_geometryComponent = value;
			if ( _geometryComponent )
			{
				_mesh.geometry = _geometryComponent.geometry;
				_geometryComponent.addEventListener(Event.CHANGE, onChangeGeometry);
			}
			else
			{
				_mesh.geometry = new Geometry();
			}
		}
		
		public function get geometryComponent():AbstractGeometryComponent
		{
			return _geometryComponent;
		}
		
		[Serializable][Inspectable( priority="151", editor="ComponentList", scope="scene" )]
		public function get materialComponent():AbstractMaterialComponent
		{
			return _materialComponent;
		}
		
		public function set materialComponent(value : AbstractMaterialComponent) : void
		{
			_materialComponent = value;
			if ( _materialComponent ) {
				_mesh.material = _materialComponent.material;
			} else {
				_mesh.material = null;
			}
		}
		
		//////////////////////////////////////////////
		// PRIVATE
		/////////////////////////////////////////////
		private function onChangeGeometry( event:Event ):void
		{
			_mesh.geometry = _geometryComponent.geometry;
		}
	}
}