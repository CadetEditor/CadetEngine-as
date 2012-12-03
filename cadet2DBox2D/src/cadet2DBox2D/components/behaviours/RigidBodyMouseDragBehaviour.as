// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2DBox2D.components.behaviours
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.b2Body;
	
	import cadet.core.Component;
	import cadet.core.IRenderer;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.renderers.IRenderer2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ISkin2D;
	
	import cadet2DBox2D.components.processes.PhysicsProcess;
	
	import flash.geom.Point;
	
	import starling.display.DisplayObject;
	import starling.display.Stage;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class RigidBodyMouseDragBehaviour extends Component implements ISteppableComponent
	{
		protected var _skin					:AbstractSkin2D;
		protected var _rigidBodyBehaviour	:RigidBodyBehaviour;
		protected var _physicsProcess		:PhysicsProcess;
		private var _renderer				:Renderer2D;
		
		protected var dragJoint				:b2MouseJoint;
		
		// Local vars
		private var mousePos				:Point;
		private var mouseTargetVec			:b2Vec2;
		
		public function RigidBodyMouseDragBehaviour()
		{
			name = "RigidBodyMouseDragBehaviour";
			mousePos = new Point();
			mouseTargetVec = new b2Vec2();
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(ISkin2D, "skin");
			addSiblingReference(RigidBodyBehaviour, "rigidBodyBehaviour");
			addSceneReference( PhysicsProcess, "physicsProcess" );
			addSceneReference( IRenderer, "renderer" );
		}
		
		override protected function removedFromScene():void
		{
			destroyJoint();
		}
		
		public function set skin( value:ISkin2D ):void
		{
			destroyJoint();
			
			if (!(value is AbstractSkin2D)) return;
			
			_skin = AbstractSkin2D(value);
		}
		public function get skin():ISkin2D { return _skin; }
		
		public function set rigidBodyBehaviour( value:RigidBodyBehaviour ):void
		{
			destroyJoint();
			_rigidBodyBehaviour = value;
		}
		public function get rigidBodyBehaviour():RigidBodyBehaviour { return _rigidBodyBehaviour; }
		
		public function set physicsProcess( value:PhysicsProcess ):void
		{
			destroyJoint();
			_physicsProcess = value;
		}
		public function get physicsProcess():PhysicsProcess { return _physicsProcess; }
		
		public function set renderer( value:IRenderer ):void
		{
			if (!(value is Renderer2D)) return;
			
			if ( _renderer) {
				_renderer.viewport.stage.removeEventListener( TouchEvent.TOUCH, touchEventHandler );
			}
			_renderer = Renderer2D(value);
			
			if ( _renderer) {
				_renderer.viewport.stage.addEventListener( TouchEvent.TOUCH, touchEventHandler );
			}
		}
		public function get renderer():IRenderer
		{
			return _renderer;
		}
		
		private function createJoint():void
		{
			var body:b2Body = _rigidBodyBehaviour.getBody();
			if ( !body ) return;
			
			var mousePos:Point = _renderer.viewportToWorld(new Point( _renderer.mouseX, _renderer.mouseY ));
			mousePos.x *= _physicsProcess.scaleFactor;
			mousePos.y *= _physicsProcess.scaleFactor;
			
			var jointDef:b2MouseJointDef = new b2MouseJointDef();
			jointDef.body1 = _physicsProcess.getGroundBody();
			jointDef.body2 = body;
			jointDef.frequencyHz = 2;
			jointDef.target.Set( mousePos.x, mousePos.y );
			jointDef.maxForce = 300 * body.GetMass();
			dragJoint = b2MouseJoint( _physicsProcess.createJoint( jointDef ) );
		}
		
		private function destroyJoint():void
		{
			if (!dragJoint) return;
			
			_physicsProcess.destroyJoint( dragJoint );
			
			dragJoint = null;
		}
		
		protected function touchEventHandler( event:TouchEvent ):void
		{
			if ( !_rigidBodyBehaviour ) return;
			if ( !_physicsProcess ) return;
			if ( !_renderer ) return;
			
			var body:b2Body = _rigidBodyBehaviour.getBody()
			if ( !body ) return;
			
			var dispObj:DisplayObject = DisplayObject(_skin.displayObjectContainer);
			var touches:Vector.<Touch> = event.getTouches(dispObj);
			
			if (!touches || touches.length == 0) return;
			
			for ( var i:uint = 0; i < touches.length; i ++ )
			{
				var touch:Touch = touches[i];
				//trace("RB onTouch x "+renderer.mouseX+" y "+renderer.mouseY+" phase "+touch.phase);
				if ( touch.phase == TouchPhase.ENDED ) {
					destroyJoint();
					break;
				}
				else if ( touch.phase == TouchPhase.BEGAN ) {
					createJoint();		
					break;
				}
			}
		}
		
		public function step(dt:Number):void
		{
			if ( !dragJoint ) return;
			if ( !_physicsProcess ) return;
			if ( !_renderer ) return;
			
			mousePos.x = _renderer.mouseX;
			mousePos.y = _renderer.mouseY;
			mousePos = _renderer.viewportToWorld(mousePos);
			mousePos.x *= _physicsProcess.scaleFactor;
			mousePos.y *= _physicsProcess.scaleFactor;
			
			mouseTargetVec.Set(mousePos.x, mousePos.y);
			dragJoint.SetTarget( mouseTargetVec );
		}
	}
}