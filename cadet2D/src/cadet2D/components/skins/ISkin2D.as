// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.skins
{
	import cadet.core.IComponent;
	
	import cadet2D.components.transforms.Transform2D;
	
	import flash.display.DisplayObject;
	
	public interface ISkin2D extends IComponent
	{
		function get transform2D():Transform2D
		//function get displayObject():DisplayObject //TODO: Not sure about this...
		function get containerID():String
		function get layerIndex():int
	}
}