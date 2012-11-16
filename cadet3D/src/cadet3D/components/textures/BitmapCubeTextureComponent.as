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
	import away3d.textures.BitmapCubeTexture;
	
	import cadet.core.Component;
	
	import cadet3D.util.BitmapDataUtil;
	import cadet3D.util.NullBitmap;
	import cadet3D.util.NullBitmapCubeTexture;
	
	import flash.display.BitmapData;

	public class BitmapCubeTextureComponent extends AbstractCubeTextureComponent
	{
		private var _bitmapCubeTexture	:BitmapCubeTexture;
		
		public function BitmapCubeTextureComponent()
		{
			_cubeTexture = _bitmapCubeTexture = NullBitmapCubeTexture.getCopy();
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set positiveX( value:BitmapData ):void
		{
			_bitmapCubeTexture.positiveX = BitmapDataUtil.makePowerOfTwo(value, true) || NullBitmap.instance ;
		}
		
		public function get positiveX():BitmapData
		{
			return _bitmapCubeTexture.positiveX;
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set negativeX( value:BitmapData ):void
		{
			_bitmapCubeTexture.negativeX = BitmapDataUtil.makePowerOfTwo(value, true) || NullBitmap.instance;
		}
		
		public function get negativeX():BitmapData
		{
			return _bitmapCubeTexture.negativeX;
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set positiveY( value:BitmapData ):void
		{
			_bitmapCubeTexture.positiveY = BitmapDataUtil.makePowerOfTwo(value, true) || NullBitmap.instance;
		}
		
		public function get positiveY():BitmapData
		{
			return _bitmapCubeTexture.positiveY;
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set negativeY( value:BitmapData ):void
		{
			_bitmapCubeTexture.negativeY = BitmapDataUtil.makePowerOfTwo(value, true) || NullBitmap.instance;
		}
		
		public function get negativeY():BitmapData
		{
			return _bitmapCubeTexture.negativeY;
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set positiveZ( value:BitmapData ):void
		{
			_bitmapCubeTexture.positiveZ = BitmapDataUtil.makePowerOfTwo(value, true) || NullBitmap.instance;
		}
		
		public function get positiveZ():BitmapData
		{
			return _bitmapCubeTexture.positiveZ;
		}
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set negativeZ( value:BitmapData ):void
		{
			_bitmapCubeTexture.negativeZ = BitmapDataUtil.makePowerOfTwo(value, true) || NullBitmap.instance;
		}
		
		public function get negativeZ():BitmapData
		{
			return _bitmapCubeTexture.negativeZ;
		}
	}
}