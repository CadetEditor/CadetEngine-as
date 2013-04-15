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
	
	public class ValidationEvent extends Event
	{
		public static const INVALIDATE	:String = "invalidate";
		public static const VALIDATED	:String = "validated";
		
		public var validationType		:String;
		
		public function ValidationEvent(type:String, validationType:String = null)
		{
			super(type);
			this.validationType = validationType;
		}
		
		override public function clone():Event
		{
			return new ValidationEvent( type, validationType );
		}
	}
}