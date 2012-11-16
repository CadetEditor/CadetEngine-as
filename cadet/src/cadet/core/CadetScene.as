// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.core
{
	import cadet.events.ComponentEvent;
	import cadet.util.ComponentUtil;
	
	import flash.utils.getTimer;
	
	import flox.core.events.PropertyChangeEvent;
	
	import flox.app.managers.DependencyManager;
	
	public class CadetScene extends ComponentContainer implements ICadetScene
	{
		private var _framerate					:int = 60;
		private var _timeScale					:Number = 1;
		private var lastFrameTime				:int = getTimer();
		
		private var steppableComponents	:Vector.<IComponent>;
		
		protected var _dependencyManager	:DependencyManager;
		protected var _userData				:Object;
		
		public function CadetScene()
		{
			_dependencyManager = new DependencyManager();
			_userData = {};
			name = "Scene";
			_scene = this;
			
			steppableComponents = new Vector.<IComponent>();
			addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedToSceneHandler);
		}
				
		private function componentAddedToSceneHandler( event:ComponentEvent ):void
		{
			if ( event.component is ISteppableComponent == false ) return;
			steppableComponents.push(event.component);
			event.component.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
		}
		
		private function componentRemovedHandler( event:ComponentEvent ):void
		{
			steppableComponents.splice(steppableComponents.indexOf(event.component), 1);
			event.component.removeEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
		}
		
		public function step():void
		{
			var timeStep:Number = 1/_framerate;
			var currentTime:int = getTimer();
			var elapsed:int = currentTime - lastFrameTime;
			if ( elapsed < (timeStep*1000) )
			{
				return;
			}
			
			
			var dt:Number = timeStep * timeScale;
			for each ( var steppableComponent:ISteppableComponent in steppableComponents )
			{
				steppableComponent.step(dt);
			}
			validateNow();
			lastFrameTime = currentTime;
		}
		
		[Serializable][Inspectable( toolTip="This value should be set to match the framerate of SWF the scene will be playing within.")]
		public function set framerate( value:int ):void
		{
			_framerate = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_framerate", null, _framerate ) );
		}
		public function get framerate():int { return _framerate; }
		
		[Serializable][Inspectable(toolTip="This value scales the amount of time elapsing per step of the Cadet Scene. Eg 0.5 = half speed.")]
		public function set timeScale( value:Number ):void
		{
			_timeScale = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_timescale", null, _timeScale ) );
		}
		public function get timeScale():Number { return _timeScale; }
		
		override protected function childAdded(child:IComponent):void
		{
			super.childAdded(child);
			child.scene = this;
		}
		
		[Serializable]
		public function set dependencyManager( value:DependencyManager ):void
		{
			_dependencyManager = value;
		}
		public function get dependencyManager():DependencyManager { return _dependencyManager; }
		
		[Serializable( type="rawObject" )]
		public function set userData( value:Object ):void
		{
			_userData = value;
		}
		public function get userData():Object
		{
			return _userData;
		}
	}
}