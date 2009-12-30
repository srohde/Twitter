package com.soenkerohde.twitter.event {
	import flash.events.Event;
	
	import org.iotashan.oauth.OAuthToken;
	
	public class TwitterOAuthEvent extends Event {
		
		public static const REQUEST_TOKEN:String = "TwitterOAuthEvent.REQUEST_TOKEN";
		public static const CONSUMER_ERROR:String = "TwitterOAuthEvent.CONSUMER_ERROR";
		
		public static const ACCESS_TOKEN:String = "TwitterOAuthEvent.ACCESS_TOKEN";
		public static const PIN_ERROR:String = "TwitterOAuthEvent.PIN_ERROR";
		
		private var _token:OAuthToken;
		
		public function get token() : OAuthToken {
			return _token;
		}
		
		public function TwitterOAuthEvent( type : String, token : OAuthToken, bubbles : Boolean = false ) {
			super( type, bubbles );
			_token = token;
		}
		
		override public function clone() : Event {
			return new TwitterOAuthEvent( type, token, bubbles );
		}
	}
}