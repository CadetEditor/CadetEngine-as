// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.entities
{
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	import cadet.assets.CadetEngineIcons;
	import cadet.validators.ComponentParentValidator;
	import cadet.validators.ComponentSiblingValidator;
	import cadet.validators.IComponentValidator;
	
	import core.app.resources.FactoryResource;
	
	public class ComponentFactory extends FactoryResource
	{
		private var _category				:String;
		private var compatibleParentType	:Class;
		private var maxSiblingsOfThisType	:int;
		private var _compatibleContextType	:Class;		// If specified during construction, this value indicates the type of context that must be focused for this component to appear in the AddComponent panel.
		private var _visible				:Boolean;	// If false, will not appear in 'add-component' dialogue.
		
		public var validators				:Vector.<IComponentValidator>;
		
		public function ComponentFactory(type:Class, 
										 label:String, 
										 category:String = null,
										 icon:Class = null,
										 requiredParentType:Class = null, 
										 maxSiblingsOfThisType:int = -1, 
										 requiredSiblingTypes:Array = null, 
										 compatibleContextType:Class = null,
										 visible:Boolean = true )
		{
			super(type, label, icon);
			
			_category = category;
			_icon = icon;
			_visible = visible;
			
			validators = new Vector.<IComponentValidator>();
			if ( requiredParentType != null )
			{
				validators.push(new ComponentParentValidator(requiredParentType));
			}
			else
			{
				validators.push(new ComponentParentValidator(IComponentContainer));
			}
			
			if ( maxSiblingsOfThisType != -1 || requiredSiblingTypes != null )
			{
				validators.push( new ComponentSiblingValidator(maxSiblingsOfThisType, requiredSiblingTypes ) );
			}
			
			_compatibleContextType = compatibleContextType;
		}
		
		public function get category():String
		{
			return _category;
		}
		
		override public function get icon():Class
		{
			if ( _icon == null )
			{
				return CadetEngineIcons.Component;
			}
			return super.icon;
		}
		
		override public function getInstance():Object
		{
			var instance:IComponent = IComponent(super.getInstance());
			instance.name = _label;
			return instance;
		}
		
		public function validate( parent:IComponentContainer ):Boolean
		{
			for each ( var validator:IComponentValidator in validators )
			{
				if ( validator.validate( _type, parent ) == false ) return false;
			}
			
			return true;
		}
		
		public function get compatibleContextType():Class { return _compatibleContextType; }
		
		public function get visible():Boolean
		{
			return _visible;
		}
	}
}