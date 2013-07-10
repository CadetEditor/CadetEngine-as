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

package cadet2D.components.renderers
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.events.ComponentEvent;
	import cadet.events.RendererEvent;
	import cadet.events.ValidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.skins.IRenderable;
	import cadet2D.overlays.Overlay;
	import cadet2D.util.RenderablesUtil;
	
	import core.app.util.AsynchronousUtil;
	
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	[Event( type="cadet.events.RendererEvent", name="initialised" )]
	public class Renderer2D extends Component implements IRenderer2D
	{
		// Properties
		protected var _viewportWidth				:Number;
		protected var _viewportHeight				:Number;
		
		// Display Hierachy
		protected var _viewport						:DisplayObjectContainer;
//		protected var _mask							:flash.display.Shape;
		protected var _worldContainer				:Sprite;
		protected var _viewportOverlayContainer		:Sprite;
			
		// Misc
		protected var skinTable				:Dictionary; //These two...
		//protected var displayObjectTable	:Dictionary; //...perform the same function?
		protected var displayListVector		:Vector.<IRenderable>;
		protected var identityMatrix		:Matrix;
		
		private var star					:Starling;
		
		private var _parent					:DisplayObjectContainer;
		private var _nativeParent			:flash.display.DisplayObject; // Required for validateViewport()
		private var _nativeStage			:Stage;
		
		private var _mouseX					:Number;
		private var _mouseY					:Number;

		private var _viewportX				:Number = 0;
		private var _viewportY				:Number = 0;
		
		private var _enabled				:Boolean = false; 
		private var _initialised 			:Boolean = false;
		
		private var overlaysTable			:Dictionary;
		private var _backgroundColor		:uint = 0x303030;
		
		public const BASELINE				:String = "baseline";
		public const BASELINECONSTRAINED	:String = "baselineConstrained";
		
		public var defaultProfile			:String = BASELINE;
		
		private var _depthSort				:Boolean = false;
		
		public function Renderer2D( depthSort:Boolean = false )
		{
			_depthSort = depthSort;
			
			name = "Starling Renderer";
			
			reset();
		}
		
		// When adding a Starling renderer to a native scene where a reference to the nativeParent's transform is required.
		public function enable(nativeParent:flash.display.DisplayObject):void
		{
			_nativeParent = nativeParent;
			_nativeStage = _nativeParent.stage;
			
			if (_enabled) return;
			
			_enabled = true;
			
			_viewportWidth = _nativeStage.stageWidth;
			_viewportHeight = _nativeStage.stageHeight;
			
			if (!Starling.current) {
				star = new Starling( Sprite, _nativeStage, null, null, "auto", defaultProfile );
				star.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreatedHandler);
				star.antiAliasing = 1;
				star.start();	// TouchEvents require start() to be called...
			} else {
				star = Starling.current;
				AsynchronousUtil.callLater(init);
			}
			
			invalidate( RendererInvalidationTypes.VIEWPORT );
		}
		
		// When we know this isn't the only Starling instance and we want to render into a specific starling.display.DisplayObjectContainer
		public function enableToExisting(parent:DisplayObjectContainer):void
		{
			star = Starling.current;
			_parent = parent;
			_nativeStage = star.nativeStage;
			
			if (_enabled) return;
			
			_enabled = true;
			
			_viewportWidth = _parent.stage.stageWidth;
			_viewportHeight = _parent.stage.stageHeight;
			
			AsynchronousUtil.callLater(init);
			
			invalidate( RendererInvalidationTypes.VIEWPORT );
		}
		
		public function disable():void
		{
			_enabled = false;
			_initialised = false;
			
			_viewport.stage.removeEventListener(TouchEvent.TOUCH, onTouchHandler);
			
			_viewport.removeChildren();
		}

		private function onTouchHandler(e:TouchEvent):void
		{
			var dispObj:starling.display.DisplayObject = starling.display.DisplayObject(_viewport.stage);
			var touches:Vector.<Touch> = e.getTouches(dispObj);
			
			for each (var touch:Touch in touches)
			{
				var location:Point = touch.getLocation(dispObj);
				_mouseX = location.x;
				_mouseY = location.y;
				
				var local:Point = _viewport.globalToLocal(location);
				break;
			}
		}
		
		private function onRootCreatedHandler( event:starling.events.Event ):void
		{	
			init();
		}
		
		private function reset():void
		{
			identityMatrix = new Matrix();
			skinTable = new Dictionary();
			//displayObjectTable = new Dictionary();
			displayListVector = new Vector.<IRenderable>();
			overlaysTable = new Dictionary();
		}
		
		private function init():void
		{
			reset();
			
			_initialised = true;
			
			if ( _parent ) 	_viewport = _parent;
			else 			_viewport = DisplayObjectContainer(star.root);
			
			_viewport.stage.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			
			_worldContainer = new Sprite();
			_viewport.addChild(_worldContainer);
			
			_viewportOverlayContainer = new Sprite();
			_viewport.addChild(_viewportOverlayContainer);
			
			addRenderables();
			addOverlays();
			
			dispatchEvent(new RendererEvent(RendererEvent.INITIALISED));
			
			invalidate(RendererInvalidationTypes.VIEWPORT);			
		}
		
		[Serializable][Inspectable( priority="50" )]
		public function set depthSort( value:Boolean ):void
		{
			_depthSort = value;
			//dispatchEvent( new PropertyChangeEvent( "propertyChange_name", null, _name ) );
		}
		public function get depthSort():Boolean { return _depthSort; }
		
		[Inspectable]//[Serializable]
		public function set viewportWidth( value:Number ):void
		{
			if ( _viewportWidth == value ) return;
			
			_viewportWidth = value;
			invalidate(RendererInvalidationTypes.VIEWPORT);
		}
		public function get viewportWidth():Number { return _viewportWidth; }
		
		[Inspectable]//[Serializable]
		public function set viewportHeight( value:Number ):void
		{
			if ( _viewportHeight == value ) return;
			
			_viewportHeight = value;
			invalidate(RendererInvalidationTypes.VIEWPORT);
		}
		public function get viewportHeight():Number { return _viewportHeight; }
		
		public function addToJuggler( object:IAnimatable ):void
		{
			Starling.juggler.add( object );
		}
		
		public function removeFromJuggler( object:IAnimatable ):void
		{
			Starling.juggler.remove( object );
		}
		
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
//			if (!_nativeStage) return;
			if (!_parent && !_nativeParent) return;
			
			var pt:Point;
			if ( _parent )				pt = _parent.localToGlobal(new Point(0,0));
			else if ( _nativeParent) 	pt = _nativeParent.localToGlobal(new Point(0,0));
			
			_viewportX = pt.x;
			_viewportY = pt.y;
			
			star.stage.stageWidth = _viewportWidth;
			star.stage.stageHeight = _viewportHeight;
			//star.stage.color = _backgroundColor;
			
			var viewportRect:Rectangle = new Rectangle(_viewportX, _viewportY, _viewportWidth, _viewportHeight);
			
			//trace("Starling stage: x "+_parent.stage.x+" y "+_parent.stage.y+ " w "+_parent.stage.stageWidth+" h "+_parent.stage.stageHeight+" viewportRect "+viewportRect);
		
			star.viewPort = viewportRect;
		}
		
		private function validateOverlays():void
		{
			for ( var key:Object in overlaysTable ) {
				var overlay:Overlay = Overlay(key);
				overlay.validateNow();
			}
		}
		
		override protected function addedToScene():void
		{
			scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedToSceneHandler);
			scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedFromSceneHandler);
		}
		
		private function addRenderables():void
		{
			var allRenderables:Vector.<IComponent> = ComponentUtil.getChildrenOfType( scene, IRenderable, true );
			for each ( var renderable:IRenderable in allRenderables )
			{
				addRenderable( renderable );
			}
		}
		
	/*	private function removeSkins():void
		{
			var allSkins:Vector.<IComponent> = ComponentUtil.getChildrenOfType( scene, IRenderable, true );
			for each ( var skin:IRenderable in allSkins )
			{
				removeSkin( skin );
			}
		}*/
		
		private function componentAddedToSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is IRenderable == false ) return;
			addRenderable( IRenderable( event.component ) );
		}
		
		private function componentRemovedFromSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is IRenderable == false ) return;
			removeRenderable( IRenderable( event.component ) );
		}
		
		private function addRenderable( renderable:IRenderable ):void
		{
			addRenderableToDisplayList(renderable);
			
			var displayObject:starling.display.DisplayObject = renderable.displayObject;
			
			renderable.invalidate("*");
			renderable.validateNow();
			
			renderable.addEventListener(ValidationEvent.INVALIDATE, invalidateRenderableHandler);
			
			skinTable[displayObject] = renderable;
			//displayObjectTable[displayObject] = renderable;
		}
		
		private function removeRenderable( renderable:IRenderable ):void
		{
			var displayObject:starling.display.DisplayObject = renderable.displayObject;
			
			removeRenderableFromDisplayList(renderable);
			renderable.removeEventListener(ValidationEvent.INVALIDATE, invalidateRenderableHandler);
			
			delete skinTable[displayObject];
			//delete displayObjectTable[displayObject];
		}
		
		private function invalidateRenderableHandler( event:ValidationEvent ):void
		{
//			var renderable:IRenderable = IRenderable(event.target);
//			var displayObject:starling.display.DisplayObject = AbstractSkin2D(renderable).displayObject;
			
/*			if ( displayObject.parent == null )
			{
				addRenderableToDisplayList(skin);
			}*/
			
			// The the layer index, or containerID on a ISkin2D has changed, then re-add them
			// to the displaylist at the appropriate place
/*			if ( event.invalidationType == "layer" || event.invalidationType == "container" )
			{
				addRenderableToDisplayList(skin);
			}*/
		}
		
		private function addRenderableToDisplayList( renderable:IRenderable ):void
		{
			if (!_worldContainer) return;
		
			var displayObject:starling.display.DisplayObject = renderable.displayObject;
			
			if (depthSort) {
				var indexStr:String = renderable.indexStr;
				
				displayListVector.push(renderable);
				//displayListVector.sortOn("indexStr");
				displayListVector.sort(RenderablesUtil.sortSkinsById);
				
				var index:int = displayListVector.indexOf(renderable);
				
				//trace("ADD SKIN INDEX "+indexStr+" at index "+index+" dlArray "+displayListVector);								
				_worldContainer.addChildAt( displayObject, index );
			} else {
				_worldContainer.addChild( displayObject );
			}
		}
		
		private function removeRenderableFromDisplayList( renderable:IRenderable ):void
		{
			//var indexStr:String = indexStrTable[skin];
			var index:int = displayListVector.indexOf(renderable);//indexStr);
			displayListVector.splice(index, 1);
			
			//trace("REMOVE SKIN INDEX "+skin.indexStr+" at index "+index+" dlArray "+displayListVector);
			
			var displayObject:starling.display.DisplayObject = renderable.displayObject;
			
			if ( displayObject.parent ) {
				displayObject.parent.removeChild(displayObject);
			}
		}
		
		override protected function removedFromScene():void
		{
			super.removedFromScene();
		
			while ( _worldContainer.numChildren > 0 )
			{
				var displayObject:starling.display.DisplayObject = _worldContainer.getChildAt(0);
				var skin:IRenderable = skinTable[displayObject];
				_worldContainer.removeChildAt(0);
				delete skinTable[displayObject];
			}
		}
		
		
		
		public function addOverlay( overlay:Overlay, layerIndex:uint = 0 ):void
		{
			if (!_viewportOverlayContainer) return;
			
			overlaysTable[overlay] = layerIndex;
			
			_viewportOverlayContainer.addChild( overlay );
		}
		
		public function removeOverlay( overlay:Overlay ):void
		{
			var layerIndex:uint = overlaysTable[overlay];
			
			if ( _viewportOverlayContainer.contains( overlay ) ) {
				_viewportOverlayContainer.removeChild( overlay );
				delete overlaysTable[overlay];
			}
		}
		
		private function addOverlays():void
		{
			for ( var key:Object in overlaysTable ) {
				var overlay:Overlay = Overlay(key);
				addOverlay(overlay);
			}			
		}
		private function removeOverlays():void
		{
			for ( var key:Object in overlaysTable ) {
				var overlay:Overlay = Overlay(key);
				removeOverlay(overlay);
			}
		}
		
		public function getOverlayOfType( type:Class ):starling.display.DisplayObject
		{
			for each ( var overlay:Overlay in overlaysTable ) {
				if ( overlay is type ) {
					return overlay;
				}
			}
			
			return null;
		}

		
		public function get viewport():DisplayObjectContainer { return _viewport; }
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
			if (!_worldContainer) return null;
			
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
			_worldContainer.transformationMatrix = m;
		}
		
		public function getNativeStage():flash.display.Stage
		{
			return _nativeStage;
		}
		
		public function getNativeParent():flash.display.DisplayObject
		{
			return _nativeParent;
		}
		
		public function get initialised():Boolean
		{
			return _initialised;
		}
		
		public function get viewportX():Number { return _viewportX; }
		public function get viewportY():Number { return _viewportY; }
		
		//public function getWorldToViewportMatrix():Matrix { return identityMatrix.clone(); }
		//public function getViewportToWorldMatrix():Matrix { return identityMatrix.clone(); }
	}
}