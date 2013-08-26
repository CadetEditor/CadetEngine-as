package cadet2D.components.skins
{
    import cadet.events.ValidationEvent;
    import cadet.util.deg2rad;

    import cadet2D.components.transforms.ITransform2D;
    import cadet2D.components.transforms.Transform2D;

    import flash.geom.Matrix;

    public class TransformableSkin extends AbstractSkin2D implements ITransform2D
	{
        private var _internalTransform:Transform2D = new Transform2D();

		public function TransformableSkin(name:String="AbstractSkin2D")
		{
			super(name);
		}

        [Serializable]
        public function set internalTransform(value:Transform2D):void
        {
            if( _internalTransform != null) {
                _internalTransform.removeEventListener(ValidationEvent.INVALIDATE, onInternalTransformInvalidated);
                _internalTransform.cleanUpParentTransform();
            }

            _internalTransform = value;

            // don't listen to internal transform's events, if sibling transform is available
            if( _internalTransform != null ) {
                if(_transform2D == null)
                    _internalTransform.addEventListener(ValidationEvent.INVALIDATE, onInternalTransformInvalidated);

                var parentTransform:Transform2D = Transform2D.findParentTransform(parentComponent.parentComponent);
                _internalTransform.setupParentTransform(parentTransform); // may be null
            }
        }
        public function get internalTransform():Transform2D { return _internalTransform; }

		// -------------------------------------------------------------------------------------
		// ITRANSFORM2D API
		// -------------------------------------------------------------------------------------

        [Inspectable( priority="50" )]
		public function set x( value:Number ):void
		{
            if( _transform2D != null )
                _transform2D.x = value;
            else
                _internalTransform.x = value;

            invalidate(TRANSFORM);
		}
		public function get x():Number { return _transform2D != null ? _transform2D.x : _internalTransform.x; }
		
		[Inspectable( priority="51" )]
		public function set y( value:Number ):void
		{
            if( _transform2D != null )
                _transform2D.y = value;
            else
                _internalTransform.y = value;

            invalidate(TRANSFORM);
		}
		public function get y():Number { return _transform2D != null ? _transform2D.y : _internalTransform.y; }
		
		[Inspectable( priority="52" )]
		public function set scaleX( value:Number ):void
		{
            if( _transform2D != null )
                _transform2D.scaleX = value;
            else
                _internalTransform.scaleX = value;

            invalidate(TRANSFORM);
		}
		public function get scaleX():Number { return _transform2D != null ? _transform2D.scaleX : _internalTransform.scaleX; }
		
		[Inspectable( priority="53" )]
		public function set scaleY( value:Number ):void
		{
            if( _transform2D != null )
                _transform2D.scaleY = value;
            else
                _internalTransform.scaleY = value;

            invalidate(TRANSFORM);
		}
		public function get scaleY():Number { return _transform2D != null ? _transform2D.scaleY : _internalTransform.scaleY; }
		
		[Inspectable( priority="54", editor="Slider", min="0", max="360", snapInterval="1" ) ]
		public function set rotation( value:Number ):void
		{
            if( _transform2D != null )
                _transform2D.rotation = value;
            else
                _internalTransform.rotation = value;

            invalidate(TRANSFORM);
		}
		public function get rotation():Number { return _transform2D != null ? _transform2D.rotation : _internalTransform.rotation; }
		
		public function set matrix( value:Matrix ):void
		{
            if( _transform2D != null )
                _transform2D.matrix = value;
            else
                _internalTransform.matrix = value;

			invalidate(TRANSFORM);
		}
		public function get matrix():Matrix  { return _transform2D != null ? _transform2D.matrix : _internalTransform.matrix; }

        public function get globalMatrix():Matrix{ return _transform2D != null ? _transform2D.globalMatrix : _internalTransform.globalMatrix; }

        public function get parentTransform():ITransform2D { return _transform2D != null ? _transform2D.parentTransform : _internalTransform.parentTransform; }
        public function set parentTransform(value:ITransform2D):void
        {
            throw new Error("setting parentTransform for TransformableSkin instance is not allowed");

            /*
            if( _transform2D != null )
                _transform2D.parentTransform = Transform2D(value);

            invalidate(TRANSFORM);
            */
        }

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

        [Serializable]
        override public function set transform2D(value:Transform2D):void
        {
            super.transform2D = value;

            // there's a sibling transform - listen to its events instead
            if( _transform2D == null) {
                _internalTransform.removeEventListener(ValidationEvent.INVALIDATE, onInternalTransformInvalidated);
                _internalTransform.addEventListener(ValidationEvent.INVALIDATE, onInternalTransformInvalidated);

                _internalTransform.cleanUpParentTransform();

                var parentTransform:Transform2D = Transform2D.findParentTransform(parentComponent.parentComponent);
                _internalTransform.setupParentTransform(parentTransform); // may be null
            }
            else {
                _internalTransform.removeEventListener(ValidationEvent.INVALIDATE, onInternalTransformInvalidated);
                _internalTransform.cleanUpParentTransform();
            }
        }

        override protected function addedToScene():void
        {
            if( internalTransform == null)
                internalTransform = new Transform2D();

            var excludedTypes:Vector.<Class> = new Vector.<Class>();
            excludedTypes.push(IRenderable);
            addSiblingReference(Transform2D, "transform2D", excludedTypes);

            invalidate(TRANSFORM);
        }

        override protected function validateTransform():void
        {
            if( _transform2D != null) {
                super.validateTransform();
            }
            else if( _internalTransform.parentTransform != null) {
                _displayObject.transformationMatrix = _internalTransform.globalMatrix;
            }
            // if this is a top-level transform, simply set the properties (may be faster)
            else {
                _displayObject.x = _internalTransform.x;
                _displayObject.y = _internalTransform.y;
                _displayObject.scaleX = _internalTransform.scaleX;
                _displayObject.scaleY = _internalTransform.scaleY;
                _displayObject.rotation = deg2rad(_internalTransform.rotation);
            }
        }

        protected function onInternalTransformInvalidated(event:ValidationEvent):void { invalidate(TRANSFORM); }
    }
}
