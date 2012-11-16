// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.renderPipeline.flash.components.skins
{
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.connections.Pin;
	import cadet2D.components.renderers.IRenderer2D;
	import cadet2D.renderPipeline.flash.components.renderers.Renderer2D;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	
	[CadetBuilder( transformable="false" )]
	public class PinSkin extends AbstractSkin2D
	{
		private static const DISPLAY		:String = "display";
		
		private var _fillColor:uint;
		private var _fillAlpha:Number;
		private var _radius:Number;
		
		private var _pin				:Pin;
		private var _renderer			:IRenderer2D;
		
		public function PinSkin( fillColor:uint = 0xFFFFFF, fillAlpha:Number = 0.5, radius:Number = 5 )
		{
			name = "PinSkin";
			this.fillColor = fillColor;
			this.fillAlpha = fillAlpha;
			this.radius = radius;
		}
		
		override protected function addedToScene():void
		{
			super.addedToScene();
			addSiblingReference(Pin, "pin");
			addSceneReference( IRenderer2D, "renderer" );
		}
		
		public function set renderer( value:IRenderer2D ):void
		{
			_renderer = value;
			invalidate(DISPLAY);
		}
		public function get renderer():IRenderer2D { return _renderer; }
		
		public function set pin( value:Pin ):void
		{
			if ( _pin )
			{
				_pin.removeEventListener(InvalidationEvent.INVALIDATE, invalidatePinHandler);
			}
			_pin = value;
			
			if ( _pin )
			{
				_pin.addEventListener(InvalidationEvent.INVALIDATE, invalidatePinHandler);
			}
			
			invalidate(DISPLAY);
		}
		public function get pin():Pin { return _pin; }
		
		private function invalidatePinHandler( event:InvalidationEvent ):void
		{
			invalidate(DISPLAY);
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( DISPLAY ) )
			{
				validateDisplay();
			}
			
			super.validateNow();
		}
		
		public function validateDisplay():void
		{
			if ( !_pin ) return;
			if ( !_renderer ) return;
			if ( !_pin.transformA ) return;
			
			var graphics:Graphics = sprite.graphics
			graphics.clear();
			graphics.beginFill( _fillColor, _fillAlpha );
			
			var pt:Point = _pin.transformA.matrix.transformPoint( _pin.localPos.toPoint() );
			pt = _renderer.worldToViewport(pt);
			pt = Renderer2D(_renderer).viewport.localToGlobal(pt);
			pt = sprite.globalToLocal(pt);
												
			graphics.drawCircle( pt.x, pt.y, radius );
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