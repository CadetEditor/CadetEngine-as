package cadet3D.components.lights
{
	import away3d.lights.PointLight;

	public class PointLightComponent extends AbstractLightComponent
	{
		public function PointLightComponent()
		{
			_object3D = _light = new PointLight();
			
			castsShadows = true;
		}
	}
}