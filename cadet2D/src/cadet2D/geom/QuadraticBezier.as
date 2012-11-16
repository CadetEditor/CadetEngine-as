// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2D.geom
{
	public class QuadraticBezier
	{
		[Serializable] public var startX		:Number;
		[Serializable] public var startY		:Number;
		[Serializable] public var controlX		:Number;
		[Serializable] public var controlY		:Number;
		[Serializable] public var endX			:Number;
		[Serializable] public var endY			:Number;
		
		public function QuadraticBezier( startX:Number = 0, startY:Number = 0, controlX:Number = 0, controlY:Number = 0, endX:Number = 0, endY:Number = 0)
		{
			this.startX = startX;
			this.startY = startY;
			this.controlX = controlX;
			this.controlY = controlY;
			this.endX = endX;
			this.endY = endY;
		}
		
		public function clone():QuadraticBezier
		{
			return new QuadraticBezier( startX, startY, controlX, controlY, endX, endY );
		}
	}
}