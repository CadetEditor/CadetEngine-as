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
	import flash.geom.Matrix;
	
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.transforms.ITransform2D;
	import cadet2D.components.transforms.Transform2D;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;

	public class AbstractSkin2D extends Component implements IRenderable, ITransform2D
	{
		// ITransform2D
		protected var _x						:Number = 0;
		protected var _y						:Number = 0;
		protected var _scaleX					:Number = 1;
		protected var _scaleY					:Number = 1;
		protected var _rotation					:Number = 0;
		
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
		
		// Only fired if we're listening in to an external Transform2D
		private function invalidateTransformHandler( event:InvalidationEvent ):void
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
			// A sibling transform component takes precedence over directly setting x, y, etc.
			if (_transform2D) {
				_x = _transform2D.x;
				_y = _transform2D.y;
				_scaleX = _transform2D.scaleX;
				_scaleY = _transform2D.scaleY;
				_rotation = _transform2D.rotation;
			//	return;
			}
			
			_displayObject.x = _x;
			_displayObject.y = _y;
			_displayObject.scaleX = _scaleX;
			_displayObject.scaleY = _scaleY;
			_displayObject.rotation = _rotation;
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
		
		// -------------------------------------------------------------------------------------
		// ITRANSFORM2D API
		// -------------------------------------------------------------------------------------
		
		[Inspectable( priority="50" )]
		public function set x( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_x = value;
			invalidate(TRANSFORM);
		}
		public function get x():Number { return _x; }
		
		[Inspectable( priority="51" )]
		public function set y( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_y = value;
			invalidate(TRANSFORM);
		}
		public function get y():Number { return _y; }
		
		[Inspectable( priority="52" )]
		public function set scaleX( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_scaleX = value;
			invalidate(TRANSFORM);
		}
		public function get scaleX():Number { return _scaleX; }
		
		[Inspectable( priority="53" )]
		public function set scaleY( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_scaleY = value;
			invalidate(TRANSFORM);
		}
		public function get scaleY():Number { return _scaleY; }
		
		[Inspectable( priority="54" )]
		public function set rotation( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_rotation = value;
			invalidate(TRANSFORM);
		}
		public function get rotation():Number { return _rotation; }
		
		public function set matrix( value:Matrix ):void
		{
			_displayObject.transformationMatrix = value;
			_x = _displayObject.x;
			_y = _displayObject.y;
			_scaleX = _displayObject.scaleX;
			_scaleY = _displayObject.scaleY;
			_rotation = _displayObject.rotation;
			
			invalidate(TRANSFORM);
		}
		public function get matrix():Matrix 
		{ 
			if (isInvalid(TRANSFORM)) {
				validateTransform();
			}
			
			return _displayObject.transformationMatrix; 
		}
		
		[Serializable(alias="matrix")]
		public function set serializedMatrix( value:String ):void
		{
			var split:Array = value.split( "," );
			matrix = new Matrix( split[0], split[1], split[2], split[3], split[4], split[5] );
		}
		
		public function get serializedMatrix():String 
		{ 
			var m:Matrix = matrix;
			return m.a + "," + m.b + "," + m.c + "," + m.d + "," + m.tx + "," + m.ty;
		}
		
		// -------------------------------------------------------------------------------------
	}
}