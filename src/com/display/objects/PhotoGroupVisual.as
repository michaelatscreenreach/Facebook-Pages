package com.display.objects
{
	import com.data.AssetManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.requests.facebook.objects.FeedObject;
	import com.requests.facebook.objects.Photo;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;

	public class PhotoGroupVisual extends VisualObject
	{
		private var photoFeedObject:FeedObject 
		private var images:Array 
		private var photoWidth:int = 360
		private var photoHeight:int = 360
		private var gap:int = 50			
//		private var loaders:Array = new Array()
		
		private var buffer:int = 13
		public function PhotoGroupVisual(feedObject:FeedObject)
		{
			photoFeedObject=feedObject
			images = new Array()		
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
		}
		
		override public function createVisuals():void{			
			for each (var pho:Photo in photoFeedObject.photoGroup.photos) 
			{			
				createPhoto(pho)	
			}
			
			animateIn()
			
		}
		
		override public function animateIn():void
		{
			var delay:Number = 0.5
				
			for (var i:int = 0; i < images.length; i++) 
			{
				if (i==images.length -1){
					TweenMax.to(images[i],0.5,{x:(gap + i*360) + gap*i, delay:i*delay,ease:Quint.easeOut, onComplete:onStage})

				} else {
					TweenMax.to(images[i],0.5,{x:(gap + i*360) + gap*i, delay:i*delay,ease:Quint.easeOut})

				}
			}		
			
		}		
		
		override public function animateOut():void{
			var delay:Number = 0.3
			
			for (var i:int = 0; i < images.length; i++) 
			{
				
				
				if(i == images.length-1){
					TweenMax.to(images[i],0.5,{x:-photoWidth-buffer, delay:i*delay,ease:Quint.easeOut, onComplete:offStage})
				} else {
					TweenMax.to(images[i],0.5,{x:-photoWidth-buffer, delay:i*delay,ease:Quint.easeOut})
				}
			}
			
			
		}
		override public function update():void{
			
				for (var i:int; i< photoFeedObject.photoGroup.photos.length; i++){ 
					
					TextField(images[i].getChildByName("likes")).text = String(Photo(photoFeedObject.photoGroup.photos[i]).like_count).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
					TextField(images[i].getChildByName("comments")).text= String(Photo(photoFeedObject.photoGroup.photos[i]).comment_count).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
//					images[i])
					
					
//					images[i].likesText.text = Photo(photoFeedObject.photoGroup.photos[i]).like_count
//					images[i].commentsText.text = Photo(photoFeedObject.photoGroup.photos[i]).comment_count
				}
			
		}
		
		
		private function cleanUp(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			while(numChildren)
			{
				this.removeChildAt(0);
			}			
			TweenMax.killAll()
			photoFeedObject = null 
			images = null
		}
		
		
		private function createPhoto(pho:Photo):void
		{			
			
			var imageSprite:Sprite = new Sprite()
			addChild(imageSprite)
			var photo:Bitmap = pho.photo
			imageSprite.addChild(photo)
			var shapeMask:Shape = new Shape()
			shapeMask.graphics.beginFill(0)
			shapeMask.graphics.drawRect(0,0,photoWidth,photoHeight)
			shapeMask.graphics.endFill()
			imageSprite.addChild(shapeMask)	
			var photoBackground:Sprite = new Sprite()
			photoBackground.graphics.beginFill(0xFFFFFF, 0.8)
			photoBackground.graphics.drawRect(shapeMask.x - buffer, shapeMask.y - buffer, shapeMask.width + buffer*2, shapeMask.height + buffer*2+40)
			photoBackground.graphics.endFill()
			imageSprite.addChildAt(photoBackground,0)
			photo.mask = shapeMask
			//set x and y
			imageSprite.x = 1280 + buffer
			imageSprite.y = (720 - photoHeight )/2
			//add comments
			var commentsText:TextField = new TextField()
			commentsText.name="comments"
			commentsText.embedFonts = true
			commentsText.autoSize = "left"				
			commentsText.defaultTextFormat = AssetManager.photoGroupCommentFormat
			commentsText.text = String(pho.comment_count).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
			imageSprite.addChild(commentsText)
			commentsText.x = (photoBackground.width - commentsText.width) -20
			commentsText.y = shapeMask.y + shapeMask.height +10 - buffer
			//add comment symbol
			var commentSymbol:Bitmap = AssetManager.getAssetByName("SmallComment")
			imageSprite.addChild(commentSymbol)
			commentSymbol.x = commentsText.x - commentSymbol.width 
			commentSymbol.y = shapeMask.y + shapeMask.height 	+10
			//add Likes
			var likesText:TextField = new TextField()
			likesText.name ="likes" 
			likesText.embedFonts = true
			likesText.autoSize = "left"
			likesText.defaultTextFormat = AssetManager.photoGroupCommentFormat
			likesText.text = String(pho.like_count).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
			imageSprite.addChild(likesText)
			likesText.x = commentSymbol.x - likesText.width -10
			likesText.y = shapeMask.y + shapeMask.height + 10 - buffer
			//add like symbol
			var likeSymbol:Bitmap = AssetManager.getAssetByName("SmallLike")
			imageSprite.addChild(likeSymbol)
			likeSymbol.x = likesText.x - likeSymbol.width
			likeSymbol.y = shapeMask.y + shapeMask.height + 10				
//			addToImages
			images.push(imageSprite)
		}
	}
}