package components.behaviours
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.transforms.ITransform2D;
	
	public class BounceBehaviour extends Component implements ISteppableComponent
	{
		public var velocity		:Point;
		public var transform	:ITransform2D;
		
		public var gravity		:int = 3;
		
		public var boundsRect	:Rectangle;
		
		public function BounceBehaviour()
		{
			
		}

		public function step( dt:Number ):void
		{
			transform.x += velocity.x;
			transform.y += velocity.y;				
			velocity.y += gravity;
			
			if (transform.x > boundsRect.right) {
				velocity.x *= -1;
				transform.x = boundsRect.right;
			}
			else if (transform.x < boundsRect.left) {
				velocity.x *= -1;
				transform.x = boundsRect.left;
			}
			
			if (transform.y > boundsRect.bottom) {
				velocity.y *= -0.8;
				transform.y = boundsRect.bottom;
				
				if (Math.random() > 0.5) {
					velocity.y -= Math.random() * 12;
				}
			}
			else if (transform.y < boundsRect.top) {
				velocity.y = 0;
				transform.y = boundsRect.top;
			}
		}
	}
}