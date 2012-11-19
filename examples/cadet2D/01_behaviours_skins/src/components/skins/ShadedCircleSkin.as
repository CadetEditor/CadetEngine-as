package components.skins
{
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.renderPipeline.starling.components.skins.AbstractSkin2D;
	
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import starling.display.Shape;
	import starling.textures.GradientTexture;
	import starling.textures.Texture;
	
	public class ShadedCircleSkin extends AbstractSkin2D
	{
		private var _circle		: CircleGeometry;
		
		private var _shape		:Shape;
		
		public function ShadedCircleSkin()
		{
			_displayObjectContainer = new Shape();
			_shape = Shape(_displayObjectContainer);
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
				_circle.removeEventListener(InvalidationEvent.INVALIDATE, invalidateCircleHandler);
			}
			
			_circle = value;
			
			if ( _circle )
			{
				_circle.addEventListener(InvalidationEvent.INVALIDATE, invalidateCircleHandler);
			}
			
			invalidate("display");
		}
		public function get circle():CircleGeometry{ return _circle; }
		
		
		private function invalidateCircleHandler( event:InvalidationEvent ):void
		{
			invalidate("display");
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( "display" ) )
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
			
			var gradientTexture:Texture = GradientTexture.create(128, 128, GradientType.RADIAL, colors, alphas, ratios );
			_shape.graphics.beginTextureFill(gradientTexture);
			_shape.graphics.drawCircle(circle.x,circle.y,circle.radius);
			_shape.graphics.endFill();
		}
	}
}