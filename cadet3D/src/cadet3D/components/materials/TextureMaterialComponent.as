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
	import away3d.materials.methods.EnvMapMethod;
	
	import cadet.events.ValidationEvent;
	
	import cadet3D.components.textures.AbstractTexture2DComponent;
	import cadet3D.components.textures.BitmapCubeTextureComponent;
	import cadet3D.util.NullBitmapTexture;
	

	public class TextureMaterialComponent extends AbstractMaterialComponent
	{
		private var _textureMaterial			:TextureMaterial;
		private var _ambientTexture				:AbstractTexture2DComponent;
		private var _diffuseTexture				:AbstractTexture2DComponent;
		private var _normalMap					:AbstractTexture2DComponent;
		private var _specularMap				:AbstractTexture2DComponent;
		private var _environmentMap				:BitmapCubeTextureComponent;
		private var _envMapMethod				:EnvMapMethod;
		private var _envMapAlpha				:Number = 1;
		
		public function TextureMaterialComponent()
		{
			_material = _textureMaterial = new TextureMaterial( NullBitmapTexture.instance, true, true, true );
		}
		
		override public function dispose():void
		{
			diffuseTexture = null;
			normalMap = null;
			super.dispose();
		}
		
		[Serializable][Inspectable( priority="100", editor="Slider", min="0", max="1", snapInterval="0.01", showMarkers="false" )]
		public function set alphaThreshold( value:Number ):void
		{
			_material.alphaThreshold = value;
		}
		public function get alphaThreshold():Number
		{
			return _material.alphaThreshold;
		}
		
		[Serializable][Inspectable( priority="101", editor="Slider", min="0", max="1", snapInterval="0.01", showMarkers="false" )]
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
		
		[Serializable][Inspectable( priority="102",editor="ComponentList", scope="scene")]
		public function set ambientTexture( value:AbstractTexture2DComponent  ):void
		{
			if ( _ambientTexture ) {
				_ambientTexture.removeEventListener(ValidationEvent.INVALIDATE, invalidateDiffuseTextureHandler);
			}
			_ambientTexture = value;
			if ( _ambientTexture ) {
				_ambientTexture.addEventListener(ValidationEvent.INVALIDATE, invalidateDiffuseTextureHandler);
			}
			updateAmbientTexture();
		}
		
		public function get ambientTexture():AbstractTexture2DComponent
		{
			return _ambientTexture;
		}
		
		[Serializable][Inspectable( priority="103", editor="ComponentList", scope="scene")]
		public function set diffuseTexture( value:AbstractTexture2DComponent  ):void
		{
			if ( _diffuseTexture ) {
				_diffuseTexture.removeEventListener(ValidationEvent.INVALIDATE, invalidateDiffuseTextureHandler);
			}
			_diffuseTexture = value;
			if ( _diffuseTexture ) {
				_diffuseTexture.addEventListener(ValidationEvent.INVALIDATE, invalidateDiffuseTextureHandler);
			}
			updateDiffuseTexture();
		}
		
		public function get diffuseTexture():AbstractTexture2DComponent
		{
			return _diffuseTexture;
		}
		
		[Serializable][Inspectable( priority="104", editor="ComponentList", scope="scene")]
		public function set environmentMap( value:BitmapCubeTextureComponent  ):void
		{
			if ( _environmentMap ) {
				_environmentMap.removeEventListener(ValidationEvent.INVALIDATE, invalidateEnvironmentMapHandler);
			}
			_environmentMap = value;
			if ( _environmentMap ) {
				_environmentMap.addEventListener(ValidationEvent.INVALIDATE, invalidateEnvironmentMapHandler);
			}
			updateEnvironmentMap();
		}
		
		public function get environmentMap():BitmapCubeTextureComponent
		{
			return _environmentMap;
		}
		
		[Serializable][Inspectable( priority="105", editor="ComponentList", scope="scene")]
		public function set normalMap( value:AbstractTexture2DComponent  ):void
		{
			if ( _normalMap ) {
				_normalMap.removeEventListener(ValidationEvent.INVALIDATE, invalidateNormalMapHandler);
			}
			_normalMap = value;
			if ( _normalMap ) {
				_normalMap.addEventListener(ValidationEvent.INVALIDATE, invalidateNormalMapHandler);
			}
			updateNormalMap();
		}
		
		public function get normalMap():AbstractTexture2DComponent
		{
			return _normalMap;
		}
		
		[Serializable][Inspectable( priority="106", editor="ComponentList", scope="scene")]
		public function set specularMap( value:AbstractTexture2DComponent  ):void
		{
			if ( _specularMap ) {
				_specularMap.removeEventListener(ValidationEvent.INVALIDATE, invalidateSpecularMapHandler);
			}
			_specularMap = value;
			if ( _specularMap ) {
				_specularMap.addEventListener(ValidationEvent.INVALIDATE, invalidateSpecularMapHandler);
			}
			updateSpecularMap();
		}
		
		public function get specularMap():AbstractTexture2DComponent
		{
			return _specularMap;
		}
		
		
		private function invalidateDiffuseTextureHandler( event:ValidationEvent ):void
		{
			updateDiffuseTexture();
		}
		
		private function invalidateNormalMapHandler( event:ValidationEvent ):void
		{
			updateNormalMap();
		}
		
		private function invalidateEnvironmentMapHandler( event:ValidationEvent ):void
		{
			updateEnvironmentMap();
		}
		
		private function invalidateSpecularMapHandler( event:ValidationEvent ):void
		{
			updateSpecularMap();
		}
		
		private function updateAmbientTexture():void
		{
			if ( _ambientTexture ) {
				_textureMaterial.ambientTexture = _ambientTexture.texture2D;
			} else {
				_textureMaterial.ambientTexture = NullBitmapTexture.instance;
			}
		}
		
		private function updateDiffuseTexture():void
		{
			if ( _diffuseTexture ) {
				_textureMaterial.texture = _diffuseTexture.texture2D;
			} else {
				_textureMaterial.texture = NullBitmapTexture.instance;
			}
		}
		
		private function updateEnvironmentMap():void
		{
			if ( _environmentMap ) {
				if ( _envMapMethod == null ) {
					_envMapMethod = new EnvMapMethod( _environmentMap.cubeTexture );
					_material.addMethod(_envMapMethod);
					_envMapMethod.alpha = _envMapAlpha;
				} else {
					_envMapMethod.envMap = _environmentMap.cubeTexture;
				}
			} else {
				if ( _envMapMethod ) {
					_material.removeMethod(_envMapMethod);
					_envMapMethod = null;
				}
			}
		}
		
		private function updateNormalMap():void
		{
			if ( _normalMap ) {
				_textureMaterial.normalMap = _normalMap.texture2D;
			} else {
				_textureMaterial.normalMap = NullBitmapTexture.instance;
			}
		}
		
		private function updateSpecularMap():void
		{
			if ( _specularMap ) {
				_textureMaterial.specularMap = _specularMap.texture2D;
			} else {
				_textureMaterial.specularMap = NullBitmapTexture.instance;
			}
		}
	}
}