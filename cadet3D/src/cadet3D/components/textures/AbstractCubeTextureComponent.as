// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.components.textures
{
	import away3d.textures.CubeTextureBase;
	import away3d.textures.Texture2DBase;
	
	import cadet.core.Component;
	
	public class AbstractCubeTextureComponent extends Component
	{
		protected var _cubeTexture	:CubeTextureBase;
		
		public function AbstractCubeTextureComponent()
		{
			
		}
		
		override public function dispose():void
		{
			_cubeTexture.dispose();
			super.dispose();
		}
		
		public function get cubeTexture():CubeTextureBase
		{
			return _cubeTexture;
		}
	}
}