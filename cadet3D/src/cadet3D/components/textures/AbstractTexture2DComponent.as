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
	import away3d.textures.Texture2DBase;
	
	import cadet.core.Component;
	
	public class AbstractTexture2DComponent extends Component
	{
		protected var _texture2D	:Texture2DBase;
		
		public function AbstractTexture2DComponent()
		{
			
		}
		
		override public function dispose():void
		{
			_texture2D.dispose();
			super.dispose();
		}
		
		public function get texture2D():Texture2DBase
		{
			return _texture2D;
		}
	}
}