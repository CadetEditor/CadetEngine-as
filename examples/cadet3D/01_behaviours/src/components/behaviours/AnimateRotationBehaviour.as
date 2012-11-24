package components.behaviours
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet3D.components.core.MeshComponent;

	public class AnimateRotationBehaviour extends Component implements ISteppableComponent
	{
		public var mesh				:MeshComponent;
		
		public var rotationSpeed	:Number = 30;
		
		public function AnimateRotationBehaviour(name:String=null)
		{
			super();
		}
		
		override protected function addedToParent():void
		{
			if ( parentComponent is MeshComponent ) {
				mesh = MeshComponent(parentComponent);
			}
		}
		
		public function step( dt:Number ):void
		{
			if ( !mesh ) return;
			
			mesh.rotationX += rotationSpeed * dt;
		}
	}
}