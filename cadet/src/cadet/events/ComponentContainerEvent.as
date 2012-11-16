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

	public class ComponentContainerEvent extends Event
	{
		public static const CHILD_ADDED		:String = "childAdded";
		public static const CHILD_REMOVED	:String = "childRemoved";
		
		public var child:IComponent;
		
		public function ComponentContainerEvent(type:String, child:IComponent)
		{
			super(type);
			this.child = child;
		}
		
		
		override public function clone():Event
		{
			return new ComponentContainerEvent( type, child );
		}
	}
}