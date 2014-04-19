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
	import core.data.ArrayCollection;
	
	[Event( type="cadet.events.ComponentContainerEvent", name="childAdded" )]
	[Event( type="cadet.events.ComponentContainerEvent", name="childRemoved" )]
	
	public interface IComponentContainer extends IComponent
	{
		function get children():ArrayCollection;
	}
}