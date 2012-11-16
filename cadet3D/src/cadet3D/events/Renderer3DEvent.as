// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.events
{
	import flash.events.Event;
	
	public class Renderer3DEvent extends Event
	{
		public static const PRE_RENDER	:String = "preRender";
		public static const POST_RENDER	:String = "postRender";
		
		public function Renderer3DEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event
		{
			return new Renderer3DEvent( type );
		}
	}
}