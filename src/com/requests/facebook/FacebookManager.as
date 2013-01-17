package com.requests.facebook
{
	import com.adobe.serialization.json.*;
	import com.data.SettingsManager;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.*;
	import com.requests.auth.OAuthToken;
	import com.requests.facebook.objects.Cover;
	import com.requests.facebook.objects.FeedObject;
	import com.requests.facebook.objects.Photo;
	import com.requests.facebook.objects.PhotoGroup;
	import com.requests.facebook.objects.PollOption;
	
	import flash.events.*;
	import flash.utils.Timer;

	public class FacebookManager
	{
		public var eventDispatcher:EventDispatcher		
		public var name:String
		public var authToken:OAuthToken
		public var disallowedFeedItems:Array		
		public var cover:Cover
		public var photos:Array
		public var checkinDataAvailable:Boolean
		public var checkins:int
		public var likes:int
		public var feed:Array
		private var settings:SettingsManager
		public var request:String
		public var refreshTime:String
		public var started:Boolean = false;
		

		private var dataPhotosLength:uint;
		
		
		public function FacebookManager(auth:OAuthToken, disallowedFeedItemsList:Array, settings:SettingsManager)
		{			
			this.settings = settings
			refreshTime = settings.refreshTime
			disallowedFeedItems = disallowedFeedItemsList
			authToken = auth
			feed = new Array()
			photos = new Array()
			eventDispatcher = new EventDispatcher()
		}		
		
		public function getRequest(request:String):void{
			var requestLoader:DataLoader = new DataLoader(request, {name:"request", onComplete:parseRequest, autoDispose:true, allowMalformedURL:true})
			requestLoader.load()
			request = null
		}
		
		public function parseRequest(e:LoaderEvent):void{
			var jsonData:Object = JSON.decode(e.target.content)			
			
			if (jsonData.cover !=undefined){
				cover = new Cover(jsonData.cover)				
			}
			if (jsonData.name == undefined){
				throw new Error("Facebook Manager needs to be provided with a name, please check JSON")
			} 
			name = jsonData.name
			
			//check in checkins data exists
			if (jsonData.checkins == undefined){
				checkinDataAvailable = false
			} else {
				checkins = jsonData.checkins
			}
			
			if(jsonData.likes !=undefined){
				likes = jsonData.likes
			}
			
			
			if (jsonData.feed !=null && jsonData.feed !=undefined){
				
				for each (var fo:Object in jsonData.feed.data) 
				{
					var allowed:Boolean = true
					for each (var disallowedFeed:String in disallowedFeedItems) 
					{
//						trace(settings.allowUserContent)
						if (fo.type == disallowedFeed){
						allowed = false
						} if (!settings.allowUserContent){
							if (fo.status_type == undefined && fo.from.name!=settings.facebookID){
								allowed = false
							}
						}
					}
					if (allowed){
						var existingFeed:Boolean = false
						for each (var existingFeedItem:FeedObject in feed) 
						{
							if (fo.type != "question"){
							if (existingFeedItem.id == fo.id){
								if (fo.likes != undefined){
									existingFeedItem.noOfLikes = fo.likes.count									
								} else {
									existingFeedItem.noOfLikes = 0
								}						
								
								existingFeed = true;
							}
							}
						}
					if (existingFeed == false){
					var feedObject:FeedObject = new FeedObject()
					feedObject.addEventListener("FEED_OBJECT_LOADED", addFeedObject)					
					feedObject.create(fo, authToken,name, settings.timeBetweenObjects)
					}
					}
				}
				
				
			}
			
			if (jsonData.photos !=null){				
				for each (var ph:Object in jsonData.photos.data) 
				{
					var exists:Boolean = false
					for each (var pho:Photo in photos) 
					{
						if(pho.id == ph.id){
							exists = true
						pho.update()							
						}
					}			

					if (exists == false){
					dataPhotosLength = jsonData.photos.data.length
					var photo:Photo = new Photo(ph,settings.facebookID)
					photo.addEventListener("LOADED", pushPhotos)
					
				}
				}
				ph = null
			}
			eventDispatcher.dispatchEvent(new Event("REQUEST_LOADED"))			
			if(started){
			eventDispatcher.dispatchEvent(new Event("UPDATE_DATA"))
			}
			
			e.target.dispose(true)			
			jsonData = null
			addTimer();
			
			
				
		}
		
		protected function pushPhotos(e:Event):void
		{					
			e.target.removeEventListener("LOADED", pushPhotos)
			photos.push(e.target)
			
			if (photos.length == dataPhotosLength){
				if (disallowedFeedItems.indexOf("photoGroup") == -1){
					//								if(started){
					createPhotoGroups()
					//								}
				}				
			}
			
		}	
	
		
		private function addTimer():void
		{
			// TODO Auto Generated method stub
//			var time:Number = refreshTimeInMinutes*60000	
//			var time:Number = 10*1000
			var requestTimer:Timer = new Timer(int(refreshTime)*1000, 1)
			requestTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete)
			requestTimer.start()
		}
		
		protected function timerComplete(e:TimerEvent):void
		{						
			e.target.removeEventListener(TimerEvent.TIMER_COMPLETE, timerComplete)			
			getRequest(request)
		}
		
		private function createPhotoGroups():void
		{
			
			var numOfPhotoGroups:int = settings.numberOfPhotoGroups
			var photoGroupCount:int = 0
			var count:int = 0	
			if (photoGroupCount != numOfPhotoGroups){
			while(photoGroupCount < numOfPhotoGroups){
			if (count == 0){
			var ph:Array = new Array()			
			}
			ph.push(photos[0])
			photos.push(photos.shift())
			count +=1	
			if (count == 3){
				count = 0;	
				var photoGroup:PhotoGroup = new PhotoGroup(ph)
				var fo:Object = new Object()
				fo.type ="photoGroup"
				fo.photoGroup = photoGroup				
				var feedObject:FeedObject = new FeedObject()
				feedObject.addEventListener("FEED_OBJECT_LOADED", addFeedObject)
				feedObject.create(fo, authToken,name, settings.timeBetweenObjects)					
				photoGroupCount +=1
			}					
			}				
			}
			
			
			
		}
		
		protected function addFeedObject(e:Event):void
		{		
			e.target.removeEventListener("FEED_OBJECT_LOADED", addFeedObject)
			var fO:FeedObject = FeedObject(e.target)
			if (fO.type == "question"){
			for each (var feedObject:FeedObject in feed) 
			{
				if (fO.id == feedObject.id){
				for each (var pollOption:PollOption in feedObject.poll.options) 
				{
					for each (var pollOption2:PollOption in fO.poll.options) 
					{
						if (pollOption.id == pollOption2.id){
							pollOption.vote_count = pollOption2.vote_count
//							return;
							
						}
					}
					
				}
				fO = null
				return 
			} 
			}
			
			}
			
			var randomPos:int = int(Math.random() * feed.length);			
			feed.splice(randomPos,0,e.target)			
			
		}
	}
}