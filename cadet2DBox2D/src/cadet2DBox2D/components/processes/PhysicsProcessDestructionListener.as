// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2DBox2D.components.processes
{
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2DestructionListener;

	public class PhysicsProcessDestructionListener extends b2DestructionListener
	{
		private var process	:PhysicsProcess;
		
		public function PhysicsProcessDestructionListener( process:PhysicsProcess )
		{
			this.process = process;
		}
		
		override public function SayGoodbyeJoint(joint:b2Joint):void
		{
			process.jointDestroyed(joint);
		}
	}
}