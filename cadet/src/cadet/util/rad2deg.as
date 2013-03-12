// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet.util
{
    /** Converts an angle from radions into degrees. */
    public function rad2deg(rad:Number):Number
    {
        return rad / Math.PI * 180.0;            
    }
}