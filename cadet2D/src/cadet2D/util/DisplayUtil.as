package cadet2D.util
{
	import starling.display.DisplayObject;

	public class DisplayUtil
	{
		static public function haveCommonParent(currentObject:DisplayObject, targetSpace:DisplayObject):Boolean
		{
			// 1. find a common parent of this and the target space
			var commonParent:DisplayObject = null;
			var sAncestors:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			while (currentObject)
			{
				sAncestors.push(currentObject);
				currentObject = currentObject.parent;
			}
			
			currentObject = targetSpace;
			while (currentObject && sAncestors.indexOf(currentObject) == -1)
				currentObject = currentObject.parent;
			
			sAncestors.length = 0;
			
			if (currentObject) {
				commonParent = currentObject;
				return true;
			}
			
			return false;
		}
	}
}