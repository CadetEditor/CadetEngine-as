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
	
	public class BunnySpawner extends Component implements ISteppableComponent
	{
		[Serializable][Inspectable( editor="NumericStepper", label="Number of Bunnies", min="1", max="1000" ) ]
		public var numEntities			:int = 100;
		
		private var _textureComponent	:TextureComponent;
		
		private var allSpawned			:Boolean;
		private var entityIndex			:uint;
		
		public function BunnySpawner()
		{

		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene" )]
		public function set textureComponent( value:TextureComponent ):void
		{
			_textureComponent = value;
		}
		public function get textureComponent():TextureComponent { return _textureComponent; }	
		
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
			var bounceBehaviour:BounceBehaviour = new BounceBehaviour(randomVelocity);
			bunnyEntity.children.addItem(bounceBehaviour);
			
			// Add a Skin to the Entity
			var skin:AssetSkin = new AssetSkin();
			skin.fillTexture = _textureComponent;
			bunnyEntity.children.addItem(skin);			
		}
		
		public function step( dt:Number ):void
		{
			if (allSpawned) return;
			
			if (entityIndex < numEntities) {
				entityIndex ++;
				createBunny();
			} else {
				allSpawned = true;
			}
		}
	}
}


