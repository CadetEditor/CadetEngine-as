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
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2Body;
	
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	import cadet.events.ComponentEvent;
	import cadet.events.ValidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Connection;
	
	import cadet2DBox2D.components.processes.PhysicsProcess;
	import cadet2DBox2D.events.RigidBodyBehaviourEvent;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	public class SpringBehaviour extends Component implements ISteppableComponent
	{
		// Invalidation types
		private static const BEHAVIOURS		:String = "behaviours";
		
		// Component references
		protected var _connection			:Connection;
		public var physicsProcess			:PhysicsProcess;
		
		protected var joint					:b2Joint
		
		protected var _rigidBodyBehaviourA	:RigidBodyBehaviour
		protected var _rigidBodyBehaviourB	:RigidBodyBehaviour
		
		[Serializable][Inspectable]
		public var length					:Number = 100;//-1;
		[Serializable][Inspectable]
		public var stiffness				:Number = 0.5;
		
		private var len						:Number = -1;
		
		// Local vars
		private var posA:b2Vec2
		private var posB:b2Vec2
		private var diff:b2Vec2
		
		
		public function SpringBehaviour()
		{
			name = "SpringBehaviour";
			posA = new b2Vec2();
			posB = new b2Vec2();
			diff = new b2Vec2();
		}
				
		override protected function addedToScene():void
		{
			addSiblingReference( Connection, "connection" );
			addSceneReference(PhysicsProcess, "physicsProcess");
		}
		
		public function set connection( value:Connection ):void
		{
			if ( _connection )
			{
				_connection.removeEventListener(ComponentEvent.ADDED_TO_PARENT, connectionChangeHandler);
				_connection.removeEventListener(ComponentEvent.REMOVED_FROM_PARENT, connectionChangeHandler);
				_connection.removeEventListener(ValidationEvent.INVALIDATE, connectionChangeHandler);
			}
			_connection = value;
			
			if ( _connection )
			{
				_connection.addEventListener(ComponentEvent.ADDED_TO_PARENT, connectionChangeHandler);
				_connection.addEventListener(ComponentEvent.REMOVED_FROM_PARENT, connectionChangeHandler);
				_connection.addEventListener(ValidationEvent.INVALIDATE, connectionChangeHandler);
			}
			
			invalidate(BEHAVIOURS);
		}
		public function get connection():Connection { return _connection; }
		
		private function connectionChangeHandler( event:Event ):void
		{
			invalidate(BEHAVIOURS);
		}
				
		protected function validateBehaviours():void
		{
			if ( !_connection )
			{
				_rigidBodyBehaviourA = null;
				_rigidBodyBehaviourB = null;
				return;
			}
			
			if ( !_connection.transformA.parentComponent ) return;
			if ( !_connection.transformB.parentComponent ) return;
			
			_rigidBodyBehaviourA = ComponentUtil.getChildOfType( _connection.transformA.parentComponent, RigidBodyBehaviour );
			_rigidBodyBehaviourB = ComponentUtil.getChildOfType( _connection.transformB.parentComponent, RigidBodyBehaviour );
			
			len = -1;
		}
				
		public function step(dt:Number):void
		{
			applySpringForce();
		}
			
		private function applySpringForce():void
		{
			if ( !physicsProcess ) return;
			
			var friction:Number = 0.2;
			var k:Number = stiffness * 100;
			
			var pt1:Point = _connection.transformA.matrix.transformPoint( connection.localPosA.toPoint() );
			var pt2:Point = _connection.transformB.matrix.transformPoint( connection.localPosB.toPoint() );
			
			posA.Set( pt1.x * physicsProcess.scaleFactor, pt1.y * physicsProcess.scaleFactor );
			posB.Set( pt2.x * physicsProcess.scaleFactor, pt2.y * physicsProcess.scaleFactor );
			
			diff.Set(posB.x, posB.y);
			diff.Subtract(posA);
			
			var bA:b2Body
			var vA:b2Vec2
			if ( _rigidBodyBehaviourA )
			{
				bA = _rigidBodyBehaviourA.getBody();
				if ( !bA ) return;
				vA = bA.GetLinearVelocityFromWorldPoint( posA );
			}
			else
			{
				vA = new b2Vec2();
			}
			
			var bB:b2Body
			var vB:b2Vec2
			if ( _rigidBodyBehaviourB )
			{
				bB = _rigidBodyBehaviourB.getBody();
				if ( !bB ) return;
				vB = bB.GetLinearVelocityFromWorldPoint( posB );
			}
			else
			{
				vB = new b2Vec2();
			}
			
			var vDiff:b2Vec2 = vB.Copy();
			vDiff.Subtract(vA);
			
			
			if ( len == -1 ) 
			{	
				if ( length != -1 )
				{
					len = length * physicsProcess.scaleFactor;
				}
				else
				{
					len = diff.Length();
				}
			}
			
			var dx:Number = diff.Normalize();
			var vRel:Number = vDiff.x*diff.x + vDiff.y*diff.y;
			var forceMag:Number = -k*(dx-len) - friction*vRel
	        
	        diff.Multiply(forceMag);
	        
	        if ( bB )
	        {
	        	bB.ApplyForce( diff, posA );
	        	bB.WakeUp();
	        }
	        
	        diff.Multiply(-1);
	        
	        if ( bA )
	        {
	        	bA.ApplyForce( diff, posB );
	        	bA.WakeUp();
	        }
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( "behaviours" ) )
			{
				validateBehaviours();
			}
			super.validateNow();
		}
	}
}