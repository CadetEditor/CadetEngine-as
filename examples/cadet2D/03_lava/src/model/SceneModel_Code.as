package model
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import cadet.core.CadetScene;
	import cadet.core.ComponentContainer;
	
	import cadet2D.components.geom.BezierCurve;
	import cadet2D.components.materials.StandardMaterialComponent;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.shaders.fragment.TextureFragmentShaderComponent;
	import cadet2D.components.shaders.vertex.AnimateUVVertexShaderComponent;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.QuadraticBezier;
	
	import core.app.managers.ResourceManager;
	
	public class SceneModel_Code implements ISceneModel
	{
		private var _parent:DisplayObject;
		private var _cadetScene:CadetScene;
		private var _resourceManager:ResourceManager;
		
		private var _bgTextureURL:String = "lavaDemo/FinalBackground.png";
		private var _fgTextureURL:String = "lavaDemo/FinalRock.png";
		private var _banksTextureURL:String = "lavaDemo/BanksTiled.png";
		private var _lavaTextureURL:String = "lavaDemo/LavaTiled.png";
		
		private var _lavaThickness:Number = 90;
		private var _banksThickness:Number = _lavaThickness*2.2;
		
		public function SceneModel_Code( resourceManager:ResourceManager )
		{
			_cadetScene = new CadetScene();
			_resourceManager = resourceManager;
		}
		
		public function init( parent:DisplayObject ):void 
		{
			_parent = parent;
			
			var renderer:Renderer2D = new Renderer2D();
			renderer.viewportWidth = parent.stage.stageWidth;
			renderer.viewportHeight = parent.stage.stageHeight;
			_cadetScene.children.addItem(renderer);
			
			renderer.enable(parent.stage);
			
			drawBg();
			drawLava();
			drawBanks();
			drawFg();
			
			_parent.addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		public function get cadetScene():CadetScene
		{
			return _cadetScene;
		}
		public function set cadetScene( value:CadetScene ):void
		{
			_cadetScene = value;
		}
		
		private function drawBg():void
		{
			var entity:ComponentContainer = new ComponentContainer("Background Entity");
			_cadetScene.children.addItem(entity);	
			
			// Add the bg texture to the scene
			var bgTexture:TextureComponent = new TextureComponent("Bg Texture");
			_resourceManager.bindResource(_bgTextureURL, bgTexture, "bitmapData");
			entity.children.addItem(bgTexture);
			
			var imgSkin:ImageSkin = new ImageSkin("Bg Skin");
			imgSkin.texture = bgTexture;
			imgSkin.width = _parent.stage.stageWidth;
			imgSkin.height = _parent.stage.stageHeight;
			entity.children.addItem(imgSkin);
		}
		
		private function drawFg():void
		{
			var entity:ComponentContainer = new ComponentContainer("Foreground Entity");
			_cadetScene.children.addItem(entity);	
			
			// Add the bg texture to the scene
			var fgTexture:TextureComponent = new TextureComponent("Fg Texture");
			_resourceManager.bindResource(_fgTextureURL, fgTexture, "bitmapData");
			entity.children.addItem(fgTexture);
			
			var imgSkin:ImageSkin = new ImageSkin("Fg Skin");
			imgSkin.texture = fgTexture;
			imgSkin.width = _parent.stage.stageWidth;
			imgSkin.height = _parent.stage.stageHeight * 1.6;
			entity.children.addItem(imgSkin);
		}
		
		private function drawLava():void
		{
			var entity:ComponentContainer = new ComponentContainer("Lava Entity");
			_cadetScene.children.addItem(entity);	
			
			var curve:BezierCurve = new BezierCurve();
			entity.children.addItem(curve);
			
			var transform:Transform2D = new Transform2D();
			entity.children.addItem( transform );
			
			var skin:GeometrySkin = new GeometrySkin(_lavaThickness);
			entity.children.addItem( skin );
			
			var qb:QuadraticBezier;
			
			qb = new QuadraticBezier( 150, 0, 500, 100, 500, 300 );
			curve.segments.push(qb);
			
			qb = new QuadraticBezier( 500, 300, 500, 500, 700, 650 );
			curve.segments.push(qb);
			
			// Add lava material to scene
			var lavaMaterial:StandardMaterialComponent = new StandardMaterialComponent();
			entity.children.addItem(lavaMaterial);
			
			// Add shaders to lava material
			var vertexShader:AnimateUVVertexShaderComponent = new AnimateUVVertexShaderComponent();
			vertexShader.uSpeed = 0.1;
			vertexShader.vSpeed = 0;
			entity.children.addItem(vertexShader);
			
			var fragmentShader:TextureFragmentShaderComponent = new TextureFragmentShaderComponent();
			entity.children.addItem(fragmentShader);
			
			// Add the lava texture to the scene
			var lavaTexture:TextureComponent = new TextureComponent("Lava Texture");
			_resourceManager.bindResource(_lavaTextureURL, lavaTexture, "bitmapData");
			lavaMaterial.children.addItem(lavaTexture);
			
			lavaMaterial.vertexShader = vertexShader;
			lavaMaterial.fragmentShader = fragmentShader;
			
			skin.lineMaterial = lavaMaterial;
		}
		
		private function drawBanks():void
		{
			var entity:ComponentContainer = new ComponentContainer("Banks Entity");
			_cadetScene.children.addItem(entity);	
			
			var curve:BezierCurve = new BezierCurve();
			entity.children.addItem(curve);
			
			var transform:Transform2D = new Transform2D();
			entity.children.addItem( transform );
			
			var skin:GeometrySkin = new GeometrySkin(_banksThickness);
			entity.children.addItem( skin );
			
			var qb:QuadraticBezier;
			
			qb = new QuadraticBezier( 150, 0, 500, 100, 500, 300 );
			curve.segments.push(qb);
			
			qb = new QuadraticBezier( 500, 300, 500, 500, 700, 650 );
			curve.segments.push(qb);
			
			// Add the banks texture to the scene
			var banksTexture:TextureComponent = new TextureComponent("Banks Texture");
			_resourceManager.bindResource(_banksTextureURL, banksTexture, "bitmapData");
			entity.children.addItem(banksTexture);
			
			skin.lineTexture = banksTexture;
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			_cadetScene.step();
		}
	}
}