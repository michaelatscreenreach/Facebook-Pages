package com.data
{
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.text.engine.FontWeight;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	public class AssetManager
	{
		
		private static var instance:AssetManager

		[Embed(source="/../ASSETS/blackoverlay.png")] private var BlackOverlay:Class;
		[Embed(source="/../ASSETS/facebookLogo.png")] private var FacebookLogo:Class;
		[Embed(source="/../ASSETS/like.png")] private var Like:Class;
		[Embed(source="/../ASSETS/smalllike.png")] private var SmallLike:Class;
		[Embed(source="/../ASSETS/smallcomment.png")] private var SmallComment:Class;
		[Embed(source="/../ASSETS/loadingscreen.png")] private var SplashScreen:Class;
		[Embed(source="/../ASSETS/line.png")] private var Line:Class;



		[Embed(source="/../ASSETS/Fonts/MyriadPro-Regular.otf", fontName="myriad", mimeType="application/x-font", fontWeight="normal", fontStyle="normal", embedAsCFF="false")]  private var MyriadFont:Class;


		public static var wallPostTitleFormat:TextFormat = new TextFormat("myriad", 46, 0xFFFFFF, null,null,null,null,null,"left", null, null, null)
		public static var wallPostCommentFormat:TextFormat = new TextFormat("myriad", 46, 0xFFFFFF, null,null,null,null,null,"left", null, null,null,-10)
		public static var photoGroupCommentFormat:TextFormat = new TextFormat("myriad", 42, 0, null,null,null,null,null,"left", null, null, null)
		public static var pollFormat:TextFormat = new TextFormat("myriad", 56, 0xFFFFFF, null,null,null,null,null,"left", null, null, null)


		public static var dateFormat:TextFormat = new TextFormat("myriad", 36, 0xFFFFFF, null,null,null,null,null,"left", null, null, null)

		public static var headerFormat:TextFormat = new TextFormat("myriad", 51, 0xFFFFFF, null,null,null,null,null,"left", null, null, null)
		public static var headerNoCheckinFormat:TextFormat = new TextFormat("myriad", 62, 0xFFFFFF, null,null,null,null,null,"left", null, null, null)
		public static var likesFormat:TextFormat = new TextFormat("myriad", 70, 0xFFFFFF, null,null,null,null,null,"left", null, null, null)

			
		public function AssetManager()
		{
			
		}
		
		public static function init():AssetManager{
			if(instance==null){
				instance=new AssetManager()
			}
			return instance 
		}
		
		public static function getAssetByName(type:String):*{
			var className:String = describeType(instance).@name.toXMLString();
			var fullname:String = className + "_" + type;
			var ref:Object = getDefinitionByName(fullname);
			return new ref();
		}
	}
}