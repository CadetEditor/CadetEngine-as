// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Inspectable Priority range 0-49

package cadet.core
{
	import flash.events.EventDispatcher;
	
	import cadet.events.ComponentEvent;
	import cadet.events.InvalidationEvent;
	import cadet.util.ComponentReferenceUtil;
	
	import flox.core.events.PropertyChangeEvent;
	
	[Event( type="cadet.events.ComponentEvent", name="addedToParent" )]
	[Event( type="cadet.events.ComponentEvent", name="removedFromParent" )]
	[Event( type="cadet.events.ComponentEvent", name="addedToScene" )]
	[Event( type="cadet.events.ComponentEvent", name="removedFromScene" )]
	[Event( type="cadet.events.InvalidationEvent", name="invalidate" )]
	
	/**
	 * Abstract. This class is not designed to be directly instantiated. 
	 * @author Jonathan
	 * 
	 */	
	public class Component extends EventDispatcher implements IComponent
	{
		//public static const INDEX:String = "index";
		
		protected var _name					:String;
		protected var _index				:int = -1;
		
		protected var _scene				:CadetScene;
		protected var _parentComponent		:IComponentContainer;
		
		protected var _templateID			:String;
		protected var _exportTemplateID		:String;
		
		
		private var addedToSceneEvent		:ComponentEvent;
		private var removedFromSceneEvent	:ComponentEvent;
		private var addedToParentEvent		:ComponentEvent;
		private var removedFromParentEvent	:ComponentEvent;
		
		protected var _invalidationTable	:Object;
		private var invalidationEvent		:InvalidationEvent;
		
		
		public function Component()
		{
			// Delegate work to init() function to gain
			// performance increase from JIT compilation (which ignores constructors).
			init();
		}
		
		private function init():void
		{
			// Create some event classes that can be re-used.
			addedToSceneEvent = new ComponentEvent( ComponentEvent.ADDED_TO_SCENE, this );
			removedFromSceneEvent = new ComponentEvent( ComponentEvent.REMOVED_FROM_SCENE, this );
			addedToParentEvent = new ComponentEvent( ComponentEvent.ADDED_TO_PARENT, this );
			removedFromParentEvent = new ComponentEvent( ComponentEvent.REMOVED_FROM_PARENT, this );
			
			_invalidationTable = {};
			invalidationEvent = new InvalidationEvent( InvalidationEvent.INVALIDATE );
			invalidate("*");
			
			name = "Component";
		}
		
		public function dispose():void
		{
			_templateID = null;
			_exportTemplateID = null;
		}
		
		protected function addSiblingReference( type:Class, property:String ):void
		{
			ComponentReferenceUtil.addReferenceByType(_parentComponent, type, this, property);
		}
		
		protected function addSceneReference( type:Class, property:String ):void
		{
			ComponentReferenceUtil.addReferenceByType(_scene, type, this, property);
		}
		
		public function set parentComponent(value:IComponentContainer):void
		{
			if ( value == _parentComponent ) return;
			
			if ( _parentComponent )
			{
				removedFromParent();
				ComponentReferenceUtil.removeAllReferencesForHost(this);
				dispatchEvent( removedFromParentEvent );
			}
			_parentComponent = value;
			if ( _parentComponent )
			{
				addedToParent();
				
				invalidate("*");
				dispatchEvent( addedToParentEvent );
			}
		}
		public function get parentComponent():IComponentContainer { return _parentComponent; }
		
		public function set scene( value:CadetScene ):void
		{
			if ( value == _scene ) return;
			
			if ( _scene )
			{
				removedFromScene();
				ComponentReferenceUtil.removeAllReferencesForHost(this);
				dispatchEvent( removedFromSceneEvent );
			}
			_scene = value;
			if ( _scene )
			{
				addedToScene();
				invalidate("*");
				dispatchEvent( addedToSceneEvent );
			}
		}
		public function get scene():CadetScene { return _scene; }
		
		public function set index( value:int ):void
		{
			_index = value;
		}
		public function get index():int
		{
			return _index;
		}
		
		[Serializable][Inspectable( label="Name", priority="0" )]
		public function set name( value:String ):void
		{
			_name = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_name", null, _name ) );
		}
		public function get name():String { return _name; }
		
		[Serializable]
		public function set exportTemplateID( value:String ):void
		{
			_exportTemplateID = value;
		}
		public function get exportTemplateID():String { return _exportTemplateID; }
		
		[Serializable]
		public function set templateID( value:String ):void
		{
			_templateID = value;
		}
		public function get templateID():String { return _templateID; }
		
		
		// Invalidation methods
		public function invalidate( invalidationType:String ):void
		{
			//if ( _invalidationTable[invalidationType] ) return;
			_invalidationTable[invalidationType] = true;
			invalidationEvent.invalidationType = invalidationType;
			dispatchEvent( invalidationEvent );
		}
		
		public function validateNow():void
		{
/*			if ( isInvalid(INDEX) )
			{
				validateIndex();
			}*/
			
			validate();
			_invalidationTable = {};
		}
		
		private function validateIndex():void
		{
			if (parentComponent) {
				index = parentComponent.children.getItemIndex(this);
			}
		}
		
		protected function validate():void
		{
			
		}
		
		public function isInvalid(type:String):Boolean
		{
			if ( _invalidationTable["*"] ) return true;
			if ( type == "*" )
			{
				for each ( var val:String in _invalidationTable )
				{
					return true;
				}
			}
			return _invalidationTable[type] == true;
		}
		
		public function get invalidationTable():Object { return _invalidationTable; }
		
		// Virtual methods
		protected function addedToParent():void {}
		protected function removedFromParent():void {}
		protected function addedToScene():void {}
		protected function removedFromScene():void {}
	}
}