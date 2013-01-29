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
	import cadet.util.ComponentUtil;
	
	public class ComponentSiblingValidator implements IComponentValidator
	{
		private var maxSiblingsOfSameType	:int = -1;
		private var requiredSiblingTypes	:Array;
		
		public function ComponentSiblingValidator( maxSiblingsOfSameType:int = -1, requiredSiblingTypes:Array = null )
		{
			this.maxSiblingsOfSameType = maxSiblingsOfSameType;
			this.requiredSiblingTypes = requiredSiblingTypes || [];
		}
		
		public function validate(componentType:Class, parent:IComponentContainer):Boolean
		{
			if ( maxSiblingsOfSameType != -1 )
			{
				var numSameTypeSiblings:int = ComponentUtil.getChildrenOfType( parent, componentType, false ).length;
				if ( numSameTypeSiblings >= maxSiblingsOfSameType ) return false;
			}
			
			for each ( var requiredSiblingType:Class in requiredSiblingTypes )
			{
				var numRequiredSiblings:int = ComponentUtil.getChildrenOfType( parent, requiredSiblingType, false ).length;
				if ( numRequiredSiblings == 0 ) return false;
			}
			
			return true;
		}
	}
}