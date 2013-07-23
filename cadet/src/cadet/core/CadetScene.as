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
	import flash.utils.getTimer;
	
	import cadet.events.ComponentEvent;
	
	import core.app.managers.DependencyManager;
	import core.events.PropertyChangeEvent;
	
	public class CadetScene extends ComponentContainer implements ICadetScene
	{
		private var _framerate					:int = 60;
		private var _timeScale					:Number = 1;
		private var _runMode					:Boolean = false;
		private var lastFrameTime				:int = getTimer();
		
		private var steppableComponents		:Vector.<IComponent>;
		private var initOnRunComponents		:Vector.<IComponent>;
		
		protected var _dependencyManager	:DependencyManager;
		protected var _userData				:Object;
		
		public function CadetScene()
		{
			_dependencyManager = new DependencyManager();
			name = "Scene";
			_scene = this;
			
			steppableComponents = new Vector.<IComponent>();
			initOnRunComponents = new Vector.<IComponent>();
			addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedToSceneHandler);
		}
				
		private function componentAddedToSceneHandler( event:ComponentEvent ):void
		{
			var component:IComponent = event.component;
			var onAList:Boolean = false; 
			
			if ( component is ISteppableComponent ) {
				steppableComponents.push(component);
				onAList = true;
			} 
			if ( component is IInitialisableComponent ) {
				initOnRunComponents.push(component);
				onAList = true;
				
				// if scene already running, init the component
				if ( runMode ) {
					IInitialisableComponent(component).init();
				}
			}
			
			if ( onAList ) {
				component.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
			}
		}
		
		private function componentRemovedHandler( event:ComponentEvent ):void
		{
			var component:IComponent = event.component;
			var steppableIndex:int = steppableComponents.indexOf(component);
			var initOnRunIndex:int = initOnRunComponents.indexOf(component);
			
			if ( steppableIndex != -1 ) {
				steppableComponents.splice(steppableIndex, 1);
			}
			
			if ( initOnRunIndex != -1 ) {
				initOnRunComponents.splice(initOnRunIndex, 1);
			}
			
			component.removeEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
		}
		
		public function step():void
		{
			if (!runMode) {
				for each ( var iORComponent:IInitialisableComponent in initOnRunComponents ) {
					iORComponent.init();
				}
				runMode = true;
			}
			
			var timeStep:Number = 1/_framerate;
			var currentTime:int = getTimer();
			var elapsed:int = currentTime - lastFrameTime;
			if ( elapsed < (timeStep*1000) ) {
				return;
			}
			
			
			var dt:Number = timeStep * timeScale;
			for each ( var steppableComponent:ISteppableComponent in steppableComponents ) {
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
		
		override protected function childAdded(child:IComponent, index:uint):void
		{
			super.childAdded(child, index);
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
		
		// runMode is set to "true" the first time the scene is "stepped" and all IInitialisableComponents are initialised.
		// Certain Processes and Behaviours may require the scene to behave differently at edit time and runtime,
		// for instance, a process might remove it's edit time Skins at runtime and generate them procedurally.
		// The default value is false.
		public function get runMode():Boolean
		{
			return _runMode;
		}
		public function set runMode( value:Boolean ):void
		{
			_runMode = value;
		}
		
		// Allow the scene to re-initialise components
		public function reset():void
		{
			_runMode = false;
		}
	}
}





