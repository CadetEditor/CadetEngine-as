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
	import flash.display.Stage;

	public interface IRenderer extends IComponent
	{
		//function get viewport():Sprite;	
		
		function set viewportWidth( value:Number ):void;
		function get viewportWidth():Number;
		function set viewportHeight( value:Number ):void;
		function get viewportHeight():Number;
		
		function get mouseX():Number
		function get mouseY():Number;
		
//		function enable(parent:DisplayObjectContainer, depth:int = -1):void
//		function disable(parent:DisplayObjectContainer):void
			
		function getNativeStage():Stage
			
		function get initialised():Boolean;
	}
}