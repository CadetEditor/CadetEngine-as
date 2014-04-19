package cadet3D.components.renderers
{
	import flash.display.DisplayObjectContainer;
	
	import cadet.core.IRenderer;

	public interface IRenderer3D extends IRenderer
	{
		function enable(parent:DisplayObjectContainer, depth:int = -1):void;
		function disable(parent:DisplayObjectContainer):void;
	}
}