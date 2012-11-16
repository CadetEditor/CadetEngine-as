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
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.EnvMapAmbientMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.textures.BitmapTexture;
	
	import cadet.events.InvalidationEvent;
	
	import cadet3D.components.textures.AbstractTexture2DComponent;
	import cadet3D.components.textures.BitmapCubeTextureComponent;
	import cadet3D.util.NullBitmap;
	import cadet3D.util.NullBitmapCubeTexture;
	import cadet3D.util.NullBitmapTexture;
	
	import flash.display.Bitmap;
	

	public class TextureMaterialComponent extends AbstractMaterialComponent
	{
		private var _textureMaterial			:TextureMaterial;
		private var _diffuseTexture				:AbstractTexture2DComponent;
		private var _normalTexture				:AbstractTexture2DComponent;
		private var _environmentTexture			:BitmapCubeTextureComponent;
		private var _envMapMethod				:EnvMapMethod;
		private var _envMapAlpha				:Number = 1;
		
		public function TextureMaterialComponent()
		{
			_material = _textureMaterial = new TextureMaterial( NullBitmapTexture.instance, true, true, true );
		}
		
		override public function dispose():void
		{
			diffuseTexture = null;
			normalTexture = null;
			super.dispose();
		}
		
		[Serializable][Inspectable(editor="Slider", min="0", max="1", snapInterval="0.01", showMarkers="false" )]
		public function set alphaThreshold( value:Number ):void
		{
			_material.alphaThreshold = value;
		}
		
		public function get alphaThreshold():Number
		{
			return _material.alphaThreshold;
		}
		
		[Serializable][Inspectable(editor="ComponentList", scope="scene")]
		public function set diffuseTexture( value:AbstractTexture2DComponent  ):void
		{
			if ( _diffuseTexture )
			{
				_diffuseTexture.removeEventListener(InvalidationEvent.INVALIDATE, invalidateDiffuseTextureHandler);
			}
			_diffuseTexture = value;
			if ( _diffuseTexture )
			{
				_diffuseTexture.addEventListener(InvalidationEvent.INVALIDATE, invalidateDiffuseTextureHandler);
			}
			updateDiffuseTexture();
		}
		
		public function get diffuseTexture():AbstractTexture2DComponent
		{
			return _diffuseTexture;
		}
		
		[Serializable][Inspectable(editor="ComponentList", scope="scene")]
		public function set normalTexture( value:AbstractTexture2DComponent  ):void
		{
			if ( _normalTexture )
			{
				_normalTexture.removeEventListener(InvalidationEvent.INVALIDATE, invalidateNormalTextureHandler);
			}
			_normalTexture = value;
			if ( _normalTexture )
			{
				_normalTexture.addEventListener(InvalidationEvent.INVALIDATE, invalidateNormalTextureHandler);
			}
			updateNormalTexture();
		}
		
		public function get normalTexture():AbstractTexture2DComponent
		{
			return _normalTexture;
		}
		
		[Serializable][Inspectable(editor="ComponentList", scope="scene")]
		public function set environmentTexture( value:BitmapCubeTextureComponent  ):void
		{
			if ( _environmentTexture )
			{
				_environmentTexture.removeEventListener(InvalidationEvent.INVALIDATE, invalidateEnvironmentTextureHandler);
			}
			_environmentTexture = value;
			if ( _environmentTexture )
			{
				_environmentTexture.addEventListener(InvalidationEvent.INVALIDATE, invalidateEnvironmentTextureHandler);
			}
			updateEnvironmentTexture();
		}
		
		public function get environmentTexture():BitmapCubeTextureComponent
		{
			return _environmentTexture;
		}
		
		[Serializable][Inspectable(editor="Slider", min="0", max="1", snapInterval="0.01", showMarkers="false" )]
		public function set envMapAlpha( value:Number ):void
		{
			if ( _envMapMethod )
			{
				_envMapMethod.alpha = value;
			}
			_envMapAlpha = value;
		}
		
		public function get envMapAlpha():Number
		{
			return _envMapAlpha;
		}
		
		private function invalidateDiffuseTextureHandler( event:InvalidationEvent ):void
		{
			updateDiffuseTexture();
		}
		
		private function invalidateNormalTextureHandler( event:InvalidationEvent ):void
		{
			updateNormalTexture();
		}
		
		private function invalidateEnvironmentTextureHandler( event:InvalidationEvent ):void
		{
			updateEnvironmentTexture();
		}
		
		private function updateDiffuseTexture():void
		{
			if ( _diffuseTexture )
			{
				_textureMaterial.texture = _diffuseTexture.texture2D;
			}
			else
			{
				_textureMaterial.texture = NullBitmapTexture.instance;
			}
		}
		
		private function updateNormalTexture():void
		{
			if ( _normalTexture )
			{
				_textureMaterial.normalMap = _normalTexture.texture2D;
			}
			else
			{
				_textureMaterial.normalMap = NullBitmapTexture.instance;
			}
		}
		
		private function updateEnvironmentTexture():void
		{
			if ( _environmentTexture )
			{
				if ( _envMapMethod == null )
				{
					_envMapMethod = new EnvMapMethod( _environmentTexture.cubeTexture );
					_material.addMethod(_envMapMethod);
					_envMapMethod.alpha = _envMapAlpha;
				}
				else
				{
					_envMapMethod.envMap = _environmentTexture.cubeTexture;
				}
			}
			else
			{
				if ( _envMapMethod )
				{
					_material.removeMethod(_envMapMethod);
					_envMapMethod = null;
				}
			}
		}
	}
}