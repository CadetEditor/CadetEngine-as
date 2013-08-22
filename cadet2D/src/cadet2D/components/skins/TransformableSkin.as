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

        protected var _globalMatrix             :Matrix = new Matrix();
		
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

            if(_transform2D) {
                _transform2D.x = value;
            }

            _x = value;

            invalidate(TRANSFORM);
		}
		public function get x():Number { return _transform2D ? _transform2D.x : _x; }
		
		[Inspectable( priority="51" )]
		public function set y( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}

            if(_transform2D) {
                _transform2D.y = value;
            }

            _y = value;

            invalidate(TRANSFORM);
		}
		public function get y():Number { return _transform2D ? _transform2D.y : _y; }
		
		[Inspectable( priority="52" )]
		public function set scaleX( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}

            if(_transform2D) {
                _transform2D.scaleX = value;
            }

            _scaleX = value;

            invalidate(TRANSFORM);
		}
		public function get scaleX():Number { return _transform2D ? _transform2D.scaleX : _scaleX; }
		
		[Inspectable( priority="53" )]
		public function set scaleY( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}

            if(_transform2D) {
                _transform2D.scaleY = value;
            }

            _scaleY = value;

            invalidate(TRANSFORM);
		}
		public function get scaleY():Number { return _transform2D ? _transform2D.scaleY : _scaleY; }
		
		[Inspectable( priority="54", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function set rotation( value:Number ):void
		{
			if ( isNaN(value) ) {
				throw( new Error( "value is not a number" ) );
			}

            if(_transform2D) {
                _transform2D.rotation = value;
            }

            _rotation = value;

            invalidate(TRANSFORM);
		}
		public function get rotation():Number { return _transform2D ? _transform2D.rotation : _rotation; }
		
		public function set matrix( value:Matrix ):void
		{
            if(_transform2D) {
                _transform2D.matrix = value;
                _x = value.tx;
                _y = value.ty;
                _scaleX = Math.sqrt(value.a * value.a + value.b * value.b);
                _scaleY = Math.sqrt(value.c * value.c + value.d * value.d);
                _rotation = rad2deg(Math.atan(value.b / value.a));
            }
            else {
                _displayObject.transformationMatrix = value;
                _x = _displayObject.x;
                _y = _displayObject.y;
                _scaleX = _displayObject.scaleX;
                _scaleY = _displayObject.scaleY;
                _rotation = rad2deg(_displayObject.rotation);
            }

			invalidate(TRANSFORM);
		}
		public function get matrix():Matrix 
		{ 
			if (isInvalid(TRANSFORM)) {
				validateTransform();
			}
			
			return _displayObject.transformationMatrix; 
		}

        public function get globalMatrix():Matrix{ return _transform2D ? _transform2D.globalMatrix : _globalMatrix; }
        public function get parentTransform():ITransform2D { return _transform2D ? _transform2D.parentTransform : null; }

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
            if(_transform2D) {
			    super.validateTransform();
            }
            else {
                _displayObject.x = _x;
                _displayObject.y = _y;
                _displayObject.scaleX = _scaleX;
                _displayObject.scaleY = _scaleY;
                _displayObject.rotation = deg2rad(_rotation);
                _displayObject.getTransformationMatrix(null, _globalMatrix);
            }
		}
    }
}
