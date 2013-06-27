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
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import cadet.core.Component;
	import cadet.core.IComponentContainer;
	import cadet.core.ISteppableComponent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.renderers.IRenderer2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.IRenderable;
	
	import core.app.util.Easing;
	
	import starling.display.DisplayObject;

	public class TrackCamera2DProcess extends Component implements ISteppableComponent
	{
		private var _renderer			:IRenderer2D;
		private var _debugDrawProcess	:IDebugDrawProcess;
		private var _target				:IComponentContainer;
		private var _worldBounds		:WorldBounds2D;
		
		[Serializable][Inspectable]
		public var ease				:Number = 0.2;
		[Serializable][Inspectable]
		public var maxZoom			:Number = 1;
		[Serializable][Inspectable]
		public var minZoom			:Number = 0.25;
		[Serializable][Inspectable]
		public var minSpeed			:Number = 0;
		[Serializable][Inspectable]
		public var maxSpeed			:Number = 100;
		
		private var snapTo			:Boolean = false;
		private var matrix			:Matrix;
		
		private var cameraRect		:Rectangle;
		private var oldCameraRect	:Rectangle;
		
		private var oldObjectX		:Number;
		private var oldObjectY		:Number;
		
		public function TrackCamera2DProcess()
		{
			name = "TrackCamera2DProcess";
			matrix = new Matrix();
			cameraRect = new Rectangle();
			oldCameraRect = new Rectangle();
		}
		
		override protected function addedToScene():void
		{
			addSceneReference(IRenderer2D, "renderer");
			addSceneReference(WorldBounds2D, "worldBounds");
			addSceneReference(IDebugDrawProcess, "debugDrawProcess");
		}
		
		[Serializable][Inspectable( editor="ComponentList" )]
		public function set target( value:IComponentContainer ):void
		{
			_target = value;
			snapTo = true;
		}
		public function get target():IComponentContainer { return _target; }
		
		public function set renderer(value:IRenderer2D):void
		{
			_renderer = value;
			snapTo = true;
		}
		public function get renderer():IRenderer2D { return _renderer; }
		
		public function set worldBounds( value:WorldBounds2D ):void
		{
			_worldBounds = value;
		}
		public function get worldBounds():WorldBounds2D { return _worldBounds; }
		
		public function set debugDrawProcess( value:IDebugDrawProcess ):void
		{
			_debugDrawProcess = value;
		}
		public function get debugDrawProcess():IDebugDrawProcess { return _debugDrawProcess; }
		
		public function step( dt:Number ):void
		{
			if ( !_renderer || !_renderer.initialised ) return;
			if ( !_target ) return;
			
			var skin:IRenderable = ComponentUtil.getChildOfType(_target, IRenderable, false);
			
			if ( !skin ) return;
			
			// Calculate the components position relative to the container.
			var bounds:Rectangle = AbstractSkin2D(skin).displayObject.getBounds(DisplayObject(Renderer2D(_renderer).worldContainer));
			
			if ( bounds.width == 0 ) return;
			if ( bounds.height == 0 ) return;
			
			var viewportWidth:Number = _renderer.viewportWidth;
			var viewportHeight:Number = _renderer.viewportHeight;
			var halfViewportWidth:Number = viewportWidth*0.5;
			var halfViewportHeight:Number = viewportHeight*0.5;
			
			var objectX:Number = bounds.left + (bounds.width*0.5);
			var objectY:Number = bounds.top + (bounds.height*0.5);
			
			if ( snapTo )
			{
				cameraRect.left = objectX - halfViewportWidth;
				cameraRect.right = objectX + halfViewportWidth;
				cameraRect.top = objectY - halfViewportHeight;
				cameraRect.bottom = objectY + halfViewportHeight;
				oldCameraRect = cameraRect.clone();
				oldObjectX = objectX;
				oldObjectY = objectY;
				snapTo = false;
			}
			
			// Based on the speed the camera is moving, calculate a desired zoom level
			var objectVX:Number = objectX-oldObjectX;
			var objectVY:Number = objectY-oldObjectY;
			var objectSpeed:Number = Math.sqrt(objectVX*objectVX + objectVY*objectVY);
			var speedRatio:Number = (objectSpeed-minSpeed) / (maxSpeed-minSpeed);
			speedRatio = speedRatio < 0 ? 0 : speedRatio > 1 ? 1 : speedRatio;
			speedRatio = Easing.easeOutCubic(speedRatio, 0, 1, 1);
			var desiredZoom:Number = maxZoom + speedRatio * (minZoom-maxZoom);
			
			var newCameraRect:Rectangle = new Rectangle();
			newCameraRect.left = objectX - halfViewportWidth / desiredZoom;
			newCameraRect.right = objectX + halfViewportWidth / desiredZoom;
			newCameraRect.top = objectY - halfViewportHeight / desiredZoom;
			newCameraRect.bottom = objectY + halfViewportHeight / desiredZoom;
			
				
			// Now we need to limit this rectangle to the worldBounds (if available)
			if ( _worldBounds )
			{
				if ( newCameraRect.left < _worldBounds.left )
				{
					newCameraRect.x += _worldBounds.left-newCameraRect.left;
					
					if ( newCameraRect.right > _worldBounds.right )
					{
						newCameraRect.right = _worldBounds.right;
					}
				}
				
				if ( newCameraRect.right > _worldBounds.right )
				{
					newCameraRect.x += _worldBounds.right-newCameraRect.right;
					
					if ( newCameraRect.left < _worldBounds.left )
					{
						newCameraRect.left = _worldBounds.left;
					}
				}
				
				
				if ( newCameraRect.top < _worldBounds.top )
				{
					newCameraRect.y += _worldBounds.top-newCameraRect.top;
					
					if ( newCameraRect.bottom > _worldBounds.bottom )
					{
						newCameraRect.bottom = _worldBounds.bottom;
					}
				}
				
				if ( newCameraRect.bottom > _worldBounds.bottom )
				{
					newCameraRect.y += _worldBounds.bottom-newCameraRect.bottom;
					
					if ( newCameraRect.top < _worldBounds.top )
					{
						newCameraRect.top = _worldBounds.top;
					}
				}
			}
			
			// Now ease the cameraRect towards newCameraRect
			cameraRect.left += (newCameraRect.left-cameraRect.left) * ease;
			cameraRect.right += (newCameraRect.right-cameraRect.right) * ease;
			cameraRect.top += (newCameraRect.top-cameraRect.top) * ease;
			cameraRect.bottom += (newCameraRect.bottom-cameraRect.bottom) * ease;
			
			
			var rectZoom:Number = Math.max( viewportWidth / cameraRect.width, viewportHeight / cameraRect.height );
			var rectX:Number = cameraRect.x + cameraRect.width * 0.5;
			var rectY:Number = cameraRect.y + cameraRect.height * 0.5;
			
			// Update the Renderer's container position 
			matrix.identity();
			matrix.translate(-rectX, -rectY);
			matrix.scale(rectZoom, rectZoom);
			matrix.translate(halfViewportWidth, halfViewportHeight);
			
			Renderer2D(_renderer).worldContainer.transformationMatrix = matrix;
			_renderer.invalidate("container");
			
			if ( _debugDrawProcess && _debugDrawProcess.trackCamera ) {
				if ( _debugDrawProcess.sprite is flash.display.Sprite ) {
					var flashSprite:flash.display.Sprite = flash.display.Sprite(_debugDrawProcess.sprite);
					flashSprite.transform.matrix = matrix;
				}
			}
			
			oldCameraRect = cameraRect.clone();
			oldObjectX = objectX;
			oldObjectY = objectY;
		}
	}
}