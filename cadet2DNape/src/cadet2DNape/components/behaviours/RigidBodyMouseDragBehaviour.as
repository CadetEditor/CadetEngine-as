// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2DNape.components.behaviours
{
	import flash.geom.Point;
	
	import cadet.core.Component;
	import cadet.core.IRenderer;
	import cadet.core.ISteppableComponent;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.IRenderable;
	
	import cadet2DNape.components.processes.PhysicsProcess;
	
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class RigidBodyMouseDragBehaviour extends Component implements ISteppableComponent
	{
		protected var _skin					:AbstractSkin2D;
		protected var _rigidBodyBehaviour	:RigidBodyBehaviour;
		protected var _physicsProcess		:PhysicsProcess;
		private var _renderer				:Renderer2D;
		
		protected var dragJoint				:PivotJoint;
		
		// Local vars
		private var mousePos				:Point;
		private var mouseTargetVec			:Vec2;
		
		public function RigidBodyMouseDragBehaviour()
		{
			name = "RigidBodyMouseDragBehaviour";
			mousePos = new Point();
			mouseTargetVec = new Vec2();
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(IRenderable, "skin");
			addSiblingReference(RigidBodyBehaviour, "rigidBodyBehaviour");
			addSceneReference( PhysicsProcess, "physicsProcess" );
			addSceneReference( IRenderer, "renderer" );
		}
		
		override protected function removedFromScene():void
		{
			destroyJoint();
		}
		
		public function set skin( value:IRenderable ):void
		{
			destroyJoint();
			
			if (!(value is AbstractSkin2D)) return;
			
			_skin = AbstractSkin2D(value);
		}
		public function get skin():IRenderable { return _skin; }
		
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
			
			if ( _renderer && _renderer.viewport ) {
				_renderer.viewport.stage.addEventListener( TouchEvent.TOUCH, touchEventHandler );
			} else {
				renderer.addEventListener( RendererEvent.INITIALISED, rendererInitialisedHandler );
			}
		}
		public function get renderer():IRenderer
		{
			return _renderer;
		}
		
		private function rendererInitialisedHandler( event:RendererEvent ):void
		{
			renderer.removeEventListener( RendererEvent.INITIALISED, rendererInitialisedHandler );
			_renderer.viewport.stage.addEventListener( TouchEvent.TOUCH, touchEventHandler );
		}
		
		private function createJoint():void
		{
			var body:Body = _rigidBodyBehaviour.getBody();
			if ( !body || !_physicsProcess) return;
			
			var mousePos:Point = _renderer.viewportToWorld(new Point( _renderer.mouseX, _renderer.mouseY ));
			mousePos.x *= _physicsProcess.scaleFactor;
			mousePos.y *= _physicsProcess.scaleFactor;
			
			dragJoint = new PivotJoint(_physicsProcess.space.world, null, Vec2.weak(), Vec2.weak());
			dragJoint.space = _physicsProcess.space;
			dragJoint.active = true;
			dragJoint.stiff = false;
			
			dragJoint.body2 = body;
			
			mouseTargetVec.setxy(mousePos.x, mousePos.y);
			//dragJoint.SetTarget( mouseTargetVec );
			dragJoint.anchor2.set(body.worldPointToLocal(mouseTargetVec, true));
			
			_physicsProcess.createJoint(dragJoint);
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
			
			var body:Body = _rigidBodyBehaviour.getBody();
			if ( !body ) return;
			
			var dispObj:DisplayObject = DisplayObject(_skin.displayObject);
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
			if ( !dragJoint.active ) return;
			
			mousePos.x = _renderer.mouseX;
			mousePos.y = _renderer.mouseY;
			mousePos = _renderer.viewportToWorld(mousePos);
			mousePos.x *= _physicsProcess.scaleFactor;
			mousePos.y *= _physicsProcess.scaleFactor;
			
			var body:Body = _rigidBodyBehaviour.getBody();
//			dragJoint.body2 = body;
			
			mouseTargetVec.setxy(mousePos.x, mousePos.y);
			//dragJoint.SetTarget( mouseTargetVec );
			
			dragJoint.anchor1.setxy(mousePos.x, mousePos.y);
			dragJoint.anchor2.set(body.worldPointToLocal(mouseTargetVec, true));
		}
	}
}