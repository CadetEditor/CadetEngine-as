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
	import away3d.lights.LightProbe;
	
	import cadet.events.InvalidationEvent;
	
	import cadet3D.components.textures.AbstractCubeTextureComponent;
	import cadet3D.util.NullBitmapCubeTexture;

	public class LightProbeComponent extends AbstractLightComponent
	{
		private var _lightProbe		:LightProbe;
		private var _diffuseMap		:AbstractCubeTextureComponent;
		
		public function LightProbeComponent()
		{
			_object3D = _light = _lightProbe = new LightProbe(NullBitmapCubeTexture.instance, NullBitmapCubeTexture.instance);
		}
		
		[Serializable][Inspectable(editor="ComponentList", scope="scene")]
		public function set diffuseMap( value:AbstractCubeTextureComponent  ):void
		{
			if ( _diffuseMap )
			{
				_diffuseMap.removeEventListener(InvalidationEvent.INVALIDATE, invalidateDiffuseMapHandler);
			}
			_diffuseMap = value;
			if ( _diffuseMap )
			{
				_diffuseMap.addEventListener(InvalidationEvent.INVALIDATE, invalidateDiffuseMapHandler);
			}
			updateDiffuseMap();
		}
		
		public function get diffuseMap():AbstractCubeTextureComponent
		{
			return _diffuseMap;
		}
		
		
		private function invalidateDiffuseMapHandler( event:InvalidationEvent ):void
		{
			updateDiffuseMap();
		}
		
		private function updateDiffuseMap():void
		{
			if ( _diffuseMap )
			{
				_lightProbe.diffuseMap = _diffuseMap.cubeTexture;
			}
			else
			{
				_lightProbe.diffuseMap = NullBitmapCubeTexture.instance;
			}
		}
	}
}