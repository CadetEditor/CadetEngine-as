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
package cadet3D.components.lights
{
	import away3d.lights.LightBase;
	
	import cadet3D.components.core.ObjectContainer3DComponent;
	
	public class AbstractLightComponent extends ObjectContainer3DComponent
	{
		protected var _light		:LightBase;
		
		public function AbstractLightComponent()
		{
			
		}
		
		public function get light():LightBase
		{
			return _light;
		}
		
		[Serializable][Inspectable( priority="150" )]
		public function get castsShadows():Boolean
		{
			return _light.castsShadows;	
		}
		public function set castsShadows( value:Boolean ):void
		{
			_light.castsShadows = value;
		}
		
		/**
		 * The ambient emission strength of the light.
		 */
		[Serializable][Inspectable( priority="151", editor="Slider", min="0", max="1", snapInterval="0.01" )]
		public function get ambient() : Number
		{
			return _light.ambient;
		}
		
		public function set ambient(value : Number) : void
		{
			_light.ambient = value;
		}
		
		/**
		 * The diffuse emission strength of the light.
		 */
		[Serializable][Inspectable( priority="152", editor="Slider", min="0", max="10", snapInterval="0.1" )]
		public function get diffuse() : Number
		{
			return _light.diffuse;
		}
		
		public function set diffuse(value : Number) : void
		{
			_light.diffuse = value;
		}
		
		/**
		 * The specular emission strength of the light.
		 */
		[Serializable][Inspectable( priority="153", editor="Slider", min="0", max="1", snapInterval="0.01" )]
		public function get specular() : Number
		{
			return _light.specular;
		}
		public function set specular(value : Number) : void
		{
			_light.specular = value;
		}
		
		/**
		 * The color of the light.
		 */
		[Serializable][Inspectable( priority="154", editor="ColorPicker" )]
		public function get color() : uint
		{
			return _light.color;
		}
		
		public function set color(value : uint) : void
		{
			light.color = value;
		}
		
		[Serializable][Inspectable( priority="155", editor="ColorPicker" )]
		public function get ambientColor() : uint
		{
			return _light.ambientColor;
		}
		
		public function set ambientColor(value : uint) : void
		{
			_light.ambientColor = value;
		}
	}
}