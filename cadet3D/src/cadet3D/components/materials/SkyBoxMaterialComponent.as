package cadet3D.components.materials
{
	import away3d.materials.SkyBoxMaterial;
	import away3d.textures.BitmapCubeTexture;
	
	import cadet.core.Component;
	import cadet.events.ValidationEvent;
	
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
			if ( _bmpCubeTextureComponent  ) {
				_bmpCubeTextureComponent.removeEventListener(ValidationEvent.INVALIDATE, invalidateTextureHandler);
			}
			
			_bmpCubeTextureComponent = value;
			
			if ( _bmpCubeTextureComponent  ) {
				_bmpCubeTextureComponent.addEventListener(ValidationEvent.INVALIDATE, invalidateTextureHandler);
			}
			
			updateCubeTexture();
		}
		public function get cubeTexture():BitmapCubeTextureComponent
		{
			return _bmpCubeTextureComponent;
		}
		
		
		private function invalidateTextureHandler( event:ValidationEvent ):void
		{
			updateCubeTexture();
		}
		
		private function updateCubeTexture():void
		{
			if ( _bmpCubeTextureComponent  ) {
				_skyBoxMaterial.cubeMap = _bmpCubeTextureComponent.cubeTexture;
			} else {
				_skyBoxMaterial.cubeMap = NullBitmapCubeTexture.getCopy();
			}
		}
	}
}




