// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.resources
{
	import away3d.entities.Mesh;
	
	import flox.app.resources.FactoryResource;
	import flox.app.resources.IFactoryResource;
	
	public class Away3DMeshResource implements IFactoryResource
	{
		private var id			:String;
		private var mesh		:Mesh;
		
		public function Away3DMeshResource(id:String, mesh:Mesh)
		{
			this.id = id;
			this.mesh = mesh;
		}
		
		public function getLabel():String
		{
			return "Away3D Mesh Resource";
		}
		
		public function getInstance():Object
		{
			return mesh.clone();
		}
		
		public function getInstanceType():Class
		{
			return Mesh;
		}
		
		public function getID():String
		{
			return id;
		}
	}
}