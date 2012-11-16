// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.renderPipeline.flash.components.skins
{
	import cadet2D.components.processes.WorldBounds2D;
	import cadet.events.InvalidationEvent;
	
	[CadetBuilder( transformable="false" )]
	public class WorldBoundsDebugSkin extends AbstractSkin2D
	{
		private var _worldBounds		:WorldBounds2D;
		
		public function WorldBoundsDebugSkin()
		{
			name = "WorldBoundsDebugSkin";
			sprite.mouseEnabled = false;
		}
		
		override protected function addedToScene():void
		{
			super.addedToScene();
			addSceneReference(WorldBounds2D, "worldBounds");
		}
		
		public function set worldBounds( value:WorldBounds2D ):void
		{
			if ( _worldBounds )
			{
				_worldBounds.removeEventListener(InvalidationEvent.INVALIDATE, invalidateBoundsHandler);
			}
			_worldBounds = value;
			if ( _worldBounds )
			{
				_worldBounds.addEventListener(InvalidationEvent.INVALIDATE, invalidateBoundsHandler);
			}
			invalidate(DISPLAY);
		}
		public function get worldBounds():WorldBounds2D { return _worldBounds; }
		
		private function invalidateBoundsHandler( event:InvalidationEvent ):void
		{
			invalidate(DISPLAY);
		}
		
		override public function validateNow():void
		{
			if ( isInvalid(DISPLAY) )
			{
				validateDisplay();
			}
		}
		
		private function validateDisplay():void
		{
			sprite.graphics.clear();
			if ( !_worldBounds) return;
			
			sprite.graphics.beginFill(0x00FF00, 0.2);
			sprite.graphics.drawRect( _worldBounds.left, _worldBounds.top, _worldBounds.right-_worldBounds.left, _worldBounds.bottom-_worldBounds.top );
		}
	}
}