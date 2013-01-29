// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.validators
{
	import cadet.core.IComponentContainer;

	public interface IComponentValidator
	{
		function validate( componentType:Class, parent:IComponentContainer ):Boolean
	}
}