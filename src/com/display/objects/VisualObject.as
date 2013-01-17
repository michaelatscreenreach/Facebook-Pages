package com.display.objects
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class VisualObject extends Sprite
	{
		public function VisualObject()
		{
			super();
		}
		
		public function createVisuals():void{
			
		}
		
		public function onStage():void{
			this.dispatchEvent(new Event("ON_STAGE"))
		}
		public function offStage():void{
			this.dispatchEvent(new Event("OFF_STAGE"))
		}
		
		public function animateIn():void{
			
		}
		
		public function animateOut():void{
			
		}
		public function kill():void{
			
		}
		public function update():void{
			
		}
	}
}