// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2DBox2D.renderPipeline.flash.components.behaviours
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.b2Body;
	
	import cadet.core.Component;
	import cadet.core.IRenderer;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.renderers.IRenderer2D;
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.renderPipeline.flash.components.renderers.Renderer2D;
	import cadet2D.renderPipeline.flash.components.skins.AbstractSkin2D;
	
	import cadet2DBox2D.components.processes.PhysicsProcess;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;
	
	public class RigidBodyMouseDragBehaviour extends Component implements ISteppableComponent
	{
		protected var _skin					:ISkin2D;
		protected var _rigidBodyBehaviour	:RigidBodyBehaviour;
		protected var _physicsProcess		:PhysicsProcess;
		public    var renderer				:IRenderer2D;
		
		protected var dragJoint				:b2MouseJoint;
		
		private var stage					:Stage;
		
		
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
			
			if ( _skin)
			{
				AbstractSkin2D(_skin).displayObjectContainer.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			}
			_skin = value;
			
			if ( _skin)
			{
				AbstractSkin2D(_skin).displayObjectContainer.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			}
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
		
		
		private function destroyJoint():void
		{
			if ( dragJoint )
			{
				_physicsProcess.destroyJoint( dragJoint );
			}
			dragJoint = null;
			
			if ( stage )
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				stage = null;
			}
		}
		
		protected function mouseDownHandler( event:MouseEvent ):void
		{
			if ( !_rigidBodyBehaviour ) return;
			if ( !_physicsProcess ) return;
			if ( !renderer ) return;
			
			var body:b2Body = _rigidBodyBehaviour.getBody()
			if ( !body ) return;
			
			stage = Renderer2D(renderer).worldContainer.stage;
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			
			var mousePos:Point = renderer.viewportToWorld(new Point( renderer.mouseX, renderer.mouseY ));
			mousePos.x *= _physicsProcess.scaleFactor;
			mousePos.y *= _physicsProcess.scaleFactor;
			
			var jointDef:b2MouseJointDef = new b2MouseJointDef()
			jointDef.body1 = _physicsProcess.getGroundBody()
			jointDef.body2 = body;
			jointDef.frequencyHz = 2;
			jointDef.target.Set( mousePos.x, mousePos.y );
			jointDef.maxForce = 300 * body.GetMass();
			dragJoint = b2MouseJoint( _physicsProcess.createJoint( jointDef ) );
		}
		
		protected function mouseUpHandler( event:MouseEvent ):void
		{
			destroyJoint();
		}
		
		
		public function step(dt:Number):void
		{
			if ( !dragJoint ) return;
			if ( !_physicsProcess ) return;
			if ( !renderer ) return;
			
			
			mousePos.x = renderer.mouseX;
			mousePos.y = renderer.mouseY;
			mousePos = renderer.viewportToWorld(mousePos);
			mousePos.x *= _physicsProcess.scaleFactor;
			mousePos.y *= _physicsProcess.scaleFactor;
			
			mouseTargetVec.Set(mousePos.x, mousePos.y);
			dragJoint.SetTarget( mouseTargetVec );
		}
	}
}