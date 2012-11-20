package
{
	import cadet.core.CadetScene;
	import cadet.events.RendererEvent;
	
	import cadet2D.renderPipeline.starling.components.renderers.Renderer2D;
	import cadet2D.renderPipeline.starling.components.textures.TextureComponent;
	
	import components.processes.BunnySpawner;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	[SWF( width="700", height="400", backgroundColor="0x002135", frameRate="60" )]
	public class BunnyMarkSpawner extends Sprite
	{
		[Embed(source = "assets/wabbit_alpha.png")]
		private var BunnyAsset:Class;
		
		private var cadetScene:CadetScene;
		
		public function BunnyMarkSpawner()
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
			var textureComponent:TextureComponent = new TextureComponent();
			textureComponent.asset = new BunnyAsset();
			
			// Create the BunnySpawner Process
			var bunnySpawner:BunnySpawner = new BunnySpawner();
			bunnySpawner.textureComponent = textureComponent;
			bunnySpawner.numEntities = 1000;
			bunnySpawner.screenRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			cadetScene.children.addItem(bunnySpawner);
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );			
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}


