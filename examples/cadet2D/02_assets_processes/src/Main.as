package
{
	import cadet.core.CadetScene;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.geom.RectangleGeometry;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.renderPipeline.starling.components.renderers.Renderer2D;
	import cadet2D.renderPipeline.starling.components.skins.AssetSkin;
	import cadet2D.renderPipeline.starling.components.textures.TextureComponent;
	
	import components.behaviours.BounceBehaviour;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import starling.textures.Texture;
	
	[SWF( width="640", height="480", backgroundColor="0x002135", frameRate="30" )]
	public class Main extends Sprite
	{
		[Embed(source = "assets/wabbit_alpha.png")]
		private var BunnyAsset:Class;
		private var textureComponent:TextureComponent;
		
		private var cadetScene:CadetScene;
		
		public function Main()
		{
			// Create the CadetScene
			cadetScene = new CadetScene();
			
			// Add the Starling Renderer
			var renderer:Renderer2D = new Renderer2D();
			renderer.viewportWidth = stage.stageWidth;
			renderer.viewportHeight = stage.stageHeight;
			renderer.addEventListener(RendererEvent.INITIALISED, rendererInitHandler);
			cadetScene.children.addItem(renderer);
			renderer.enable(this);
		}
		
		private function rendererInitHandler( event:RendererEvent ):void
		{
			textureComponent = new TextureComponent();
			textureComponent.asset = new BunnyAsset();
			
			// create all the bunnies
			for(var i:int=0;i<1000;i++){
				createBunny();
			}
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );			
		}
		
		private function createBunny():void
		{
			// Create a Bunny Entity and add it to the CadetScene
			var bunnyEntity:Entity = new Entity();
			cadetScene.children.addItem(bunnyEntity);
			
			// Add a Transform2D to the Entity (for x & y position)
			var transform:Transform2D = new Transform2D();
			transform.x = 100;
			transform.y = 100;
			bunnyEntity.children.addItem(transform);
			
			// Add the BounceBehaviour to the Entity
			var randomVelocity:Point = new Point(Math.random() * 10, (Math.random() * 10) - 5);
			var bounceBehaviour:BounceBehaviour = new BounceBehaviour(randomVelocity);
			bunnyEntity.children.addItem(bounceBehaviour);
			
			// Add a Skin to the Entity
			var skin:AssetSkin = new AssetSkin();
			skin.fillTexture = textureComponent;
			bunnyEntity.children.addItem(skin);			
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}




