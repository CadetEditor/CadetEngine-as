package
{
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.debug.Trident;
	import away3d.entities.Sprite3D;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF( width="700", height="400", backgroundColor="0x002135", frameRate="60" )]
	public class BunnyMark extends Sprite
	{
		[Embed(source = "assets/wabbit_alpha_64x64.png")]
		private var BunnyAsset:Class;
		
		private var _view3D:View3D;
		
		public function BunnyMark()
		{
			_view3D = new View3D();
			addChild(_view3D);
			
			var trident:Trident = new Trident(100);
			_view3D.scene.addChild(trident);
			
			var camera:Camera3D = new Camera3D();
			camera.rotationX = -145;
			camera.rotationY = -45;
			camera.rotationZ = -180;
			camera.x = 200;
			camera.y = 200;
			camera.z = 200;
			_view3D.camera = camera;
			
			var bmpTexture:BitmapTexture = new BitmapTexture(new BunnyAsset().bitmapData);
			var textureMaterial:TextureMaterial = new TextureMaterial(bmpTexture);
			
			var sprite3D:Sprite3D = new Sprite3D(textureMaterial, 64, 64);			
			_view3D.scene.addChild(sprite3D);
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			_view3D.render();
		}
	}
}






