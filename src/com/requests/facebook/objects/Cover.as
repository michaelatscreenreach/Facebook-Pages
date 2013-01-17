package com.requests.facebook.objects
{
	public class Cover
	{
		public var id:String
		public var source:String
		public var offset_y:String
		
		public function Cover(data:Object)
		{
			id = data.id
			source = data.source
			offset_y = data.offset_y
		}
	}
}