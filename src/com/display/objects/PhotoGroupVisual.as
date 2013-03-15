package com.display.objects
{
	import com.data.AssetManager;
	import com.displayutils.uk.soulwire.utils.display.DisplayUtils;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.requests.facebook.objects.FeedObject;
	import com.requests.facebook.objects.Photo;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;

	public class PhotoGroupVisual extends VisualObject
	{
		private var photoFeedObject:FeedObject 
		private var images:Array 
		private var photoWidth:int = 370
		private var photoHeight:int = 370
		private var gap:int = 50			
//		private var loaders:Array = new Array()
		
		private var buffer:int = 13

		private var photoLoader:Loader;
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
					TweenMax.to(images[i],0.5,{x:(gap + i*photoWidth) + gap*i, delay:i*delay,ease:Quint.easeOut, onComplete:onStage})

				} else {
					TweenMax.to(images[i],0.5,{x:(gap + i*photoWidth) + gap*i, delay:i*delay,ease:Quint.easeOut})

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
			
			var photoContainer:Sprite = new Sprite()
			addChild(photoContainer)
			//add Photo			
			photoLoader = new Loader()
			photoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPhotoLoaded)
			photoLoader.loadBytes(pho.photo)
			photoContainer.addChild(photoLoader)
			var shapeMask:Shape = new Shape()
			shapeMask.graphics.beginFill(0)
			shapeMask.graphics.drawRect(0,0,photoWidth,photoHeight)
			shapeMask.graphics.endFill()
			photoContainer.addChild(shapeMask)	
			var photoBackground:Sprite = new Sprite()
			photoBackground.graphics.beginFill(0xFFFFFF, 0.8)
			photoBackground.graphics.drawRect(shapeMask.x - buffer, shapeMask.y - buffer, shapeMask.width + buffer*2, shapeMask.height + buffer*2+40)
			photoBackground.graphics.endFill()
			photoContainer.addChildAt(photoBackground,0)
			photoLoader.mask = shapeMask
			//set x and y
			photoContainer.x = 1280 + buffer
			photoContainer.y = (720 - photoHeight )/2
			//add comments
			var commentsText:TextField = new TextField()
			commentsText.name="comments"
			commentsText.embedFonts = true
			commentsText.autoSize = "left"				
			commentsText.defaultTextFormat = AssetManager.photoGroupCommentFormat
			commentsText.text = String(pho.comment_count).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
			photoContainer.addChild(commentsText)
			commentsText.x = (photoBackground.width - commentsText.width) -20
			commentsText.y = shapeMask.y + shapeMask.height +10 - buffer
			//add comment symbol
			var commentSymbol:Bitmap = AssetManager.getAssetByName("SmallComment")
			photoContainer.addChild(commentSymbol)
			commentSymbol.x = commentsText.x - commentSymbol.width 
			commentSymbol.y = shapeMask.y + shapeMask.height 	+10
			//add Likes
			var likesText:TextField = new TextField()
			likesText.name ="likes" 
			likesText.embedFonts = true
			likesText.autoSize = "left"
			likesText.defaultTextFormat = AssetManager.photoGroupCommentFormat
			likesText.text = String(pho.like_count).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
			photoContainer.addChild(likesText)
			likesText.x = commentSymbol.x - likesText.width -10
			likesText.y = shapeMask.y + shapeMask.height + 10 - buffer
			//add like symbol
			var likeSymbol:Bitmap = AssetManager.getAssetByName("SmallLike")
			photoContainer.addChild(likeSymbol)
			likeSymbol.x = likesText.x - likeSymbol.width
			likeSymbol.y = shapeMask.y + shapeMask.height + 10				
//			addToImages
			images.push(photoContainer)
		}
		
		protected function onPhotoLoaded(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, onPhotoLoaded)
			DisplayUtils.fitIntoRect(e.target.content, new Rectangle(0,0,photoWidth,photoHeight))
		}
		
		
		
		
		
	}
}