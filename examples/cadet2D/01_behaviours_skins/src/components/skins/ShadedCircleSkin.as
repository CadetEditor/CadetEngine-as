package components.skins
{
	import flash.display.GradientType;
	
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.skins.AbstractSkin2D;
	
	import starling.core.Starling;
	import starling.display.Shape;
	import starling.textures.GradientTexture;
	import starling.textures.Texture;
	
	public class ShadedCircleSkin extends AbstractSkin2D
	{
		private var _circle		:CircleGeometry;
		private var _shape		:Shape;
		
		private const DISPLAY	:String = "display";
		
		public function ShadedCircleSkin()
		{
			_displayObject = new Shape();
			_shape = Shape(_displayObject);
		}
		
		override protected function addedToParent():void
		{
			super.addedToParent();
			addSiblingReference(CircleGeometry, "circle");
		}
		
		public function set circle( value:CircleGeometry ):void
		{
			if ( _circle )
			{
				_circle.removeEventListener(ValidationEvent.INVALIDATE, invalidateCircleHandler);
			}
			
			_circle = value;
			
			if ( _circle )
			{
				_circle.addEventListener(ValidationEvent.INVALIDATE, invalidateCircleHandler);
			}
			
			invalidate(DISPLAY);
		}
		public function get circle():CircleGeometry{ return _circle; }
		
		
		private function invalidateCircleHandler( event:ValidationEvent ):void
		{
			invalidate(DISPLAY);
		}
		
		override public function validateNow():void
		{
			if ( isInvalid(DISPLAY) )
			{
				validateDisplay();
			}
			super.validateNow()
		}
		
		private function validateDisplay():void
		{
			_shape.graphics.clear();
			if ( !_circle ) return;
			
			var colors:Array = [0xFFFFFF, 0x909090];
			var ratios:Array = [0,255];
			var alphas:Array = [1,1];
			
			// Don't attempt to create the gradientTexture if the Starling.context is unavailable,
			// as Texture.fromBitmapData() will throw a missing context error
			if (!Starling.context) return;
			
			var gradientTexture:Texture = GradientTexture.create(128, 128, GradientType.RADIAL, colors, alphas, ratios );
			_shape.graphics.beginTextureFill(gradientTexture);
			_shape.graphics.drawCircle(circle.x,circle.y,circle.radius);
			_shape.graphics.endFill();
		}
	}
}