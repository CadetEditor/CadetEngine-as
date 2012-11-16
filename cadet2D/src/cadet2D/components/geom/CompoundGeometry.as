// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.geom
{
	import cadet.components.geom.IGeometry;
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	import cadet.events.InvalidationEvent;
	
	public class CompoundGeometry extends ComponentContainer implements IGeometry
	{
		public function CompoundGeometry()
		{
			name = "CompoundGeometry";
		}
		
		override protected function childAdded(child:IComponent):void
		{
			super.childAdded(child);
			if ( child is IGeometry == false )
			{
				throw( new Error( "CompoundGeometry only supports children of type IGeometry" ));
				return;
			}
			child.addEventListener(InvalidationEvent.INVALIDATE, invalidateChildHandler);
			invalidate("geometry");
		}
		
		override protected function childRemoved(child:IComponent):void
		{
			super.childRemoved(child);
			child.removeEventListener(InvalidationEvent.INVALIDATE, invalidateChildHandler);
			invalidate("geometry");
		}
		
		private function invalidateChildHandler( event:InvalidationEvent ):void
		{
			invalidate(event.invalidationType);
		}
		
		public function get label():String { return "Compound Geometry"; }
	}
}