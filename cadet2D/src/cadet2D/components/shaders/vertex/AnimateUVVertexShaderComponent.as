package cadet2D.components.shaders.vertex
{
	import cadet.core.Component;
	
	import cadet2D.components.shaders.IShaderComponent;
	
	import starling.display.shaders.IShader;
	import starling.display.shaders.vertex.AnimateUVVertexShader;
	
	public class AnimateUVVertexShaderComponent extends Component implements IShaderComponent
	{
		private const VALUES		:String = "values";
		
		private var _shader			:AnimateUVVertexShader;
		private var _uSpeed			:Number;
		private var _vSpeed			:Number;
		
		public function AnimateUVVertexShaderComponent(name:String="AnimateUVVertexShaderComponent")
		{
			super(name);
			
			_shader = new AnimateUVVertexShader();
		}
		
		[Serializable][Inspectable(priority="50") ]
		public function get uSpeed():Number
		{
			return _uSpeed;
		}
		public function set uSpeed( value:Number ):void
		{
			_uSpeed = value;
			invalidate( VALUES );
		}
		
		[Serializable][Inspectable(priority="51") ]
		public function get vSpeed():Number
		{
			return _vSpeed;
		}
		public function set vSpeed( value:Number ):void
		{
			_vSpeed = value;
			invalidate( VALUES );
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( VALUES ) ) {
				validateValues();
			}
			
			super.validateNow();
		}
		
		private function validateValues():void
		{
			_shader.uSpeed = _uSpeed;
			_shader.vSpeed = _vSpeed;
		}
		
		public function get shader():IShader
		{
			return _shader;
		}
	}
}











