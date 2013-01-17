package
{
	import com.data.AssetManager;
	import com.data.SettingsManager;
	import com.display.FeedVisual;
	import com.graphics.TimerCircle;
	import com.greensock.TweenMax;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.ImageLoader;
	import com.michael.utils.ResizeText;
	import com.requests.facebook.FacebookManager;
	import com.requests.facebook.FieldObject;
	import com.requests.facebook.objects.FeedObject;
	import com.requests.facebook.objects.Photo;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	[SWF(width="1280", height="720")]
	public class FacebookPages extends Sprite
	{
	
		private var settings:SettingsManager;
		private var facebookManager:FacebookManager;
		private var bgContainer:Sprite;
		private var splashScreen:Bitmap;
		private var feedVisual:FeedVisual;
		private var likesText:TextField;
		private var thumb:Bitmap;
		private var title:TextField;
		private var currentFormat:TextFormat;
		
		public function FacebookPages()
		{
			var am:AssetManager = AssetManager.init()
			splashScreen = AssetManager.getAssetByName("SplashScreen")
			addChild(splashScreen)
			settings = new SettingsManager()
			settings.eventDispatcher.addEventListener("AUTH_SUCCESS", onAuth)
			settings.authRequest()
		}
		
		protected function onAuth(event:Event):void
		{
			settings.eventDispatcher.removeEventListener("AUTH_SUCCESS", onAuth)
			trace("AUTH")
			settings.eventDispatcher.addEventListener("SETTINGS_LOADED", onSettingsLoaded)
			settings.loadSettings()			
		}
		
		protected function onSettingsLoaded(event:Event):void
		{
		facebookManager = new FacebookManager(settings.authToken, settings.disallowedList, settings)			
		
		var request:String = "https://graph.facebook.com/"+settings.facebookID+"" +		
//		var request:String = "https://graph.facebook.com/the-buck-inn" +		
			"/?fields=feed.limit("+settings.feedLimit+").fields(type,likes,story,status_type,message,picture,object_id,application, from)" +
//			"/?fields=feed.limit(100).fields(type,likes,story,status_type,message,picture,object_id,application, from)" +			

			",photos.type(uploaded).limit(20).fields(images,comments)" +
			",cover,name,likes,location"+
//			"&limit=20"+
			"&access_token="+settings.authToken.code		

		facebookManager.request = request			
		trace(request)
		facebookManager.eventDispatcher.addEventListener("REQUEST_LOADED", onRequest)
		facebookManager.getRequest(request)
			
		}
		
		protected function onRequest(event:Event):void
		{
			event.target.removeEventListener("REQUEST_LOADED", onRequest)
			event.target.removeEventListener(Event.ENTER_FRAME,onRequest)
			if(facebookManager.feed.length > 0){
			createDisplay()
			} else {
			this.addEventListener(Event.ENTER_FRAME, onRequest)
			}
		}
		
		private function createDisplay():void
		{
			//create background
			bgContainer = new Sprite()
			addChild(bgContainer)		
			var fbCover:String
			if (facebookManager.cover == null){
				fbCover="http://media.screa.ch.s3.amazonaws.com/resources/facebookPages/map.png"
			} else {
				fbCover = facebookManager.cover.source
			}
			var bgLoader:ImageLoader = new ImageLoader(fbCover, {name:"cover", width:1280, height:720,scaleMode:"proportionalOutside", container:bgContainer, autoDispose:true})
			TweenMax.to(bgLoader.content, 0, {blurFilter:{blurX:20, blurY:20, quality:2}});
			bgContainer.addChild(AssetManager.getAssetByName("BlackOverlay"))
			bgLoader.load()
			//create header
			var header:Sprite = new Sprite()
			header.graphics.beginFill(0, 0.38)
			header.graphics.drawRect(0,0,1280,100)
			header.graphics.endFill()
			addChild(header)
			TweenMax.to(header,0,{dropShadowFilter:{color:0x000000, alpha:0.35, blurX:5, blurY:5, angle:90, distance:3}});
			//add facebook logo
			var facebookLogo:Bitmap = AssetManager.getAssetByName("FacebookLogo")
			header.addChild(facebookLogo)
			facebookLogo.x = 10
			facebookLogo.y = 8
			//page title
			title = new TextField()
			title.embedFonts
			title.autoSize = "left"			
			title.text = facebookManager.name.toUpperCase()
						if (facebookManager.checkinDataAvailable){
			currentFormat = AssetManager.headerFormat
			title.x = 111
			title.y = -5
			} else {
			currentFormat = AssetManager.headerNoCheckinFormat		
			title.x = 111
			title.y = 10
			}			
			
			title.setTextFormat(currentFormat)		
			header.addChild(title)
			//add likes
			likesText = new TextField()
			likesText.embedFonts
			likesText.autoSize = "right"
			likesText.defaultTextFormat = AssetManager.likesFormat
			likesText.text = facebookManager.likes.toString().replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
			likesText.x = 1280 - likesText.width -10
			likesText. y = 5
			header.addChild(likesText)
			//add like symbol
			thumb = AssetManager.getAssetByName("Like")
			header.addChild(thumb)
			thumb.x = likesText.x - thumb.width -20
			thumb.y = (100 - thumb.width)/2
			//resize and move title
			ResizeText.resize(title, (1280 - title.x) - (1280 - thumb.x), currentFormat)
			//add custom message
			var customMessage:TextField = new TextField()
			customMessage.embedFonts
			customMessage.autoSize = "right"
			customMessage.defaultTextFormat = AssetManager.likesFormat
			customMessage.text = settings.customMessage
			ResizeText.resize(customMessage, 1100, AssetManager.likesFormat)
			customMessage.x = 10
			customMessage. y = stage.stageHeight - customMessage.height -10
			
			header.addChild(customMessage)
			//create feed
			feedVisual = new FeedVisual(facebookManager.feed, facebookManager.photos,settings.timeBetweenObjects)
			addChild(feedVisual)
			facebookManager.started = true			
			facebookManager.eventDispatcher.addEventListener("UPDATE_DATA", onUpdate)
			addChild(splashScreen)
			TweenMax.to(splashScreen,2,{alpha:0, onComplete:function remove():void{removeChild(splashScreen)}});


			
			
		}
		
		protected function onUpdate(e:Event):void
		{
			likesText.text = facebookManager.likes.toString().replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
			thumb.x = likesText.x - thumb.width -20
			thumb.y = (100 - thumb.width)/2
			ResizeText.resize(title, (1280 - title.x) - (1280 - thumb.x), currentFormat) 
				
			feedVisual.update()
				
			
		}
	}
}