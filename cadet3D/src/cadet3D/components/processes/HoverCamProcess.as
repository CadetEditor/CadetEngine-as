package cadet3D.components.processes
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Entity;
	
	import cadet.components.processes.InputProcess;
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	import cadet.util.ComponentUtil;
	
	import cadet3D.components.cameras.CameraComponent;
	import cadet3D.components.core.Object3DComponent;
	import cadet3D.components.core.Renderer3D;
	import cadet3D.controllers.HoverController;
	
	public class HoverCamProcess extends Component implements ISteppableComponent
	{
		[Serializable][Inspectable]
		public var mouseMapping		:String = "LMB";
		
		private var _controller			:HoverController;
		
		private var _targetComponent	:Object3DComponent;
		private var _lookAtComponent	:Object3DComponent;
		
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		public var inputProcess			:InputProcess;
		private var _active				:Boolean;
		
		public function HoverCamProcess()
		{
			_controller = new HoverController();
		}
		
		override protected function addedToScene():void
		{
			addSceneReference( InputProcess, "inputProcess" );
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene" )]
		public function set targetComponent( target:Object3DComponent ):void
		{
			_targetComponent = target;
			if ( _targetComponent ) {
				_controller.targetObject = Entity(target.object3D);
			} else {
				_controller.targetObject = null;
			}
		}
		public function get targetComponent():Object3DComponent
		{
			return _targetComponent;
		}
		
		[Serializable][Inspectable( editor="ComponentList", scope="scene" )]
		public function set lookAtComponent( target:Object3DComponent ):void
		{
			_lookAtComponent = target;
			if ( _lookAtComponent ) {
				_controller.lookAtObject = ObjectContainer3D(target.object3D);
			} else {
				_controller.lookAtObject = null;
			}
		}
		public function get lookAtComponent():Object3DComponent
		{
			return _lookAtComponent;
		}
		
		[Serializable][Inspectable]
		public function set distance( value:Number ):void
		{
			_controller.distance = value;
		}
		public function get distance():Number
		{
			return _controller.distance;
		}
		
		[Serializable][Inspectable]
		public function set currentPanAngle( value:Number ):void
		{
			_controller.currentPanAngle = value;
		}
		public function get currentPanAngle():Number
		{
			return _controller.currentPanAngle;
		}
		
		[Serializable][Inspectable]
		public function set currentTiltAngle( value:Number ):void
		{
			_controller.currentTiltAngle = value;
		}
		public function get currentTiltAngle():Number
		{
			return _controller.currentTiltAngle;
		}
		
		public function step( dt:Number ):void
		{
			if ( !inputProcess ) return;
			var renderer:Renderer3D = ComponentUtil.getChildOfType(scene, Renderer3D);
			if (!renderer) return;
			
			if ( inputProcess.isInputDown( mouseMapping ) )
			{				
				if (!_active) {
					lastPanAngle = _controller.panAngle;
					lastTiltAngle = _controller.tiltAngle;
					lastMouseX = renderer.viewport.stage.mouseX;
					lastMouseY = renderer.viewport.stage.mouseY;
				}
				_active = true;
				
				_controller.panAngle = 0.3 * (renderer.viewport.stage.mouseX - lastMouseX) + lastPanAngle;
				_controller.tiltAngle = 0.3 * (renderer.viewport.stage.mouseY - lastMouseY) + lastTiltAngle;
			} else {
				_active = false;
			}
			
			if ( _targetComponent && _lookAtComponent ) {
				_controller.update();
			}
		}
	}
}





