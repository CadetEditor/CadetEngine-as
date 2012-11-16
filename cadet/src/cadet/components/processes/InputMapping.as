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
	
	import flox.core.events.PropertyChangeEvent;

	public class InputMapping extends Component
	{
		private static const KEY_CODE_TABLE	:Object = { "UP":38, "DOWN":40, "LEFT":37, "RIGHT":39, "SPACE":32, "ENTER":13, "0":48, "1":49, "2":50, "3":51, "4":52, "5":53, "6":54, "7":55, "8":56, "9":67 };
		private static const SYMBOL_TABLE	:Object = { "38":"UP", "40":"DOWN", "37":"LEFT", "39":"RIGHT", "32":"SPACE", "13":"ENTER", "48":"0", "49":"1", "50":"2", "51":"3", "52":"4", "53":"5", "54":"6", "55":"7", "56":"8", "67":"9" };
		
		private var _symbol	:String;
		
		public static const UP:String = "UP";
		public static const DOWN:String = "DOWN";
		public static const LEFT:String = "LEFT";
		public static const RIGHT:String = "RIGHT";
		
		public function InputMapping()
		{
			name = "InputMapping";
		}
		
		[Serializable][Inspectable( editor="DropDownMenu", dataProvider="[LMB,UP,DOWN,LEFT,RIGHT,SPACE,ENTER,0,1,2,3,4,5,6,7,8,9]" )]
		public function set symbol( value:String ):void
		{
			if ( value )
			{
				value = value.toUpperCase();
			}
			_symbol = value;
			
			invalidate("code");
			dispatchEvent( new PropertyChangeEvent( "propertyChange_symbol", null, _symbol ) );
		}
		public function get symbol():String { return _symbol; }
		
		public function getKeyCode():int
		{
			return symbolToKeyCode(_symbol);
		}
		
		public static function symbolToKeyCode( symbol:String ):int
		{
			return KEY_CODE_TABLE[symbol] ? KEY_CODE_TABLE[symbol] : -1;
		}
		
		public static function keyCodeToSymbol( keyCode:int ):String
		{
			return SYMBOL_TABLE[keyCode];
		}
	}
}