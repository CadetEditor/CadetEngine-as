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
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.connections.Connection;
	import cadet2D.components.renderers.Renderer2D;
	
	import flash.geom.Point;
	
	import starling.display.Graphics;
	import starling.display.Shape;

	[CadetEditor( transformable="false" )]
	public class ConnectionSkin extends AbstractSkin2D
	{		
		private var _lineThickness:Number;
		private var _lineColor:Number;
		private var _lineAlpha:Number;
		private var _radius:Number;
		
		private var _connection	:Connection;
		private var _renderer	:Renderer2D;
		
		private var _shape		:Shape;
		
		public function ConnectionSkin( lineThickness:Number = 1, lineColor:uint = 0xFFFFFF, lineAlpha:Number = 0.5, width:Number = 10, radius:Number = 10 )
		{
			name = "ConnectionSkin";
			this.lineThickness = lineThickness;
			this.lineColor = lineColor;
			this.lineAlpha = lineAlpha;
			this.radius = radius;
			this.width = width;
			
			_displayObject = new Shape();
			_shape = Shape(_displayObject);
		}
		
		override protected function addedToScene():void
		{
			super.addedToScene();
			addSiblingReference(Connection, "connection");
			addSceneReference( Renderer2D, "renderer" );
		}
		
		public function set renderer( value:Renderer2D ):void
		{
			_renderer = value;
			invalidate(DISPLAY);
		}
		public function get renderer():Renderer2D { return _renderer; }
		
		public function set connection( value:Connection ):void
		{
			if ( _connection )
			{
				_connection.removeEventListener(InvalidationEvent.INVALIDATE, invalidateConnectionHandler);
			}
			_connection = value;
			
			if ( _connection )
			{
				_connection.addEventListener(InvalidationEvent.INVALIDATE, invalidateConnectionHandler);
			}
			
			invalidate(DISPLAY);
		}
		public function get connection():Connection { return _connection; }
		
		
		
		private function invalidateConnectionHandler( event:InvalidationEvent ):void
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
			if ( !_connection ) return;
			if ( !_renderer || !_renderer.viewport ) return;
			
			var graphics:Graphics = _shape.graphics;
			graphics.clear();
			graphics.lineStyle( lineThickness, lineColor, lineAlpha );
			
			var pt1:Point = _connection.transformA.matrix.transformPoint( _connection.localPosA.toPoint() );
			pt1 = _renderer.worldToViewport(pt1);
			pt1 = _renderer.viewport.localToGlobal(pt1);
			pt1 = _shape.globalToLocal(pt1);
			
			var pt2:Point = _connection.transformB.matrix.transformPoint( _connection.localPosB.toPoint() );
			pt2 = _renderer.worldToViewport(pt2);
			pt2 = _renderer.viewport.localToGlobal(pt2);
			pt2 = _shape.globalToLocal(pt2);
					
			graphics.drawCircle( pt1.x, pt1.y, radius );
			graphics.drawCircle( pt2.x, pt2.y, radius );
			
			graphics.lineStyle( width, lineColor, lineAlpha );
			graphics.moveTo( pt1.x, pt1.y );
			graphics.lineTo( pt2.x, pt2.y );
		}
		
		// Getters / Setters ////////////////////////////////////////////////////////////////////////////
		
		[Serializable][Inspectable( label="Line thickness", priority="1", editor="Slider", min="0.1", max="100", snapInterval="0.1" )]
		public function set lineThickness( value:Number ):void
		{
			_lineThickness = value;
			invalidate(DISPLAY);
		}
		public function get lineThickness():Number { return _lineThickness; }
		
		[Serializable][Inspectable( label="Line colour", priority="2", editor="ColorPicker" )]
		public function set lineColor( value:uint ):void
		{
			_lineColor = value;
			invalidate(DISPLAY);
		}
		public function get lineColor():uint { return _lineColor; }
		
		
		[Serializable][Inspectable( label="Line alpha", priority="3", editor="Slider", min="0", max="1" )]
		public function set lineAlpha( value:Number ):void
		{
			_lineAlpha = value;
			invalidate(DISPLAY);
		}
		public function get lineAlpha():Number { return _lineAlpha; }
		
		
		[Serializable][Inspectable]
		public function set radius( value:Number ):void
		{
			_radius = value;
			invalidate(DISPLAY);
		}
		public function get radius():Number { return _radius; }
		
		
/*		[Serializable][Inspectable]
		public function set width( value:Number ):void
		{
			_width = value;
			invalidate(DISPLAY);
		}
		public function get width():Number { return _width; }*/
	}
}