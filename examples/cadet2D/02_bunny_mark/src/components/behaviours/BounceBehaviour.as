package components.behaviours
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.skins.AbstractSkin2D;
	
	public class BounceBehaviour extends Component implements ISteppableComponent
	{
		public var velocity		:Point;
		//public var transform	:Transform2D;
		public var skin			:AbstractSkin2D;
		
		public var gravity		:int = 3;
		
		public var screenRect	:Rectangle;
		
		public function BounceBehaviour()
		{
			
		}

		override protected function addedToScene():void
		{
			//addSiblingReference( Transform2D, "transform" );
		}
		
		public function step( dt:Number ):void
		{
			skin.x += velocity.x;
			skin.y += velocity.y;				
			velocity.y += gravity;
			
			if (skin.x > screenRect.right) {
				velocity.x *= -1;
				skin.x = screenRect.right;
			}
			else if (skin.x < screenRect.left) {
				velocity.x *= -1;
				skin.x = screenRect.left;
			}
			
			if (skin.y > screenRect.bottom) {
				velocity.y *= -0.8;
				skin.y = screenRect.bottom;
				
				if (Math.random() > 0.5) {
					velocity.y -= Math.random() * 12;
				}
			}
			else if (skin.y < screenRect.top) {
				velocity.y = 0;
				skin.y = screenRect.top;
			}
		}
	}
}