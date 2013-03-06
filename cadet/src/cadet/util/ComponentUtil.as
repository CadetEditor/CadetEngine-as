// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.util
{
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	public class ComponentUtil
	{
		static public function getChildByName( parent:IComponentContainer, name:String ):*
		{
			for each ( var component:IComponent in parent.children )
			{
				if ( component.name == name ) return component;
			}
			return null;
		}
		
		static public function getChildren( container:IComponentContainer, recursive:Boolean = false ):Vector.<IComponent>
		{
			var children:Vector.<IComponent> = new Vector.<IComponent>();
			var L:int = 0;
			for each ( var component:IComponent in container.children )
			{
				children[L++] = component;
				
				if ( recursive && component is IComponentContainer )
				{
					children = children.concat( getChildren(IComponentContainer(component), true ));
					L = children.length;
				}
			}
			return children;
		}
		
		static public function getChildWithExportTemplateID( container:IComponentContainer, exportTemplateID:String, recursive:Boolean = false ):*
		{
			for each ( var component:IComponent in container.children )
			{
				if ( component.exportTemplateID == exportTemplateID )
				{
					return component;
				}
				
				if ( recursive && component is IComponentContainer )
				{
					var result:IComponent = getChildWithExportTemplateID(IComponentContainer(component), exportTemplateID, true );
					if ( result )
					{
						return result;
					}
				}
			}
			return null;
		}
		
		static public function getChildOfType( container:IComponentContainer, type:Class, recursive:Boolean = false, excludedComponents:Vector.<IComponent> = null, excludedTypes:Vector.<Class> = null ):*
		{
			for each ( var component:IComponent in container.children )
			{
				if ( component is type )
				{
					var excluded:Boolean = isExcluded(component, excludedComponents, excludedTypes);
					if (!excluded) {
						return component;
					}
				}
				if ( recursive && component is IComponentContainer )
				{
					var result:IComponent = getChildOfType(IComponentContainer(component), type, true, excludedComponents, excludedTypes );
					if ( result )
					{
						return result;
					}
				}
			}
			return null;
		}
		
		static public function isExcluded(component:IComponent, excludedComponents:Vector.<IComponent> = null, excludedTypes:Vector.<Class> = null):Boolean
		{
			if (excludedComponents) {
				for ( var i:uint = 0; i < excludedComponents.length; i ++ ) {
					var child:IComponent = excludedComponents[i];
					if ( component == child ) {
						return true;
					}
				}
			}
			
			if (excludedTypes) {
				for ( i = 0; i < excludedTypes.length; i ++ ) {
					var type:Class = excludedTypes[i];
					if ( component is type ) {
						return true;
					}
				}
			}
			
			return false;
		}
		
		static public function getChildrenOfType( container:IComponentContainer, type:Class, recursive:Boolean = false ):Vector.<IComponent>
		{
			var children:Vector.<IComponent> = new Vector.<IComponent>();
			for each ( var component:IComponent in container.children )
			{
				if ( component is type )
				{
					children.push(component);
				}
				if ( recursive && component is IComponentContainer )
				{
					children = children.concat( getChildrenOfType(IComponentContainer(component), type, true ));
				}
			}
			return children;
		}
		
		
		static public function getUniqueName( baseName:String, parent:IComponentContainer ):String
		{
			var table:Object = {};
			for each ( var child:IComponent in parent.children )
			{
				table[child.name] = true;	
			}
			
			var uid:int = 0;
			while ( table[baseName+ "_" + uid] ) { uid++ }
			
			var newName:String = baseName + "_" + uid;
			return newName; 
		}
		
		static public function getComponentContainers( components:Array ):Vector.<IComponentContainer>
		{
			var containers:Vector.<IComponentContainer> = new Vector.<IComponentContainer>();
			for ( var i:int = 0; i < components.length; i++ )
			{
				var component:IComponent = IComponent( components[i] );
				if ( component is IComponentContainer )
				{
					containers.push(component);
				}
				else if ( component.parentComponent )
				{
					containers.push( component.parentComponent );
				}
			}
			return containers;
		}
	}
}