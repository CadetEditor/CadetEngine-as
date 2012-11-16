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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	public class AssetSkin extends AbstractSkin2D
	{
		protected var ASSET				:String = "asset";

		private var _fillBitmap			:BitmapData;
		private var _fillXOffset		:Number = 0;
		private var _fillYOffset		:Number = 0;
		
		protected var asset				:Bitmap;		
		
		public function AssetSkin()
		{
			name = "AssetSkin";
		}
		
		[Serializable][Inspectable]
		public function set fillXOffset( value:Number ):void
		{
			_fillXOffset = value;
			invalidate( ASSET );
		}
		public function get fillXOffset():Number { return _fillXOffset; }
		
		[Serializable][Inspectable]
		public function set fillYOffset( value:Number ):void
		{
			_fillYOffset = value;
			invalidate( ASSET );
		}
		public function get fillYOffset():Number { return _fillYOffset; }			
		
		[Serializable( type="resource" )][Inspectable(editor="ResourceItemEditor")]
		public function set fillBitmap( value:BitmapData ):void
		{
			_fillBitmap = value;
			invalidate( ASSET );
		}
		public function get fillBitmap():BitmapData { return _fillBitmap; }	
		
		
		override public function validateNow():void
		{
			if ( isInvalid(ASSET) )
			{
				validateAsset();
			}
			
			super.validateNow();
		}
		
		/*
		protected function validateAsset():void
		{
			if ( asset )
			{
				sprite.removeChild(asset);
			}
			
			if ( !_assetClass ) return;
			
			asset = new _assetClass();
			sprite.addChild(asset);
		}
		*/
		
		protected function validateAsset():void
		{
			if ( asset && sprite.contains(asset) )
			{
				sprite.removeChild(asset);
			}
			
			if ( !_fillBitmap ) return;
			
			asset = new Bitmap(_fillBitmap);
			asset.x = _fillXOffset;
			asset.y = _fillYOffset;
			sprite.addChild(asset);			
		}		
	}
}









