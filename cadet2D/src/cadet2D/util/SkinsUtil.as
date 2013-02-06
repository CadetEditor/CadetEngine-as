package cadet2D.util
{
	import cadet2D.components.skins.AbstractSkin2D;

	public class SkinsUtil
	{
		public static function sortSkinsById( skinA:AbstractSkin2D, skinB:AbstractSkin2D):int
		{
			var skinA_Ids:Array = skinA.indexStr.split("_");
			var skinB_Ids:Array = skinB.indexStr.split("_");
			
			var longest:uint = Math.max(skinA_Ids.length, skinB_Ids.length);
			var index:uint = 0;
			
			while ( index < longest ) {
				var idA:Number = index < skinA_Ids.length ? skinA_Ids[index] : -1;
				var idB:Number = index < skinB_Ids.length ? skinB_Ids[index] : -1;
				
				if ( idA < idB ) {
					return -1;
				} else if ( idA > idB ) {
					return 1;
				}
				index ++;
			}
			
			return 0;
		}
	}
}