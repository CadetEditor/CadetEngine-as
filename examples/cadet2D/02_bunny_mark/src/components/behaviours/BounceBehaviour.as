package components.behaviours
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.transforms.Transform2D;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BounceBehaviour extends Component implements ISteppableComponent
	{
		public var velocity		:Point;
		public var transform	:Transform2D;
		
		public var gravity		:int = 3;
		
		public var screenRect	:Rectangle;
		
		public function BounceBehaviour()
		{
			
		}

		override protected function addedToScene():void
		{
			addSiblingReference( Transform2D, "transform" );
		}
		
		public function step( dt:Number ):void
		{
			transform.x += velocity.x;
			transform.y += velocity.y;				
			velocity.y += gravity;
			
			if (transform.x > screenRect.right) {
				velocity.x *= -1;
				transform.x = screenRect.right;
			}
			else if (transform.x < screenRect.left) {
				velocity.x *= -1;
				transform.x = screenRect.left;
			}
			
			if (transform.y > screenRect.bottom) {
				velocity.y *= -0.8;
				transform.y = screenRect.bottom;
				
				if (Math.random() > 0.5) {
					velocity.y -= Math.random() * 12;
				}
			}
			else if (transform.y < screenRect.top) {
				velocity.y = 0;
				transform.y = screenRect.top;
			}
		}
	}
}