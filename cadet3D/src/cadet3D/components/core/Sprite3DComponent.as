package cadet3D.components.core
{
	import away3d.materials.TextureMaterial;
	
	import cadet3D.components.materials.AbstractMaterialComponent;
	import cadet3D.primitives.Sprite3D;
	import cadet3D.util.NullBitmapTexture;

	public class Sprite3DComponent extends ObjectContainer3DComponent
	{
		private var _sprite3D:Sprite3D;
		private var _materialComponent:AbstractMaterialComponent;
		
		public function Sprite3DComponent()
		{
			_object3D = _sprite3D = new Sprite3D(new TextureMaterial( NullBitmapTexture.instance, true, true, true ), 128, 128);
		}
		
		[Serializable][Inspectable( priority="150" )]
		public function get width():Number 
		{
			return _sprite3D.width;
		}
		public function set width( value:Number ):void 
		{
			_sprite3D.width = value;
		}
		
		[Serializable][Inspectable( priority="151" )]
		public function get height():Number 
		{
			return _sprite3D.height;
		}
		public function set height( value:Number ):void
		{
			_sprite3D.height = value;
		}
		
		[Serializable][Inspectable( priority="152", editor="ComponentList", scope="scene" )]
		public function get materialComponent():AbstractMaterialComponent
		{
			return _materialComponent;
		}
		
		public function set materialComponent(value : AbstractMaterialComponent) : void
		{
			_materialComponent = value;
			if ( _materialComponent ) {
				_sprite3D.material = _materialComponent.material;
			} else {
				_sprite3D.material = null;
			}
		}
	}
}