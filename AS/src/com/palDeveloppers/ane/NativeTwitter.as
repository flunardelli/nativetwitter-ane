package com.palDeveloppers.ane
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class NativeTwitter extends EventDispatcher
	{
		private static var _canInstatiate:Boolean;
		private static var _instance:NativeTwitter;
		
		private static var extCtx:ExtensionContext = null;
		
		private var _accessDenied:Function;
		private var _nonexistentAccount:Function;
		private var _tweetComposed:Function;
		private var _homeTimelineRequested:Function;
		private var _twitterUsernamesGot:Function;
		private var _mentionsRequested:Function;
		private var _twRequestResult:Function;
		
		{
			initialize();
		}
		
		public function NativeTwitter()
		{
			if (!_canInstatiate)
				throw Error("Singleton, use instance property");
			
			extCtx.addEventListener(StatusEvent.STATUS, onStatus);
		}
		
		public static function get instance():NativeTwitter
		{
			return _instance;
		}
		
		public function get accessDenied():Function
		{
			return _accessDenied;
		}
		
		public function set accessDenied(value:Function):void
		{
			_accessDenied = value;
		}
		
		public function get twRequestResult():Function
		{
			return _twRequestResult;
		}
		
		public function set twRequestResult(value:Function):void
		{
			_twRequestResult = value;
		}
		
		public function get nonexistentAccount():Function
		{
			return _nonexistentAccount;
		}
		
		public function set nonexistentAccount(value:Function):void
		{
			_nonexistentAccount = value;
		}
		
		public function get tweetComposed():Function
		{
			return _tweetComposed;
		}
		
		public function set tweetComposed(value:Function):void
		{
			_tweetComposed = value;
		}
		
		public function get homeTimelineRequested():Function
		{
			return _homeTimelineRequested;
		}
		
		public function set homeTimelineRequested(value:Function):void
		{
			_homeTimelineRequested = value;
		}
		
		public function get twitterUsernamesGot():Function
		{
			return _twitterUsernamesGot;
		}
		
		public function set twitterUsernamesGot(value:Function):void
		{
			_twitterUsernamesGot = value;
		}
		
		public function get mentionsRequested():Function
		{
			return _mentionsRequested;
		}
		
		public function set mentionsRequested(value:Function):void
		{
			_mentionsRequested = value;
		}
		
		private static function initialize():void
		{
			if (Capabilities.os.toLowerCase().indexOf("ip") > -1)
			{
				extCtx = ExtensionContext.createExtensionContext("com.palDeveloppers.ane.NativeTwitter", null);
				if (extCtx != null && extCtx.call("isTwitterAvailable"))
				{
					_canInstatiate = true;
					
					_instance = new NativeTwitter();
					
					_canInstatiate = false;
				}
				else
				{
					extCtx = null;
					trace("[NativeTwitter] Error - Extension Context is null.");
				}
			}
		}
		
		public static function isSupported():Boolean
		{
			return _instance != null;
		}
		
		public function isTwitterSetup():Boolean
		{
			return extCtx.call("ìsTwitterSetup");
		}
		
		public function composeTweet(messageText:String = null, imageAttach:String = null, urlAttach:String = null):void
		{
			extCtx.call("composeTweet", messageText, imageAttach, urlAttach);
		}
		
		public function getHomeTimeLine(accountId:int = 0):void
		{
			extCtx.call("getHomeTimeline", accountId);
		}
		
		public function getTwitterUsernames():void
		{
			extCtx.call("getTwitterUsernames");
		}
		
		public function getMentions(accountId:int = 0):void
		{
			extCtx.call("getMentions", accountId);
		}
		
		public function getTWRequest(url:String, params:Object = null, requestMethod:String = TWRequestMethod.GET, accountId:int = 0):void
		{
			var paramsJson:String = null;
			
			if (params != null)
				paramsJson = JSON.stringify(params);
			
			extCtx.call("getTWRequest", url, paramsJson, requestMethod, accountId);
		}
		
		private function onStatus(event:StatusEvent):void
		{
			var data:Object;
			
			switch (event.code)
			{
				case "tweetComposed":
					if (_tweetComposed != null)
						tweetComposed(int(event.level));
					
					break;
				
				case "deniedAccess":
					if (_accessDenied != null)
						_accessDenied(event.level);
					
					break;
				
				case "nonexistentAccount":
					if (_nonexistentAccount != null)
						_nonexistentAccount(int(event.level));
					
					break;
				
				case "getTwitterUsernames":
					if (_twitterUsernamesGot != null) 
					{
						var namesArr:Array = event.level.split("/");
						var names:Vector.<String> = new Vector.<String>(namesArr.length - 1, true);
						
						for (var i:int = 0, count:int = names.length; i < count; i++)
							names[i] = namesArr[i];
						
						_twitterUsernamesGot(names);
					}
					
					break;
				
				case "homeTimelineRequested":
					data = JSON.parse(event.level);
					
				case "homeTimelineRequestError":
					if (_homeTimelineRequested != null)
						_homeTimelineRequested(data != null ? "200" : event.level, data);
					
					break;
					
				case "mentionsRequested":
					data = JSON.parse(event.level);
					
				case "mentionsRequestError":
					if (_mentionsRequested != null)
						_mentionsRequested(data != null ? "200" : event.level, data);
					
					break;
				
				case "twRequestResult":
					data = JSON.parse(event.level);
				
				case "twRequestError":
					if (_twRequestResult != null)
						_twRequestResult(data != null ? "200" : event.level, data);
					
					break;
			}
		}
	}
}
