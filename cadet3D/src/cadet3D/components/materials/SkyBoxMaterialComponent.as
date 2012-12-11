package cadet3D.components.materials
{
	import away3d.materials.SkyBoxMaterial;
	import away3d.textures.BitmapCubeTexture;
	
	import cadet.core.Component;
	
	import cadet3D.components.textures.BitmapCubeTextureComponent;
	
	import flash.display.BitmapData;

	public class SkyBoxMaterialComponent extends Component
	{
		private var _skyBoxMaterial:SkyBoxMaterial;
		private var _bmpCubeTextureComponent:BitmapCubeTextureComponent;
		private var defaultBitmapData	:BitmapData = new BitmapData(256, 256, false, 0xFF0000);
		
		public function SkyBoxMaterialComponent()
		{
			_skyBoxMaterial = new SkyBoxMaterial( new BitmapCubeTexture(defaultBitmapData, defaultBitmapData, defaultBitmapData, defaultBitmapData, defaultBitmapData, defaultBitmapData));
		}
		
		[Serializable][Inspectable(editor="ComponentList", scope="scene")]
		public function set cubeTexture(value : BitmapCubeTextureComponent) : void
		{
			_bmpCubeTextureComponent = value;
			if ( value ) {
				_skyBoxMaterial.cubeMap = value.cubeTexture;
			} else {
				_skyBoxMaterial.cubeMap = new BitmapCubeTexture(defaultBitmapData, defaultBitmapData, defaultBitmapData, defaultBitmapData, defaultBitmapData, defaultBitmapData);
			}
		}
		public function get cubeTexture():BitmapCubeTextureComponent
		{
			return _bmpCubeTextureComponent;
		}
		
		public function get material():SkyBoxMaterial
		{
			return _skyBoxMaterial;
		}
	}
}