// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.events
{
	import flash.events.Event;
	
	import cadet.core.IComponent;

	public class ComponentEvent extends Event
	{
		public static const ADDED_TO_PARENT		:String = "addedToParent";
		public static const REMOVED_FROM_PARENT	:String = "removedFromParent";
		
		public static const ADDED_TO_SCENE		:String = "addedToScene";
		public static const REMOVED_FROM_SCENE	:String = "removedFromScene";
		
		private var _component:IComponent;
		
		public function ComponentEvent(type:String, component:IComponent)
		{
			super(type);
			_component = component;
		}
		
		public function get component():IComponent { return _component; }
		
		override public function clone():Event
		{
			return new ComponentEvent( type, _component );
		}
	}
}