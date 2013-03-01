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
	import flash.geom.Rectangle;
	
	import cadet.core.Component;
	
	import flox.core.events.PropertyChangeEvent;

	public class WorldBounds2D extends Component
	{
		private static const BOUNDS	:String = "bounds";
		
		private var _left		:Number = 0;
		private var _right		:Number = 1000;
		private var _top		:Number = 0;
		private var _bottom		:Number = 1000;
		
		private var rect		:Rectangle;
		
		public function WorldBounds2D()
		{
			name = "WorldBounds2D";
		}
		
		[Serializable][Inspectable]
		public function set left( value:Number ):void
		{
			_left = value;
			invalidate(BOUNDS);
			dispatchEvent( new PropertyChangeEvent( "propertyChange_left", null, _name ) );
		}
		public function get left():Number { return _left; }
		
		[Serializable][Inspectable]
		public function set right( value:Number ):void
		{
			_right = value;
			invalidate(BOUNDS);
			dispatchEvent( new PropertyChangeEvent( "propertyChange_right", null, _name ) );
		}
		public function get right():Number { return _right; }
		
		[Serializable][Inspectable]
		public function set top( value:Number ):void
		{
			_top = value;
			invalidate(BOUNDS);
			dispatchEvent( new PropertyChangeEvent( "propertyChange_top", null, _name ) );
		}
		public function get top():Number { return _top; }
		
		[Serializable][Inspectable]
		public function set bottom( value:Number ):void
		{
			_bottom = value;
			invalidate(BOUNDS);
			dispatchEvent( new PropertyChangeEvent( "propertyChange_bottom", null, _name ) );
		}
		public function get bottom():Number { return _bottom; }
		
		override public function validateNow():void
		{
			if ( isInvalid(BOUNDS) ) {
				validateBounds();
			}
			
			super.validateNow();
		}
		
		private function validateBounds():void
		{
			rect = new Rectangle(left, top, left + right, top + bottom);
		}
		
		public function getRect():Rectangle
		{
			if (!rect) validateBounds();
			return rect;
		}
	}
}