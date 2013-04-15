// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.components.behaviours
{
	import cadet.core.Component;
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.processes.FootprintManagerProcess;
	import cadet2D.components.transforms.Transform2D;

	public class SimpleFootprintBehaviour extends Component implements IFootprint
	{
		private var _x			:int;
		private var _y			:int;
		private var _sizeX		:int = 1;
		private var _sizeY		:int = 1;
		
		private var _values		:Array;
		
		private var _footprintManager	:FootprintManagerProcess;
		
		private var _transform	:Transform2D
		
		public function SimpleFootprintBehaviour()
		{
			name = "SimpleFootprintBehaviour";
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(Transform2D, "transform");
			addSceneReference( FootprintManagerProcess, "footprintManager" );
		}
		
		override protected function removedFromScene():void
		{
			if ( _footprintManager )
			{
				_footprintManager.removeFootprint(this);
			}
		}
		
		public function set footprintManager( value:FootprintManagerProcess ):void
		{
			if ( _footprintManager )
			{
				_footprintManager.removeFootprint(this);
			}
			_footprintManager = value;
			invalidate("values");
		}
		public function get footprintManager():FootprintManagerProcess { return _footprintManager; }
		
		
		override public function validateNow():void
		{
			if ( isInvalid("values") )
			{
				validateValues();
			}
		
			super.validateNow();
		}
				
		private function validateValues():void
		{
			if ( !_transform ) return;
			if ( !_footprintManager ) return;
			
			_x = _transform.x;
			_y = _transform.y;
			
			
			_footprintManager.removeFootprint(this);
			_values = [];
			for ( var x:int = 0; x < sizeX; x++ )
			{
				_values[x] = [];
				for ( var y:int = 0; y < sizeY; y++ )
				{
					_values[x][y] = true;
				}
			}
			_footprintManager.addFootprint(this);
		}
		
		public function set transform( value:Transform2D ):void
		{
			if ( _transform )
			{
				_transform.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			_transform = value;
			if ( _transform )
			{
				_transform.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			invalidate("values");
		}
		public function get transform():Transform2D { return _transform; }
		
		private function invalidateTransformHandler( event:ValidationEvent ):void
		{
			invalidate("values");
		}
		
		public function get x():int { return _x; }
		public function get y():int { return _y; }
		
		[Serializable][Inspectable]
		public function set sizeX( value:int ):void
		{
			if ( value == _sizeX ) return;
			_sizeX = value;
			invalidate("values");
		}
		public function get sizeX():int { return _sizeX; }
		
		[Serializable][Inspectable]
		public function set sizeY( value:int ):void
		{
			if ( value == _sizeY ) return;
			_sizeY = value;
			invalidate("values");
		}
		public function get sizeY():int { return _sizeY; }
		
		
		public function get values():Array
		{
			return _values;
		}
	}
}