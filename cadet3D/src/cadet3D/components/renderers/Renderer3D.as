// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.components.renderers
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.utils.Dictionary;
	
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.lights.DirectionalLight;
	import away3d.materials.MaterialBase;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.ShadowMapMethodBase;
	import away3d.materials.methods.SoftShadowMapMethod;
	
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.events.ComponentEvent;
	import cadet.events.RendererEvent;
	import cadet.util.ComponentUtil;
	
	import cadet3D.components.cameras.CameraComponent;
	import cadet3D.components.core.ObjectContainer3DComponent;
	import cadet3D.components.lights.AbstractLightComponent;
	import cadet3D.components.materials.AbstractMaterialComponent;
	import cadet3D.events.Renderer3DEvent;
	
	[Event(name="preRender", type="cadet3D.events.Renderer3DEvent")]
	[Event(name="postRender", type="cadet3D.events.Renderer3DEvent")]
	public class Renderer3D extends Component implements IRenderer3D
	{
		private var _view3D						:View3D;
		private var lightPicker					:StaticLightPicker;
		private var lights						:Array;
		private var _cameraComponent			:CameraComponent;
		private var _rootContainer				:ObjectContainer3D;
		private var _materials					:Vector.<MaterialBase>;
		private var object3DComponentTable		:Dictionary;
		private var _shadowMapMethod			:ShadowMapMethodBase;
		
		private var preRenderEvent				:Renderer3DEvent;
		private var postRenderEvent				:Renderer3DEvent;
		
		private var _enabled					:Boolean;
		private var _initialised				:Boolean;
		private var _parent						:DisplayObjectContainer;
		
		public function Renderer3D()
		{
			_view3D = new View3D();
			_view3D.antiAlias = 2;
			
			_materials = new Vector.<MaterialBase>();
			object3DComponentTable = new Dictionary();
			
			preRenderEvent = new Renderer3DEvent( Renderer3DEvent.PRE_RENDER );
			postRenderEvent = new Renderer3DEvent( Renderer3DEvent.POST_RENDER );
			
			// Away3D 4 doesn't provide a way of accessing a top-level object container
			// (The Scene3D class isn't an ObjectContainer3D).
			// We need access to a top-level container to be able to do things like
			// registering for global mouse events bubbling up.
			// That's what this root container is for, and we add all entities to this
			// rather than the scene.
			_rootContainer = new ObjectContainer3D();
			_view3D.scene.addChild(_rootContainer);
			
			lights = [];
			lightPicker = new StaticLightPicker(lights);
		}
		
		public function enable(parent:DisplayObjectContainer, depth:int = -1):void
		{
			_parent = parent;
			
			if ( depth > -1 )	parent.addChildAt(viewport, depth);
			else				parent.addChild(viewport);
			
			_enabled = true;
			_initialised = true;
			
			dispatchEvent(new RendererEvent(RendererEvent.INITIALISED));
		}
		public function disable(parent:DisplayObjectContainer):void
		{
			_enabled = false;
			parent.removeChild(viewport);
		}
		
		override public function dispose():void
		{
			_view3D.dispose();
			_view3D = null;
			
			scene.removeEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedToSceneHandler);
			scene.removeEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedFromSceneHandler);
			
			lightPicker = null;
			lights = null;
			
			super.dispose();
		}
		
		public function getComponentForObject3D( object3D:ObjectContainer3D ):ObjectContainer3DComponent
		{
			return object3DComponentTable[object3D];
		}
		
		[Serializable]
		public function set cameraComponent( value:CameraComponent ):void
		{
			_cameraComponent = value;
			if ( _cameraComponent )
			{
				_view3D.camera = _cameraComponent.camera;
			}
			else
			{
				_view3D.camera = new Camera3D();
				//_view3D.camera.pivotPoint = new Vector3D( -_view3D.camera.position.x, -_view3D.camera.position.y, -_view3D.camera.position.z );
			}
		}
		
		public function get cameraComponent():CameraComponent
		{
			return _cameraComponent;
		}
		
		override public function validateNow():void
		{
			if ( _view3D.stage == null ) return;
			dispatchEvent( preRenderEvent );
			_view3D.render();
			dispatchEvent( postRenderEvent );
			super.validateNow();
		}
		
		public function get view3D():View3D
		{
			return _view3D;
		}
		
		public function get rootContainer():ObjectContainer3D
		{
			return _rootContainer;
		}
		
		public function get viewport():Sprite
		{
			return _view3D;
		}
		
		public function set viewportWidth(value:Number):void
		{
			_view3D.width = value;
		}
		
		public function get viewportWidth():Number
		{
			return _view3D.width
		}
		
		public function set viewportHeight(value:Number):void
		{
			_view3D.height = value;
		}
		
		public function get viewportHeight():Number
		{
			return _view3D.height;
		}
		
		public function get mouseX():Number
		{
			return _view3D.mouseX;
		}
		public function get mouseY():Number
		{
			return _view3D.mouseY;
		}
		
		override protected function addedToScene():void
		{
			scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedToSceneHandler);
			scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedFromSceneHandler);
			
			var allEntityComponents:Vector.<IComponent> = ComponentUtil.getChildrenOfType( scene, ObjectContainer3DComponent, true );
			for each ( var entityComponent:ObjectContainer3DComponent in allEntityComponents )
			{
				addObject3DComponent( entityComponent );
			}
			
			var allLightComponents:Vector.<IComponent> = ComponentUtil.getChildrenOfType( scene, AbstractLightComponent, true );
			for each ( var lightComponent:AbstractLightComponent in allLightComponents )
			{
				addLightComponent( lightComponent );
			}
			
			var allMaterialComponents:Vector.<IComponent> = ComponentUtil.getChildrenOfType( scene, AbstractMaterialComponent, true );
			for each ( var materialComponent:AbstractMaterialComponent in allMaterialComponents )
			{
				addMaterialComponent( materialComponent );
			}
			
			if ( _cameraComponent == null )
			{
				cameraComponent = ComponentUtil.getChildOfType( scene, CameraComponent, true );
			}
		}
		
		override protected function removedFromScene():void
		{
			if ( lightPicker )
			{
				lightPicker.lights = lights = [];
			}
			
			for each ( var material:MaterialBase in _materials )
			{
				material.lightPicker = null;
			}
			_materials = new Vector.<MaterialBase>();
		}
		
		private function componentAddedToSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is ObjectContainer3DComponent )
			{
				addObject3DComponent( ObjectContainer3DComponent( event.component ) )
			}
			if ( event.component is AbstractLightComponent )
			{
				addLightComponent( AbstractLightComponent( event.component ) );
			}
			if ( event.component is AbstractMaterialComponent )
			{
				addMaterialComponent( AbstractMaterialComponent( event.component ) );
			}
			
			if ( _cameraComponent == null && event.component is CameraComponent )
			{
				cameraComponent = CameraComponent(event.component);
			}
		}
		
		private function componentRemovedFromSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is ObjectContainer3DComponent )
			{
				removeObject3DComponent( ObjectContainer3DComponent( event.component ) );
			}
			if ( event.component is AbstractLightComponent )
			{
				removeLightComponent( AbstractLightComponent( event.component ) );
			}
			if ( event.component is AbstractMaterialComponent )
			{
				removeMaterialComponent( AbstractMaterialComponent( event.component ) );
			}
			if ( event.component == _cameraComponent )
			{
				cameraComponent = null;
			}
		}
		
		private function addObject3DComponent( entityComponent:ObjectContainer3DComponent ):void
		{
			object3DComponentTable[entityComponent.object3D] = entityComponent;
			if ( entityComponent.parentComponent == _scene )
			{
				_rootContainer.addChild(entityComponent.object3D);
			}
		}
		
		private function removeObject3DComponent( entityComponent:ObjectContainer3DComponent ):void
		{
			delete object3DComponentTable[entityComponent.object3D];
			if ( entityComponent.object3D.parent == _rootContainer )
			{
				_rootContainer.removeChild(entityComponent.object3D);
			}
		}
		
		private function addLightComponent( lightComponent:AbstractLightComponent ):void
		{
			lights.push(lightComponent.light);
			lightPicker.lights = lights.slice();
			
			if ( _shadowMapMethod == null && lightComponent.light is DirectionalLight )
			{
				_shadowMapMethod = new SoftShadowMapMethod(DirectionalLight(lightComponent.light));
				for each ( var material:MaterialBase in _materials )
				{
					if ( material is SinglePassMaterialBase ) {
						SinglePassMaterialBase(material).shadowMethod = _shadowMapMethod;
					}
				}
			}
		}
		
		private function removeLightComponent( lightComponent:AbstractLightComponent ):void
		{
			lights.splice(lights.indexOf(lightComponent.light));
			lightPicker.lights = lights;
			
			if ( _shadowMapMethod && _shadowMapMethod.castingLight == lightComponent.light )
			{
				for each ( var material:MaterialBase in _materials )
				{
					if ( material is SinglePassMaterialBase ) {
						SinglePassMaterialBase(material).shadowMethod = null;
					}
				}
				_shadowMapMethod.dispose();
			}
		}
		
		private function addMaterialComponent( materialComponent:AbstractMaterialComponent ):void
		{
			materialComponent.material.lightPicker = lightPicker;
			_materials.push(materialComponent.material);
			
			if ( _shadowMapMethod )
			{
				materialComponent.material.shadowMethod = _shadowMapMethod;
			}
		}
		
		private function removeMaterialComponent( materialComponent:AbstractMaterialComponent ):void
		{
			//materialComponent.material.lightPicker = null;
			_materials.splice(_materials.indexOf(materialComponent.material), 1);
		}
		
		public function getNativeStage():flash.display.Stage
		{
			return _parent.stage;
		}
		
		public function get initialised():Boolean
		{
			return _initialised;
		}
	}
}