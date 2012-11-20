package components.processes
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.renderPipeline.starling.components.skins.AssetSkin;
	import cadet2D.renderPipeline.starling.components.textures.TextureComponent;
	
	import components.behaviours.BounceBehaviour;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BunnySpawner extends Component implements ISteppableComponent
	{
		public var numEntities			:int = 100;
		private var entityIndex			:uint;
		
		public var textureComponent		:TextureComponent;
		public var screenRect			:Rectangle;
		
		public function BunnySpawner()
		{

		}
		
		private function createBunny():void
		{
			// Create a Bunny Entity and add it to the CadetScene
			var bunnyEntity:Entity = new Entity();
			scene.children.addItem(bunnyEntity);
			
			// Add a Transform2D to the Entity (for x & y position)
			var transform:Transform2D = new Transform2D();
			transform.x = 100;
			transform.y = 100;
			bunnyEntity.children.addItem(transform);
			
			// Add the BounceBehaviour to the Entity
			var randomVelocity:Point = new Point(Math.random() * 10, (Math.random() * 10) - 5);
			var bounceBehaviour:BounceBehaviour = new BounceBehaviour();
			bounceBehaviour.velocity = randomVelocity;
			bounceBehaviour.screenRect = screenRect;
			bunnyEntity.children.addItem(bounceBehaviour);
			
			// Add a Skin to the Entity
			var skin:AssetSkin = new AssetSkin();
			skin.fillTexture = textureComponent;
			bunnyEntity.children.addItem(skin);			
		}
		
		public function step( dt:Number ):void
		{
			if (entityIndex < numEntities) {
				entityIndex ++;
				createBunny();
			}
		}
	}
}


