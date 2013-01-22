// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.components.behaviours
{
	import cadet.components.processes.KeyboardInputProcess;
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	public class EntityUserControlBehaviour extends Component implements ISteppableComponent
	{
		[Serializable][Inspectable]
		public var upMapping			:String = "UP";
		[Serializable][Inspectable]
		public var downMapping			:String = "DOWN";
		[Serializable][Inspectable]
		public var leftMapping			:String = "LEFT";
		[Serializable][Inspectable]
		public var rightMapping			:String = "RIGHT";
		[Serializable][Inspectable]
		public var spaceMapping			:String = "SPACE";
		
		public var inputProcess		:KeyboardInputProcess;
		public var entityBehaviour	:IEntityUserControlledBehaviour;
		
		public function EntityUserControlBehaviour()
		{
			name = "EntityUserControlBehaviour";
		}
		
		override protected function addedToScene():void
		{
			addSiblingReference(IEntityUserControlledBehaviour, "entityBehaviour");
			addSceneReference( KeyboardInputProcess, "inputProcess" );
		}
		
		public function step(dt:Number):void
		{
			if ( !entityBehaviour ) return;
			if ( !inputProcess ) return;
			
			if ( inputProcess.isInputDown( upMapping ) )
			{
				entityBehaviour.up();
			}
			
			if ( inputProcess.isInputDown( downMapping ) )
			{
				entityBehaviour.down();
			}
			
			if ( inputProcess.isInputDown( leftMapping ) )
			{
				entityBehaviour.left();
			}
			
			if ( inputProcess.isInputDown( rightMapping ) )
			{
				entityBehaviour.right();
			}
			
			if ( inputProcess.isInputDown( spaceMapping ) )
			{
				entityBehaviour.space();
			}
		}
	}
}
















