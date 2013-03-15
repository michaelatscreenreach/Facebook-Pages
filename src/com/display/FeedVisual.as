package com.display
{
	import com.display.objects.PhotoGroupVisual;
	import com.display.objects.PhotoVisual;
	import com.display.objects.QuestionVisual;
	import com.display.objects.StatusVisual;
	import com.display.objects.VisualObject;
	import com.graphics.TimerCircle;
	import com.requests.facebook.objects.FeedObject;
	import com.requests.facebook.objects.PhotoGroup;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class FeedVisual extends Sprite
	{
			
		private var queue:Array
		private var photos:Array
		private var currentFeedObject:FeedObject
		private var currentVisual:VisualObject
		private var currentArray:Array
		private var timeBetweenFeed:int
		private var visualContainer:Sprite
		private var count:int = 0;
		
		public function FeedVisual(feed:Array, photoGroupFeed:Array, timeBetweenFeed:int)
		{
			
		photos = photoGroupFeed
		this.timeBetweenFeed = timeBetweenFeed
		visualContainer = new Sprite()
		addChild(visualContainer)
		queue = feed		
		
		next(null)
		}
		
		private function createPhotoGroups():void
		{
			// TODO Auto Generated method stub
			
		}
		public function update():void{
//			if (currentVisual != null){
//			if (currentVisual == null){
//				next(null)
//			}
//			trace(currentVisual)
			currentVisual.update()
//			}
			
		}
		private function next(e:Event):void
		{
			
			
			if (count%3 == 0 && photos[0]!=undefined){
			currentArray = photos;
			} else {
				currentArray = queue;
			}
			currentFeedObject = currentArray[0]	
		
			
			if (currentVisual != null){				
				currentVisual = null
			}
			
			if (currentFeedObject.type == "photoGroup"){
				var photoGroupVisual:PhotoGroupVisual = new PhotoGroupVisual(currentFeedObject)					
				photoGroupVisual.addEventListener("ON_STAGE", createTimer)
				photoGroupVisual.createVisuals()
				visualContainer.addChild(photoGroupVisual)
				currentVisual = photoGroupVisual
			} else if (currentFeedObject.type =="photo"){
				var photoVisual:PhotoVisual = new PhotoVisual(currentFeedObject)
				photoVisual.addEventListener("ON_STAGE", createTimer)
				photoVisual.createVisuals()
				visualContainer.addChild(photoVisual)
				currentVisual = photoVisual
				
				
			} else if (currentFeedObject.type =="status" || currentFeedObject.type == "swf"){
				var statusVisual:StatusVisual = new StatusVisual(currentFeedObject)				
				statusVisual.addEventListener("ON_STAGE", createTimer)
				statusVisual.createVisuals()
				visualContainer.addChild(statusVisual)
				currentVisual = statusVisual
			} else if (currentFeedObject.type == "question"){
				var questionVisual:QuestionVisual = new QuestionVisual(currentFeedObject)
				questionVisual.addEventListener("ON_STAGE", createTimer)
				questionVisual.createVisuals()
				visualContainer.addChild(questionVisual)
				currentVisual = questionVisual
			}
			else {
				trace("unrecognized type");
				createTimer(null)
			}
			
			
			
	
		}		
		
		private function createTimer(e:Event):void
		{
			if (e !=null){
				e.target.removeEventListener("ON_STAGE", createTimer)				
			}
			var timer:TimerCircle = new TimerCircle(timeBetweenFeed)
			timer.addEventListener("Timer_Complete", timerComplete)
			addChild(timer)
			timer.alpha = 0.7
			timer.scaleX = timer.scaleY = 0.5
			timer.y = 720 - timer.height- 10
			timer.x = 1280 - timer.width -10
			timer.start()
			count ++;
		}
		
		private function remove(e:Event):void{
			e.target.removeEventListener("OFF_STAGE", remove)			
			visualContainer.removeChild(currentVisual)		
			next(null)
		}
		
		protected function timerComplete(event:Event):void
		{
			event.target.removeEventListener("Timer_Complete", timerComplete)
			removeChild(TimerCircle(event.target))
			currentArray.push(currentArray.shift())
				
			if(currentVisual !=null){
			currentVisual.addEventListener("OFF_STAGE", remove)
			currentVisual.animateOut()
			} else {
			next(null)
			}
		
			
		}
		
	}
}