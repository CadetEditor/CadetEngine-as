// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3DPhysics.components.behaviours
{
	import away3d.entities.Mesh;
	import away3d.primitives.ConeGeometry;
	
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPCollisionShape;
	import awayphysics.collision.shapes.AWPConeShape;
	import awayphysics.collision.shapes.AWPCylinderShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.dynamics.AWPRigidBody;
	
	import cadet.components.geom.IGeometry;
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet3D.components.core.MeshComponent;
	import cadet3D.components.geom.CubeGeometryComponent;
	import cadet3D.components.geom.PlaneGeometryComponent;
	import cadet3D.components.geom.SphereGeometryComponent;
	
	import cadet3DPhysics.components.processes.PhysicsProcess;
	
	import flash.geom.Vector3D;
	
	public class RigidBodyBehaviour extends Component implements ISteppableComponent
	{
		private var _geometry			:IGeometry;
		private var _physicsProcess		:PhysicsProcess;
		private var _mesh				:Mesh;
		private var body				:AWPRigidBody;
		private var mass				:Number = 1;
		
		private static const BODY:String = "body";
		
		public function RigidBodyBehaviour()
		{
			super();
			
			name = "RigidBodyBehaviour";
		}
		
		override protected function addedToScene():void
		{
			//addSiblingReference(Transform2D, "transform");
			addSiblingReference(IGeometry, "geometry");
			addSceneReference( PhysicsProcess, "physicsProcess" );
			
			_mesh = MeshComponent(parentComponent).mesh;
			
			invalidate(BODY);
		}
		
		public function step(dt:Number):void
		{
		}
		
		override public function validateNow():void
		{
			if ( isInvalid(BODY) )
			{
				validateBody();
			}
//			if ( isInvalid(SHAPES) )
//			{
//				validateShapes();
//			}
			super.validateNow();
		}
		
		protected function validateBody():void
		{
			destroyBody();
			
			//if ( !_transform ) return;
			if ( !_geometry ) return;
			if ( !_physicsProcess ) return;
			
			
			var shape:AWPCollisionShape = buildShape(geometry);
		 
			body = new AWPRigidBody(shape, _mesh, mass);
			
			if (mass != 0) {
				body.friction = .9;
				body.ccdSweptSphereRadius = 0.5;
				body.ccdMotionThreshold = 1;
			}
			
			var mRX:Number = _mesh.rotationX;
			var mRY:Number = _mesh.rotationY;
			var mRZ:Number = _mesh.rotationZ;

			body.position = new Vector3D(_mesh.x, _mesh.y, _mesh.z);
			body.rotation = new Vector3D(mRX, mRY, mRZ);
			//body.scale = new Vector3D(_mesh.scaleX, _mesh.scaleY, _mesh.scaleZ);
			
			_physicsProcess.addRigidBody(this, body);

			/*
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.x = _transform.x * _physicsProcess.scaleFactor;
			bodyDef.position.y = _transform.y * _physicsProcess.scaleFactor;
			bodyDef.angle = _transform.rotation * 0.0174;
			
			storedScaleX = _transform.scaleX;
			storedScaleY = _transform.scaleY;
			
			
			body = _physicsProcess.createRigidBody(this, bodyDef);
			buildShape( _geometry, body );
			body.SetMassFromShapes();
			body.SetAngularDamping(_angularDamping);
			body.SetLinearDamping(_linearDamping);
			body.AllowSleeping( true );
			*/
		}
		
		protected function buildShape( geometry:IGeometry ):AWPCollisionShape
		{
			geometry.validateNow();
			
			var shape:AWPCollisionShape;
			
			if ( geometry is SphereGeometryComponent )
			{
				var sphereGeom:SphereGeometryComponent = SphereGeometryComponent(geometry);
				shape = new AWPSphereShape(sphereGeom.radius);
			}
			else if ( geometry is CubeGeometryComponent )
			{
				var cubeGeom:CubeGeometryComponent = CubeGeometryComponent(geometry);
				shape = new AWPBoxShape(cubeGeom.width, cubeGeom.height, cubeGeom.depth);
			}
			else if ( geometry is PlaneGeometryComponent )
			{
				mass = 0;
				var planeGeom:PlaneGeometryComponent = PlaneGeometryComponent(geometry);
				shape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
			}
			/*
			else if ( geometry is CylinderGeometryComponent )
			{
				shape = new AWPCylinderShape(100, 200);
			}
			else if ( geometry is ConeGeometryComponent )
			{
				shape = new AWPConeShape(100, 200);
			}
			*/

			return shape;
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene" )]
		public function set geometry( value:IGeometry ):void
		{
			destroyBody();
			_geometry = value;
			invalidate(BODY);
		}
		public function get geometry():IGeometry { return _geometry; }
		
		public function set physicsProcess( value:PhysicsProcess ):void
		{
			destroyBody();
			if ( _physicsProcess )
			{
				//_physicsProcess.removeEventListener(InvalidationEvent.INVALIDATE, invalidatePhysicsProcessHandler);
			}
			_physicsProcess = value;
			if ( _physicsProcess )
			{
				//_physicsProcess.addEventListener(InvalidationEvent.INVALIDATE, invalidatePhysicsProcessHandler);
			}
			invalidate(BODY);
		}
		public function get physicsProcess():PhysicsProcess { return _physicsProcess; }
		
		private function destroyBody():void
		{
			if ( body )
			{
				/// First, let any listening components know that the rigid body is about to be destroyed.
				// This is so joints and other behaviours that depend on the rigid body can destroy their resources first.
				//dispatchEvent( new RigidBodyBehaviourEvent( RigidBodyBehaviourEvent.DESTROY_RIGID_BODY ) );
				
				_physicsProcess.removeRigidBody( body );
				body = null;
			}
		}
		
		public function getAngularVelocity():Vector3D
		{
			if ( !body ) return null;
			return body.angularVelocity;
		}
		
		public function applyTorque(torque:Vector3D):void
		{
			if ( !body ) return;
			body.applyTorque(torque);
		}
	}
}












