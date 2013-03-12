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
    /** Converts an angle from degrees into radians. */
    public function deg2rad(deg:Number):Number
    {
        return deg / 180.0 * Math.PI;   
    }
}