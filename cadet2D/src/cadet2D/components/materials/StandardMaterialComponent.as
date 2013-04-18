package cadet2D.components.materials
{
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.events.ComponentContainerEvent;
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.shaders.IShaderComponent;
	import cadet2D.components.textures.TextureComponent;
	
	import starling.display.materials.IMaterial;
	import starling.display.materials.StandardMaterial;
	import starling.textures.Texture;
	
	public class StandardMaterialComponent extends ComponentContainer implements IMaterialComponent
	{
		private const VALUES					:String = "values";
		private const TEXTURES					:String = "textures";
		
		private var _material					:StandardMaterial;
		private var _vertexShader				:IShaderComponent;
		private var _fragmentShader				:IShaderComponent;
		private var _texturesContainer			:IComponentContainer;
		
		private var _textures					:Vector.<Texture>;
		private var _textureComps				:Vector.<TextureComponent>;
		
		public function StandardMaterialComponent(name:String="StandardMaterialComponent")
		{
			super(name);
			
			_material = new StandardMaterial();
			
			texturesContainer = this;
			_textureComps = new Vector.<TextureComponent>();
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="50" )]
		public function set vertexShader( value:IShaderComponent ):void
		{
			_vertexShader = value;
			invalidate( VALUES );
		}
		public function get vertexShader():IShaderComponent
		{
			return _vertexShader;
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="51" )]
		public function set fragmentShader( value:IShaderComponent ):void
		{
			_fragmentShader = value;
			invalidate( VALUES );
		}
		public function get fragmentShader():IShaderComponent
		{
			return _fragmentShader;
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene", priority="52" )]
		public function set texturesContainer( value:IComponentContainer ):void
		{
			if ( _texturesContainer ) {
				_texturesContainer.removeEventListener( ComponentContainerEvent.CHILD_ADDED, childAddedHandler );
			}
			
			_texturesContainer = value;
			
			if ( _texturesContainer ) {
				_texturesContainer.addEventListener( ComponentContainerEvent.CHILD_ADDED, childAddedHandler );
			}
			
			invalidate( TEXTURES );
		}
		public function get texturesContainer():IComponentContainer
		{
			return _texturesContainer;
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( VALUES ) ) {
				validateValues();
			}
			if ( isInvalid( TEXTURES ) ) {
				validateTextures();
			}
			super.validateNow();
		}
		
		private function validateValues():void
		{
			_material.vertexShader = _vertexShader ? _vertexShader.shader : null;
			_material.fragmentShader = _fragmentShader ? _fragmentShader.shader : null;
		}
		
		private function validateTextures():void
		{
			for ( var i:uint = 0; i < _textureComps.length; i ++ ) {
				var textureComp:TextureComponent = _textureComps[i];
				textureComp.removeEventListener(ValidationEvent.VALIDATED, textureValidatedHandler);
			}
			
			_textures		= new Vector.<Texture>();
			_textureComps = new Vector.<TextureComponent>();
			
			if ( _texturesContainer ) {
				for ( i = 0; i < _texturesContainer.children.length; i ++ ) {
					var childComp:IComponent = _texturesContainer.children[i];
					if ( childComp is TextureComponent ) {
						textureComp = TextureComponent(childComp);
						textureComp.validateNow();
						textureComp.addEventListener(ValidationEvent.VALIDATED, textureValidatedHandler);
						if ( textureComp.texture ) {
							_textures.push(textureComp.texture);
							_textureComps.push(textureComp);
						}
					}
				}
			}
			_material.textures = _textures;
			
			dispatchEvent( new ValidationEvent(ValidationEvent.VALIDATED, TEXTURES) );
		}
		
		private function textureValidatedHandler( event:ValidationEvent ):void
		{
			if ( event.validationType == TextureComponent.TEXTURE) {
				invalidate( TEXTURES );
			}
		}
		
		private function childAddedHandler( event:ComponentContainerEvent ):void
		{
			invalidate( TEXTURES );
		}
		
		// Graphics.clear() disposes materials referenced on Graphic classes,
		// So the material needs to be reconstructed on each frame.
		public function get material():IMaterial
		{
			validateValues();
			validateTextures();
			return _material;
		}
	}
}











