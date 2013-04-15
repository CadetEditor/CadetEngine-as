// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Inspectable Priority range 50-99

package cadet2D.components.skins
{
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.transforms.Transform2D;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;

	public class AbstractSkin2D extends Component implements IRenderable
	{		
		protected var _displayObject			:DisplayObject;
		
		protected static const TRANSFORM		:String = "transform";
		protected static const DISPLAY			:String = "display";
		
		protected var _transform2D				:Transform2D;
		
		protected var _indexStr					:String;
		
		protected var _width					:Number = 0;
		protected var _height					:Number = 0;
		
		public function AbstractSkin2D( name:String = "AbstractSkin2D" )
		{
			super( name );
			_displayObject = new Sprite();
		}
		
		override protected function addedToScene():void
		{
			var excludedTypes:Vector.<Class> = new Vector.<Class>();
			excludedTypes.push(IRenderable);
			addSiblingReference(Transform2D, "transform2D", excludedTypes);
		}
		
		public function get displayObject():DisplayObject { return _displayObject; }

		override public function toString():String
		{
			return _indexStr;
		}
		
		public function get indexStr():String
		{
			// Refresh the indices
			var component:IComponent = this;
			while ( component.parentComponent ) {
				component.index = component.parentComponent.children.getItemIndex(component);
				component = component.parentComponent;
			}
			
			// Refresh the indexStr
			var indexArr:Array = [index];
			
			var parent:IComponentContainer = parentComponent;
			while (parent) {
				if (parent.index != -1) {
					indexArr.push(parent.index);
				} else {
					break;
				}
				parent = parent.parentComponent;
			}
			indexArr.reverse();
			_indexStr = indexArr.toString();
			_indexStr = _indexStr.replace(",", "_");
			
			return _indexStr;
		}		
		
		[Serializable]
		public function set transform2D( value:Transform2D ):void
		{
			if ( _transform2D )
			{
				_transform2D.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			_transform2D = value;
			if ( _transform2D )
			{
				_transform2D.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
				_displayObject.transformationMatrix = _transform2D.matrix;
			}
		}
		public function get transform2D():Transform2D { return _transform2D; }
		
		// Only fired if we're listening in to an external Transform2D
		private function invalidateTransformHandler( event:ValidationEvent ):void
		{
			_displayObject.transformationMatrix = _transform2D.matrix;
			invalidate(TRANSFORM);
		}
		
		override public function validateNow():void
		{
			if (isInvalid(TRANSFORM)) {
				validateTransform();
			}
			if (isInvalid(DISPLAY)) {
				validateDisplay();
			}
			super.validateNow();
		}
		
		protected function validateTransform():void
		{
			if (!_transform2D) return;
			
			_displayObject.x = _transform2D.x;
			_displayObject.y = _transform2D.y;
			_displayObject.scaleX = _transform2D.scaleX;
			_displayObject.scaleY = _transform2D.scaleY;
			_displayObject.rotation = _transform2D.rotation;
		}
		
		protected function validateDisplay():void
		{
			
		}
		
		[Serializable][Inspectable( priority="55" )]
		public function set width( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_width = value;
			invalidate(DISPLAY);
		}
		public function get width():Number { return _width; }
		
		[Serializable][Inspectable( priority="56" )]
		public function set height( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_height = value;
			invalidate(DISPLAY);
		}
		public function get height():Number { return _height; }
		
		[Serializable][Inspectable( priority="57" )]
		public function get visible():Boolean
		{
			return _displayObject.visible;
		}
		public function set visible( value:Boolean ):void
		{
			_displayObject.visible = value;
		}
		
		[Serializable][Inspectable( priority="58" )]
		public function set touchable( value:Boolean ):void
		{
			_displayObject.touchable = value;
		}
		public function get touchable():Boolean { return _displayObject.touchable;	 }
		
		public function clone():IRenderable
		{
			throw(Error("Abstract method"));
		}
	}
}