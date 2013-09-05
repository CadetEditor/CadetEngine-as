package util
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import starling.utils.MatrixUtil;

	public class TransformUtil
	{
		public static function convertCoordSpace( parentMatrix:Matrix, childMatrix:Matrix ):Point
		{
			trace("parent globalMatrix "+parentMatrix);
			parentMatrix.invert(); // invert and get global-to-local
		
			trace("child globalMatrix "+childMatrix);
			// this is from Starling, but you can copy this method code as well - it's just 2 lines
			var pt:Point = MatrixUtil.transformCoords(parentMatrix, childMatrix.tx, childMatrix.ty);
			trace("globalToLocal point x "+pt.x+" y "+pt.y);

			return pt;
		}
	}
}