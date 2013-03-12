package com.data
{
	import com.adobe.serialization.json.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.*;
	import com.requests.auth.OAuthToken;
	
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	
	public class SettingsManager
	{
		private var appID:String = "170766089734428"
		private var appSecret:String = "65535e49cfdee5932ed20e12e1f7ab6c"
		public var authToken:OAuthToken	
		public var eventDispatcher:EventDispatcher
		public var facebookID:String		
		public var feedLimit:int = 100
		public var timeBetweenObjects:int = 20
		public var numberOfPhotoGroups:int 
		public var disallowedList:Array = []
		public var customMessage:String;		
		public var refreshTime:String;
		public var dayFilter:String;
		public var allowUserContent:Boolean;
		public var splashTime:int = 0;
		
		public function SettingsManager()
		{
			eventDispatcher = new EventDispatcher()
		}
		
		public function authRequest():void{
			
			
			var url:String = "https://graph.facebook.com/oauth/access_token" +
				"?grant_type=client_credentials" +
//				"&scope=read_stream,user_photos" +
				"&client_id="+appID+"" +
				"&client_secret="+appSecret+""
				
			trace(url)
			
			var authLoader:DataLoader = new DataLoader(url,{name:"auth", onComplete:onAuth, onError:authError, autoDispose:true})
			
			authLoader.load()
		}
		
		private function authError(e:LoaderEvent):void{
			trace("ERROR OCURRED WITH " + e.target + ": " + e.text);
		}
		
		private function onAuth(e:LoaderEvent):void{
			var dataString:String = DataLoader(e.target).content
			dataString = dataString.replace("access_token=", "")
			//create authToken Object
			authToken = new OAuthToken(dataString)
			eventDispatcher.dispatchEvent(new Event("AUTH_SUCCESS"))
//			e.target.dispose(true)
		}
		
		public function loadSettings():void{
			var settingsURL:String;
			if (Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn")
			{
				var url:String=ExternalInterface.call('eval', 'window.location.href');
				var urlVars:Array=url.split('?');
				var l:uint=urlVars.length;
				if (urlVars.length > 1)
				{
					var vars:URLVariables=new URLVariables(urlVars[1]);
					settingsURL=(vars.settingsURL != null) ? vars.settingsURL : null;
				}
			}
			
			
			if (settingsURL == null || settingsURL =="")
			{
				//live
				//				settingsURL="http://media.screa.ch.s3.amazonaws.com/resources/facebookPages/settings.json"
				//test	
				settingsURL = "http://media.screa.ch.s3.amazonaws.com/resources/facebookPages/test.json"
				//				throw new Error("No Settings File")
			}
			
			var settingsLoader:URLLoader = new URLLoader()
			settingsLoader.addEventListener(Event.COMPLETE, parseSettings)
			settingsLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError)
			settingsLoader.load(new URLRequest(settingsURL))

//			= new DataLoader(settingsURL, {name:"settings", onComplete:parseSettings, autoDispose:true})
//			settingsLoader.load()
		}
		
		protected function onIOError(event:IOErrorEvent):void
		{
			trace(event)
		}
		private function isBoolean(string:String):Boolean{
			var isBool:Boolean =	string  == "true" ? true : false;						
			return isBool
		}
		private function parseSettings(e:Event):void{
			e.target.removeEventListener(Event.COMPLETE, parseSettings)
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, onIOError)
				
			trace(e.target.data)
			var settings:Object = JSON.decode(e.target.data)
			settings = settings.settings			
			timeBetweenObjects = settings.timebetweenobjects
			facebookID = settings.id
			numberOfPhotoGroups = settings.numberofphotogroups
			customMessage = settings.message
			refreshTime = settings.refreshtime
			if (settings.dayfilter == undefined){
			dayFilter = "0"
			} else {
			dayFilter = settings.dayfilter
			}
			splashTime = int(settings.splashtimer)
			trace(settings.allowusercontent)
			allowUserContent = isBoolean(settings.allowusercontent)
			
			
			
			if(isBoolean(settings.video) == false){
				disallowedList.push ("video")
				disallowedList.push("swf")
			} 
			if (isBoolean(settings.link) == false){
				disallowedList.push("link")
			}
			if (isBoolean(settings.photoGroup) == false){
				disallowedList.push("photoGroup")
			}
			if (isBoolean(settings.photo) == false){
				disallowedList.push("photo")
			}
			if (isBoolean(settings.status) == false){
				disallowedList.push("status")
			}
			if (isBoolean(settings.question) == false){
				disallowedList.push("question")
			}		
			
			eventDispatcher.dispatchEvent(new Event("SETTINGS_LOADED"))
		}
	}
}