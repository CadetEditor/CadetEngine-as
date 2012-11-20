package components.behaviours
{
	import Box2D.Dynamics.b2Body;
	
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;
	
	public class ApplyTorqueBehaviour extends Component implements ISteppableComponent
	{
		public var rigidBodyBehaviour			:RigidBodyBehaviour;
		public var torque				:Number;
		public var targetVelocity			:Number;
		
		public function ApplyTorqueBehaviour( torque:Number = 50, targetVelocity:Number = 2 )
		{
			this.torque = torque;
			this.targetVelocity = targetVelocity;
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference( RigidBodyBehaviour, "rigidBodyBehaviour" );
		}
		
		public function step(dt:Number):void
		{
			// If we're not attached to an Entity with a RigidBodyBehaviour, then skip.
			if ( !rigidBodyBehaviour ) return;
			
			// Calculate a ratio where 0.5 means we're spinning at half the target speed, and 1 means full speed.
			var ratio:Number = rigidBodyBehaviour.getAngularVelocity() / targetVelocity;
			
			// Scale the torque value by the opposite of the ratio, so as we near the target
			// velocity, we reduce the amount of torque applied.
			rigidBodyBehaviour.applyTorque((1-ratio)*torque);
		}
	}
}