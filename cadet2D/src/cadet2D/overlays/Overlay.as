package cadet2D.overlays
{	
	import starling.display.Shape;
	
	public class Overlay extends Shape
	{
		protected var _invalidationTable	:Object;
		//private var invalidationEvent		:InvalidationEvent;
		
		public function Overlay()
		{
			_invalidationTable = {};
			//invalidationEvent = new InvalidationEvent( InvalidationEvent.INVALIDATE );
			invalidate("*");
		}
		
		// Invalidation methods
		public function invalidate( invalidationType:String ):void
		{
			_invalidationTable[invalidationType] = true;
			//invalidationEvent.invalidationType = invalidationType;
			//dispatchEvent( invalidationEvent );
		}
		
		public function validateNow():void
		{
			validate();
			_invalidationTable = {};
		}
		
		protected function validate():void
		{
			
		}
		
		public function isInvalid(type:String):Boolean
		{
			if ( _invalidationTable["*"] ) return true;
			if ( type == "*" )
			{
				for each ( var val:String in _invalidationTable )
				{
					return true;
				}
			}
			return _invalidationTable[type] == true;
		}
		
		public function get invalidationTable():Object { return _invalidationTable; }		
	}
}