package com.soenkerohde.twitter.event {
	import flash.events.Event;
	
	public class TwitterUserEvent extends Event {
		
		public static const USER_INFO:String = "TwitterUserEvent.USER_INFO";
		public static const USER_ERROR:String = "TwitterUserEvent.USER_ERROR";
		
		public var screenName:String;
		
		public function TwitterUserEvent( type : String, screenName:String, bubbles : Boolean = false, cancelable : Boolean = false ) {
			super( type, bubbles, cancelable );
			this.screenName = screenName;
		}
	}
}