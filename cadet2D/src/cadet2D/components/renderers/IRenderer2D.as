// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.renderers
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import cadet.core.IRenderer;

	public interface IRenderer2D extends IRenderer
	{
		//need to return Object rather than Sprite because of Starling implementation
		//function get worldContainer():Sprite;
		function worldToViewport( pt:Point ):Point;
		function viewportToWorld( pt:Point ):Point;
		
		function enable(parent:DisplayObject):void;
		function disable():void;
		
		function setWorldContainerTransform( m:Matrix ):void;
	}
}