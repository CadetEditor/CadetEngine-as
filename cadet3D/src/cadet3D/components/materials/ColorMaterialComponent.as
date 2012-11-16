// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.components.materials
{
	import away3d.materials.ColorMaterial;
	import away3d.materials.methods.FilteredShadowMapMethod;
	
	import flash.display.BlendMode;

	public class ColorMaterialComponent extends AbstractMaterialComponent
	{
		private var _colorMaterial	:ColorMaterial;
		
		public function ColorMaterialComponent( material:ColorMaterial = null )
		{
			if ( material != null )
			{
				_material = _colorMaterial = material;
			}
			else
			{
				_material = _colorMaterial = new ColorMaterial(0xCCCCCC);
			}
		}
		
		/**
		 * The diffuse color of the surface.
		 */
		[Serializable][Inspectable( editor="ColorPicker" )]
		public function get color() : uint
		{
			return _colorMaterial.color;
		}
		
		public function set color(value : uint) : void
		{
			_colorMaterial.color = value;
		}
	}
}