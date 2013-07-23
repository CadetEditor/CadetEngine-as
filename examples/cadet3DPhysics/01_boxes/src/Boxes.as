package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import cadet.core.CadetScene;
	
	import cadet3D.components.cameras.CameraComponent;
	import cadet3D.components.core.MeshComponent;
	import cadet3D.components.debug.TridentComponent;
	import cadet3D.components.geom.CubeGeometryComponent;
	import cadet3D.components.geom.PlaneGeometryComponent;
	import cadet3D.components.lights.DirectionalLightComponent;
	import cadet3D.components.materials.ColorMaterialComponent;
	import cadet3D.components.renderers.Renderer3D;
	
	import cadet3DPhysics.components.behaviours.RigidBodyBehaviour;
	import cadet3DPhysics.components.processes.PhysicsProcess;
	
	import components.behaviours.ApplyTorqueBehaviour;
	
	[SWF( width="700", height="400", backgroundColor="0x002135", frameRate="60" )]
	public class Boxes extends Sprite
	{
		private var cadetScene:CadetScene;
		
		private var defaultMaterial:ColorMaterialComponent;
		
		public function Boxes()
		{
			cadetScene = new CadetScene();
			
			// Add Renderer
			var renderer:Renderer3D = new Renderer3D();
			renderer.viewportWidth = stage.stageWidth;
			renderer.viewportHeight = stage.stageHeight;
			cadetScene.children.addItem(renderer);
			renderer.enable(this);
			
			// Add Trident
			var trident:TridentComponent = new TridentComponent();
			cadetScene.children.addItem(trident);
			
			// Add Camera
			var camera:CameraComponent = new CameraComponent();
			camera.rotationX = -145;
			camera.rotationY = -45;
			camera.rotationZ = -180;
			camera.x = 1000;
			camera.y = 1000;
			camera.z = 1000;
			cadetScene.children.addItem(camera);
			
			// Add Light source
			var dirLight:DirectionalLightComponent = new DirectionalLightComponent();
			dirLight.ambient = 0.3;
			dirLight.diffuse = 1;
			dirLight.rotationX = 65;
			dirLight.rotationY = -90;
			cadetScene.children.addItem(dirLight);
			
			// Add Physics Process
			cadetScene.children.addItem(new PhysicsProcess());
			
			// Add default Material
			defaultMaterial = new ColorMaterialComponent();
			cadetScene.children.addItem(defaultMaterial);
			
			// Create floor
			var planeGeometry:PlaneGeometryComponent = new PlaneGeometryComponent(6000, 6000);
			var planeEntity:MeshComponent = new MeshComponent();
			planeEntity.materialComponent = defaultMaterial;
			planeEntity.geometryComponent = planeGeometry;
			planeEntity.children.addItem(planeGeometry);
			planeEntity.children.addItem(new RigidBodyBehaviour());
			cadetScene.children.addItem(planeEntity);
			
			// Create cubes
			var sceneWidth:uint = 2000;
			var sceneHeight:uint = 6000;
			var sceneDepth:uint = 2000;
			var cubeSize:uint = 80;
			var variation:uint = 20;
			for ( var i:int = 0; i < 150; i++ )
			{
				var x:Number = Math.random() * sceneWidth - sceneWidth/2;
				var y:Number = Math.random() * sceneHeight;
				var z:Number = Math.random() * sceneDepth - sceneDepth/2;
				var width:Number = cubeSize + Math.random() * variation;
				var height:Number = cubeSize + Math.random() * variation;
				var depth:Number = cubeSize + Math.random() * variation;
				addCubeEntity( x, y, z, width, height, depth );
			}
			
			// Add big cube Material
			var bigCubeMaterial:ColorMaterialComponent = new ColorMaterialComponent();
			bigCubeMaterial.color = 0xFF0000;
			cadetScene.children.addItem(bigCubeMaterial);
			// Add big cube
			var bigCube:MeshComponent  = addCubeEntity( 0, 6500, 0, 200, 200, 200 );
			bigCube.materialComponent = bigCubeMaterial;
			bigCube.children.addItem(new ApplyTorqueBehaviour());
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function addCubeEntity( x:Number, y:Number, z:Number, width:Number, height:Number, depth:Number ):MeshComponent
		{
			var cubeGeometry:CubeGeometryComponent = new CubeGeometryComponent(width, height, depth);
			
			var entity:MeshComponent = new MeshComponent();
			entity.x = x;
			entity.y = y;
			entity.z = z;
			entity.materialComponent = defaultMaterial;
			entity.geometryComponent = cubeGeometry;
			entity.children.addItem(cubeGeometry);
			entity.children.addItem(new RigidBodyBehaviour());
			
			cadetScene.children.addItem(entity);
			
			return entity;
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}