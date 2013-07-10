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
	import flash.geom.Point;
	
	import cadet.core.Component;
	import cadet.events.ValidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.IRenderable;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	
	public class Pin extends Component
	{
		private static const SKINA			:String = "skinA";
		private static const DISPLAY		:String = "display";
		private static const TRANSFORM		:String = "transform";
		private static const TRANSFORM_AB	:String = "transformAB";
		
		private var _skinA			:IRenderable;
		private var _renderer		:Renderer2D;
		
		private var _transform		:Transform2D; // The transform sibling of the Pin component
		private var _transformA		:Transform2D;
		private var _transformB		:Transform2D;
		private var _localPos		:Vertex;
		
		public function Pin( name:String = "Pin" )
		{			
			super(name);
			
			_localPos	 = new Vertex();
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(Transform2D, "transform");
			addSceneReference(Renderer2D, "renderer");
		}
		
		public function set renderer( value:Renderer2D ):void
		{
			if ( _renderer ) {
				_renderer.removeEventListener(ValidationEvent.INVALIDATE, invalidateDisplayHandler);
			}
			
			_renderer = value;
			
			if ( _renderer ) {
				_renderer.addEventListener(ValidationEvent.INVALIDATE, invalidateDisplayHandler);
			}
			invalidate(DISPLAY);
		}
		public function get renderer():Renderer2D { return _renderer; }
		
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
			invalidate(SKINA);
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
		
		private function invalidateDisplayHandler( event:ValidationEvent ):void
		{
			invalidate(DISPLAY);
		}
		
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
			if ( isInvalid( TRANSFORM_AB ) || isInvalid( DISPLAY ) ) {
				validatePinTransformFromSkin();
			}
			if ( isInvalid( SKINA ) ) {
				skinAValid = validateSkinA();
			}
			
			super.validateNow();
			
			if (!skinAValid) {
				invalidate(SKINA);
			}
		}
		
		private function validateSkinA():Boolean
		{
			if (!_transformA || !_transformA.parentComponent ) return false;
			
			_skinA = ComponentUtil.getChildOfType(_transformA.parentComponent, IRenderable);
			
			//trace("VALIDATE SKIN A "+_skinA.name);
			
			return true;
		}
		
		// When you change the transform of SkinA, set the pin's transform to match the local pos
 		private function validatePinTransformFromSkin():void
		{
			if (!_transform) return;
			if (!_renderer || !_renderer.viewport) return;
			if (!_skinA) return;
			
			var offset:Point = new Point(_localPos.x, _localPos.y);
			
			// Convert the point from local skin space to global (screen) space 
			offset = _skinA.displayObject.localToGlobal(offset);
			// Change the point from viewport space to screen space
			offset = renderer.viewport.globalToLocal(offset);
			// Change the point from screen space to world space
			offset = renderer.viewportToWorld(offset);
			
			_transform.x = offset.x;
			_transform.y = offset.y;
			
			//trace("validatePinTransformFromSkin transform x "+_transform.x+" y "+_transform.y);
		}
		
		// When you drag the pin itself around, set the pin's local pos to match its transform
		private function validatePinLocalPosFromTransform():void
		{
			if (!_transform) return;
			if (!_renderer || !_renderer.viewport) return;
			if (!_skinA) return;
			
			var offset:Point = new Point(_transform.x, _transform.y);
			// Get the viewport location of the click within world space
			offset = renderer.worldToViewport(offset);
			
			// Change the point from viewport space to screen space
			offset = renderer.viewport.localToGlobal(offset);
			
			// Convert the point from global (screen) space to local skin space
			offset = _skinA.displayObject.globalToLocal(offset);
			
			localPos = new Vertex(offset.x, offset.y);
			
			//trace("validatePinLocalPosFromTransform localPos x "+localPos.x+" y "+localPos.y);
		}
		
		public function get label():String { return "Connection"; }
	}
}