package cadet2D.events
{
	import flash.events.Event;
	
	public class SkinEvent extends Event
	{
		public static const TEXTURE_VALIDATED	:String = "textureValidated";
		
		public function SkinEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}