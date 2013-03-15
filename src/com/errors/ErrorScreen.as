package com.errors
{
	import com.data.AssetManager;
	import com.data.SettingsManager;
	import com.errors.ErrorList
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class ErrorScreen extends Sprite
	{		
		private var backgroundImage:Bitmap		
		
		public function ErrorScreen()
		{
		
		}
		
		public function displayError(errorType:String, params:Object):void{
			
			backgroundImage = AssetManager.getAssetByName("ERROR_"+errorType)
			addChild(backgroundImage)
			
			switch (errorType){
				case ErrorList.NO_POSTS_USER_CONTENT:
					var facebookName:TextField = new TextField()
					facebookName.embedFonts = true	
					facebookName.defaultTextFormat = AssetManager.errorFormat	
					facebookName.autoSize = "center"
					facebookName.text = params.facebookName
					facebookName.x = 90
					facebookName.y = 350
					addChild(facebookName)	
				break;
				case ErrorList.NO_POSTS_MASTER:
					var facebookName2:TextField = new TextField()
					facebookName2.embedFonts = true	
					facebookName2.defaultTextFormat = AssetManager.errorFormat	
					facebookName2.autoSize = "center"
					facebookName2.text = params.facebookName
					facebookName2.x = 90
					facebookName2.y = 350
					addChild(facebookName2)
					break;		
				default:
				throw (new Error("Unknown Error"));
				break
					
			}
			
			
			
		}
	}
}