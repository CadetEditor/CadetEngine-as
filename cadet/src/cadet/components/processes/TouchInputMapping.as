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
	
	public class TouchInputMapping extends Component implements IInputMapping
	{
		private var _input	:String;
		
		/** Only available for mouse input: the cursor hovers over an object <em>without</em> a 
		 *  pressed button. */
		public static const HOVER:String = "HOVER";
		
		/** The finger touched the screen just now, or the mouse button was pressed. */
		public static const BEGAN:String = "BEGAN";
		
		/** The finger moves around on the screen, or the mouse is moved while the button is 
		 *  pressed. */
		public static const MOVED:String = "MOVED";
		
		/** The finger or mouse (with pressed button) has not moved since the last frame. */
		public static const STATIONARY:String = "STATIONARY";
		
		/** The finger was lifted from the screen or from the mouse button. */
		public static const ENDED:String = "ENDED";
		
		
		public static const mappings:Array = [HOVER, BEGAN, MOVED, STATIONARY, ENDED];
		
		public function TouchInputMapping()
		{
			super();
		}
		
		[Serializable][Inspectable( editor="DropDownMenu", dataProvider="[HOVER,BEGAN,MOVED,STATIONARY,ENDED]" )]
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
	}
}