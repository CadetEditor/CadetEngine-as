// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Inspectable Priority range 100-149

package cadet2D.components.connections
{
	import cadet.core.Component;
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	
	public class Pin extends Component
	{
		private static const TRANSFORM	:String = "transform";
		
		//private var _transform		:Transform2D;
		private var _transformA		:Transform2D;
		private var _transformB		:Transform2D;
		private var _localPos		:Vertex;
		
		public function Pin(name:String = "Pin")
		{
			super(name);
		}
		
/*		override protected function addedToScene():void
		{
			addSiblingReference(Transform2D, "transform");
		}
		
		public function set transform( value:Transform2D ):void
		{
			if ( _transform ) {
				_transform.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			
			_transform = value;
			
			if ( _transform ) {
				_transform.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			invalidate(TRANSFORM);
		}
		public function get transform():Transform2D { return _transform; }*/
		
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="100" )]
		public function set transformA( value:Transform2D ):void
		{
			if ( _transformA ) {
				_transformA.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			
			_transformA = value;
			
			if ( _transformA ) {
				_transformA.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			invalidate(TRANSFORM);
		}
		public function get transformA():Transform2D { return _transformA; }
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="101" )]
		public function set transformB( value:Transform2D ):void
		{
			if ( _transformB ) {
				_transformB.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			
			_transformB = value;
			
			if ( _transformB ) {
				_transformB.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			invalidate(TRANSFORM);
		}
		public function get transformB():Transform2D { return _transformB; }
		
		[Serializable]
		public function set localPos( value:Vertex ):void
		{
			_localPos = value;
			invalidate( TRANSFORM );
		}
		public function get localPos():Vertex { return _localPos; }
		
		protected function invalidateTransformHandler( event:ValidationEvent ):void
		{
			invalidate(TRANSFORM);
		}
		
		public function get label():String { return "Connection"; }
	}
}