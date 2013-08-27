// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.skins
{
    import cadet.events.ValidationEvent;

    import cadet2D.components.connections.Pin;

    import flash.geom.Point;

    import starling.core.Starling;
    import starling.display.Graphics;
    import starling.display.Shape;

    //	[CadetEditor( transformable="false" )]
	public class PinSkin extends AbstractSkin2D
	{
		private static const DISPLAY		:String = "display";

        private static var helperPoint      :Point = new Point();

		private var _fillColor:uint;
		private var _fillAlpha:Number;
		private var _radius:Number;
		
		private var _pin				:Pin;

		private var _shape				:Shape;
		
		public function PinSkin( fillColor:uint = 0xFFFFFF, fillAlpha:Number = 0.5, radius:Number = 5 )
		{
			name = "PinSkin";
			this.fillColor = fillColor;
			this.fillAlpha = fillAlpha;
			this.radius = radius;
			
			_displayObject = new Shape();
			_shape = Shape(_displayObject);
		}
		
		override protected function addedToScene():void
		{
			super.addedToScene();
			
			addSiblingReference(Pin, "pin");
		}

		public function set pin( value:Pin ):void
		{
			if ( _pin ) {
				_pin.removeEventListener(ValidationEvent.INVALIDATE, invalidatePinHandler);
			}
			_pin = value;
			
			if ( _pin ) {
				_pin.addEventListener(ValidationEvent.INVALIDATE, invalidatePinHandler);
			}
			
			invalidate(DISPLAY);
		}
		public function get pin():Pin { return _pin; }
		
		private function invalidatePinHandler( event:ValidationEvent ):void
		{
			invalidate(DISPLAY);
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( DISPLAY ) ) {
				validateDisplay();
			}
			
			super.validateNow();
		}
		
		override protected function validateDisplay():Boolean
		{
            if (!Starling.current) return false;

            var graphics:Graphics = _shape.graphics;
            graphics.clear();
            graphics.beginFill( _fillColor, _fillAlpha );
            graphics.drawCircle( 0, 0, radius );

			super.validateDisplay();
			
			return true;
		}
		
		[Serializable][Inspectable( editor="ColorPicker" )]
		public function set fillColor( value:uint ):void
		{
			_fillColor = value;
			invalidate(DISPLAY);
		}
		public function get fillColor():uint { return _fillColor; }
		
		
		[Serializable][Inspectable]
		public function set fillAlpha( value:Number ):void
		{
			_fillAlpha = value;
			invalidate(DISPLAY);
		}
		public function get fillAlpha():Number { return _fillAlpha; }
				
		[Serializable][Inspectable]
		public function set radius( value:Number ):void
		{
			_radius = value;
			invalidate(DISPLAY);
		}
		public function get radius():Number { return _radius; }
	}
}
