package
{
	import cadet.core.CadetScene;
	import cadet.events.RendererEvent;
	
	import cadet2D.renderPipeline.starling.components.renderers.Renderer2D;
	import cadet2D.renderPipeline.starling.components.textures.TextureComponent;
	
	import components.processes.BunnySpawner;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF( width="640", height="480", backgroundColor="0x002135", frameRate="30" )]
	public class Spawner extends Sprite
	{
		[Embed(source = "assets/wabbit_alpha.png")]
		private var BunnyAsset:Class;
		
		private var cadetScene:CadetScene;
		
		public function Spawner()
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
			var textureComponent:TextureComponent = new TextureComponent();
			textureComponent.asset = new BunnyAsset();
			
			var bunnySpawner:BunnySpawner = new BunnySpawner();
			bunnySpawner.textureComponent = textureComponent;
			bunnySpawner.numEntities = 1000;
			cadetScene.children.addItem(bunnySpawner);
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );			
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}


