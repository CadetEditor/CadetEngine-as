package cadet2D.components.skins
{
	public interface IAnimatable extends IRenderable
	{
		function addToJuggler():Boolean
		function removeFromJuggler():Boolean
			
		function get isAnimating():Boolean
		
		function set previewAnimation( value:Boolean ):void;
		function get previewAnimation():Boolean;
	}
}