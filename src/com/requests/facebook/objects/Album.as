package com.requests.facebook.objects
{
	public class Album
	{
		public var albumName:String
		public var id:String
		public var created_time:String
		public var photos:Array
		
		public function Album()
		{
			photos = new Array()
		}
	}
}