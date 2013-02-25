package cadet2D.components.transforms
{
	import flash.geom.Matrix;

	public interface ITransform2D
	{
		function set x( value:Number ):void
		function get x():Number
		function set y( value:Number ):void
		function get y():Number
		function set scaleX( value:Number ):void
		function get scaleX():Number
		function set scaleY( value:Number ):void
		function get scaleY():Number
		function set rotation( value:Number ):void
		function get rotation():Number
		function set matrix( value:Matrix ):void
		function get matrix():Matrix
	}
}