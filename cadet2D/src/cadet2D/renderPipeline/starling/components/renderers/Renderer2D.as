// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.renderPipeline.starling.components.renderers
{
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.events.ComponentEvent;
	import cadet.events.InvalidationEvent;
	import cadet.events.RendererEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.IRenderer2D;
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.overlays.Overlay;
	import cadet2D.renderPipeline.starling.components.skins.AbstractSkin2D;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	[Event( type="cadet.events.RendererEvent", name="initialised" )]
	public class Renderer2D extends Component implements IRenderer2D
	{		
		// Container ID's
		public static const WORLD_CONTAINER					:String = "worldContainer";
		public static const VIEWPORT_BACKGROUND_CONTAINER	:String = "viewportBackgroundContainer";
		public static const VIEWPORT_FOREGROUND_CONTAINER	:String = "viewportForegroundContainer";
		public static const VIEWPORT_OVERLAY_CONTAINER		:String = "viewportOverlayContainer";
		
		// Config consts
		public static const NUM_CONTAINER_LAYERS			:int = 8;
		public static const NUM_VIEWPORT_FOREGROUND_LAYERS	:int = 8;
		public static const NUM_VIEWPORT_BACKGROUND_LAYERS	:int = 8;
		public static const NUM_VIEWPORT_OVERLAY_LAYERS		:int = 3;
		
		// Properties
		protected var _viewportWidth				:Number;
		protected var _viewportHeight				:Number;
		
		// Display Hierachy
		protected var _viewport						:Sprite;
//		protected var _mask							:flash.display.Shape;
		protected var viewportBackgroundContainer	:Sprite;
		protected var _worldContainer				:Sprite;
		protected var viewportForegroundContainer	:Sprite;
		protected var viewportOverlayContainer		:Sprite;
		
		protected var viewportBackgroundLayers			:Array;	
		protected var worldContainerLayers				:Array;
		protected var viewportForegroundLayers			:Array;	
		protected var viewportOverlayLayers				:Array;
		
		// Misc
		protected var skinTable				:Dictionary;
		protected var displayObjectTable	:Dictionary;
		protected var identityMatrix		:Matrix;
		protected var layersTable			:Object;
		
		private var star					:Starling;
		
		private var _mouseX					:Number;
		private var _mouseY					:Number;
		
		private var _parent					:flash.display.DisplayObjectContainer;
		private var _viewportX				:Number = 0;
		private var _viewportY				:Number = 0;
		
		private var _enabled				:Boolean = false; 
		private var _initialised 			:Boolean = false;
		
		//private static var numInstances		:uint = 0;
		private var overlaysTable			:Dictionary;
		
		public function Renderer2D()
		{
			name = "Starling Renderer";
			viewportWidth = 800;
			viewportHeight = 600;	
			
			identityMatrix = new Matrix();
			skinTable = new Dictionary();
			displayObjectTable = new Dictionary();
			
			layersTable = {};
			overlaysTable = new Dictionary();
		}
		
		public function enable(parent:flash.display.DisplayObjectContainer, depth:int = -1):void
		{
			if (_enabled) return;
			
			_enabled = true;
			
			//trace("RENDERER2D ENABLE: parent x "+parent.x+" y "+parent.y);//+" numInstances "+numInstances);
			_parent = parent;
			
//			var pt:Point = _parent.localToGlobal(new Point(0,0));
//			//TODO: Should be viewRect?
//			viewportX = pt.x;
//			viewportY = pt.y;
			
			var viewportRect:Rectangle = null;//new Rectangle(_viewportX, _viewportY, _viewportWidth, _viewportHeight);
			
			//if (Starling.current)	Starling.current.dispose();
			if (star) star.dispose();
			
			star = new Starling( Sprite, parent.stage, viewportRect );//, parent.stage.stage3Ds[numInstances] );
			star.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreatedHandler);
			star.antiAliasing = 1;
			star.start();	// TouchEvents require start() to be called...
			
			//numInstances ++;
		}
		
		public function disable(parent:flash.display.DisplayObjectContainer):void
		{
			_enabled = false;
			_initialised = false;
			
			_viewport.stage.removeEventListener(TouchEvent.TOUCH, onTouchHandler);
			
			if (!star) return;
			
			star.stop();
			star.dispose();
			
			//if (Starling.current) Starling.current.dispose();
			
			star = null;
		}

		private function onTouchHandler(e:TouchEvent):void
		{
			//var dispObj:DisplayObject = DisplayObject(e.target);
			var dispObj:DisplayObject = DisplayObject(_viewport.stage);
			var touches:Vector.<Touch> = e.getTouches(dispObj);
			
			for each (var touch:Touch in touches)
			{
				var location:Point = touch.getLocation(dispObj);
				_mouseX = location.x //- _viewportX;
				_mouseY = location.y //- _viewportY;
				
				var local:Point = _viewport.globalToLocal(location);
				
				//trace("onTouch x "+_mouseX+" y "+_mouseY+" phase "+touch.phase);
				//trace("local x "+local.x+" y "+local.y);
				//trace("parent x "+_parent.x+" y "+_parent.y);
				break;
			}
		}
		
		private function onRootCreatedHandler( event:starling.events.Event ):void
		{
			_initialised = true;
			
			_viewport = Sprite(star.root);
			_viewport.stage.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			
			_worldContainer = new Sprite();
			_viewport.addChild(_worldContainer);
			
			viewportBackgroundContainer = new Sprite();
			_viewport.addChild(viewportBackgroundContainer);
			
			viewportBackgroundLayers = [];
			for ( var i:int = 0; i < NUM_VIEWPORT_BACKGROUND_LAYERS; i++ )
			{
				var layer:Sprite = new Sprite();
				viewportBackgroundLayers[i] = layer;
				viewportBackgroundContainer.addChild(layer);
			}
			
			_worldContainer = new Sprite();
			_viewport.addChild(_worldContainer);
			
			worldContainerLayers = [];
			for ( i = 0; i < NUM_CONTAINER_LAYERS; i++ )
			{
				layer = new Sprite();
				worldContainerLayers[i] = layer;
				_worldContainer.addChild(layer);
			}
			
			viewportForegroundContainer = new Sprite();
			_viewport.addChild(viewportForegroundContainer);
			
			viewportForegroundLayers = [];
			for ( i = 0; i < NUM_VIEWPORT_FOREGROUND_LAYERS; i++ )
			{
				layer = new Sprite();
				viewportForegroundLayers[i] = layer;
				viewportForegroundContainer.addChild(layer);
			}
			
			viewportOverlayContainer = new Sprite();
			_viewport.addChild(viewportOverlayContainer);
			
			viewportOverlayLayers = [];
			for ( i = 0; i < NUM_VIEWPORT_OVERLAY_LAYERS; i++ )
			{
				layer = new Sprite();
				viewportOverlayLayers[i] = layer;
				viewportOverlayContainer.addChild(layer);
			}
			
			layersTable[WORLD_CONTAINER] = worldContainerLayers;
			layersTable[VIEWPORT_BACKGROUND_CONTAINER] = viewportBackgroundLayers;
			layersTable[VIEWPORT_FOREGROUND_CONTAINER] = viewportForegroundLayers;
			layersTable[VIEWPORT_OVERLAY_CONTAINER] = viewportOverlayLayers;
			
			addSkins();
			
			dispatchEvent(new RendererEvent(RendererEvent.INITIALISED));
			
			invalidate(RendererInvalidationTypes.VIEWPORT);
		}
		
		public function set viewportX( value:Number ):void
		{
			_viewportX = value;
			invalidate(RendererInvalidationTypes.VIEWPORT);
		}
		public function get viewportX():Number
		{
			return _viewportX;
		}
		
//		public function set viewportY( value:Number ):void
//		{
//			_viewportY = value;
//			invalidate(VIEWPORT);
//		}
//		public function get viewportY():Number
//		{
//			return _viewportY;
//		}
		
		[Inspectable][Serializable]
		public function set viewportWidth( value:Number ):void
		{
			trace("set viewportWidth "+value);
			_viewportWidth = value;
			invalidate(RendererInvalidationTypes.VIEWPORT);
		}
		public function get viewportWidth():Number { return _viewportWidth; }
		
		[Inspectable][Serializable]
		public function set viewportHeight( value:Number ):void
		{
			trace("set viewportHeight "+value);
			_viewportHeight = value;
			invalidate(RendererInvalidationTypes.VIEWPORT);
		}
		public function get viewportHeight():Number { return _viewportHeight; }
		
		override public function validateNow():void
		{
			if ( isInvalid(RendererInvalidationTypes.VIEWPORT) ) {
				validateViewport();
			}
			
			//TODO: commented out for now as TouchEvents require start() to be used...
			//if (star)	star.nextFrame();
			
			if ( isInvalid(RendererInvalidationTypes.OVERLAYS) ) {
				delete invalidationTable[RendererInvalidationTypes.OVERLAYS];
				validateOverlays();
			}
			
			super.validateNow();
		}
		
		private function validateViewport():void
		{
			if (!_viewport) return;
			
			var pt:Point = _parent.localToGlobal(new Point(0,0));
			
			_viewportX = pt.x;
			_viewportY = pt.y;
			
//			_viewport.x = _viewportX;
//			_viewport.y = _viewportY;
			
			star.stage.stageWidth = _viewportWidth;
			star.stage.stageHeight = _viewportHeight;
			
			var viewportRect:Rectangle = new Rectangle(_viewportX, _viewportY, _viewportWidth, _viewportHeight);
			
			star.viewPort = viewportRect;
		}
		
		private function validateOverlays():void
		{
			for ( var key:Object in overlaysTable ) {
				var overlay:Overlay = Overlay(key);
				overlay.validateNow();
			}
		}
		
		public function getSkinForDisplayObject( displayObject:DisplayObject ):ISkin2D
		{
			return displayObjectTable[displayObject];
		}
		
		override protected function addedToScene():void
		{
			scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedToSceneHandler);
			scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedFromSceneHandler);
			
