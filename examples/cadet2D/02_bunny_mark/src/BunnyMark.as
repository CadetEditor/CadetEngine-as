package
{
	import cadet.core.CadetScene;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.components.transforms.Transform2D;
	
	import components.behaviours.BounceBehaviour;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[SWF( width="700", height="400", backgroundColor="0x002135", frameRate="60" )]
	public class BunnyMark extends Sprite
	{
		[Embed(source = "assets/wabbit_alpha.png")]
		private var BunnyAsset:Class;
		private var textureComponent:TextureComponent;
		
		private var numEntities			:int = 1000;
		private var entityIndex			:uint;
		
		private var cadetScene:CadetScene;
		
		public function BunnyMark()
		{
			cadetScene = new CadetScene();
			
			var renderer:Renderer2D = new Renderer2D();
			renderer.viewportWidth = stage.stageWidth;
			renderer.viewportHeight = stage.stageHeight;
			renderer.addEventListener(RendererEvent.INITIALISED, rendererInitHandler);
			cadetScene.children.addItem(renderer);
			renderer.enable(this);
		}
		
		private function rendererInitHandler( event:RendererEvent ):void
		{
			// Create the shared TextureComponent
			textureComponent = new TextureComponent();
			textureComponent.bitmapData = new BunnyAsset().bitmapData;
			
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
			var bounceBehaviour:BounceBehaviour = new BounceBehaviour();
			bounceBehaviour.velocity = randomVelocity;
			bounceBehaviour.screenRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			bunnyEntity.children.addItem(bounceBehaviour);
			
			// Add a Skin to the Entity
			var skin:ImageSkin = new ImageSkin();
			skin.texture = textureComponent;
			bunnyEntity.children.addItem(skin);			
		}
	}
}