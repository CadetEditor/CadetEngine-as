// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Abstract
package cadet3D.components.materials
{
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.MaterialBase;
	
	import cadet.core.Component;
	
	import flash.display3D.Context3DCompareMode;
	
	public class AbstractMaterialComponent extends Component
	{
		protected var _material	:DefaultMaterialBase;
		
		public function AbstractMaterialComponent()
		{
			
		}
		
		override public function dispose():void
		{
			super.dispose();
			try
			{
				_material.dispose();
			}
			catch( e:Error ) {}
		}
		
		public function get material():DefaultMaterialBase
		{
			return _material;
		}
		
		[Serializable][Inspectable( editor="DropDownMenu", dataProvider="[always,equal,greater,greaterEqual,less,lessEqual,never,notEqual]")]
		public function set depthCompareMode( value:String ):void
		{
			_material.depthCompareMode = value;
		}
		
		public function get depthCompareMode():String
		{
			return _material.depthCompareMode;
		}
		
		[Serializable][Inspectable( editor="Slider", min="0", max="100", snapInterval="0.1", showMarkers="false" )]
		public function set gloss( value:Number ):void
		{
			_material.gloss = value;
		}
		
		public function get gloss():Number
		{
			return _material.gloss;
		}
		
		[Serializable][Inspectable( editor="Slider", min="0", max="10", snapInterval="0.01", showMarkers="false" )]
		public function set specularStrength( value:Number ):void
		{
			_material.specular = value;
		}
		
		public function get specularStrength():Number
		{
			return _material.specular;
		}
	}
}