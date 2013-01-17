package com.display.objects
{
	import com.components.DateConv;
	import com.data.AssetManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quint;
	import com.requests.facebook.objects.FeedObject;
	import com.requests.facebook.objects.PollOption;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;

	public class QuestionVisual extends VisualObject
	{
		private var questionObject:FeedObject
		private var photoWidth:int = 370
		private var photoHeight:int = 370
		private var textBuffer:int = 10		
		private var questionVisualContainer:Sprite;		
		private var blackBackground:Shape;
		
		public function QuestionVisual(feedObject:FeedObject)
		{
			questionObject = feedObject
			super();
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanUp);

		}
		
		override public function createVisuals():void{
			var buffer:int = 15
			
			questionVisualContainer = new Sprite
			addChild(questionVisualContainer)		
			//add black background	
			blackBackground = new Shape()
			blackBackground.graphics.beginFill(0, 0.6)
			blackBackground.graphics.drawRect(0,0,1175, 395)
			blackBackground.graphics.endFill()
			questionVisualContainer.addChild(blackBackground)
			
			//add title
			var title:TextField = new TextField()
			title.embedFonts = true
			title.autoSize = "left"			
			title.defaultTextFormat = AssetManager.wallPostTitleFormat
			title.text = "QUESTION"
			questionVisualContainer.addChild(title)
			title.x = buffer
//			title.y = photoContainer.y - textBuffer		
			//addText
			var mainText:TextField = new TextField()
			mainText.embedFonts = true
			mainText.autoSize = "left"			
			mainText.defaultTextFormat = AssetManager.dateFormat
			mainText.text = questionObject.poll.question
			questionVisualContainer.addChild(mainText)
			mainText.wordWrap = true
			mainText.width = 760
			mainText.height = 280
			mainText.x = title.x
			mainText.y = title.y + title.height	- buffer		
			questionVisualContainer.x = 1280
			questionVisualContainer.y = (720 - blackBackground.height)/2
			//add textmask
			var textMask:Sprite = new Sprite()
			textMask.graphics.beginFill(0)
			textMask.graphics.drawRect(mainText.x, mainText.y, 760, 280)
			textMask.graphics.endFill()
			questionVisualContainer.addChild(textMask)
			mainText.mask = textMask			
			//add seperating line
			var line:Bitmap = AssetManager.getAssetByName("Line")
			line.x = title.x 
			line.y = mainText.y + mainText.height
			questionVisualContainer.addChild(line)
			//add questions
			var optionCount:int = 0
			var pollContainer:Sprite = new Sprite()
			questionVisualContainer.addChild(pollContainer)
			pollContainer.y = mainText.y + mainText.height
				pollContainer.x = 20
			for each (var option:PollOption in questionObject.poll.options) 
			{
				var pollText:TextField = new TextField()
				pollText.embedFonts = true
				pollText.autoSize = "left"			
				pollText.defaultTextFormat = AssetManager.pollFormat
				pollText.text = option.name							
				if (optionCount%2 == 0){
				pollText.x = 600				
				} 				
				pollText.y = Math.floor(optionCount/2)*50
				pollContainer.addChild(pollText)
					
				var pollNumberText:TextField = new TextField()
				pollNumberText.embedFonts = true
				pollNumberText.autoSize = "right"			
				pollNumberText.defaultTextFormat = AssetManager.pollFormat
				pollNumberText.text = option.vote_count.toString()
								
				if (optionCount%2 == 0){
					pollNumberText.x = 1000				
				} 		else {
					pollNumberText.x = 400
				}
				pollNumberText.y = pollText.y	
				pollContainer.addChild(pollNumberText)
				optionCount++
				
			}
			
			
			animateIn()
		}
		
		
		

		
		private function cleanUp(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			while(numChildren)
			{
				this.removeChildAt(0);
			}			
			TweenMax.killAll()
			questionVisualContainer = null
			blackBackground = null
			questionObject = null
		}
		
		private function parseDate(created_time:String):String
		{
			//2012-05-03T09:19:23+0000
			
			var date:String = created_time
			var dateSplit:Array = date.split("-")
			dateSplit[2] = String(dateSplit[2]).slice(0,2)
			date = dateSplit[2] +" " + DateConv.convert(dateSplit[1])
			
			// TODO Auto Generated method stub
			return date;
		}
		
		override public function animateIn():void{
			
			TweenMax.to(questionVisualContainer,0.5, {x:(1280-blackBackground.width)/2, ease:Quint.easeOut, onComplete:onStage})		

		}
		
		override public function animateOut():void{
			TweenMax.to(questionVisualContainer,0.5, {x:0- blackBackground.width, ease:Quint.easeOut, onComplete:offStage})
		}
		 
		
	}
}