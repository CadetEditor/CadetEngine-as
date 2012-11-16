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
	import away3d.materials.MaterialBase;
	
	import flox.app.resources.FactoryResource;
	import flox.app.resources.IFactoryResource;
	
	public class Away3DMaterialResource implements IFactoryResource
	{
		private var id			:String;
		private var material	:MaterialBase;
		
		public function Away3DMaterialResource(id:String, material:MaterialBase)
		{
			this.id = id;
			this.material = material;
		}
		
		public function getLabel():String
		{
			return "Away3D Material Resource";
		}
		
		public function getInstance():Object
		{
			return material;
		}
		
		public function getInstanceType():Class
		{
			return MaterialBase;
		}
		
		public function getID():String
		{
			return id;
		}
	}
}