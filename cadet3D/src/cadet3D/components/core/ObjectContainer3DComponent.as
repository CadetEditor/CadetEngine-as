// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Abstract
package cadet3D.components.core
{
	import flash.geom.Matrix3D;
	
	import away3d.containers.ObjectContainer3D;
	
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;

	[Event(name="object3DAdded", type="cadetAway3D4.events.Object3DComponentEvent")]
	[Event(name="object3DRemoved", type="cadetAway3D4.events.Object3DComponentEvent")]
	public class ObjectContainer3DComponent extends ComponentContainer
	{
		protected var _object3D		:ObjectContainer3D;
		
		public function ObjectContainer3DComponent()
		{
			_object3D = new ObjectContainer3D();
		}
		
		override public function dispose():void
		{
			super.dispose();
			if ( _object3D )
			{
				_object3D.dispose();
			}
		}
		
		override protected function childAdded( child:IComponent, index:uint ):void
		{
			super.childAdded(child, index);
			
			var object3DComponent:ObjectContainer3DComponent = child as ObjectContainer3DComponent;
			if ( !object3DComponent ) return;
			
			_object3D.addChild(object3DComponent.object3D);
		}
		
		override protected function childRemoved( child:IComponent ):void
		{
			super.childRemoved(child);
			
			var object3DComponent:ObjectContainer3DComponent = child as ObjectContainer3DComponent;
			if ( !object3DComponent ) return;
			if ( object3DComponent.object3D.parent == null ) return;
			
			object3DComponent.object3D.parent.removeChild(object3DComponent.object3D);
		}
		
		public function get object3D():ObjectContainer3D
		{
			return _object3D;
		}
		
		[Serializable(alias="transform")]
		public function set serializedTransform( value:String ):void
		{
			var split:Array = value.split( "," );
			
			var v:Vector.<Number> = new Vector.<Number>();
			for ( var i:int = 0; i < split.length; i++ )
			{
				v.push( Number(split[i]) );
			}
			transform = new Matrix3D( v );
		}
		
		public function get serializedTransform():String 
		{ 
			var m:Matrix3D = transform;
			var output:String = "";
			for ( var i:int = 0; i < m.rawData.length; i++ )
			{
				output += m.rawData[i] + (i == m.rawData.length-1 ? "" : ",");
			}
			
			return output;
		}
		
		public function get transform():Matrix3D
		{
			return _object3D.transform;
		}
		
		public function set transform( value:Matrix3D ):void
		{
			_object3D.transform = value;
		}
		
		/**
		 * Defines the x coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		[Inspectable ( priority="100" ) ]
		public function get x() : Number
		{
			return _object3D.x;
		}
		
		public function set x(val:Number) : void
		{
			_object3D.x = val;
		}
		
		/**
		 * Defines the y coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		[Inspectable ( priority="101" ) ]
		public function get y() : Number
		{
			return _object3D.y;
		}
		
		public function set y(val:Number) : void
		{
			_object3D.y = val;
		}
		
		/**
		 * Defines the z coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		[Inspectable ( priority="102" ) ]
		public function get z() : Number
		{
			return _object3D.z;
		}
		
		public function set z(val:Number) : void
		{
			_object3D.z = val;
		}
		
		/**
		 * Defines the euler angle of rotation of the 3d object around the x-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		[Inspectable ( priority="106" ) ]
		public function get rotationX() : Number
		{
			return _object3D.rotationX;
		}
		
		public function set rotationX(val:Number) : void
		{
			_object3D.rotationX = val;
		}
		
		/**
		 * Defines the euler angle of rotation of the 3d object around the y-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		[Inspectable ( priority="107" ) ]
		public function get rotationY():Number
		{
			return _object3D.rotationY;
		}
		
		public function set rotationY(val:Number):void
		{
			_object3D.rotationY = val;
		}
		
		/**
		 * Defines the euler angle of rotation of the 3d object around the z-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		[Inspectable ( priority="108" ) ]
		public function get rotationZ():Number
		{
			return _object3D.rotationZ;
		}
		
		public function set rotationZ(val:Number):void
		{
			_object3D.rotationZ = val;
		}
		
		/**
		 * Defines the scale of the 3d object along the x-axis, relative to local coordinates.
		 */
		[Inspectable ( priority="103" ) ]
		public function get scaleX():Number
		{
			return _object3D.scaleX;
		}
		
		public function set scaleX(val:Number):void
		{
			_object3D.scaleX = val;
		}
		
		/**
		 * Defines the scale of the 3d object along the y-axis, relative to local coordinates.
		 */
		[Inspectable ( priority="104" ) ]
		public function get scaleY():Number
		{
			return _object3D.scaleY;
		}
		
		public function set scaleY(val:Number) : void
		{
			_object3D.scaleY = val;
		}
		
		/**
		 * Defines the scale of the 3d object along the z-axis, relative to local coordinates.
		 */
		[Inspectable ( priority="105" ) ]
		public function get scaleZ():Number
		{
			return _object3D.scaleZ;
		}
		
		public function set scaleZ(val:Number) : void
		{
			_object3D.scaleZ = val;
		}
	}
}