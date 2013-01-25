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
	import cadet.core.IComponentContainer;
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.transforms.Transform2D;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import cadet.core.IComponent;

	public class AbstractSkin2D extends Component implements IRenderable
	{
		protected static const DISPLAY	:String = "display";
//		protected static const LAYER	:String = "layer";
//		protected static const CONTAINER:String = "container";
		protected static const TRANSFORM:String = "transform";
		
		protected var _displayObject			:DisplayObject;
//		protected var _layerIndex				:int = 0;
//		protected var _containerID				:String = Renderer2D.WORLD_CONTAINER;
		protected var _transform2D				:Transform2D;
		
		private var _indexStr					:String;
		
		public function AbstractSkin2D()
		{
			_displayObject = new Sprite();
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(Transform2D, "transform2D");
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
				_transform2D.removeEventListener(InvalidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			_transform2D = value;
			if ( _transform2D )
			{
				_transform2D.addEventListener(InvalidationEvent.INVALIDATE, invalidateTransformHandler);
				_displayObject.transformationMatrix = _transform2D.matrix;
			}
		}
		public function get transform2D():Transform2D { return _transform2D; }
				
		private function invalidateTransformHandler( event:InvalidationEvent ):void
		{
			_displayObject.transformationMatrix = _transform2D.matrix;
			invalidate(TRANSFORM);
		}
/*		
		[Serializable][Inspectable( label="Layer index", priority="50", editor="NumericStepper", min="0", max="7" )]
		public function set layerIndex( value:int ):void
		{
			if ( value == _layerIndex ) return;
			_layerIndex = value;
			invalidate(LAYER);
		}
		public function get layerIndex():int { return _layerIndex; }
		
		[Serializable][Inspectable( label="Render layer", priority="51", editor="DropDownMenu", dataProvider="[worldContainer,viewportForegroundContainer,viewportBackgroundContainer]" )]
		public function set containerID( value:String ):void
		{
			if ( value == _containerID ) return;
			_containerID = value;
			invalidate(CONTAINER);
		}
		public function get containerID():String { return _containerID; }
		*/
		[Serializable][Inspectable( label="Mouse enabled", priority="52" )]
		public function set mouseEnabled( value:Boolean ):void
		{
			_displayObject.touchable = value;
		}
		public function get mouseEnabled():Boolean { return _displayObject.touchable; }
	}
}