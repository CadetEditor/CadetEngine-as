package cadet2D.components.shaders.fragment
{
	import cadet.core.Component;
	
	import cadet2D.components.shaders.IShaderComponent;
	
	import starling.display.shaders.IShader;
	import starling.display.shaders.fragment.TextureFragmentShader;
	
	public class TextureFragmentShaderComponent extends Component implements IShaderComponent
	{
		private var _shader		:IShader;
		
		public function TextureFragmentShaderComponent(name:String="TextureFragmentShaderComponent")
		{
			super(name);
			
			_shader = new TextureFragmentShader();
		}
		
		public function get shader():IShader
		{
			return _shader;
		}
	}
}