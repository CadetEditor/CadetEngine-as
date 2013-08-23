// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.operations
{
	import cadet.core.IComponentContainer;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.util.VertexUtil;
	
	import core.app.core.operations.IUndoableOperation;
	import core.app.util.IntrospectionUtil;

	public class ConvertToPolygonOperation implements IUndoableOperation
	{
		private var polygon			:PolygonGeometry;
		private var result			:PolygonGeometry;
		
		private var parentComponent	:IComponentContainer;
		private var index			:int;
		
		
		public function ConvertToPolygonOperation( polygon:PolygonGeometry )
		{
			this.polygon = polygon;
			
			var type:Class = IntrospectionUtil.getType(polygon);
			if ( type == PolygonGeometry )
			{
				result = polygon;
			}
			else
			{
				result = new PolygonGeometry();
				result.name = polygon.name;
				result.exportTemplateID = polygon.exportTemplateID;
				result.templateID = polygon.templateID;
				var clonedVertices:Array = VertexUtil.copy(polygon.vertices);
				result.vertices = clonedVertices;
			}
		}
		
		public function execute():void
		{
			parentComponent = polygon.parentComponent;
			if ( parentComponent )
			{
				index = parentComponent.children.getItemIndex(polygon);
				
				parentComponent.children.removeItem(polygon);
				parentComponent.children.addItem(result);
			}
		}
		
		public function undo():void
		{
			if ( result == polygon ) return;
			
			if ( parentComponent )
			{
				parentComponent.children.removeItem(result);
				parentComponent.children.addItemAt(polygon, index);
			}
		}
		
		public function get label():String { return "Convert To Polygon"; }
		
		
		public function getResult():PolygonGeometry
		{
			return result;
		}
		
	}
}