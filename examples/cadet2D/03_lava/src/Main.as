package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import cadet.core.CadetScene;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.geom.BezierCurve;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.QuadraticBezier;
	
	[SWF( width="800", height="600", backgroundColor="0x002135", frameRate="60" )]
	public class Main extends Sprite
	{
		private var cadetScene:CadetScene;
		
		public function Main()
		{
			cadetScene = new CadetScene();
			
			var renderer:Renderer2D = new Renderer2D();
			renderer.addEventListener(RendererEvent.INITIALISED, rendererInitialisedHandler );
			renderer.viewportWidth = stage.stageWidth;
			renderer.viewportHeight = stage.stageHeight;
			cadetScene.children.addItem(renderer);
			renderer.enable(this);
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function rendererInitialisedHandler( event:Event ):void
		{
			initScene();
		}
		
		private function initScene():void
		{
			var entity:Entity = new Entity();
			//entity.name = ComponentUtil.getUniqueName("Curve", context.scene);
			var curve:BezierCurve = new BezierCurve();
			var transform:Transform2D = new Transform2D();
			entity.children.addItem(curve);
			
			var skin:GeometrySkin = new GeometrySkin(90);
			entity.children.addItem(skin);
			entity.children.addItem( transform );
			
			var qb:QuadraticBezier;
			
			qb = new QuadraticBezier( 150, 0, 500, 100, 500, 300);
			curve.segments.push(qb);
			
			qb = new QuadraticBezier( 500, 300, 500, 500, 700, 650);
			curve.segments.push(qb);
			
			cadetScene.children.addItem(entity);
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}