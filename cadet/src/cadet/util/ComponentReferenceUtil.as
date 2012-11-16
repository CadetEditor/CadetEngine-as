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
	import flash.utils.Dictionary;
	
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.events.ComponentContainerEvent;
	
	public class ComponentReferenceUtil
	{
		private static var hostTable	:Dictionary = new Dictionary();;
		
		public static function addReferenceByType( target:IComponentContainer, type:Class, host:IComponent, property:String ):void
		{
			var reference:Reference = new Reference( target, type, host, property );
			
			var references:Array = hostTable[host];
			if ( references == null )
			{
				hostTable[host] = references = [];
			}
			references[references.length] = reference;
		}
		
		public static function removeReferenceByType( target:IComponentContainer, type:Class, host:IComponent, property:String ):void
		{
			var references:Array = hostTable[host];
			if ( !references ) return;
			
			const L:int = references.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var reference:Reference = references[i];
				
				if ( reference.target != target ) continue;
				if ( reference.property != property ) continue;
				if ( reference.type != type ) continue;
				
				references.splice(i,1);
				return;
			}
		}
		
		public static function removeAllReferencesForHost( host:IComponent ):void
		{
			var references:Array = hostTable[host];
			if ( !references ) return;
			
			for each ( var reference:Reference in references )
			{
				reference.dispose();
			}
			
			hostTable[host] = null;
			delete hostTable[host];
		}
	}
}
import cadet.events.ComponentContainerEvent;
import cadet.core.IComponentContainer;
import cadet.core.IComponent;
import cadet.util.ComponentUtil;

internal class Reference
{
	public var type:Class;
	public var host:IComponent;
	public var property:String;
	public var target:IComponentContainer;
	
	
	public function Reference( target:IComponentContainer, type:Class, host:IComponent, property:String )
	{
		init( target, type, host, property );
	}
	
	public function init( target:IComponentContainer, type:Class, host:IComponent, property:String ):void
	{
		this.target = target;
		this.type = type;
		this.host = host
		this.property = property;
		
		target.addEventListener(ComponentContainerEvent.CHILD_ADDED, childAddedHandler);
		target.addEventListener(ComponentContainerEvent.CHILD_REMOVED, childRemovedHandler);
		
		var child:IComponent = ComponentUtil.getChildOfType(target, type);
		if ( child )
		{
			host[property] = child;
		}
	}
	
	public function dispose():void
	{
		target.removeEventListener(ComponentContainerEvent.CHILD_ADDED, childAddedHandler);
		target.removeEventListener(ComponentContainerEvent.CHILD_REMOVED, childRemovedHandler);
		
		target = null;
		host = null;
		type = null;
		property = null;
	}	
	
	private function childAddedHandler( event:ComponentContainerEvent ):void
	{
		if ( event.child is type )
		{
			host[property] = event.child;
		}
	}
	
	private function childRemovedHandler( event:ComponentContainerEvent ):void
	{
		if ( event.child is type )
		{
			host[property] = null;
		}
	}
}

