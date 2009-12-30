package com.soenkerohde.twitter {
	
	import flash.events.IEventDispatcher;
	
	import org.iotashan.oauth.OAuthToken;
	
	public interface ITwitter extends IEventDispatcher {
		
		/**
		 * @param key OAuth Consumer Key
		 */
		function set consumerKey( key : String ) : void;
		
		/**
		 * @param secret OAuth Consumer Secret
		 */
		function set consumerSecret( secret : String ) : void;
		
		/**
		 * Call this method if the user is not authenticated yet.
		 * An OAuth RequestToken will be requested from the TwitterAPI using
		 * the consumerKey and consumerSecret.
		 *
		 * NOTE: consumerKey and consumerSecret have to be set upfront.
		 * Otherwise a TwitterOAuthEvent.CONSUMER_ERROR event will be fired.
		 *
		 * When the RequestToken is retrieved a TwitterOAuthEvent.REQUEST_TOKEN event will be fired.
		 * If this event is not canceled the Twitter Authorize Website will be opened.
		 *
		 * After the user has granted access he will obtain a PIN which he has to enter somewhere
		 * in the application. After the user has done that the AccessToken can be obtained.
		 */
		function authenticate() : void;
		
		/**
		 * @param pin 6 digit PIN which the user has gathered from the Twitter authorize website
		 * after he has granted access to his Twitter account.
		 *
		 * If the PIN is not valid a TwitterOAuthEvent.PIN_ERROR event will be fired.
		 * If the PIN matches an OAuth AccessToken will the requested from the Twitter API
		 * and finally the TwitterOAuthEvent.ACCESS_TOKEN event will be fired.
		 */
		function obtainAccessToken( pin : uint ) : void;
		
		/**
		 * If the user is already authenticated you can verify if the AccessToken is still valid.
		 * The token will be verified against Twitter API "account/verify_credentials".
		 * If successful a TwitterUserEvent.USER_INFO or if not a TwitterUserEvent.USER_ERROR will be fired.
		 *
		 * @param token OAuth AccessToken
		 */
		function verifyAccessToken( token : OAuthToken ) : void;
		
		
		/**
		 *
		 * @param status
		 *
		 */
		function setStatus( accessToken : OAuthToken, status : String ) : void;
	
	}
}