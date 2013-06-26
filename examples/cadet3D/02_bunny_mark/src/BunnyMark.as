package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import cadet.core.CadetScene;
	
	import cadet3D.components.cameras.CameraComponent;
	import cadet3D.components.core.Sprite3DComponent;
	import cadet3D.components.debug.TridentComponent;
	import cadet3D.components.materials.TextureMaterialComponent;
	import cadet3D.components.renderers.Renderer3D;
	import cadet3D.components.textures.BitmapTextureComponent;
	
	import components.behaviours.BounceBehaviour;
	
	[SWF( width="700", height="400", backgroundColor="0x002135", frameRate="60" )]
	public class BunnyMark extends Sprite
	{
		[Embed(source = "assets/wabbit_alpha_64x64.png")]
		private var BunnyAsset:Class;
		
		private var bmpMaterialComp:TextureMaterialComponent;
		
		private var numEntities:int = 1000;
		private var entityIndex:uint;
		
		private var cadetScene:CadetScene;
		
		public function BunnyMark()
		{
			cadetScene = new CadetScene();
			
			var bmpTextureComp:BitmapTextureComponent = new BitmapTextureComponent();
			bmpTextureComp.bitmapData = new BunnyAsset().bitmapData;
			
			bmpMaterialComp = new TextureMaterialComponent();
			bmpMaterialComp.diffuseTexture = bmpTextureComp;
			bmpMaterialComp.alphaBlending = true;
			
			var renderer:Renderer3D = new Renderer3D();
			renderer.viewportWidth = stage.stageWidth;
			renderer.viewportHeight = stage.stageHeight;
			cadetScene.children.addItem(renderer);
			renderer.enable(this);
			
			var trident:TridentComponent = new TridentComponent();
			cadetScene.children.addItem(trident);
			
			var camera:CameraComponent = new CameraComponent();
			camera.rotationX = -145;
			camera.rotationY = -45;
			camera.rotationZ = -180;
			camera.x = 1000;
			camera.y = 1000;
			camera.z = 1000;
			cadetScene.children.addItem(camera);			
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			if (entityIndex < numEntities) {
				entityIndex ++;
				createBunny();
			}
			
			cadetScene.step();
		}
		
		private function createBunny():void
		{
			var sprite3DComp:Sprite3DComponent = new Sprite3DComponent();
			sprite3DComp.materialComponent = bmpMaterialComp;	
			cadetScene.children.addItem(sprite3DComp);
			
			// Add the BounceBehaviour
			var randomVelocity:Vector3D = new Vector3D(Math.random() * 10, (Math.random() * 10) - 5, (Math.random() * 10) - 5);
			var bounceBehaviour:BounceBehaviour = new BounceBehaviour();
			bounceBehaviour.sprite3D = sprite3DComp;
			bounceBehaviour.velocity = randomVelocity;
			bounceBehaviour.screenRect = new Rectangle(0, 0, 800, 800);
			cadetScene.children.addItem(bounceBehaviour);			
		}		
	}
}






