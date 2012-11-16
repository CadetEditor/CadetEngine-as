// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet3D.components.debug
{	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.debug.Trident;
	import away3d.debug.data.TridentLines;
	import away3d.entities.Mesh;
	import away3d.extrusions.LatheExtrude;
	import away3d.materials.ColorMaterial;
	import away3d.tools.commands.Merge;
	
	import cadet3D.components.core.Object3DComponent;
	
	import flash.geom.Vector3D;

	public class TridentComponent extends Object3DComponent
	{
		private var _mesh				:Mesh;
		
		private var _length				:uint;
		private var _showLetters		:Boolean;
	
		private static const DISPLAY	:String = "display";
		
		public function TridentComponent(length:uint = 500, showLetters:Boolean = true)
		{
			_object3D = _mesh = new Mesh();
			_mesh.castsShadows = false;
			
			_length = length;
			_showLetters = showLetters;
			
			invalidate( DISPLAY );
		}
		
		[Serializable][Inspectable( priority="1" )]
		public function set length( value:uint ):void
		{
			if ( _length == value ) return;
			
			_length = value;
			invalidate( DISPLAY );
		}
		public function get length():uint
		{
			return _length;
		}
		
		[Serializable][Inspectable( priority="2" )]
		public function set showLetters( value:Boolean ):void
		{
			if (_showLetters == value ) return;
			
			_showLetters = value;
			invalidate( DISPLAY );
		}
		public function get showLetters():Boolean
		{
			return _showLetters;
		}
		
		override protected function validate():void
		{
			if ( isInvalid( DISPLAY ) )
			{
				validateDisplay();
			}
		}
		
		private function validateDisplay():void
		{
			while ( _mesh.numChildren ) {
				var child:ObjectContainer3D = _mesh.getChildAt(0);
				_mesh.removeChild(child);
			}
			
			buildTrident(_length, _showLetters);
		}
		
		override public function dispose():void
		{
			super.dispose();
			_mesh.dispose();
		}
		
		public function get mesh():Mesh
		{
			return _mesh;
		}
		
		private function buildTrident(length:Number, showLetters:Boolean):void
		{
			_mesh.geometry = new Geometry();
			
			var base:Number = length*.9;
			var rad:Number = 2.4;
			var offset:Number = length*.025;
			var vectors:Vector.<Vector.<Vector3D>> = new Vector.<Vector.<Vector3D>>();
			var colors:Vector.<uint> = Vector.<uint>([0xFF0000, 0x00FF00, 0x0000FF]);
			
			var matX:ColorMaterial = new ColorMaterial(0xFF0000);
			var matY:ColorMaterial = new ColorMaterial(0x00FF00);
			var matZ:ColorMaterial = new ColorMaterial(0x0000FF);
			var matOrigin:ColorMaterial = new ColorMaterial(0xCCCCCC);
			
			var merge:Merge = new Merge(true, true);
			
			var profileX:Vector.<Vector3D> = new Vector.<Vector3D>();
			profileX[0] = new Vector3D(length, 0 , 0);
			profileX[1] = new Vector3D(base, 0, offset);
			profileX[2] = new Vector3D(base, 0, -rad);
			vectors[0] = Vector.<Vector3D>([new Vector3D(0, 0, 0), new Vector3D(base, 0, 0) ]);
			var arrowX:LatheExtrude = new LatheExtrude(matX, profileX, LatheExtrude.X_AXIS, 1, 10);
			
			var profileY:Vector.<Vector3D> = new Vector.<Vector3D>();
			profileY[0] = new Vector3D(0, length, 0);
			profileY[1] = new Vector3D(offset, base, 0);
			profileY[2] = new Vector3D(-rad, base, 0);
			vectors[1] = Vector.<Vector3D>([new Vector3D(0, 0, 0), new Vector3D(0, base, 0) ]);
			var arrowY:LatheExtrude = new LatheExtrude(matY, profileY, LatheExtrude.Y_AXIS, 1, 10);
			
			var profileZ:Vector.<Vector3D> = new Vector.<Vector3D>();
			vectors[2] = Vector.<Vector3D>([new Vector3D( 0, 0, 0), new Vector3D( 0, 0, base) ]);
			profileZ[0] = new Vector3D( 0, rad, base);
			profileZ[1] = new Vector3D( 0, offset, base);
			profileZ[2] = new Vector3D( 0 , 0, length);
			var arrowZ:LatheExtrude = new LatheExtrude(matZ, profileZ, LatheExtrude.Z_AXIS, 1, 10);
			
			var profileO:Vector.<Vector3D> = new Vector.<Vector3D>();
			profileO[0] = new Vector3D( 0 , rad, 0);
			profileO[1] = new Vector3D( -(rad*.7) , rad*.7, 0);
			profileO[2] = new Vector3D( -rad, 0, 0);
			profileO[3] = new Vector3D( -(rad*.7), -(rad*.7), 0);
			profileO[4] = new Vector3D( 0, -rad, 0);
			var origin:LatheExtrude = new LatheExtrude(matOrigin, profileO, LatheExtrude.Y_AXIS, 1, 10);
			
			merge.applyToMeshes(_mesh, Vector.<Mesh>([arrowX, arrowY, arrowZ, origin]));
			
			if(showLetters){
				
				var scaleH:Number = length/10;
				var scaleW:Number = length/20;
				offset = length-scaleW;
				
				var scl1:Number = scaleW*1.5;
				var scl2:Number = scaleH*3;
				var scl3:Number = scaleH*2;
				var scl4:Number = scaleH*3.4;
				var cross:Number = length+(scl3) + (  ((length+scl4) - (length+scl3)) /3  * 2);
				
				//x
				vectors[3] = Vector.<Vector3D>([	new Vector3D(length+scl2, scl1 , 0),
					new Vector3D(length+scl3, -scl1 , 0),
					new Vector3D(length+scl3, scl1 , 0),
					new Vector3D(length+scl2, -scl1 , 0)] );
				//y
				vectors[4] = Vector.<Vector3D>([	new Vector3D(-scaleW*1.2, length+scl4,0),
					new Vector3D( 0, cross, 0),
					new Vector3D(scaleW*1.2, length+scl4,0),
					new Vector3D( 0, cross, 0),
					new Vector3D( 0, cross, 0),
					new Vector3D( 0, length+scl3, 0)] );
				
				//z
				vectors[5] = Vector.<Vector3D>([	new Vector3D(0, scl1, length+scl2),
					new Vector3D(0, scl1, length+scl3),
					new Vector3D(0, -scl1, length+scl2),
					new Vector3D(0, -scl1, length+scl3),
					new Vector3D(0, -scl1, length+scl3),
					new Vector3D(0, scl1, length+scl2)] );
				
				colors.push(0xFF0000, 0x00FF00, 0x0000FF);
			}
			
			_mesh.addChild(new TridentLines(vectors, colors));
			
			arrowX = arrowY = arrowZ = origin = null;
		}
	}
}













