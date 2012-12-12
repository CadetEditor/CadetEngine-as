package cadet3D.components.materials
{
	import away3d.materials.SkyBoxMaterial;
	import away3d.textures.BitmapCubeTexture;
	
	import cadet.core.Component;
	
	import cadet3D.components.textures.BitmapCubeTextureComponent;
	import cadet3D.util.NullBitmapCubeTexture;
	
	import flash.display.BitmapData;

	public class SkyBoxMaterialComponent extends Component
	{
		private var _skyBoxMaterial:SkyBoxMaterial;
		private var _bmpCubeTextureComponent:BitmapCubeTextureComponent;
		//private var defaultBitmapData	:BitmapData = new BitmapData(256, 256, false, 0xFF0000);
		
		public function SkyBoxMaterialComponent()
		{
			_skyBoxMaterial = new SkyBoxMaterial( NullBitmapCubeTexture.getCopy() );
		}
		
		public function get material():SkyBoxMaterial
		{
			return _skyBoxMaterial;
		}
		
		[Serializable][Inspectable( priority="100", editor="ComponentList", scope="scene" )]
		public function set cubeTexture(value : BitmapCubeTextureComponent) : void
		{
			_bmpCubeTextureComponent = value;
			if ( value ) {
				_skyBoxMaterial.cubeMap = value.cubeTexture;
			} else {
				_skyBoxMaterial.cubeMap = NullBitmapCubeTexture.getCopy();
			}
		}
		public function get cubeTexture():BitmapCubeTextureComponent
		{
			return _bmpCubeTextureComponent;
		}
	}
}