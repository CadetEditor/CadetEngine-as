// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.renderPipeline.starling.components.skins
{
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	import cadet2D.renderPipeline.starling.components.renderers.Renderer2D;
	import cadet2D.components.transforms.Transform2D;
	import cadet.core.Component;
	import cadet.events.InvalidationEvent;
	import cadet2D.components.skins.ISkin2D;

	public class AbstractSkin2D extends Component implements ISkin2D
	{
		protected static const DISPLAY	:String = "display";
		protected static const LAYER	:String = "layer";
		protected static const CONTAINER:String = "container";
		protected static const TRANSFORM:String = "transform";
		
		protected var sprite			:Sprite;
		protected var _layerIndex		:int = 0;
		protected var _containerID		:String = Renderer2D.WORLD_CONTAINER;
		protected var _transform2D		:Transform2D;
		
		public function AbstractSkin2D()
		{
			sprite = new Sprite();
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(Transform2D, "transform2D");
		}
		
		public function get displayObject():Sprite { return sprite; }
		
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
				sprite.transformationMatrix = _transform2D.matrix;
			}
		}
		public function get transform2D():Transform2D { return _transform2D; }
				
		private function invalidateTransformHandler( event:InvalidationEvent ):void
		{
			sprite.transformationMatrix = _transform2D.matrix;
			invalidate(TRANSFORM);
		}
		
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
		
		[Serializable][Inspectable( label="Mouse enabled", priority="52" )]
		public function set mouseEnabled( value:Boolean ):void
		{
			sprite.touchable = value;
		}
		public function get mouseEnabled():Boolean { return sprite.touchable; }
		/*
		[Serializable][Inspectable( label="Mouse children", priority="53" )]
		public function set mouseChildren( value:Boolean ):void
		{
			sprite.touchable = value;
		}
		public function get mouseChildren():Boolean { return sprite.touchable; }
		*/
	}
}