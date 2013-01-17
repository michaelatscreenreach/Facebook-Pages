package com.graphics
	
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*
	
	
	public class TimerCircle extends Sprite
	{
		[Embed(source="/../ASSETS/circle.swf", symbol="Circle")] private var Circle:Class
		
		public var circle:MovieClip = new Circle()
		
		private var time:int;
		public function TimerCircle(timeInSeconds:int)
		{
		time = timeInSeconds
		addChild(circle)		
		circle.stop()
		}
		
		public function start():void{
			TweenMax.fromTo(circle, time, {frame:circle.totalFrames},{frame:0, ease:Linear.easeNone, repeat:0, onComplete:timerComplete});
		}
		
		public function timerComplete():void{
			circle.stop()
			this.dispatchEvent(new Event("Timer_Complete"))
		}
	}
}