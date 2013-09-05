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

    import cadet2D.components.renderers.Renderer2D;
    import cadet2D.components.transforms.Transform2D;
    import cadet2D.geom.Vertex;

    import flash.geom.Matrix;
    import flash.geom.Point;

    import starling.utils.MatrixUtil;

    public class Pin extends Component
	{
		private static const TRANSFORM		:String = "transform";
		private static const TRANSFORM_AB	:String = "transformAB";

        private static var helperPoint      :Point  = new Point();
        private static var helperMatrix     :Matrix = new Matrix();

		private var _transform		:Transform2D;   // The transform sibling of the Pin component
		private var _transformA		:Transform2D;   // Pin uses this transform coordinate system (it's 'inside' this transform)
		private var _transformB		:Transform2D;   // Transform pinned to transformA
		private var _localPos		:Vertex;        // Local point in transform coordinate system.
		
		public function Pin( name:String = "Pin" )
		{			
			super(name);
			
			_localPos = new Vertex();
		}
		
		override protected function addedToScene():void
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
		public function get transform():Transform2D { return _transform; }
		
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="100" )]
		public function set transformA( value:Transform2D ):void
		{
			if ( _transformA ) {
				_transformA.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformABHandler);
			}
			
			_transformA = value;
			
			if ( _transformA ) {
				_transformA.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformABHandler);
			}
			
			invalidate(TRANSFORM_AB);
		}
		public function get transformA():Transform2D { return _transformA; }
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="101" )]
		public function set transformB( value:Transform2D ):void
		{
			if ( _transformB ) {
				_transformB.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformABHandler);
			}
			
			_transformB = value;
			
			if ( _transformB ) {
				_transformB.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformABHandler);
			}
			invalidate(TRANSFORM_AB);
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
			//trace("INVALIDATE PIN TRANSFORM");
			invalidate(TRANSFORM);
		}
		
		protected function invalidateTransformABHandler( event:ValidationEvent ):void
		{
			//trace("INVALIDATE TRANSFORM AB");
			invalidate(TRANSFORM_AB);
		}
		
		override public function validateNow():void
		{
			var skinAValid:Boolean = true;
			
			if ( isInvalid( TRANSFORM ) ) {
				validatePinLocalPosFromTransform();
			} 
			if ( isInvalid( TRANSFORM_AB )) {
				validatePinTransformFromSkin();
			}

			super.validateNow();
		}
		
		// When you change the transform of SkinA, set the pin's transform to match the local pos
 		private function validatePinTransformFromSkin():void
		{
			if (_transform == null || _transformA == null) return;
			//if (!_renderer || !_renderer.viewport) return;
			//if (!_skinA) return;

			// Convert the point from local skin space to global (screen) space
			//offset = _skinA.displayObject.localToGlobal(offset);
			MatrixUtil.transformCoords(_transformA.globalMatrix, _localPos.x, _localPos.y, helperPoint);

            helperMatrix.identity();

            if(_transform.parentTransform != null) {
                helperMatrix.concat(_transform.parentTransform.globalMatrix);
                helperMatrix.invert();
            }

            MatrixUtil.transformCoords(helperMatrix, helperPoint.x, helperPoint.y, helperPoint);

            _transform.x = helperPoint.x;
			_transform.y = helperPoint.y;
			
			//trace("validatePinTransformFromSkin transform x "+_transform.x+" y "+_transform.y);
		}
		
		// When you drag the pin itself around, set the pin's local pos to match its transform
		private function validatePinLocalPosFromTransform():void
		{
			if (!_transform || !_transformA) return;
			//if (!_renderer || !_renderer.viewport) return;
			//if (!_skinA) return;

            // Get the global origin
            MatrixUtil.transformCoords(_transform.globalMatrix, 0, 0, helperPoint);

            helperMatrix.identity();
            helperMatrix.concat(_transformA.globalMatrix);
            helperMatrix.invert();

            // Convert the point from global (screen) space to local _transformA space
            MatrixUtil.transformCoords(helperMatrix, helperPoint.x, helperPoint.y, helperPoint);

            _localPos.x = helperPoint.x;
            _localPos.y = helperPoint.y;

            invalidate(TRANSFORM);

			//trace("validatePinLocalPosFromTransform localPos x "+localPos.x+" y "+localPos.y);
		}
		
		public function get label():String { return "Connection"; }
	}
}
