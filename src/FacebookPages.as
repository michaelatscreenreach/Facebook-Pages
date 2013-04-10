package
{
	import com.data.AssetManager;
	import com.data.SettingsManager;
	import com.display.FeedVisual;
	import com.errors.ErrorList;
	import com.errors.ErrorScreen;
	import com.graphics.TimerCircle;
	import com.greensock.TweenMax;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.ImageLoader;
	import com.michael.utils.ResizeText;
	import com.michael.utils.RotateAroundCenter;
	import com.requests.facebook.FacebookManager;
	import com.requests.facebook.FieldObject;
	import com.requests.facebook.objects.FeedObject;
	import com.requests.facebook.objects.Photo;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	[SWF(width="1280", height="720")]
	public class FacebookPages extends Sprite
	{
	
		/**
		 * 
		 * Facebook Pages
		 * Version 1.0.61
		 * 		 	 
		 */
		
		private var settings:SettingsManager;
		private var facebookManager:FacebookManager;
		private var bgContainer:Sprite;
		private var splashScreen:Bitmap;
		private var feedVisual:FeedVisual;
		private var likesText:TextField;
		private var thumb:Bitmap;
		private var title:TextField;
		private var currentFormat:TextFormat;
		private var loadingScreenSprite:*;	
		
		private static const APP_NAME:String = "Facebook Pages"
		private static const MAJOR:int=1;
		private static const MINOR:int=0;
		private static const BUILD:int=61;

		//splash timer		
		private var splashTimer:Timer;

		private var errorScreen:ErrorScreen;
		
		public function FacebookPages()
		{
			trace("--------------------------")
			trace("* " + APP_NAME)
			trace("* Version : " +MAJOR+"."+MINOR+"."+BUILD)
			trace("--------------------------")
			
			var am:AssetManager = AssetManager.init()
			loadingScreenSprite = new Sprite()
			splashScreen = AssetManager.getAssetByName("SplashScreen")
			addChild(loadingScreenSprite)
			loadingScreenSprite.addChild(splashScreen)						
			var loadingCircle:Bitmap = AssetManager.getAssetByName("LoadingAnim");			
			var r:RotateAroundCenter = new RotateAroundCenter()
			loadingScreenSprite.addChild(r)
			r.rotate(loadingCircle);
			r.scaleX = r.scaleY = 0.8
			r.x = (1280)/2 - 200
			r.y = 720 - r.height - 200
			settings = new SettingsManager()
			settings.eventDispatcher.addEventListener("AUTH_SUCCESS", onAuth)
			settings.authRequest()			
		}
		
		
		
		protected function onAuth(event:Event):void
		{
			settings.eventDispatcher.removeEventListener("AUTH_SUCCESS", onAuth)
			trace("AUTH Successful")
			settings.eventDispatcher.addEventListener("SETTINGS_LOADED", onSettingsLoaded)
			settings.loadSettings()	
			
		}
		
		protected function onSettingsLoaded(event:Event):void
		{
		facebookManager = new FacebookManager(settings.authToken, settings.disallowedList, settings)	
		
			settings.eventDispatcher.removeEventListener("SETTINGS_LOADED", onSettingsLoaded)
			var request:String = "https://graph.facebook.com/"+settings.facebookID+"";
			if(settings.allowUserContent == true){
				request +="/?fields=feed.limit("+settings.feedLimit+").fields(type,story,status_type,message,picture,object_id,application, from)" 
			} else {
				request+="/?fields=posts.fields(type,story,status_type,message,picture,object_id,application, from)" 

			}
			request+= ",photos.type(uploaded).limit(20).fields(images)"
			request+= ",cover,name,likes,location"
////			"&limit=20"+
			request+="&access_token="+settings.authToken.code		

			facebookManager.request = request			
			trace("* facebook request: " +request)
			facebookManager.eventDispatcher.addEventListener("NO_FEED", noFeed)
			facebookManager.getRequest(request)
			splashTimer = new Timer(settings.splashTime*1000, 1)
			splashTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onSplashTimerComplete)	
			splashTimer.start()
			
		}
		
		private function noFeed(e:Event):void
		{
			e.target.removeEventListener("NO_FEED", noFeed)			
			errorScreen = new ErrorScreen()
			if (settings.allowUserContent == true){				
				errorScreen.displayError(ErrorList.NO_POSTS_USER_CONTENT,{facebookName:facebookManager.name})
			} else if (settings.allowUserContent == false){
				errorScreen.displayError(ErrorList.NO_POSTS_MASTER,{facebookName:facebookManager.name})
			}
			addChild(errorScreen)
		}
		
		protected function onSplashTimerComplete(event:TimerEvent):void
		{		
			splashTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onSplashTimerComplete)	
			onRequest(null)			
		}
		
		protected function onRequest(event:Event):void
		{
			if (event !=null){
				event.target.removeEventListener("REQUEST_LOADED", onRequest)
				event.target.removeEventListener(Event.ENTER_FRAME,onRequest)
			}
			
			
//			if(facebookManager.disallowedFeedItems.indexOf("photoGroup") != -1){
			if(facebookManager.photoGroupObjects.length > 0 || facebookManager.feed.length > 0 ){		
				createDisplay()
			} else {
				this.addEventListener(Event.ENTER_FRAME, onRequest)
			}
//			}
		}
		
		private function createDisplay():void
		{
			//remove error message is it exists
			if (errorScreen != null){
				removeChild(errorScreen)
			}
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
			feedVisual = new FeedVisual(facebookManager.feed, facebookManager.photoGroupObjects,settings.timeBetweenObjects)
			feedVisual.addEventListener("NO_FEED", noFeed);
			addChild(feedVisual)
			facebookManager.started = true			
			facebookManager.eventDispatcher.addEventListener("UPDATE_DATA", onUpdate)
			addChild(loadingScreenSprite)
			TweenMax.to(splashScreen,0,{alpha:0, onComplete:function remove():void{removeChild(loadingScreenSprite)}});


			
			
		}
		
		protected function onUpdate(e:Event):void
		{
			facebookManager.eventDispatcher.removeEventListener("UPDATE_DATA", onUpdate)
			likesText.text = facebookManager.likes.toString().replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
			thumb.x = likesText.x - thumb.width -20
			thumb.y = (100 - thumb.width)/2
			ResizeText.resize(title, (1280 - title.x) - (1280 - thumb.x), currentFormat)				
			feedVisual.update()
				
			
		}
	}
}