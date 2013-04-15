// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.connections
{
	import cadet2D.components.transforms.Transform2D;
	import cadet.core.Component;
	import cadet.events.ValidationEvent;
	import cadet2D.geom.Vertex;
	
	public class Connection extends Component
	{
		private static const TRANSFORM	:String = "transform";
		
		private var _transformA		:Transform2D;
		private var _transformB		:Transform2D;
		private var _localPosA		:Vertex;
		private var _localPosB		:Vertex;
				
		public function Connection()
		{
			name = "Connection";
		}
		
		[Serializable]
		public function set transformA( value:Transform2D ):void
		{
			if ( _transformA )
			{
				_transformA.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			
			_transformA = value;
			
			if ( _transformA )
			{
				_transformA.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			invalidate(TRANSFORM);
		}
		public function get transformA():Transform2D { return _transformA; }
		
		[Serializable]
		public function set transformB( value:Transform2D ):void
		{
			if ( _transformB )
			{
				_transformB.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			
			_transformB = value;
			
			if ( _transformB )
			{
				_transformB.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			invalidate(TRANSFORM);
		}
		public function get transformB():Transform2D { return _transformB; }
		
		[Serializable]
		public function set localPosA( value:Vertex ):void
		{
			_localPosA = value;
			invalidate( TRANSFORM );
		}
		public function get localPosA():Vertex { return _localPosA; }
		
		[Serializable]
		public function set localPosB( value:Vertex ):void
		{
			_localPosB = value;
			invalidate( TRANSFORM );
		}
		public function get localPosB():Vertex { return _localPosB; }
		
		protected function invalidateTransformHandler( event:ValidationEvent ):void
		{
			invalidate(TRANSFORM);
		}
		
		public function get label():String { return "Connection"; }
	}
}