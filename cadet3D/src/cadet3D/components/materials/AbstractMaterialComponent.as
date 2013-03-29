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
package cadet3D.components.materials
{
	import away3d.materials.DefaultMaterialBase;
	
	import cadet.core.Component;
	
	public class AbstractMaterialComponent extends Component
	{
		protected var _material	:DefaultMaterialBase;
		
		public function AbstractMaterialComponent()
		{
			
		}
		
		override public function dispose():void
		{
			super.dispose();
			try
			{
				_material.dispose();
			}
			catch( e:Error ) {}
		}
		
		public function get material():DefaultMaterialBase
		{
			return _material;
		}
		
		/**
		 * Indicate whether or not the material has transparency. If binary transparency is sufficient, for
		 * example when using textures of foliage, consider using alphaThreshold instead.
		 */
		[Serializable][Inspectable( priority="50" )]
		public function get alphaBlending() : Boolean
		{
			return _material.alphaBlending;
		}
		
		public function set alphaBlending(value : Boolean) : void
		{
			_material.alphaBlending = value;
		}
		
		/**
		 * The blend mode to use when drawing this renderable. The following blend modes are supported:
		 * <ul>
		 * <li>BlendMode.NORMAL</li>
		 * <li>BlendMode.MULTIPLY</li>
		 * <li>BlendMode.ADD</li>
		 * <li>BlendMode.ALPHA</li>
		 * </ul>
		 */
		[Serializable][Inspectable( priority="51", editor="DropDownMenu", dataProvider="[NORMAL,MULTIPLY,ADD,ALPHA]" )]
		public function get blendMode() : String
		{
			return _material.blendMode;
		}
		
		public function set blendMode(value : String) : void
		{
			_material.blendMode = value.toLowerCase();
		}		
		
		[Serializable][Inspectable( priority="52", editor="DropDownMenu", dataProvider="[always,equal,greater,greaterEqual,less,lessEqual,never,notEqual]")]
		public function set depthCompareMode( value:String ):void
		{
			_material.depthCompareMode = value;
		}
		
		public function get depthCompareMode():String
		{
			return _material.depthCompareMode;
		}
		
		/**
		 * The strength of the ambient reflection.
		 */
		[Serializable][Inspectable( priority="53", editor="Slider", min="0", max="10", snapInterval="0.01", showMarkers="false" )]
		public function get ambient() : Number
		{
			return _material.ambient;
		}
		
		public function set ambient(value : Number) : void
		{
			_material.ambient = value;
		}
		
		/**
		 * The sharpness of the specular highlight.
		 */
		[Serializable][Inspectable( priority="54", editor="Slider", min="0", max="100", snapInterval="0.1", showMarkers="false" )]
		public function set gloss( value:Number ):void
		{
			_material.gloss = value;
		}
		
		public function get gloss():Number
		{
			return _material.gloss;
		}
		
		/**
		 * The overall strength of the specular reflection.
		 */
		[Serializable][Inspectable( priority="55", editor="Slider", min="0", max="10", snapInterval="0.01", showMarkers="false" )]
		public function set specular( value:Number ):void
		{
			_material.specular = value;
		}
		
		public function get specular():Number
		{
			return _material.specular;
		}
		
		/**
		 * The colour of the ambient reflection.
		 */
		[Serializable][Inspectable( priority="56", editor="ColorPicker" )]
		public function get ambientColor() : uint
		{
			return _material.ambientColor;
		}
		
		public function set ambientColor(value : uint) : void
		{
			_material.ambientColor = value;
		}
		
		/**
		 * The colour of the specular reflection.
		 */
		[Serializable][Inspectable( priority="57", editor="ColorPicker" )]
		public function get specularColor() : uint
		{
			return _material.specularColor;
		}
		
		public function set specularColor(value : uint) : void
		{
			_material.specularColor = value;
		}
	}
}





