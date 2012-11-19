package components.behaviours
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.transforms.Transform2D;
	
	import flash.geom.Point;
	
	public class BounceBehaviour extends Component implements ISteppableComponent
	{
		private var _velocity	:Point;
		public var transform	:Transform2D;
		
		private const _maxX:int = 640;
		private const _minX:int = 0;
		private const _maxY:int = 480;
		private const _minY:int = 0;
		private const _gravity:int = 3;
		
		public function BounceBehaviour(velocity:Point)
		{
			_velocity	= velocity;
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference( Transform2D, "transform" );
		}
		
		public function step( dt:Number ):void
		{
			transform.x += _velocity.x;
			transform.y += _velocity.y;				
			_velocity.y += _gravity;
			
			if (transform.x > _maxX)
			{
				_velocity.x *= -1;
				transform.x = _maxX;
			}
			else if (transform.x < _minX)
			{
				_velocity.x *= -1;
				transform.x = _minX;
			}
			
			if (transform.y > _maxY)
			{
				_velocity.y *= -0.8;
				transform.y = _maxY;
				
				if (Math.random() > 0.5)
				{
					_velocity.y -= Math.random() * 12;
				}
			} 
			else if (transform.y < _minY)
			{
				_velocity.y = 0;
				transform.y = _minY;
			}
		}
	}
}