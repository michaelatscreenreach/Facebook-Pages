package com.requests.facebook.objects
{
	import com.adobe.serialization.json.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Photo extends EventDispatcher
	{
		public var facebookID:String
		public var id:String
		public var photoURL:String
		public var photo:Bitmap
		public var created_time:String
		public var like_count:String
		public var comment_count:String
		
		private var query:String;

		private var exists:Boolean = false
		
		public function Photo(data:Object,fbID:String) 
		{						
			facebookID = fbID
			fbID = null
			if (data.id !=null && data.id!= undefined){id = data.id}	
			
			query = "https://graph.facebook.com/"+facebookID+"/fql?q=SELECT like_info,comment_info FROM photo WHERE object_id="+id+""

			if (data.images !=null && data.images != undefined){
				this.photoURL = data.images[0].source
				var photoLoader:ImageLoader = new ImageLoader(photoURL, {name:"photo", width:360, height:360, scaleMode:"proportionalOutside", onError:updateError,onComplete:photoLoaded, autoDispose:true});
				photoLoader.load()	
					
			}	else {
				throw new Error("no images")
			}
			if (data.created_time !=null && data.created_time != undefined){this.created_time = data.created_time}
			data=null
		}
		
		private function likesAndCommentsLoaded(e:Event):void{
			e.target.removeEventListener(Event.COMPLETE, likesAndCommentsLoaded)
//			var data:Object = JSON.decode(e.target.content)
			var data:Object = JSON.decode(e.target.data)
			like_count = data.data[0].like_info.like_count
			comment_count = data.data[0].comment_info.comment_count
			data = null
//			DataLoader(e.target).dispose(true)		
			dispatchEvent(new Event("LOADED"))			
			
		}
		
		private function photoLoaded(e:Event):void{
			photo = e.target.rawContent
			update();	

			
		}
		
		public function update():void
		{
//			trace(query) d
//			var facebookQuery:DataLoader = new DataLoader(query, {onComplete:likesAndCommentsLoaded, onError:updateError, autoDispose:true})
//			facebookQuery.load()		
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(query);
			loader.addEventListener(Event.COMPLETE, likesAndCommentsLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, updateError)
			loader.load(request);
			
		}
		
		public function updateError(e:IOErrorEvent):void{
			trace("error")
			e.target.removeEventListener(Event.COMPLETE, likesAndCommentsLoaded)
//			e.target.dispose(true)
		}
		
	}
}