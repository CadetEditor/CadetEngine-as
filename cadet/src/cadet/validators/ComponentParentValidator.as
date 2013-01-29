// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

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