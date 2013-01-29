// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadet.validators
{
	import cadet.core.IComponentContainer;

	public interface IComponentValidator
	{
		function validate( componentType:Class, parent:IComponentContainer ):Boolean
	}
}