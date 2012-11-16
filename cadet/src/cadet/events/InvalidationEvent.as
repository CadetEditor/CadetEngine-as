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
	
	public class InvalidationEvent extends Event
	{
		public static const INVALIDATE	:String = "invalidate";
		
		public var invalidationType		:String;
		
		public function InvalidationEvent(type:String, invalidationType:String = null)
		{
			super(type);
			this.invalidationType = invalidationType;
		}
		
		override public function clone():Event
		{
			return new InvalidationEvent( type, invalidationType );
		}
	}
}