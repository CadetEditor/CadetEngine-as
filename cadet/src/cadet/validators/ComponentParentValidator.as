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
	
	public class ComponentParentValidator implements IComponentValidator
	{
		private var compatibleParentType	:Class;
		
		public function ComponentParentValidator( compatibleParentType:Class )
		{
			this.compatibleParentType = compatibleParentType;
		}
		
		public function validate(componentType:Class, parent:IComponentContainer):Boolean
		{
			if ( parent is compatibleParentType == false ) return false;
			return true;
		}
	}
}