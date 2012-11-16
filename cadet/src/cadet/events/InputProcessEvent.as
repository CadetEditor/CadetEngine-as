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

	public class InputProcessEvent extends Event
	{
		public static const INPUT_DOWN		:String = "inputDown";
		public static const INPUT_UP		:String = "inputUp";
		
		public var name		:String;
		
		public function InputProcessEvent(type:String, name:String)
		{
			super(type);
			this.name = name;
		}
	}
}