//			addSkins();
		}
		
		private function addSkins():void
		{
			var allSkins:Vector.<IComponent> = ComponentUtil.getChildrenOfType( scene, ISkin2D, true );
			for each ( var skin:ISkin2D in allSkins )
			{
				addSkin( skin );
			}
		}
		
		private function componentAddedToSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is ISkin2D == false ) return;
			addSkin( ISkin2D( event.component ) );
		}
		
		private function componentRemovedFromSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is ISkin2D == false ) return;
			removeSkin( ISkin2D( event.component ) );
		}
		
		private function addSkin( skin:ISkin2D ):void
		{
			// Could be a Flash Skin of type ISkin2D
			if (!(skin is AbstractSkin2D)) return;
			
			addSkinToDisplayList(skin);
			
			var displayObject:DisplayObject = AbstractSkin2D(skin).displayObjectContainer;
			
			skin.invalidate("*");
			skin.validateNow();
			
			skin.addEventListener(InvalidationEvent.INVALIDATE, invalidateSkinHandler);
			skinTable[displayObject] = skin;
			displayObjectTable[displayObject] = skin;
		}
		
		private function removeSkin( skin:ISkin2D ):void
		{
			// Could be a Flash Skin of type ISkin2D
			if (!(skin is AbstractSkin2D)) return;
			
			var displayObject:DisplayObject = AbstractSkin2D(skin).displayObjectContainer;
			
			removeSkinFromDisplayList(skin);
			skin.removeEventListener(InvalidationEvent.INVALIDATE, invalidateSkinHandler);
			delete skinTable[displayObject];
			delete displayObjectTable[displayObject];
		}
		
		private function invalidateSkinHandler( event:InvalidationEvent ):void
		{
			var skin:ISkin2D = ISkin2D(event.target);
			var displayObject:DisplayObject = AbstractSkin2D(skin).displayObjectContainer;
			
			if ( displayObject.parent == null )
			{
				addSkinToDisplayList(skin);
			}
			
			// The the layer index, or containerID on a ISkin2D has changed, then re-add them
			// to the displaylist at the appropritate place
			if ( event.invalidationType == "layer" || event.invalidationType == "container" )
			{
				addSkinToDisplayList(skin);
			}
		}
		
		private function addSkinToDisplayList( skin:ISkin2D ):void
		{
			var layers:Array = layersTable[skin.containerID];
			if ( !layers ) return;
			
			var parent:starling.display.DisplayObjectContainer = layers[skin.layerIndex];
			var displayObject:DisplayObject = AbstractSkin2D(skin).displayObjectContainer;
			
			parent.addChild( displayObject );
		}
		
		private function removeSkinFromDisplayList( skin:ISkin2D ):void
		{
			var displayObject:DisplayObject = AbstractSkin2D(skin).displayObjectContainer;
			
			if ( displayObject.parent )
			{
				displayObject.parent.removeChild(displayObject);
			}
		}
		
		
		
		override protected function removedFromScene():void
		{
			super.removedFromScene();
			
			for each ( var layer:Sprite in worldContainerLayers )
			{
				while ( layer.numChildren > 0 )
				{
					var displayObject:starling.display.DisplayObject = layer.getChildAt(0);
					var skin:ISkin2D = skinTable[displayObject];
					layer.removeChildAt(0);
					delete skinTable[displayObject];
				}
			}
		}
		
		
		
		public function addOverlay( overlay:Overlay, layerIndex:uint = 0 ):void
		{
			var layers:Array = layersTable[VIEWPORT_OVERLAY_CONTAINER];
			
			if (!layers) return;
			
			var parent:starling.display.DisplayObjectContainer = layers[layerIndex];
			
			overlaysTable[overlay] = layerIndex;
			
			parent.addChild( overlay );
		}
		
		public function removeOverlay( overlay:Overlay ):void
		{
			var layerIndex:uint = overlaysTable[overlay];
			
			var layers:Array = layersTable[VIEWPORT_OVERLAY_CONTAINER];
			
			var parent:starling.display.DisplayObjectContainer = layers[layerIndex];
			
			if ( parent.contains( overlay ) ) {
				parent.removeChild( overlay );
				delete overlaysTable[overlay];
			}
		}
		
		public function getOverlayOfType( type:Class ):DisplayObject
		{
			for each ( var overlay:DisplayObject in overlaysTable ) {
				if ( overlay is type ) {
					return overlay;
				}
			}
			
			return null;
		}
		
		
		
		public function get viewport():Sprite { return _viewport; }
		public function get worldContainer():Sprite { return _worldContainer; }
		
		public function get mouseX():Number
		{
			return _mouseX;
		}
		public function get mouseY():Number
		{
			return _mouseY;
		}
		
		public function worldToViewport( pt:Point ):Point
		{
			pt = _worldContainer.localToGlobal(pt);
			return _viewport.globalToLocal(pt);
		}
		
		public function viewportToWorld( pt:Point ):Point
		{
			if (!_viewport) return null;
			
			pt = _viewport.localToGlobal(pt);
			return _worldContainer.globalToLocal(pt);
		}
		
		public function setWorldContainerTransform( m:Matrix ):void
		{
			if (!_worldContainer) return;
			//_worldContainer.transform.matrix = m;
			_worldContainer.transformationMatrix = m;
		}
		
		//public function getWorldToViewportMatrix():Matrix { return identityMatrix.clone(); }
		//public function getViewportToWorldMatrix():Matrix { return identityMatrix.clone(); }
	}
}