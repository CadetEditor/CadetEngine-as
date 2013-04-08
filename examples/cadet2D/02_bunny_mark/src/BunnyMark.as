package
{
	import cadet.core.CadetScene;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.textures.TextureComponent;
	
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
			cadetScene.children.addItem(renderer);
			renderer.enable(this);
			
			// Create the shared TextureComponent
			textureComponent = new TextureComponent();
			textureComponent.bitmapData = new BunnyAsset().bitmapData;
			cadetScene.children.addItem(textureComponent);
			
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
			// Add the BounceBehaviour to the scene
			var randomVelocity:Point = new Point(Math.random() * 10, (Math.random() * 10) - 5);
			var bounceBehaviour:BounceBehaviour = new BounceBehaviour();
			bounceBehaviour.velocity = randomVelocity;
			bounceBehaviour.boundsRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			cadetScene.children.addItem(bounceBehaviour);
			
			// Add a Skin to the scene
			var skin:ImageSkin = new ImageSkin();
			skin.texture = textureComponent;
			cadetScene.children.addItem(skin);
			
			// Pass reference to skin to bounceBehaviour
			bounceBehaviour.transform = skin;
		}
	}
}