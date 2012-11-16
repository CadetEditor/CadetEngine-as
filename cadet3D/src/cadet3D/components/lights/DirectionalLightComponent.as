// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.components.lights
{
	import away3d.lights.DirectionalLight;

	public class DirectionalLightComponent extends AbstractLightComponent
	{
		public function DirectionalLightComponent()
		{
			_object3D = _light = new DirectionalLight();
			_light.castsShadows = true;
		}
	}
}