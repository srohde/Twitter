package com.soenkerohde.twitter {
	import com.adobe.serialization.json.JSONDecoder;
	import com.soenkerohde.twitter.event.TwitterOAuthEvent;
	import com.soenkerohde.twitter.event.TwitterStatusEvent;
	import com.soenkerohde.twitter.event.TwitterUserEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import org.iotashan.oauth.OAuthConsumer;
	import org.iotashan.oauth.OAuthRequest;
	import org.iotashan.oauth.OAuthSignatureMethod_HMAC_SHA1;
	import org.iotashan.oauth.OAuthToken;
	import org.iotashan.utils.URLEncoding;
	
	public class Twitter extends EventDispatcher implements ITwitter {
		
		public static const VERIFY_CREDENTIALS:String = "https://twitter.com/account/verify_credentials.json";
		public static const REQUEST_TOKEN:String = "http://twitter.com/oauth/request_token";
		public static const ACCESS_TOKEN:String = "http://twitter.com/oauth/access_token";
		public static const AUTHORIZE:String = "http://twitter.com/oauth/authorize";
		public static const SET_STATUS:String = "https://twitter.com/statuses/update.json";
		
		public static function getTokenFromResponse( tokenResponse : String ) : OAuthToken {
			var result:OAuthToken = new OAuthToken();
			
			var params:Array = tokenResponse.split( "&" );
			for each ( var param : String in params ) {
				var paramNameValue:Array = param.split( "=" );
				if ( paramNameValue.length == 2 ) {
					if ( paramNameValue[0] == "oauth_token" ) {
						result.key = paramNameValue[1];
					} else if ( paramNameValue[0] == "oauth_token_secret" ) {
						result.secret = paramNameValue[1];
					}
				}
			}
			
			return result;
		}
		
		protected var signature:OAuthSignatureMethod_HMAC_SHA1 = new OAuthSignatureMethod_HMAC_SHA1();
		
		protected var requestToken:OAuthToken;
		protected var accessToken:OAuthToken;
		
		private var _consumerKey:String;
		private var _consumerSecret:String;
		
		private var _consumer:OAuthConsumer;
		
		public function set consumerKey( key : String ) : void {
			_consumerKey = key;
		}
		
		public function set consumerSecret( secret : String ) : void {
			_consumerSecret = secret;
		}
		
		private function get consumer() : OAuthConsumer {
			if ( _consumer == null && _consumerKey != null && _consumerSecret != null ) {
				_consumer = new OAuthConsumer( _consumerKey, _consumerSecret );
			}
			return _consumer;
		}
		
		public function Twitter( consumerKey : String = null, consumerSecret : String = null ) {
			_consumerKey = consumerKey;
			_consumerSecret = consumerSecret;
		}
		
		public function setAccessToken( token : OAuthToken ) : void {
			accessToken = token;
		}
		
		public function authenticate() : void {
			var oauthRequest:OAuthRequest = new OAuthRequest( "GET", REQUEST_TOKEN, null, consumer, null );
			var request:URLRequest = new URLRequest( oauthRequest.buildRequest( signature ) );
			var loader:URLLoader = new URLLoader( request );
			loader.addEventListener( Event.COMPLETE, requestTokenHandler );
		}
		
		protected function requestTokenHandler( e : Event ) : void {
			requestToken = getTokenFromResponse( e.currentTarget.data as String );
			if ( dispatchEvent( new TwitterOAuthEvent( TwitterOAuthEvent.REQUEST_TOKEN, requestToken ) ) ) {
				var request:URLRequest = new URLRequest( AUTHORIZE + "?oauth_token=" + requestToken.key );
				navigateToURL( request, "_blank" );
			}
		}
		
		public function obtainAccessToken( pin : uint ) : void {
			var oauthRequest:OAuthRequest = new OAuthRequest( "GET", ACCESS_TOKEN, { oauth_verifier: pin }, consumer, requestToken );
			var request:URLRequest = new URLRequest( oauthRequest.buildRequest( signature, OAuthRequest.RESULT_TYPE_URL_STRING ) );
			request.method = "GET";
			
			var loader:URLLoader = new URLLoader( request );
			loader.addEventListener( Event.COMPLETE, accessTokenResultHandler );
		}
		
		protected function accessTokenResultHandler( event : Event ) : void {
			var accessToken:OAuthToken = getTokenFromResponse( event.currentTarget.data as String );
			if ( dispatchEvent( new TwitterOAuthEvent( TwitterOAuthEvent.ACCESS_TOKEN, accessToken ) ) ) {
				setAccessToken( accessToken );
			}
		}
		
		public function verifyAccessToken( token : OAuthToken ) : void {
			var oauthRequest:OAuthRequest = new OAuthRequest( "GET", VERIFY_CREDENTIALS, null, consumer, token );
			var request:URLRequest = new URLRequest( oauthRequest.buildRequest( signature, OAuthRequest.RESULT_TYPE_URL_STRING ) );
			request.method = "GET";
			
			var loader:URLLoader = new URLLoader( request );
			loader.addEventListener( Event.COMPLETE, verifyAccessTokenHandler );
		}
		
		protected function verifyAccessTokenHandler( event : Event ) : void {
			var decoder:JSONDecoder = new JSONDecoder( event.currentTarget.data, false );
			var value:Object = decoder.getValue();
			var screenName:String = value.screen_name;
			dispatchEvent( new TwitterUserEvent( TwitterUserEvent.USER_INFO, screenName ) );
		}
		
		public function setStatus( accessToken : OAuthToken, status : String ) : void {
			// create OAuthRequest
			var oauthRequest:OAuthRequest = new OAuthRequest( "POST", SET_STATUS, { status: status }, consumer, accessToken );
			
			// build request URL from OAuthRequst
			var requestUrl:String = oauthRequest.buildRequest( new OAuthSignatureMethod_HMAC_SHA1(), OAuthRequest.RESULT_TYPE_URL_STRING );
			// new URLReuqest with URL and OAuth params
			var request:URLRequest = new URLRequest( requestUrl );
			request.method = "POST";
			
			// remove status message param from URL since it is a post request
			request.url = request.url.replace( "&status=" + URLEncoding.encode( status ), "" );
			// add status message to request data
			request.data = new URLVariables( "status=" + status );
			
			if ( dispatchEvent( new TwitterStatusEvent( TwitterStatusEvent.STATUS_SENDING ) ) ) {
				var loader:URLLoader = new URLLoader( request );
				loader.addEventListener( Event.COMPLETE, statusResultHandler );
			}
		}
		
		protected function statusResultHandler( event : Event ) : void {
			dispatchEvent( new TwitterStatusEvent( TwitterStatusEvent.STATUS_SEND ) );
		}
	
	}
}