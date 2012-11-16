// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.components.cameras
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.PerspectiveLens;
	
	import cadet3D.components.core.Object3DComponent;
	
	public class CameraComponent extends Object3DComponent
	{
		public static const PERSPECTIVE		:String = "perspective";
		public static const ORTHOGRAPHIC	:String = "orthographic";
		
		protected var _camera		:Camera3D;
		protected var _lensType		:String;
		
		public function CameraComponent()
		{
			_object3D = _camera = new Camera3D();
			_lensType = PERSPECTIVE;
		}
		
		public function get camera():Camera3D
		{
			return _camera;
		}
		
		public function set lensType( value:String ):void
		{
			if ( value == _lensType ) return;
			switch( value )
			{
				case PERSPECTIVE :
					_camera.lens = new PerspectiveLens();
					break;
				case ORTHOGRAPHIC :
					_camera.lens = new OrthographicLens();
					break;
				default :
					throw( new Error( "Invalid lens type : " + value ) );
					return;
					break;
			}
		}
		
		public function get lensType():String
		{
			return _lensType;
		}
		
	}
}