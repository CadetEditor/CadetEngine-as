package components.behaviours
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	import cadet2D.components.transforms.Transform2D;
	
	public class AnimateRotationBehaviour extends Component implements ISteppableComponent
	{
		public var transform2D	:Transform2D;
		
		public var rotationSpeed	:Number = 15;
		
		public function AnimateRotationBehaviour(name:String=null)
		{
			super();
		}
		
		override protected function addedToParent():void
		{
			addSiblingReference(Transform2D, "transform2D");
		}
		
		public function step( dt:Number ):void
		{
			if ( !transform2D ) return;
			
			transform2D.rotation += rotationSpeed * dt;
		}
	}
}