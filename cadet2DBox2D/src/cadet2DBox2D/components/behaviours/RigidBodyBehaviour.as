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
	import Box2D.Collision.Shapes.b2CircleDef;
	import Box2D.Collision.Shapes.b2FilterData;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	
	import cadet.components.geom.IGeometry;
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.CompoundGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	import cadet2D.util.VertexUtil;
	
	import cadet2DBox2D.components.processes.PhysicsProcess;
	import cadet2DBox2D.events.RigidBodyBehaviourEvent;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	[Event( type="cadet2DBox2D.events.RigidBodyBehaviourEvent", name="destroyRigidBody" )]
	public class RigidBodyBehaviour extends Component implements ISteppableComponent
	{
		// Invalidation  types
		private static const BODY		:String = "body";
		private static const SHAPES		:String = "shapes";

        private static var helperMatrix :Matrix = new Matrix();

		private var _density			:Number = 1;
		private var _friction			:Number = 0.8;
		private var _restitution		:Number = 0.5;
		private var _fixed				:Boolean = false;
		private var _angularDamping		:Number = 0.1;
		private var _linearDamping		:Number = 0.1;
		private var _categoryBits		:uint = 1;
		private var _maskBits			:uint = uint.MAX_VALUE;
		
		
		protected var _geometry			:IGeometry;
		protected var _transform		:Transform2D;
		protected var _physicsProcess	:PhysicsProcess
		protected var body				:b2Body;
		
		protected var storedTranslateX	:Number;
		protected var storedTranslateY	:Number;
		protected var storedScaleX		:Number;
		protected var storedScaleY		:Number;
		protected var matrix		    :Matrix;
		
		protected var tempVecA			:b2Vec2;
		protected var tempVecB			:b2Vec2;
		
		public function RigidBodyBehaviour( fixed:Boolean = false, density:Number = 1, friction:Number = 0.8, restitution:Number = 0.5)
		{
			name = "RigidBodyBehaviour";
			
			this.fixed = fixed;
			this.density = density;
			this.friction = friction;
			this.restitution = restitution;
			
			matrix = new Matrix();
			tempVecA = new b2Vec2();
			tempVecB = new b2Vec2();
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(Transform2D, "transform");
			addSiblingReference(IGeometry, "geometry");
			addSceneReference( PhysicsProcess, "physicsProcess" );
		}
		
		override protected function removedFromScene():void
		{
			destroyBody();
		}
		
		public function set transform( value:Transform2D ):void
		{
			_transform = value;
			destroyBody();
			invalidate(BODY);
		}
		public function get transform():Transform2D { return _transform; }
		
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
				_physicsProcess.removeEventListener(ValidationEvent.INVALIDATE, invalidatePhysicsProcessHandler);
			}
			_physicsProcess = value;
			if ( _physicsProcess )
			{
				_physicsProcess.addEventListener(ValidationEvent.INVALIDATE, invalidatePhysicsProcessHandler);
			}
			invalidate(BODY);
		}
		public function get physicsProcess():PhysicsProcess { return _physicsProcess; }
		
		private function invalidatePhysicsProcessHandler( event:ValidationEvent ):void
		{
			destroyBody();
			invalidate(BODY);
		}
		
		public function step( dt:Number ):void
		{
			if ( !body ) return;
			if ( !_transform ) return;

            var globalScaleX:Number = 1;
            var globalScaleY:Number = 1;

            if(transform.parentTransform) {
                var m:Matrix = _transform.parentTransform.globalMatrix;

                globalScaleX = Math.sqrt(m.a * m.a + m.b * m.b);
                globalScaleY = Math.sqrt(m.c * m.c + m.d * m.d);
            }

            matrix.identity();

            matrix.scale(globalScaleX * storedScaleX, globalScaleY * storedScaleY);
            matrix.rotate( body.GetAngle() );
            matrix.translate(body.GetPosition().x * _physicsProcess.invScaleFactor, body.GetPosition().y * _physicsProcess.invScaleFactor);

            if(transform.parentTransform) {
                helperMatrix.identity();
                helperMatrix.concat(_transform.parentTransform.globalMatrix);
                helperMatrix.invert();

                matrix.concat(helperMatrix);
            }

            _transform.matrix = matrix;
		}
		
		override public function validateNow():void
		{
			if ( isInvalid(BODY) )
			{
				validateBody();
			}
			if ( isInvalid(SHAPES) )
			{
				validateShapes();
			}
			super.validateNow();
		}
		
		public function getBody():b2Body
		{
			if ( !body )
			{
				validateNow();
			}
			return body;
		}
		
		public function setPosition( x:Number, y:Number ):void
		{
			var body:b2Body = getBody();
			if ( !body ) return;
			
			tempVecA.Set(x * _physicsProcess.scaleFactor, y * _physicsProcess.scaleFactor);
			body.SetPosition(tempVecA);
		}
		
		public function setVelocity( vx:Number, vy:Number ):void
		{
			var body:b2Body = getBody();
			if ( !body ) return;
			
			tempVecA.Set(vx, vy);
			body.SetLinearVelocity(tempVecA);
		}
		
		public function getPosition():Point
		{
			var body:b2Body = getBody();
			if ( !body ) return null;
			return new Point( body.GetPosition().x * _physicsProcess.invScaleFactor, body.GetPosition().y * _physicsProcess.invScaleFactor );
		}
		
		public function getAngularVelocity():Number
		{
			var body:b2Body = getBody();
			if ( !body ) return 0;
			return body.GetAngularVelocity();
		}
		
		public function applyTorque( torque:Number ):void
		{
			var body:b2Body = getBody();
			if ( !body ) return;
			body.ApplyTorque(torque);
		}
		
		public function applyImpulse( impulseX:Number, impulseY:Number ):void
		{
			var body:b2Body = getBody();
			if ( !body ) return;
			tempVecA.Set( impulseX, impulseY );
			body.ApplyImpulse(tempVecA, body.GetPosition());
		}
		
		public function applyImpulseAt( impulseX:Number, impulseY:Number, worldPosX:Number, worldPosY:Number ):void
		{
			var body:b2Body = getBody();
			if ( !body ) return;
			tempVecA.Set( impulseX, impulseY );
			tempVecB.Set( worldPosX * _physicsProcess.scaleFactor, worldPosY * _physicsProcess.scaleFactor );
			body.ApplyImpulse(tempVecA, tempVecB);
		}
		
		protected function validateBody():void
		{
			destroyBody();
			
			if ( !_transform ) return;
			if ( !_geometry ) return;
			if ( !_physicsProcess ) return;

            var bodyDef:b2BodyDef = new b2BodyDef();

            if(_transform.parentTransform) {
                var m:Matrix = _transform.globalMatrix;

                bodyDef.position.x = m.tx * _physicsProcess.scaleFactor;
                bodyDef.position.y = m.ty * _physicsProcess.scaleFactor;
                bodyDef.angle = Math.atan(m.b / m.a);
            }
            else {
                bodyDef.position.x = _transform.x * _physicsProcess.scaleFactor;
                bodyDef.position.y = _transform.y * _physicsProcess.scaleFactor;
                bodyDef.angle = _transform.rotation * (Math.PI / 180);
            }

            // this is always in local coords
            storedScaleX = _transform.scaleX;
            storedScaleY = _transform.scaleY;

			body = _physicsProcess.createRigidBody(this, bodyDef);
			buildShape( _geometry, body );
			body.SetMassFromShapes();
			body.SetAngularDamping(_angularDamping);
			body.SetLinearDamping(_linearDamping);
			body.AllowSleeping( true );
		}
		
		protected function validateShapes():void
		{
			if ( !body ) return;
			
			var filterData:b2FilterData = new b2FilterData();
			filterData.categoryBits = _categoryBits;
			filterData.maskBits = _maskBits;
			
			var shape:b2Shape = body.GetShapeList();
			while ( shape ) {
				shape.SetFilterData(filterData);
				shape.SetRestitution(_restitution);
				shape.SetFriction(_friction);
				shape = shape.GetNext();
			}
		}
		
		protected function destroyBody():void
		{
			if ( body ) {
				/// First, let any listening components know that the rigid body is about to be destroyed.
				// This is so joints and other behaviours that depend on the rigid body can destroy their resources first.
				dispatchEvent( new RigidBodyBehaviourEvent( RigidBodyBehaviourEvent.DESTROY_RIGID_BODY ) );
				_physicsProcess.destroyRigidBody(this, body );
				body = null
			}
		}
		
		protected function buildShape( geometry:IGeometry, body:b2Body ):void
		{
			geometry.validateNow();

            var globalMatrix:Matrix = _transform.globalMatrix;
            var globalScaleX:Number = Math.sqrt(globalMatrix.a * globalMatrix.a + globalMatrix.b * globalMatrix.b);
            var globalScaleY:Number = Math.sqrt(globalMatrix.c * globalMatrix.c + globalMatrix.d * globalMatrix.d);

            if ( geometry is CircleGeometry )
			{
				// Take the scale transform of the circle into account
				var scale:Number = globalScaleX > globalScaleY ? globalScaleX : globalScaleY;

				var circle:CircleGeometry = CircleGeometry( geometry );
				var circleShapeDef:b2CircleDef = new b2CircleDef();
				circleShapeDef.radius = circle.radius * _physicsProcess.scaleFactor * scale;
				circleShapeDef.friction = friction;
				circleShapeDef.restitution = restitution;
				circleShapeDef.density = fixed ? 0 : density;
				circleShapeDef.localPosition = new b2Vec2( circle.x * _physicsProcess.scaleFactor, circle.y * _physicsProcess.scaleFactor );
				body.CreateShape( circleShapeDef );
			}
			else if ( geometry is PolygonGeometry )
			{
                var polygon:PolygonGeometry = PolygonGeometry( geometry );
                var vertices:Array = VertexUtil.copy(polygon.vertices);

                if(globalScaleX != 1 || globalScaleY != 1) {
                    helperMatrix.identity();

                    helperMatrix.scale(globalScaleX, globalScaleY);

                    // Transform the vertices to world space
                    VertexUtil.transform(vertices, helperMatrix);
                }

				// Simplify the vertices so vertices on, or very near, a straight line get removed.
				vertices = VertexUtil.simplify(vertices);
				
				var allVertices:Array = [vertices];
				// Check if the poylgon is concave, if so, then collapse down to convex shapes first
				if ( VertexUtil.isConcave(vertices) )
				{
					allVertices = VertexUtil.makeConvex(vertices);
				}
				
				for each ( vertices in allVertices ) {
					var polygonShapeDef:b2PolygonDef = new b2PolygonDef();
					polygonShapeDef.density = fixed ? 0 : density;
					polygonShapeDef.friction = friction;
					polygonShapeDef.restitution = restitution;
					
					for ( var i:int = 0; i < vertices.length; i++ ) {
						var vertex:Vertex = vertices[i];
						polygonShapeDef.vertices[i] = new b2Vec2( vertex.x * _physicsProcess.scaleFactor, vertex.y * _physicsProcess.scaleFactor );
						polygonShapeDef.vertexCount++;
					}
					body.CreateShape( polygonShapeDef );
				}
				
			} else if ( geometry is CompoundGeometry ) {
				var compoundGeometry:CompoundGeometry = CompoundGeometry( geometry );
				for each ( var childData:IGeometry in compoundGeometry.children ) {
					buildShape( childData, body );
				}
			}
		}
		
		[Serializable][Inspectable]
		public function set density( value:Number ):void
		{
			_density = value;
			invalidate(BODY);
		}
		public function get density():Number { return _density; }
		
		[Serializable][Inspectable]
		public function set friction( value:Number ):void
		{
			_friction = value;
			if ( body ) {
				invalidate(SHAPES);
			} else {
				invalidate(BODY);
			}
		}
		public function get friction():Number { return _friction; }
		
		[Serializable][Inspectable]
		public function set restitution( value:Number ):void
		{
			_restitution = value;
			if ( body ) {
				invalidate(SHAPES);
			} else {
				invalidate(BODY);
			}
		}
		public function get restitution():Number { return _restitution; }
		
		[Serializable][Inspectable]
		public function set fixed( value:Boolean ):void
		{
			_fixed = value;
			invalidate(BODY);
		}
		public function get fixed():Boolean { return _fixed; }
		
		
		[Serializable][Inspectable]
		public function set angularDamping( value:Number ):void
		{
			_angularDamping = value;
			if ( body ) {
				body.SetAngularDamping(_angularDamping);
			} else {
				invalidate(BODY);
			}
		}
		public function get angularDamping():Number { return _angularDamping; }
		
		
		[Serializable][Inspectable]
		public function set linearDamping( value:Number ):void
		{
			_linearDamping = value;
			if ( body ) {
				body.SetLinearDamping(_linearDamping);
			} else {
				invalidate(BODY);
			}
		}
		public function get linearDamping():Number { return _linearDamping; }
		
		[Serializable]
		public function set categoryBits( value:uint ):void
		{
			_categoryBits = value;
			if ( body ) {
				invalidate(SHAPES);
			} else {
				invalidate(BODY);
			}
		}
		public function get categoryBits():uint { return _categoryBits; }
		
		[Serializable]
		public function set maskBits( value:uint ):void
		{
			_maskBits = value;
			if ( body ) {
				invalidate(SHAPES);
			} else {
				invalidate(BODY);
			}
		}
		public function get maskBits():uint { return _maskBits; }
	}
}