package
{
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.debug.Trident;
	import away3d.entities.Sprite3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.textures.BitmapTexture;
	
	import cadet.core.CadetScene;
	
	import components.behaviours.BounceBehaviour;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	[SWF( width="700", height="400", backgroundColor="0xFFFFFF", frameRate="60" )]
	public class BunnyMark extends Sprite
	{
		[Embed(source = "assets/wabbit_alpha_64x64.png")]
		private var BunnyAsset:Class;
		private var bunnyTexture:TextureMaterial;
		
		private var numEntities:int = 1000;
		private var entityIndex:uint;
		
		private var cadetScene:CadetScene;
		private var view3D:View3D;
		
		public function BunnyMark()
		{
			// Init Cadet
			cadetScene = new CadetScene();
			
			// Init Away3D
			view3D = new View3D();
			addChild(view3D);
			
			var trident:Trident = new Trident(100);
			view3D.scene.addChild(trident);
			
			var camera:Camera3D = new Camera3D();
			camera.rotationX = -145;
			camera.rotationY = -45;
			camera.rotationZ = -180;
			camera.x = 400;
			camera.y = 400;
			camera.z = 400;
			
//			camera.x = 380;
//			camera.y = 200;
//			camera.z = -400;
			view3D.camera = camera;
			
			// Create shared TextureMaterial
			var bitmap:Bitmap = new BunnyAsset();
			var bmpTexture:BitmapTexture = new BitmapTexture(bitmap.bitmapData);
			bunnyTexture = new TextureMaterial(bmpTexture);
			bunnyTexture.alphaBlending = true;
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			if (entityIndex < numEntities) {
				entityIndex ++;
				createBunny();
			}
			
			cadetScene.step();
			view3D.render();
		}
		
		private function createBunny():void
		{
			var sprite3D:Sprite3D = new Sprite3D(bunnyTexture, 64, 64);			
			view3D.scene.addChild(sprite3D);
			
			// Add the BounceBehaviour
			//var randomVelocity:Point = new Point(Math.random() * 10, (Math.random() * 10) - 5);
			var randomVelocity:Vector3D = new Vector3D(Math.random() * 10, (Math.random() * 10) - 5, (Math.random() * 10) - 5);
			var bounceBehaviour:BounceBehaviour = new BounceBehaviour();
			bounceBehaviour.sprite3D = sprite3D;
			bounceBehaviour.velocity = randomVelocity;
			//bounceBehaviour.screenRect = new Rectangle(0, 0, 700, 400);
			bounceBehaviour.screenRect = new Rectangle(0, 0, 400, 400);
			cadetScene.children.addItem(bounceBehaviour);			
		}
	}
}



