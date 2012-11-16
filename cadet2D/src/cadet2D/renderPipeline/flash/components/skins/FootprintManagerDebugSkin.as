// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.renderPipeline.flash.components.skins
{
	import flash.display.Graphics;
	
	import cadet2D.components.behaviours.IFootprint;
	import cadet2D.components.processes.FootprintManagerProcess;
	import cadet2D.events.FootprintManagerEvent;
	import cadet.util.ComponentReferenceUtil;
	
	[CadetBuilder( transformable="false" )]
	public class FootprintManagerDebugSkin extends AbstractSkin2D
	{
		private var _footprintManager		:FootprintManagerProcess;
		
		private var validateAll				:Boolean = false;
		private var invalidIndices			:Array;
		
		public function FootprintManagerDebugSkin()
		{
			name = "FootprintManagerDebugSkin";
			invalidIndices = [];
			sprite.mouseEnabled = false;
		}
		
		override protected function addedToScene():void
		{
			addSceneReference( FootprintManagerProcess, "footprintManager" );
		}
		
		override public function validateNow():void
		{
			if ( isInvalid("display") )
			{
				validateDisplay();
			}
			super.validateNow();
		}
		
		private function validateDisplay():void
		{
			var graphics:Graphics = sprite.graphics;
			graphics.clear();
			if ( !_footprintManager ) return;
			
			
			var gridSize:int = _footprintManager.gridSize;
			
			if ( validateAll )
			{
				validateAll = false;
				
				var footprints:Array = _footprintManager.getFootprints();
				
				for each ( var footprint:IFootprint in footprints )
				{
					for ( var x:int = 0; x < footprint.sizeX; x++ )
					{
						for ( var y:int = 0; y < footprint.sizeY; y++ )
						{
							var value:Boolean = footprint.values[x][y];
							if ( !value ) continue;
							
							graphics.beginFill(0xFF0000,0.2);
							graphics.drawRect( (x+footprint.x) * gridSize, (y+footprint.y) * gridSize, gridSize, gridSize );
							graphics.endFill();
						}
					}
				}
			}
			else
			{
				/*
				for each ( var invalidIndex:Array in invalidIndices )
				{
					var footprints:Array = _footprintManager.getFootprintsAt(invalidIndex[0],invalidIndex[1]);
					if ( footprints = null ) continue;
					graphics.beginFill(0xFF0000,0.2);
					graphics.drawRect( invalidIndex[0] * gridSize, invalidIndex[1] * gridSize, gridSize, gridSize );
					graphics.endFill();
				}
				*/
			}
			invalidIndices = [];
		}
		
		public function set footprintManager( value:FootprintManagerProcess ):void
		{
			if ( _footprintManager )
			{
				_footprintManager.removeEventListener(FootprintManagerEvent.CHANGE, changeFootprintManagerEvent);
			}
			_footprintManager = value;
			if ( _footprintManager )
			{
				_footprintManager.addEventListener(FootprintManagerEvent.CHANGE, changeFootprintManagerEvent);
			}
			validateAll = true;
			invalidate("display");
		}
		public function get footprintManager():FootprintManagerProcess { return _footprintManager; }
		
		private function changeFootprintManagerEvent( event:FootprintManagerEvent ):void
		{
			invalidIndices = invalidIndices.concat( event.indices );
			validateAll = true;
			invalidate("display");
		}
	}
}