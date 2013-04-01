package cadet.validators
{
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	import core.app.events.CollectionValidatorEvent;
	import core.app.util.ArrayUtil;
	import core.app.validators.CollectionValidator;
	import core.data.ArrayCollection;

	public class ComponentChildrenValidator extends CollectionValidator
	{
		public function ComponentChildrenValidator( collection:ArrayCollection, validType:Class, min:uint = 1, max:uint = uint.MAX_VALUE )
		{
			super( collection, validType, min, max );
		}
		
/*		public function validate(componentType:Class, selection:ArrayCollection):Boolean
		{
			_validType = componentType;
			var validItems:Array = [];
			
			for each ( var component:IComponentContainer in selection ) {
				recurseItems(component, validItems);
			}
			
			if ( validItems.length > 0 ) {
				return true;
			}
			
			return false;
		}
		*/
		override public function getValidItems():Array
		{
			if ( !_collection ) return [];
			var validItems:Array = [];//ArrayUtil.filterByType(_collection.source, _validType);
			
			for ( var i:uint = 0; i < _collection.length; i ++ ) {
				if ( _collection[i] is _validType ) {
					validItems.push( _collection[i] );
				}
				if ( _collection[i] is IComponentContainer ) {
					validItems = recurseItems(_collection[i], validItems);
				}
			}
			
			if ( validItems.length < _min ) return [];
			if ( validItems.length > _max ) return [];
			
			return validItems;
		}
		
		override protected function updateState():void
		{
			var validItems:Array = getValidItems();
			
			if ( validItems.length == 0 )
			{
				setState(false);
			}
			else
			{
				setState(true);
			}
			
			if( ArrayUtil.compare( oldCollection, validItems ) == false )
			{
				oldCollection = validItems;
				dispatchEvent( new CollectionValidatorEvent( CollectionValidatorEvent.VALID_ITEMS_CHANGED, validItems ) );
			}
		}
		
		private function recurseItems(parent:IComponentContainer, validItems:Array):Array
		{
			var newItems:Array = ArrayUtil.filterByType(parent.children.source, _validType);
			if ( newItems.length > 0 ) {
				validItems = validItems.concat(newItems);
			}
			
			for ( var i:uint = 0; i < parent.children.length; i ++ )
			{
				var child:IComponent = parent.children[i];
				if ( child is IComponentContainer ) {
					recurseItems(IComponentContainer(child), validItems);
				}
			}
			
			return validItems;
		}
	}
}