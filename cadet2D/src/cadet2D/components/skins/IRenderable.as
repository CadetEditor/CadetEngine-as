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
	
	import starling.display.DisplayObject;

	public interface IRenderable extends IComponent
	{
		function get indexStr():String
		function get displayObject():DisplayObject // Ties this implementation to Starling
	}
}