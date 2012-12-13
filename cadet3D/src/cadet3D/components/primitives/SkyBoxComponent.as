package cadet3D.components.primitives
{
	import away3d.materials.SkyBoxMaterial;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.CubeTextureBase;
	
	import cadet3D.components.core.ObjectContainer3DComponent;
	import cadet3D.components.materials.SkyBoxMaterialComponent;
	import cadet3D.primitives.SkyBox;
	import cadet3D.util.NullBitmapCubeTexture;
	
	import flash.display.BitmapData;
	
	public class SkyBoxComponent extends ObjectContainer3DComponent
	{
		private var _skyBox				:SkyBox;
		private var _materialComponent	:SkyBoxMaterialComponent;
		//private var defaultBitmapData	:BitmapData = new BitmapData(256, 256, false, 0xFF0000);
		
		public function SkyBoxComponent()
		{
			_object3D = _skyBox = new SkyBox(NullBitmapCubeTexture.getCopy());
		}
		
		[Serializable][Inspectable( priority="150", editor="ComponentList", scope="scene" )]
		public function get materialComponent():SkyBoxMaterialComponent
		{
			return _materialComponent;
		}
		
		public function set materialComponent(value : SkyBoxMaterialComponent) : void
		{
			_materialComponent = value;
			if ( _materialComponent ) {
				_skyBox.material = _materialComponent.material;
			}
			else {
				_skyBox.material = new SkyBoxMaterial(NullBitmapCubeTexture.getCopy());
			}
		}
	}
}