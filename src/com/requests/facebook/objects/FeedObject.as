package com.requests.facebook.objects
{
	import com.adobe.serialization.json.*;
	import com.adobe.utils.DateUtil;
	import com.data.SettingsManager;
	import com.google.analytics.utils.URL;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.ImageLoader;
	import com.requests.auth.OAuthToken;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	

	public class FeedObject extends EventDispatcher
	{
		public var type:String
		public var message:String		
		public var picture:String
		public var comments:Array
		public var noOfLikes:int
		public var id:String
		public var created_time:Date
		public var poll:Poll
		public var photoGroup:PhotoGroup
		public var photo:String		
		public var photoData:ByteArray
		public var scroll:int
		
		//attributes
		private var photoWidth:int = 360
		private var photoHeight:int = 360
		
		
		public function FeedObject()
		{			
			
		}
		
		public function create(data:Object, authToken:OAuthToken, facebookName:String, scrollTime:int):void{
			var photoLoader:URLLoader
			this.scroll = scrollTime
			if (data.type != null){ this.type = data.type } 
			if (data.message != null){
				this.message = data.message
			} else if (data.story !=null){
				this.message = data.story
			} else {
				message= ""
			}
			if (data.picture != null){this.picture = data.picture}
			if (data.comments !=null && data.comments!=undefined){
				comments = new Array()
				for each (var c:Object in data.comments.data) 
				{
					var comment:Comment = new Comment
					comment.id = c.id
					comment.created_time = c.created_time
					comment.message = c.message
					comment.user = new User()
					comment.user.name = c.from.name
					comment.user.id = c.from.id
					comments.push(comment)
				}				
			} else {
				comments = new Array()
			}
			if (data.likes != null){this.noOfLikes = data.likes.count}
			if (data.id !=null){
				this.id = data.id
			}
			if (data.created_time !=null){ 
//				var tCT:String = data.created_time.split("-").join("/");
//				var tCT:String = data.created_time.split("T").join(" ");
//				tCT = tCT.substr(0, tCT.length - 5);
//				trace(tCT)
				this.created_time = DateUtil.parseW3CDTF(data.created_time)
			}
			if (data.photoGroup !=null){ this.photoGroup = data.photoGroup }
			
			if (data.type == "question"){				
				var url:String = "https://graph.facebook.com/" + data.object_id + "?access_token="+authToken.code				
				var pollLoader:URLLoader = new URLLoader()				
				pollLoader.addEventListener(Event.COMPLETE, parsePoll)
				pollLoader.load(new URLRequest(url))
			} else if (data.type == "photo") {
							
				var photoURL:String = "https://graph.facebook.com/" + data.object_id +"?fields=picture.width(370).height(370)" + "&access_token="+authToken.code	
				photoLoader = new URLLoader()
				photoLoader.dataFormat = URLLoaderDataFormat.BINARY
				photoLoader.addEventListener(Event.COMPLETE, parsePhoto)
				photoLoader.load(new URLRequest(photoURL))								
			
			} else if (data.type == "status"){
				if(data.application != undefined){
				return;
				}
				if(String(data.story).indexOf("\" on their own") != -1){
					message = facebookName + " commented " + message
				}
				var fromURL:String = "https://graph.facebook.com/" + data.from.id +"?fields=picture.width(370).height(370)&access_token="+authToken.code									
				photoLoader = new URLLoader()
				photoLoader.dataFormat = URLLoaderDataFormat.BINARY
				photoLoader.addEventListener(Event.COMPLETE, parseFrom)
				photoLoader.load(new URLRequest(fromURL))				
				
			} else {
				
				this.dispatchEvent(new Event("FEED_OBJECT_LOADED"))
			 
			}
			facebookName = null
		
			}
		
		public function errorHandler(e:LoaderEvent):void{			
			e.target.dispose(true)
		}
		
		public function parseFrom(e:Event):void{
			e.target.removeEventListener(Event.COMPLETE, parseFrom)
			var photoData:Object = JSON.decode(e.target.data)			
			photo = photoData.picture.data.url
			var photoDataLoader:URLLoader = new URLLoader()			
			photoDataLoader.dataFormat = URLLoaderDataFormat.BINARY
			photoDataLoader.addEventListener(Event.COMPLETE, photoBytesLoaded)
			photoDataLoader.load(new URLRequest(photo))
			e.target.data = null
//			e.target.dispose(true)			
			
		}
		
		public function parsePhoto(e:Event):void{
			e.target.removeEventListener(Event.COMPLETE, parsePhoto)
			var photoData:Object = JSON.decode(e.target.data)
				photo = photoData.picture.data.url
				var photoDataLoader:URLLoader = new URLLoader()
				photoDataLoader.dataFormat = URLLoaderDataFormat.BINARY
				photoDataLoader.addEventListener(Event.COMPLETE, photoBytesLoaded)
				photoDataLoader.load(new URLRequest(photo))
					
				
					
		}
		
		private function photoBytesLoaded(e:Event):void{
			e.target.removeEventListener(Event.COMPLETE, photoBytesLoaded)
			photoData = e.target.data
			dispatchEvent(new Event("FEED_OBJECT_LOADED"))		
		}
		
		public function parsePoll(e:Event):void{
			e.target.removeEventListener(Event.COMPLETE, parsePoll)
			var jsonData:Object = JSON.decode(e.target.data)					
			poll = new Poll(jsonData)			
//			e.target.dispose(true)
			this.dispatchEvent(new Event("FEED_OBJECT_LOADED"))
			e.target.data = null
		}
	}
}