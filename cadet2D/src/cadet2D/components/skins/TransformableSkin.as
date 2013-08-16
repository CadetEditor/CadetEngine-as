package cadet2D.components.skins
{
	import flash.geom.Matrix;
	
	import cadet.util.deg2rad;
	import cadet.util.rad2deg;
	
	import cadet2D.components.transforms.ITransform2D;

	public class TransformableSkin extends AbstractSkin2D implements ITransform2D
	{
		// ITransform2D
		protected var _x						:Number = 0;
		protected var _y						:Number = 0;
		protected var _scaleX					:Number = 1;
		protected var _scaleY					:Number = 1;
		protected var _rotation					:Number = 0;
		
		public function TransformableSkin(name:String="AbstractSkin2D")
		{
			super(name);
		}
		
		// -------------------------------------------------------------------------------------
		// ITRANSFORM2D API
		// -------------------------------------------------------------------------------------

        [Inspectable( priority="50" )]
		public function set x( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_x = value;
			invalidate(TRANSFORM);
		}
		public function get x():Number { return _x; }
		
		[Inspectable( priority="51" )]
		public function set y( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_y = value;
			invalidate(TRANSFORM);
		}
		public function get y():Number { return _y; }
		
		[Inspectable( priority="52" )]
		public function set scaleX( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_scaleX = value;
			invalidate(TRANSFORM);
		}
		public function get scaleX():Number { return _scaleX; }
		
		[Inspectable( priority="53" )]
		public function set scaleY( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_scaleY = value;
			invalidate(TRANSFORM);
		}
		public function get scaleY():Number { return _scaleY; }
		
		[Inspectable( priority="54", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function set rotation( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}
			
			_rotation = value;
			invalidate(TRANSFORM);
		}
		public function get rotation():Number { return _rotation; }
		
		public function set matrix( value:Matrix ):void
		{
			_displayObject.transformationMatrix = value;
			_x = _displayObject.x;
			_y = _displayObject.y;
			_scaleX = _displayObject.scaleX;
			_scaleY = _displayObject.scaleY;
			_rotation = rad2deg(_displayObject.rotation);
			
			invalidate(TRANSFORM);
		}
		public function get matrix():Matrix 
		{ 
			if (isInvalid(TRANSFORM)) {
				validateTransform();
			}
			
			return _displayObject.transformationMatrix; 
		}

        public function get globalMatrix():Matrix { throw new Error("unimplemented"); }
        public function get parentTransform():ITransform2D { throw new Error("unimplemented"); }

        [Serializable(alias="matrix")]
		public function set serializedMatrix( value:String ):void
		{
			var split:Array = value.split( "," );
			matrix = new Matrix( split[0], split[1], split[2], split[3], split[4], split[5] );
		}
		
		public function get serializedMatrix():String 
		{ 
			var m:Matrix = matrix;
			return m.a + "," + m.b + "," + m.c + "," + m.d + "," + m.tx + "," + m.ty;
		}

		// -------------------------------------------------------------------------------------
		
		override protected function validateTransform():void
		{
			// A sibling transform component takes precedence over directly setting x, y, etc.
			if (_transform2D) {
				_x = _transform2D.x;
				_y = _transform2D.y;
				_scaleX = _transform2D.scaleX;
				_scaleY = _transform2D.scaleY;
				_rotation = _transform2D.rotation;
				//	return;
			}
			
			_displayObject.x = _x;
			_displayObject.y = _y;
			_displayObject.scaleX = _scaleX;
			_displayObject.scaleY = _scaleY;
			_displayObject.rotation = deg2rad(_rotation);
		}
    }
}