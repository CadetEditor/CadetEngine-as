// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.core
{
	import cadet.events.ComponentContainerEvent;
	import cadet.events.ComponentEvent;
	import cadet.util.ComponentReferenceUtil;
	
	import core.data.ArrayCollection;
	import core.events.ArrayCollectionChangeKind;
	import core.events.ArrayCollectionEvent;
	
	[Event( type="cadet.events.ComponentContainerEvent", name="childAdded" )]
	[Event( type="cadet.events.ComponentContainerEvent", name="childRemoved" )]
	
	/**
	 * Abstract. This class is not designed to be directly instantiated.
	 * @author Jonathan
	 * 
	 */	
	public class ComponentContainer extends Component implements IComponent, IComponentContainer
	{
		protected var _children	:ArrayCollection;
		
		private var childRemovedEvent	:ComponentContainerEvent;
		private var childAddedEvent		:ComponentContainerEvent;
		
		
		public function ComponentContainer( name:String = "ComponentContainer" )
		{
			super( name );
			init();
		}
		
		private function init():void
		{
			children = new ArrayCollection();
			
			childRemovedEvent = new ComponentContainerEvent( ComponentContainerEvent.CHILD_REMOVED, null );
			childAddedEvent = new ComponentContainerEvent( ComponentContainerEvent.CHILD_ADDED, null );
		}
		
		protected function addChildReference( type:Class, property:String ):void
		{
			ComponentReferenceUtil.addReferenceByType(this, type, this, property);
		}
		
		override public function dispose():void
		{
			var L:int = _children.length;
			while ( L > 0 )
			{
				_children[0].dispose();
				_children.removeItemAt(0);
				L--;
			}
			previousChildSource = null;
			super.dispose();
		}
				
		override protected function addedToScene():void
		{
			for each ( var child:IComponent in _children )
			{
				child.scene = _scene;
			}
		}
		
		override protected function removedFromScene():void
		{
			for each ( var child:IComponent in _children )
			{
				child.scene = null;
			}
		}
		
		override public function validateNow():void
		{
			super.validateNow();
			for each ( var child:IComponent in _children )
			{
				child.validateNow();
			}
		}
		
		private var previousChildSource:Array = [];
		protected function childrenChangeHandler( event:ArrayCollectionEvent ):void
		{
			switch ( event.kind )
			{
				case ArrayCollectionChangeKind.ADD :
					childAdded( IComponent(event.item), event.index );
					break;
				case ArrayCollectionChangeKind.REMOVE :
					childRemoved( IComponent(event.item) );
					break;
				case ArrayCollectionChangeKind.RESET :
					for each ( var child:IComponent in event.item )
					{
						childRemoved( child );
					}
					for ( var i:uint = 0; i < _children.length; i ++ )
					{
						child = _children[i];
						childAdded(child, i);
					}
/*					for each ( child in _children )
					{
						childAdded( child, event.index );
					}*/
					
					break;
			}
			
			previousChildSource = children.source.slice();
		}
		
		protected function childAdded( child:IComponent, index:uint ):void
		{
			child.index = index;
			child.addEventListener(ComponentEvent.ADDED_TO_PARENT, childEventHandler);
			child.addEventListener(ComponentEvent.REMOVED_FROM_PARENT, childEventHandler);
			child.addEventListener(ComponentEvent.ADDED_TO_SCENE, childEventHandler);
			child.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, childEventHandler);
			child.parentComponent = this;
			child.scene = _scene;
			
			
			childAddedEvent.child = child;
			dispatchEvent( childAddedEvent );
		}
		
		protected function childRemoved( child:IComponent ):void
		{
			child.parentComponent = null;
			child.scene = null;
			
			child.removeEventListener(ComponentEvent.ADDED_TO_PARENT, childEventHandler);
			child.removeEventListener(ComponentEvent.REMOVED_FROM_PARENT, childEventHandler);
			child.removeEventListener(ComponentEvent.ADDED_TO_SCENE, childEventHandler);
			child.removeEventListener(ComponentEvent.REMOVED_FROM_SCENE, childEventHandler);
			
			childRemovedEvent.child = child;
			dispatchEvent( childRemovedEvent );
		}
		
		private function childEventHandler( event:ComponentEvent ):void
		{
			dispatchEvent( event );
		}
		
		[Serializable][Inspectable]
		public function set children( value:ArrayCollection ):void
		{
			if ( _children )
			{
				_children.source = [];
				_children.removeEventListener(ArrayCollectionEvent.CHANGE, childrenChangeHandler);
			}
			_children = value;
			if ( _children )
			{
				_children.addEventListener(ArrayCollectionEvent.CHANGE, childrenChangeHandler);
				
				for ( var i:uint = 0; i < _children.length; i ++ )
				{
					var child:IComponent = _children[i];
					childAdded(child, i);
				}
/*				for each ( var child:IComponent in _children )
				{
					childAdded(child);
				}*/
			}
		}
		public function get children():ArrayCollection { return _children; }
	}
}