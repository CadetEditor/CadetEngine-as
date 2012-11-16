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
	import flash.events.IEventDispatcher;

	[Event( type="cadet.events.ComponentEvent", name="addedToParent" )]
	[Event( type="cadet.events.ComponentEvent", name="removedFromParent" )]
	[Event( type="cadet.events.ComponentEvent", name="addedToScene" )]
	[Event( type="cadet.events.ComponentEvent", name="removedFromScene" )]
	
	public interface IComponent extends IEventDispatcher
	{
		function set name( value:String ):void
		function get name():String
		
		function set parentComponent( value:IComponentContainer ):void
		function get parentComponent():IComponentContainer;
		
		function set scene( value:CadetScene ):void
		function get scene():CadetScene;
		
		function set exportTemplateID( value:String ):void
		function get exportTemplateID():String
		function set templateID( value:String ):void
		function get templateID():String
			
		function invalidate( invalidationType:String ):void
		function validateNow():void
		
		function dispose():void;
	}
}