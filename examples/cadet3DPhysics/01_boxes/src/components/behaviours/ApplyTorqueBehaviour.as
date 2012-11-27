package components.behaviours
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet3DPhysics.components.behaviours.RigidBodyBehaviour;
	
	import flash.geom.Vector3D;
	
	public class ApplyTorqueBehaviour extends Component implements ISteppableComponent
	{
		public var rigidBodyBehaviour	:RigidBodyBehaviour;
		public var torque					    :Number;
		public var targetVelocity			:Vector3D;
		
		public function ApplyTorqueBehaviour( torque:Number = 50, targetVelocity:Vector3D = null )
		{
			this.torque = torque;
			
			if ( !targetVelocity ) {
				targetVelocity = new Vector3D(2,0,0);
			}
			
			this.targetVelocity = targetVelocity;
		}
		
		override protected function addedToParent():void
		{
			addSiblingReference( RigidBodyBehaviour, "rigidBodyBehaviour" );
		}
		
		public function step(dt:Number):void
		{
			// If we're not attached to an Entity with a RigidBodyBehaviour, then skip.
			if ( !rigidBodyBehaviour ) return;
			
			var angularVelocity:Vector3D = rigidBodyBehaviour.getAngularVelocity();
			
			if (!angularVelocity) return;
			
			// Calculate a ratio where 0.5 means we're spinning at half the target speed, and 1 means full speed.
			var ratio:Number = angularVelocity.x / targetVelocity.x;
			
			// Scale the torque value by the opposite of the ratio, so as we near the target
			// velocity, we reduce the amount of torque applied.
			rigidBodyBehaviour.applyTorque(new Vector3D((1-ratio)*torque));
		}
	}
}