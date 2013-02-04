// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

// Inspectable Priority range 50-99

package cadet2D.components.behaviours
{
	import cadet.core.Component;
	import cadet.core.ISteppableComponent;
	
	import cadet2D.components.skins.AbstractSkin2D;
	
	public class ParallaxBehaviour extends Component implements ISteppableComponent
	{
		private var _skin			:AbstractSkin2D;
		private var _skin1			:AbstractSkin2D;
		private var _skin2			:AbstractSkin2D;
		
		private var _speed			:Number;
		private var _depth			:Number;
		
		private var _initialised	:Boolean = false;
		
		public function ParallaxBehaviour()
		{
			name = "ParallaxBehaviour";
		}
		
		// "skin" will be replaced each time a new skin sibling is added, hence usage of
		// "skin1" and "skin2" when updating skin positions.
		override protected function addedToScene():void
		{
			addSiblingReference( AbstractSkin2D, "skin" );
		}
		
		public function step(dt:Number):void
		{
			if (!_skin) return;
			
			// Initialisation of this behaviour will remove the skin and add in two duplicated DisplayObjects
			// in order to provide the continuous parallax effect. Initialisation has to happen within step() to
			// ensure this operation only executes while the scene is being stepped, i.e. not while in editor mode.
			if (!_initialised && _skin.displayObject && _skin.displayObject.parent) {
				initialise();
			}
			
			if (_initialised) {
				_skin1.x += Math.round(speed * depth);
				_skin2.x += Math.round(speed * depth);
				
				// if direction is left
				if ( speed < 0 ) {
					if ( _skin1.x + _skin1.width < 0 ) {
						_skin1.x = _skin2.x + _skin2.width;
					}
					if ( _skin2.x + _skin2.width < 0 ) {
						_skin2.x = _skin1.x + _skin1.width;
					}
				} 
				// if direction is right
				else {
					if ( _skin1.x > _skin.displayObject.stage.stageWidth ) {
						_skin1.x = _skin2.x - _skin1.width;
					}
					if ( _skin2.x > _skin.displayObject.stage.stageWidth ) {
						_skin2.x = _skin1.x - _skin2.width;
					}					
				}
				//trace("stage X "+_skin.displayObject.stage.x+" Y "+_skin.displayObject.stage.y+" W "+_skin.displayObject.stage.stageWidth+" H "+_skin.displayObject.stage.stageHeight);
			}
			
			//transform.x += Math.round(speed * depth);
		}
		
		private function initialise():void
		{
//			_skin.displayObject.parent.removeChild(_skin.displayObject);
			_skin1 = _skin;
			_skin2 = AbstractSkin2D(_skin1.clone());
			parentComponent.children.addItem(_skin2);
			_skin2.x = _skin.x + _skin.width;
			
			_initialised = true;
		}
		
		[Serializable][Inspectable( editor="Slider", min="0", max="1", snapInterval="0.05" )]
		public function set depth( value:Number ):void
		{
			_depth = value;
		}
		public function get depth():Number
		{
			return _depth;
		}
		
		[Serializable][Inspectable]
		public function set speed( value:Number ):void
		{
			_speed = value;
		}
		public function get speed():Number
		{
			return _speed;
		}
		
		public function set skin( value:AbstractSkin2D ):void
		{
			_skin = value;
		}
		public function get skin():AbstractSkin2D
		{
			return _skin;
		}
	}
}