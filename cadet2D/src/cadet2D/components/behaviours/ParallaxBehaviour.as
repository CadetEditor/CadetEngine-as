package cadet2D.components.behaviours
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.transforms.Transform2D;
	
	public class ParallaxBehaviour extends Component implements ISteppableComponent
	{
		public var transform		:Transform2D;
		private var _skin			:AbstractSkin2D;
		
		private var _speed			:Number;
		private var _depth			:Number;
		
		private var _initialised	:Boolean = false;
		
		public function ParallaxBehaviour()
		{
			name = "ParallaxBehaviour";
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference( Transform2D, "transform" );
			addSiblingReference( AbstractSkin2D, "skin" );
		}
		
		public function step(dt:Number):void
		{
			if (!transform || !skin) return;
			
			// Initialisation of this behaviour will remove the skin and add in two duplicated DisplayObjects
			// in order to provide the continuous parallax effect. Initialisation has to happen within step() to
			// ensure this operation only executes while the scene is being stepped, i.e. not while in editor mode.
			if (!_initialised && _skin.displayObject.parent) {
				initialise();
			}
			
			transform.x += Math.round(speed * depth);
		}
		
		private function initialise():void
		{
			_skin.displayObject.parent.removeChild(_skin.displayObject);
			_initialised = true;
		}
		
		[Serializable][Inspectable( editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function set depth( value:Number ):void
		{
			_depth = value;
		}
		public function get depth():Number
		{
			return _depth;
		}
		
		[Serializable][Inspectable]
		public function set speed( value:Number ):void
		{
			_speed = value;
		}
		public function get speed():Number
		{
			return _speed;
		}
		
		public function set skin( value:AbstractSkin2D ):void
		{
			_skin = value;
		}
		public function get skin():AbstractSkin2D
		{
			return _skin;
		}
	}
}