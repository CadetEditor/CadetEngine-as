package cadet2D.components.behaviours
{
    import cadet.core.Component;
    import cadet.core.IRenderer;
    import cadet.core.ISteppableComponent;
    import cadet.events.RendererEvent;

    import cadet2D.components.renderers.Renderer2D;
    import cadet2D.components.transforms.Transform2D;

    import flash.geom.Matrix;
    import flash.geom.Point;

    import starling.display.DisplayObject;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.MatrixUtil;

    public class MouseFollowBehaviour extends Component implements ISteppableComponent
	{
        private static var helperMatrix :Matrix = new Matrix();

		public var transform		    :Transform2D;
		private var _renderer		    :Renderer2D;
		private var _constrain		    :String;

        private var targetPoint         :Point = new Point(0, 0);

		public static const CONSTRAIN_X	:String = "x";
		public static const CONSTRAIN_Y	:String = "y";
		
		public function MouseFollowBehaviour()
		{
			name = "MouseFollowBehaviour";
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference( Transform2D, "transform" );
			addSceneReference( Renderer2D, "renderer" );
		}
		
		public function step(dt:Number):void
		{
			if ( !transform || !renderer ) return;
			
			if ( _constrain != CONSTRAIN_X )	transform.x -= (transform.x - targetPoint.x) * 0.1;
			if ( _constrain != CONSTRAIN_Y )	transform.y -= (transform.y - targetPoint.y) * 0.1;
		}
		
		[Serializable][Inspectable( editor="DropDownMenu", dataProvider="[<None>,x,y]" )]
		public function set constrain( value:String ):void
		{
			_constrain = value;
		}
		public function get constrain():String { return _constrain; }	
		
		
		public function set renderer( value:IRenderer ):void
		{
			if (!(value is Renderer2D)) return;
			
			if ( _renderer) {
				_renderer.viewport.stage.removeEventListener( TouchEvent.TOUCH, touchEventHandler );
			}
			_renderer = Renderer2D(value);
			
			if ( _renderer && _renderer.viewport ) {
				_renderer.viewport.stage.addEventListener( TouchEvent.TOUCH, touchEventHandler );
			} else {
				renderer.addEventListener( RendererEvent.INITIALISED, rendererInitialisedHandler );
			}
		}
		public function get renderer():IRenderer
		{
			return _renderer;
		}
		
		private function rendererInitialisedHandler( event:RendererEvent ):void
		{
			renderer.removeEventListener( RendererEvent.INITIALISED, rendererInitialisedHandler );
			_renderer.viewport.stage.addEventListener( TouchEvent.TOUCH, touchEventHandler );
		}
		
		protected function touchEventHandler( event:TouchEvent ):void
		{
			if ( !transform ) return;
			if ( !_renderer ) return;
			
			var dispObj:DisplayObject = DisplayObject(_renderer.viewport.stage);
			var touches:Vector.<Touch> = event.getTouches(dispObj);

			for each (var touch:Touch in touches)
			{
				// include MOVED for touch screens (where hover isn't available)
				if (touch.phase == TouchPhase.HOVER || touch.phase == TouchPhase.MOVED) {
                    if(transform.parentTransform) {
                        helperMatrix.identity();
                        helperMatrix.concat(transform.parentTransform.globalMatrix);    // get parent -> global matrix
                        helperMatrix.invert();                                          // and change it to global -> parent

                        var p:Point = MatrixUtil.transformCoords(helperMatrix, touch.globalX, touch.globalY, targetPoint);
                    }
                    else {
                        targetPoint.x = touch.globalX;
                        targetPoint.y = touch.globalY;
                    }
					break;
				}
			}
		}
	}
}