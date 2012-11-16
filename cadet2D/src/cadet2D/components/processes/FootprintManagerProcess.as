// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.processes
{
	import cadet2D.components.behaviours.IFootprint;
	import cadet.core.Component;
	import cadet2D.events.FootprintManagerEvent;

	[Event( type="cadet2D.events.FootprintManagerEvent", name="change" )]
	public class FootprintManagerProcess extends Component
	{
		private var _gridSize			:int = 20;
		
		private var table				:Object;
		private var footprints			:Array;
		
		public function FootprintManagerProcess()
		{
			name = "FootprintManagerProcess";
			footprints = [];
			table = {};
		}
		
		public function getFootprints():Array { return footprints.slice(); } 
		
		public function addFootprint( footprint:IFootprint ):void
		{
			footprints.push(footprint);
			
			var changedIndices:Array = [];
			
			for ( var x:int = 0; x < footprint.sizeX; x++ )
			{
				var globalX:int = footprint.x+x;
				
				for ( var y:int = 0; y < footprint.sizeY; y++ )
				{
					if ( footprint.values[x][y] == false ) continue;
					var globalY:int = footprint.y+y;
					var key:String = globalX+"_"+globalY;
					var cell:Array = table[key];
					if ( !cell )
					{
						cell = table[key] = [];
					}
					
					if ( cell.indexOf(footprint) != -1 ) continue;
					
					cell.push(footprint);
					
					changedIndices.push([globalX,globalY]);
					
				}
			}
			
			if ( changedIndices.length > 0 )
			{
				dispatchEvent( new FootprintManagerEvent( FootprintManagerEvent.CHANGE, changedIndices ) );
			}
		}
		
		public function getFootprintsAt( x:int, y:int ):Array
		{
			var key:String = x + "_" + y;
			var cell:Array = table[key];
			if ( cell == null ) return null;
			return cell.slice();
		}
		
		public function removeFootprint( footprint:IFootprint ):void
		{
			var index:int = footprints.indexOf(footprint);
			if ( index == -1 ) return;
			footprints.splice(index,1);
			
			var changedIndices:Array = [];
			
			for ( var x:int = 0; x < footprint.sizeX; x++ )
			{
				var globalX:int = footprint.x+x;
				for ( var y:int = 0; y < footprint.sizeY; y++ )
				{
					if ( footprint.values[x][y] == false ) continue;
					var globalY:int = footprint.y+y;
					var key:String = globalX+"_"+globalY;
					var cell:Array = table[key];
					cell.splice(cell.indexOf(footprint),1);
					if ( cell.length == 0 )
					{
						table[key] = null;
						delete table[key];
					}
					changedIndices.push([globalX,globalY]);
				}
			}
						
			if ( changedIndices.length > 0 )
			{
				dispatchEvent( new FootprintManagerEvent( FootprintManagerEvent.CHANGE, changedIndices ) );
			}
		}
		
		public function getOverlappingFootprints( footprint:IFootprint ):Array
		{
			var overlappingFootprints:Array = [];
			var L:int = 0;
			for ( var x:int = 0; x < footprint.sizeX; x++ )
			{
				var globalX:int = footprint.x+x;
				for ( var y:int = 0; y < footprint.sizeY; y++ )
				{
					if ( footprint.values[x][y] == false ) continue;
					var globalY:int = footprint.y+y;
					
					var key:String = globalX+"_"+globalY;
					var cell:Array = table[key];
					if ( cell == null ) continue;
					
					
					for each ( var cellFootprint:IFootprint  in cell )
					{
						if ( overlappingFootprints.indexOf(cellFootprint) != -1 ) continue;
						if ( cellFootprint == footprint ) continue;
						overlappingFootprints[L++] = cellFootprint;
					}
				}
			}
						
			return overlappingFootprints;
		}
		
		[Serializer][Inspectable]
		public function set gridSize( value:int ):void
		{
			_gridSize = value;
		}
		public function get gridSize():int { return _gridSize; }
	}
}