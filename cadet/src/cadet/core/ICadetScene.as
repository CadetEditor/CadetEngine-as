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
	import flox.app.managers.DependencyManager;

	/**
	 * An ICadetScene acts as a top-level component in much the same way the Stage class acts as a top-level DisplayObject
	 * in Flash's display list. All components have a reference to the scene they are currently a child of, again much like
	 * DisplayObject's.
	 * @author Jonathan
	 * 
	 */	
	public interface ICadetScene extends IComponentContainer
	{
		function step():void
		function get dependencyManager():DependencyManager;
		function set userData( value:Object ):void;
		function get userData():Object;
	}
}