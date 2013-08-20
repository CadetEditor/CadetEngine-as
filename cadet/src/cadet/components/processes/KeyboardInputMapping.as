// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.components.processes
{
	import cadet.core.Component;
	
	import core.events.PropertyChangeEvent;

	public class KeyboardInputMapping extends Component implements IInputMapping
	{
		private static const KEY_CODE_TABLE	:Object = { "UP":38, "DOWN":40, "LEFT":37, "RIGHT":39, "SPACE":32, "ENTER":13, "0":48, "1":49, "2":50, "3":51, "4":52, "5":53, "6":54, "7":55, "8":56, "9":67 };
		private static const INPUT_TABLE	:Object = { "38":"UP", "40":"DOWN", "37":"LEFT", "39":"RIGHT", "32":"SPACE", "13":"ENTER", "48":"0", "49":"1", "50":"2", "51":"3", "52":"4", "53":"5", "54":"6", "55":"7", "56":"8", "67":"9" };
		
		private var _input	:String;
		
		public static const UP:String = "UP";
		public static const DOWN:String = "DOWN";
		public static const LEFT:String = "LEFT";
		public static const RIGHT:String = "RIGHT";
		public static const SPACE:String = "SPACE";
		public static const ENTER:String = "ENTER";
		
		public function KeyboardInputMapping( name:String = "KeyboardInputMapping" )
		{
			super(name);
		}
		
		[Serializable][Inspectable( editor="DropDownMenu", dataProvider="[UP,DOWN,LEFT,RIGHT,SPACE,ENTER,0,1,2,3,4,5,6,7,8,9]" )]
		public function set input( value:String ):void
		{
			if ( value )
			{
				value = value.toUpperCase();
			}
			_input = value;
			
			invalidate("code");
			dispatchEvent( new PropertyChangeEvent( "propertyChange_input", null, _input ) );
		}
		public function get input():String { return _input; }
		
		public function getKeyCode():int
		{
			return inputToKeyCode(_input);
		}
		
		public static function inputToKeyCode( input:String ):int
		{
			return KEY_CODE_TABLE[input] ? KEY_CODE_TABLE[input] : -1;
		}
		
		public static function keyCodeToInput( keyCode:int ):String
		{
			return INPUT_TABLE[keyCode];
		}
	}
}