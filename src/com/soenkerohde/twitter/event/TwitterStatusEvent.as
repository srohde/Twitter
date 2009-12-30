package com.soenkerohde.twitter.event {
	import flash.events.Event;
	
	public class TwitterStatusEvent extends Event {
		
		public static const STATUS_SENDING:String = "TwitterStatusEvent.STATUS_SENDING";
		public static const STATUS_SEND:String = "TwitterStatusEvent.STATUS_SEND";
		
		public function TwitterStatusEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false ) {
			super( type, bubbles, cancelable );
		}
	}
}