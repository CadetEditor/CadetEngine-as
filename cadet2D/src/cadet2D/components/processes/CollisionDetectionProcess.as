// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.processes
{
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.core.ISteppableComponent;
	import cadet.events.ComponentEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.geom.BoundingSphere;
	import cadet2D.components.geom.ICollisionShape;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.events.CollisionEvent;
	
	public class CollisionDetectionProcess extends Component implements ISteppableComponent
	{
		private var boundingSpheres	:Vector.<BoundingSphere>;
		
		public function CollisionDetectionProcess()
		{
			boundingSpheres = new Vector.<BoundingSphere>();
		}
		
		override protected function addedToScene():void
		{
			var collisionShapes:Vector.<IComponent> = ComponentUtil.getChildrenOfType(scene, ICollisionShape, true);
			for each ( var collisionShape:ICollisionShape in collisionShapes )
			{
				if ( collisionShape is BoundingSphere )
				{
					boundingSpheres.push( BoundingSphere(collisionShape) );
				}
			}
			
			scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, onComponentAddedToSceneHandler);
			scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, onComponentRemovedFromScene);
		}
		
		override protected function removedFromScene():void
		{
			boundingSpheres = new Vector.<BoundingSphere>();
			
			scene.removeEventListener(ComponentEvent.ADDED_TO_SCENE, onComponentAddedToSceneHandler);
			scene.removeEventListener(ComponentEvent.REMOVED_FROM_SCENE, onComponentRemovedFromScene);
		}
		
		private function onComponentAddedToSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is ICollisionShape == false ) return;
			
			if ( event.component is BoundingSphere )
			{
				boundingSpheres.push(BoundingSphere(event.component));
			}
		}
		
		private function onComponentRemovedFromScene( event:ComponentEvent ):void
		{
			if ( event.component is ICollisionShape == false ) return;
			
			if ( event.component is BoundingSphere )
			{
				boundingSpheres.splice(boundingSpheres.indexOf(BoundingSphere(event.component)),1);
			}
		}
		
		public function step(dt:Number):void
		{
			var collisions:Vector.<Object> = new Vector.<Object>();
			
			var L:int = boundingSpheres.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var boundingSphereA:BoundingSphere = boundingSpheres[i];
				if (boundingSphereA.transform == null) continue;
				
				for ( var j:int = i+1; j < L; j++ )
				{
					var boundingSphereB:BoundingSphere = boundingSpheres[j];
					if (boundingSphereB.transform == null) continue;
					
					var dx:Number = Transform2D(boundingSphereA.transform).x - Transform2D(boundingSphereB.transform).x;
					var dy:Number = Transform2D(boundingSphereA.transform).y - Transform2D(boundingSphereB.transform).y;
					var d:Number = dx*dx + dy*dy;
					var r:Number = boundingSphereA.radius + boundingSphereB.radius;
					if ( d > r*r ) continue;
					
					// A collision has occured. Rather than dispatching the event right away, add it
					// to a list for processing later.
					// This is because a listener for the event could make a change to the scene
					// that ends up removing a bounding sphere from the scene.
					// So we must finish processing all collisions this step before we allow that to happen.
					var event:CollisionEvent = new CollisionEvent( CollisionEvent.COLLISION, boundingSphereA, boundingSphereB );
					collisions.push( {event:event, a:boundingSphereA, b:boundingSphereB } );
				}
			}
			
			for each ( var collision:Object in collisions )
			{
				collision.a.dispatchEvent( collision.event );
				collision.b.dispatchEvent( collision.event );
			}
		}
	}
}