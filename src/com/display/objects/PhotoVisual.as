package com.display.objects
{
	import com.components.DateConv;
	import com.data.AssetManager;
	import com.displayutils.uk.soulwire.utils.display.DisplayUtils;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.requests.facebook.objects.FeedObject;
	import com.requests.facebook.objects.Photo;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class PhotoVisual extends VisualObject
	{
		private var photoObject:FeedObject
		private var photoWidth:int = 370
		private var photoHeight:int = 370
		private var textBuffer:int = 15		
		private var photoVisualContainer:Sprite;		
		private var blackBackground:Shape;						
		private var likeSymbol:Bitmap;		
		private var commentSymbol:Bitmap;
		private var mainText:TextField;
		private var textMask:Sprite;
		public var likesText:TextField;
		private var photoLoader:Loader;
		
		public function PhotoVisual(feedObject:FeedObject)
		{
			photoObject = feedObject			
			super();
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			
		}
		
		override public function createVisuals():void{
			photoVisualContainer = new Sprite
			addChild(photoVisualContainer)		
			//add black background	
			blackBackground = new Shape()
			blackBackground.graphics.beginFill(0, 0.6)
			blackBackground.graphics.drawRect(0,0,1175, 395)
			blackBackground.graphics.endFill()
			photoVisualContainer.addChild(blackBackground)
			//add Photo
			var photoContainer:Sprite = new Sprite
			photoVisualContainer.addChild(photoContainer)
			photoLoader = new Loader()
			photoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPhotoLoaded)
			photoLoader.loadBytes(photoObject.photoData)						
			photoContainer.addChild(photoLoader)						
			//add mask
			var maskShape:Shape = new Shape()
			maskShape.graphics.beginFill(0)
			maskShape.graphics.drawRect(0,0,photoWidth, photoHeight)
			maskShape.graphics.endFill()
			photoContainer.addChild(maskShape)
			photoLoader.mask = maskShape
			//move photo
			photoContainer.x = 10
			photoContainer.y = (blackBackground.height - photoHeight)/2
			//add title
			var title:TextField = new TextField()
			title.embedFonts = true
			title.autoSize = "left"			
			title.defaultTextFormat = AssetManager.wallPostTitleFormat
			title.text = "WALL POST"
			photoVisualContainer.addChild(title)
			title.x = photoContainer.x + photoWidth + 20
			title.y = photoContainer.y - textBuffer
			//addDate
			var date:TextField = new TextField()
			date.embedFonts = true
			date.autoSize = "left"			
			date.defaultTextFormat = AssetManager.dateFormat
			date.text = parseDate(photoObject.created_time)
			photoVisualContainer.addChild(date)
			date.x = photoContainer.x + photoWidth + 20
			date.y = title.y + title.height - textBuffer
			//add seperating line
			var line:Bitmap = AssetManager.getAssetByName("Line")			
			line.x = title.x 
			line.y = date.y + date.height
			photoVisualContainer.addChild(line)
			//addText
			mainText = new TextField()
			mainText.embedFonts = true
			mainText.autoSize = "left"			
			mainText.defaultTextFormat = AssetManager.wallPostCommentFormat
			mainText.text = photoObject.message
			photoVisualContainer.addChild(mainText)
			mainText.wordWrap = true
			mainText.width = 760
			mainText.height = 280
			mainText.x = photoContainer.x + photoWidth + 20
			mainText.y = date.y + date.height	+10		
			photoVisualContainer.x = 1280
			photoVisualContainer.y = (720 - blackBackground.height)/2
			//add textmask
			textMask = new Sprite()
			textMask.graphics.beginFill(0)
			textMask.graphics.drawRect(mainText.x, mainText.y, 760, 280)
			textMask.graphics.endFill()
			photoVisualContainer.addChild(textMask)
			mainText.mask = textMask
//			//add comments
//			var commentsText:TextField = new TextField()
//			commentsText.embedFonts = true
//			commentsText.autoSize = "left"
//			commentsText.defaultTextFormat = AssetManager.wallPostCommentFormat
//			commentsText.text = String(photoObject.comments.length)
//			photoVisualContainer.addChild(commentsText)
//			commentsText.x = (blackBackground.width - commentsText.width) -10
//			commentsText.y = title.y
//			//add comment symbol
//			commentSymbol = AssetManager.getAssetByName("SmallComment")
//			photoContainer.addChild(commentSymbol)
//			commentSymbol.x = commentsText.x - commentSymbol.width - textBuffer
//			commentSymbol.y = commentsText.y	
			//add Likes
			likesText = new TextField()
			likesText.embedFonts = true
			likesText.autoSize = "left"
			likesText.defaultTextFormat = AssetManager.wallPostCommentFormat
			likesText.text = String(photoObject.noOfLikes).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
			photoVisualContainer.addChild(likesText)
			likesText.x = (blackBackground.width - likesText.width) -10
			likesText.y = title.y
			//add like symbol
			likeSymbol = AssetManager.getAssetByName("SmallLike")
			photoContainer.addChild(likeSymbol)
			likeSymbol.x = likesText.x - likeSymbol.width - textBuffer
			likeSymbol.y = title.y
			
			
//			TweenMax.to(photoVisualContainer, 0, {dropShadowFilter:{color:0x000000, alpha:0.8, blurX:3, blurY:3, distance:3}});

			animateIn()
			
		}
		
		protected function onPhotoLoaded(event:Event):void
		{
			
		DisplayUtils.fitIntoRect(photoLoader.content, new Rectangle(0,0, photoWidth, photoHeight))

		}
		
		override public function update():void{
			likesText.text = String(photoObject.noOfLikes).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,")
		}		

		private function cleanUp(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			while(numChildren)
			{
				this.removeChildAt(0);
			}				
			TweenMax.killAll()		
			commentSymbol = null
			likeSymbol = null			
			photoObject = null				
			photoVisualContainer = null				
			blackBackground  = null					
			likeSymbol = null
			commentSymbol = null
			mainText = null
			textMask = null
			likesText = null
			photoLoader = null
		}
		
		private function parseDate(created_time:Date):String
		{
			//			Tue Feb 26 06:15:44 GMT+0000 2013	
			
			var timeDisplay:String = created_time.toTimeString().substr(0, 5)
			var dateDisplay:String = " - " + created_time.date +"/" +(created_time.monthUTC+1)+"/"+created_time.fullYear
			var fullDisplay:String = timeDisplay + dateDisplay;

			return fullDisplay;
		}
		
		override public function animateIn():void{
			TweenMax.to(photoVisualContainer,0.5, {x:(1280-blackBackground.width)/2, ease:Quint.easeOut, onComplete:onStage})		
		}
		
		override public function onStage():void{
			this.dispatchEvent(new Event("ON_STAGE"))
			var scrollTime:int = photoObject.scroll
			if (mainText.height > textMask.height){
				TweenMax.to(mainText,scrollTime, {y:mainText.y - (mainText.height - textMask.height)})		

			}

			
		}
		
		override public function animateOut():void{
			TweenMax.to(photoVisualContainer,0.5, {x:0- blackBackground.width, ease:Quint.easeOut, onComplete:offStage})		
			
		}
	}
}