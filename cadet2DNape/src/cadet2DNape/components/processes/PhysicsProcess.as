package cadet2DNape.components.processes
{
	import flash.utils.Dictionary;
	
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2DNape.components.behaviours.RigidBodyBehaviour;
	
	import nape.constraint.Constraint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Shape;
	import nape.space.Space;
	
	public class PhysicsProcess extends Component implements ISteppableComponent
	{
		protected var _nape					:Space;
		private var _gravity				:Number = 600;
		private var _scaleFactor			:Number = 1;
		private var _invScaleFactor			:Number = 1/_scaleFactor;
		
		private var behaviourTable			:Dictionary;
		private var jointTable				:Dictionary;
		
		public function PhysicsProcess(name:String="PhysicsProcess")
		{
			super(name);
			
			init();
		}
		
		private function init():void
		{
			// Create a new simulation Space.
			var gravity:Vec2 = Vec2.weak(0, _gravity);
			_nape = new Space(gravity);
			
			behaviourTable = new Dictionary(true);
			jointTable = new Dictionary(true);
		}
		
		public function createRigidBody( behaviour:RigidBodyBehaviour, bodyType:BodyType, shapes:Vector.<Shape> ):Body
		{
			var rigidBody:Body = new Body(bodyType);
			rigidBody.space = _nape;
			
			for ( var i:uint = 0; i < shapes.length; i ++ ) {
				rigidBody.shapes.add(shapes[i]);
			}
			 
			behaviourTable[rigidBody] = behaviour;
			return rigidBody;
		}
		
		public function destroyRigidBody( behaviour:RigidBodyBehaviour, rigidBody:Body ):void
		{
			delete behaviourTable[rigidBody];
			rigidBody.space = null;
		}
		
		public function createJoint( joint:Constraint ):Constraint
		{
			joint.space = _nape;
			jointTable[joint] = true;
			return joint;
		}
		
		public function destroyJoint( joint:Constraint ):void
		{
			// Don't try to destroy the joint if Box2D has already automatically destroyed it
			// (as Box2D gets screwed up if you destroy a joint twice)
			if ( !jointTable[joint] ) return;
			delete jointTable[joint];
			//_box2D.DestroyJoint(joint);
			joint.space = null;
		}
		
		public function step(dt:Number):void
		{
			_nape.step(1 / 60);//stage.frameRate);
		}
		
		public function get space():Space
		{
			return _nape;
		}
		
		[Serializable][Inspectable( editor="NumericStepper", label="Gravity", stepSize="1" )]
		public function set gravity( value:Number ):void
		{
			_gravity = value;
			_nape.gravity = Vec2.weak(0, _gravity);
		}
		public function get gravity():Number { return _gravity; }
		
		[Serializable][Inspectable( editor="NumericStepper", min="0.01", max="1000", stepSize="0.01", label="Meters per pixel" )]
		public function set scaleFactor( value:Number ):void
		{
			_scaleFactor = value;
			_invScaleFactor = 1/_scaleFactor;
			invalidate("scaleFactor");
		}
		public function get scaleFactor():Number { return _scaleFactor; }
		public function get invScaleFactor():Number { return _invScaleFactor; }
	}
}