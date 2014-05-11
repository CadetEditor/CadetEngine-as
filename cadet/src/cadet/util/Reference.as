package cadet.util
{
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.events.ComponentContainerEvent;

	public class Reference
	{
		public var type:Class;
		public var host:IComponent;
		public var property:String;
		public var target:IComponentContainer;
		
		private var _excludedComponents:Vector.<IComponent>;
		private var _excludedTypes:Vector.<Class>;
		
		public function Reference( target:IComponentContainer, type:Class, host:IComponent, property:String, excludedTypes:Vector.<Class> = null )
		{
			init( target, type, host, property, excludedTypes );
		}
		
		public function init( target:IComponentContainer, type:Class, host:IComponent, property:String, excludedTypes:Vector.<Class> = null ):void
		{
			this.target = target;
			this.type = type;
			this.host = host;
			this.property = property;
			
			target.addEventListener(ComponentContainerEvent.CHILD_ADDED, childAddedHandler);
			target.addEventListener(ComponentContainerEvent.CHILD_REMOVED, childRemovedHandler);
			
			_excludedComponents = new Vector.<IComponent>();
			_excludedComponents.push(host);
			
			_excludedTypes = excludedTypes;
			
			host[property] = ComponentUtil.getChildOfType(target, type, false, _excludedComponents, _excludedTypes);
		}
		
		public function dispose():void
		{
			target.removeEventListener(ComponentContainerEvent.CHILD_ADDED, childAddedHandler);
			target.removeEventListener(ComponentContainerEvent.CHILD_REMOVED, childRemovedHandler);
			
			host[property] = null;
			
			target = null;
			host = null;
			type = null;
			property = null;
		}	
		
		private function childAddedHandler( event:ComponentContainerEvent ):void
		{
			if ( event.child is type && !ComponentUtil.isExcluded(event.child, _excludedComponents, _excludedTypes) )
			{
				host[property] = event.child;
			}
		}
		
		private function childRemovedHandler( event:ComponentContainerEvent ):void
		{
			// Presumes there will only be one sibling of a type
			if ( event.child is type && !ComponentUtil.isExcluded(event.child, _excludedComponents, _excludedTypes) )
			{
				host[property] = null;
			}
		}
	}
}