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
	import flash.geom.Matrix;
	import flash.geom.Point;
	
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
	
	import cadet2DNape.components.processes.PhysicsProcess;
	import cadet2DNape.events.RigidBodyBehaviourEvent;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	
	[Event( type="cadet2DNape.events.RigidBodyBehaviourEvent", name="destroyRigidBody" )]
	public class RigidBodyBehaviour extends Component implements ISteppableComponent
	{
		// Invalidation  types
		private static const BODY		:String = "body";
		private static const SHAPES		:String = "shapes";
		
		
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
		protected var _physicsProcess	:PhysicsProcess;
		protected var body				:Body;
		
		protected var storedTranslateX	:Number;
		protected var storedTranslateY	:Number;
		protected var storedScaleX		:Number;
		protected var storedScaleY		:Number;
		protected var m					:Matrix;
		
		protected var tempVecA			:Vec2;
		protected var tempVecB			:Vec2;
		
		private var _bodyValidated		:Boolean = false;
		
		public function RigidBodyBehaviour( fixed:Boolean = false )//, density:Number = 1, friction:Number = 0.8, restitution:Number = 0.5)
		{
			name = "RigidBodyBehaviour";
			
			this.fixed = fixed;
//			this.density = density;
//			this.friction = friction;
//			this.restitution = restitution;
			
			m = new Matrix();
			tempVecA = new Vec2();
			tempVecB = new Vec2();
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
			
			m.identity();
			m.scale(storedScaleX, storedScaleY);
			m.rotate( body.rotation );
			m.translate( body.position.x * _physicsProcess.invScaleFactor, body.position.y * _physicsProcess.invScaleFactor );
			
			// TODO: Scale Factor required?
			//m.rotate( body.GetAngle() );
			//m.translate(body.GetPosition().x * _physicsProcess.invScaleFactor, body.GetPosition().y * _physicsProcess.invScaleFactor);
			
			_transform.matrix = m;
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
		
		public function getBody():Body
		{
			if ( !body )
			{
				validateNow();
			}
			return body;
		}
		
		public function setPosition( x:Number, y:Number ):void
		{
			var body:Body = getBody();
			if ( !body ) return;
			
			// TODO: Scale Factor required?
			//tempVecA.Set(x * _physicsProcess.scaleFactor, y * _physicsProcess.scaleFactor);
			tempVecA.x = x * _physicsProcess.scaleFactor;
			tempVecA.y = y * _physicsProcess.scaleFactor;
			body.position = tempVecA;
		}
		
		public function setVelocity( vx:Number, vy:Number ):void
		{
			var body:Body = getBody();
			if ( !body ) return;
			
			//tempVecA.Set(vx, vy);
			//body.SetLinearVelocity(tempVecA);
			
			tempVecA.x = vx;
			tempVecA.y = vy;
			body.velocity = tempVecA;
		}
		
		public function getPosition():Point
		{
			var body:Body = getBody();
			if ( !body ) return null;
			
			// TODO: Scale Factor required?
			//return new Point( body.GetPosition().x * _physicsProcess.invScaleFactor, body.GetPosition().y * _physicsProcess.invScaleFactor );
			return new Point( body.position.x * _physicsProcess.invScaleFactor, body.position.y * _physicsProcess.invScaleFactor );
		}
		
		public function getAngularVelocity():Number
		{
			var body:Body = getBody();
			if ( !body ) return 0;
			return body.angularVel;
		}
		
		public function applyTorque( torque:Number ):void
		{
			var body:Body = getBody();
			if ( !body ) return;
			body.torque = torque;
		}
		
		public function applyImpulse( impulseX:Number, impulseY:Number ):void
		{
			var body:Body = getBody();
			if ( !body ) return;
			tempVecA.x = impulseX;
			tempVecA.y = impulseY;
			body.applyImpulse( tempVecA, body.position );
		}
		
		public function applyImpulseAt( impulseX:Number, impulseY:Number, worldPosX:Number, worldPosY:Number ):void
		{
			var body:Body = getBody();
			if ( !body ) return;
			tempVecA.x = impulseX;
			tempVecA.y = impulseY;
			tempVecB.x = worldPosX * _physicsProcess.scaleFactor;
			tempVecB.y = worldPosY * _physicsProcess.scaleFactor;
			body.applyImpulse(tempVecA, tempVecB);
		}
		
		protected function validateBody():void
		{
			// Cannot modifiy shapes of static object once added to Space
			if ( fixed && _bodyValidated ) return;
			
			destroyBody();
			
			if ( !_transform ) return;
			if ( !_geometry ) return;
			if ( !_physicsProcess ) return;
			
//			var bodyDef:b2BodyDef = new b2BodyDef();
//			bodyDef.position.x = _transform.x * _physicsProcess.scaleFactor;
//			bodyDef.position.y = _transform.y * _physicsProcess.scaleFactor;
//			bodyDef.angle = _transform.rotation;
			
			storedScaleX = _transform.scaleX;
			storedScaleY = _transform.scaleY;
			
			
			//TODO: Type needs to be dynamic
			//body = _physicsProcess.createRigidBody(this, bodyDef);
			var bodyType:BodyType;
			
			if ( fixed ) {
				bodyType = BodyType.STATIC;
			} else {
				bodyType = BodyType.DYNAMIC;
			}
			
			body = new Body(bodyType);
			body.position.x = _transform.x * _physicsProcess.scaleFactor;
			body.position.y = _transform.y * _physicsProcess.scaleFactor;
			body.rotation = _transform.rotation;
			
			buildShape( _geometry, body );
			
			body.space = _physicsProcess.space;
			_bodyValidated = true;
			
//			body.SetMassFromShapes();
//			body.SetAngularDamping(_angularDamping);
//			body.SetLinearDamping(_linearDamping);
//			body.AllowSleeping( true );
		}
		
		protected function validateShapes():void
		{
			if ( !body ) return;
			
//			var filterData:b2FilterData = new b2FilterData();
//			filterData.categoryBits = _categoryBits;
//			filterData.maskBits = _maskBits;
			
/*			var shape:Shape = body.shapes;
			while ( shape )
			{
				shape.SetFilterData(filterData);
				shape.SetRestitution(_restitution);
				shape.SetFriction(_friction);
				shape = shape.GetNext();
			}*/
		}
		
		protected function destroyBody():void
		{
			if ( body )
			{
				/// First, let any listening components know that the rigid body is about to be destroyed.
				// This is so joints and other behaviours that depend on the rigid body can destroy their resources first.
				dispatchEvent( new RigidBodyBehaviourEvent( RigidBodyBehaviourEvent.DESTROY_RIGID_BODY ) );
				_physicsProcess.destroyRigidBody(this, body );
				body = null;
			}
		}
		
		protected function buildShape( geometry:IGeometry, body:Body ):void
		{
			geometry.validateNow();
			
			if ( geometry is CircleGeometry )
			{
				// Take the scale transform of the circle into account
				var scale:Number = 1;
				
				if ( _transform ) {
					scale = _transform.scaleX;
					
					if ( _transform.scaleY > scale ) {
						scale = _transform.scaleY;
					}
				}
				
				//TODO: Type should be dynamic
				var circle:CircleGeometry = CircleGeometry( geometry );
				var circleShape:Circle = new Circle( circle.radius * _physicsProcess.scaleFactor * scale );
				//circleShape.localCOM = new Vec2( circle.x * _physicsProcess.scaleFactor, circle.y * _physicsProcess.scaleFactor );
				body.shapes.add(circleShape);
				
//				var circleShapeDef:b2CircleDef = new b2CircleDef();
//				circleShapeDef.radius = circle.radius * _physicsProcess.scaleFactor * scale;
//				circleShapeDef.friction = friction;
//				circleShapeDef.restitution = restitution;
//				circleShapeDef.density = fixed ? 0 : density;
//				circleShapeDef.localPosition = new b2Vec2( circle.x * _physicsProcess.scaleFactor, circle.y * _physicsProcess.scaleFactor );
//				body.CreateShape( circleShapeDef );
			}
			else if ( geometry is PolygonGeometry )
			{
				var polygon:PolygonGeometry = PolygonGeometry( geometry );
				
				// Cancel out translation and rotation, but retain scale.
				//m = _transform.matrix;
				m = _transform.matrix.clone();
				m.translate(-_transform.x, -_transform.y);
				m.rotate(-_transform.rotation);//* 0.0174);
				//Note: Starling rotation already in radians.
				
				// Transform the vertices to world space
				var vertices:Array = VertexUtil.copy(polygon.vertices);
				VertexUtil.transform(vertices, m);
				
				// Simplify the vertices so vertices on, or very near, a straight line get removed.
				vertices = VertexUtil.simplify(vertices);
				
				var allVertices:Array = [vertices];
				// Check if the poylgon is concave, if so, then collapse down to convex shapes first
				if ( VertexUtil.isConcave(vertices) )
				{
					allVertices = VertexUtil.makeConvex(vertices);
				}
				
				for each ( vertices in allVertices )
				{
//					var polygonShapeDef:b2PolygonDef = new b2PolygonDef();
//					polygonShapeDef.density = fixed ? 0 : density;
//					polygonShapeDef.friction = friction;
//					polygonShapeDef.restitution = restitution;
					
					var verts:Array = new Array();
					for ( var i:int = 0; i < vertices.length; i++ )
					{
						var vertex:Vertex = vertices[i];
						//polygonShapeDef.vertices[i] 
						verts.push(new Vec2( vertex.x * _physicsProcess.scaleFactor, vertex.y * _physicsProcess.scaleFactor ));
						//polygonShapeDef.vertexCount++;
					}
					//body.CreateShape( polygonShapeDef );
					var polygonShape:Polygon = new Polygon(verts);
					body.shapes.add(polygonShape);
				}
				
			}
			else if ( geometry is CompoundGeometry )
			{
				var compoundGeometry:CompoundGeometry = CompoundGeometry( geometry );
				for each ( var childData:IGeometry in compoundGeometry.children )
				{
					buildShape( childData, body );
				}
			}
		}
/*		
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
			if ( body )
			{
				invalidate(SHAPES);
			}
			else
			{
				invalidate(BODY);
			}
		}
		public function get friction():Number { return _friction; }
		
		[Serializable][Inspectable]
		public function set restitution( value:Number ):void
		{
			_restitution = value;
			if ( body )
			{
				invalidate(SHAPES);
			}
			else
			{
				invalidate(BODY);
			}
		}
		public function get restitution():Number { return _restitution; }
		*/
		[Serializable][Inspectable]
		public function set fixed( value:Boolean ):void
		{
			_fixed = value;
			invalidate(BODY);
		}
		public function get fixed():Boolean { return _fixed; }
		
/*		
		[Serializable][Inspectable]
		public function set angularDamping( value:Number ):void
		{
			_angularDamping = value;
			if ( body )
			{
				body.SetAngularDamping(_angularDamping);
			}
			else
			{
				invalidate(BODY);
			}
		}
		public function get angularDamping():Number { return _angularDamping; }
		
		
		[Serializable][Inspectable]
		public function set linearDamping( value:Number ):void
		{
			_linearDamping = value;
			if ( body )
			{
				body.SetLinearDamping(_linearDamping);
			}
			else
			{
				invalidate(BODY);
			}
		}
		public function get linearDamping():Number { return _linearDamping; }
		
		[Serializable]
		public function set categoryBits( value:uint ):void
		{
			_categoryBits = value;
			if ( body )
			{
				invalidate(SHAPES);
			}
			else
			{
				invalidate(BODY);
			}
		}
		public function get categoryBits():uint { return _categoryBits; }
		
		[Serializable]
		public function set maskBits( value:uint ):void
		{
			_maskBits = value;
			if ( body )
			{
				invalidate(SHAPES);
			}
			else
			{
				invalidate(BODY);
			}
		}
		public function get maskBits():uint { return _maskBits; }*/
	}
}

