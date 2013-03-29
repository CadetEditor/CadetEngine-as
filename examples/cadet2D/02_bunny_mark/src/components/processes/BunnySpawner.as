package components.processes
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.textures.TextureComponent;
	
	import components.behaviours.BounceBehaviour;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BunnySpawner extends Component implements ISteppableComponent
	{
		public var numEntities			:int = 100;
		private var entityIndex			:uint;
		
		public var textureComponent		:TextureComponent;
		public var boundsRect			:Rectangle;
		
		public function BunnySpawner()
		{

		}
		
		private function createBunny():void
		{
			// Add the BounceBehaviour to the scene
			var randomVelocity:Point = new Point(Math.random() * 10, (Math.random() * 10) - 5);
			var bounceBehaviour:BounceBehaviour = new BounceBehaviour();
			bounceBehaviour.velocity = randomVelocity;
			bounceBehaviour.boundsRect = boundsRect;
			scene.children.addItem(bounceBehaviour);
			
			// Add a Skin to the scene
			var skin:ImageSkin = new ImageSkin();
			skin.texture = textureComponent;
			scene.children.addItem(skin);
			
			// Pass reference to skin to bounceBehaviour
			bounceBehaviour.transform = skin;			
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


