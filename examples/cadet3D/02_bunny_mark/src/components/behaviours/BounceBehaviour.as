package components.behaviours
{
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet3D.components.core.Sprite3DComponent;

	public class BounceBehaviour extends Component implements ISteppableComponent
	{
		public var velocity		:Vector3D;
		public var sprite3D		:Sprite3DComponent;
		
		public var gravity		:int = 3;
		
		public var screenRect	:Rectangle;
		
		public function BounceBehaviour()
		{
			
		}
		
		public function step( dt:Number ):void
		{
			sprite3D.x += velocity.x;
			sprite3D.y += velocity.y;
			sprite3D.z += velocity.z;
			velocity.y -= gravity;
			
			if (sprite3D.x > screenRect.right) {
				velocity.x *= -1;
				sprite3D.x = screenRect.right;
			}
			else if (sprite3D.x < screenRect.left) {
				velocity.x *= -1;
				sprite3D.x = screenRect.left;
			}
			
			if (sprite3D.z > screenRect.right) {
				velocity.z *= -1;
				sprite3D.z = screenRect.right;
			}
			else if (sprite3D.z < screenRect.left) {
				velocity.z *= -1;
				sprite3D.z = screenRect.left;
			}
			
			// Ceiling
			if (sprite3D.y > screenRect.bottom) {
				velocity.y = 0;
				sprite3D.y = screenRect.bottom;
				
			}
			// Floor
			else if (sprite3D.y < screenRect.top) {
				velocity.y *= -0.8;
				sprite3D.y = screenRect.top;
				
				if (Math.random() > 0.5) {
					velocity.y += Math.random() * 12;
				}
			}
		}
	}
}