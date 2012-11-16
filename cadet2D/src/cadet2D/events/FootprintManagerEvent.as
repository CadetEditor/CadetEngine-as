// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.events
{
	import flash.events.Event;

	public class FootprintManagerEvent extends Event
	{
		public static const CHANGE			:String = "change";
		
		private var _indices		:Array;
		
		public function FootprintManagerEvent(type:String, indices:Array)
		{
			super(type);
			_indices = indices;
		}
		
		override public function clone():Event
		{
			return new FootprintManagerEvent( type, _indices );
		}
		
		public function get indices():Array { return _indices.slice(); }
		
	}
}