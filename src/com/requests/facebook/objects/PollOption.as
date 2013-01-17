package com.requests.facebook.objects
{
	public class PollOption
	{
		public var id:String
		private var user:User
		public var name:String
		public var vote_count:int		
		
		public function PollOption(pollData:Object)
		{
			id = pollData.id	
			name = pollData.name
			vote_count = pollData.vote_count			
			
		}
	}
}