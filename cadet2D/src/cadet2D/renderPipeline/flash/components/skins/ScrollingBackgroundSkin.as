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
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import cadet2D.renderPipeline.flash.components.renderers.Renderer2D;
	import cadet.events.InvalidationEvent;
	
	public class ScrollingBackgroundSkin extends AbstractSkin2D
	{
		// Invalidation Types
		protected var ASSET				:String = "asset";
		
		protected var _assetClass		:Class;
		private var asset				:DisplayObject;
		
		private var shape				:Shape;
		
		private var _renderer			:Renderer2D;
		private var bitmapData			:BitmapData;
		
		private var _parallaxAmount		:Number = 0;
		
		private var m					:Matrix;
		private var pan					:Point;
		
		public function ScrollingBackgroundSkin()
		{
			init();
		}
		
		private function init():void
		{
			name = "ScrollingBackgroundSkin";
			
			m = new Matrix();
			pan = new Point();
			
			sprite.mouseEnabled = false;
			sprite.mouseChildren = false;
			
			shape = new Shape();
			sprite.addChild(shape);
			
			containerID = Renderer2D.VIEWPORT_BACKGROUND_CONTAINER;
		}
		
		override protected function addedToScene():void
		{
			super.addedToScene();
			
			addSceneReference(Renderer2D, "renderer");
		}
		
		[Serializable][Inspectable( editor="ResourceItemEditor" )]
		public function set assetClass( value:Class ):void
		{
			_assetClass = value;
			invalidate(ASSET);
			invalidate(DISPLAY);
		}
		public function get assetClass():Class { return _assetClass; }
		
		[Serializable][Inspectable]
		public function set parallaxAmount( value:Number ):void
		{
			_parallaxAmount = value;
			invalidate(DISPLAY);
		}
		public function get parallaxAmount():Number { return _parallaxAmount; }
		
		public function set renderer( value:Renderer2D ):void
		{
			if ( _renderer )
			{
				_renderer.removeEventListener(InvalidationEvent.INVALIDATE, invalidateRendererHandler);
			}
			_renderer = value;
			if ( _renderer )
			{
				_renderer.addEventListener(InvalidationEvent.INVALIDATE, invalidateRendererHandler);
			}
			invalidate(DISPLAY);
		}
		public function get renderer():Renderer2D { return _renderer; }
		
		private function invalidateRendererHandler( event:InvalidationEvent ):void
		{
			invalidate(DISPLAY);
		}
		
		override public function validateNow():void
		{
			if ( isInvalid(ASSET) )
			{
				validateAsset();
			}
			if ( isInvalid(DISPLAY) )
			{
				validateDisplay();
			}
			
			super.validateNow();
		}
		
		protected function validateAsset():void
		{
			asset = null;
			if ( !_assetClass ) return;
			asset = new _assetClass();
			
			if ( bitmapData ) bitmapData.dispose();
			bitmapData = new BitmapData(asset.width, asset.height, true, 0);
			bitmapData.draw(asset);
		}
		
		private function validateDisplay():void
		{
			sprite.graphics.clear();
			if ( !asset ) return;
			if ( !_renderer ) return;
			
			var viewportWidth:Number = _renderer.viewportWidth;
			var viewportHeight:Number = _renderer.viewportHeight;
			var scaleX:Number = _renderer.worldContainer.scaleX;
			var scaleY:Number = _renderer.worldContainer.scaleY;
			
			// Calculate what point, in world coordinates, the center of the viewport is looking at.
			pan.x = 0//viewportWidth*0.5;
			pan.y = 0//viewportHeight*0.5;
			pan = _renderer.viewportToWorld(pan);
			
			
			// We now build a matrix that will transform the bitmap in such a way so we are looking at it
			// as if it were panned and zoomded in the world.
			m.identity();			
			m.translate(-bitmapData.width*0.5, -bitmapData.height*0.5);
			m.translate(-pan.x * _parallaxAmount, -pan.y * _parallaxAmount);
			m.scale(scaleX, scaleY);
			m.translate(viewportWidth*0.5, viewportHeight*0.5);
			
			sprite.graphics.beginBitmapFill(bitmapData, m, true);
			sprite.graphics.drawRect(0,0,viewportWidth,viewportHeight);
		}
	}
}