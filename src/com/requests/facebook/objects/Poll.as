package com.requests.facebook.objects
{
	public class Poll
	{		
		public var id:String		
		public var question:String
		public var options:Array		
		
		

		public function Poll(pollData:Object)
		{
			options = new Array()			
			id = pollData.id					
			question = pollData.question
			var q:Array = question.split(":")
			question = q[0]
				
			for each (var option:Object in pollData.options.data) 
			{
			var pollOption:PollOption = new PollOption(option)	
			options.push(pollOption)
			}
			
			
		}
	}
}