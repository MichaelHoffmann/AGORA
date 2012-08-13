package Model
{
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ChatDataVO;
	import ValueObjects.UserDataVO;
	
	import com.adobe.crypto.MD5;
	
	import components.RegisterPanel;
	import components.TopPanel;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	
	import org.osmf.utils.URL;
	
	[Bindable]
	public class UserSessionModel extends EventDispatcher
	{
		private var _username:String;
		public var firstName:String;
		public var lastName:String;
		public var _uid:int;
		public var password:String;
		public var passHash:String;
		public var email:String;
		public var URL:String;
		
		private var _valueObject:UserDataVO;
		private static var _salt:String = "AGORA";
		

		public function UserSessionModel(target:IEventDispatcher=null)
		{

			_valueObject = new UserDataVO;
			super(target);
		}
		
		//Getters and setters

		public function get username():String
		{
			return _username;
		}

		public function set username(value:String):void
		{
			_username = value;
		}

		public function get valueObject():UserDataVO
		{
			_valueObject.firstName = this.firstName;
			_valueObject.lastName = this.lastName;
			_valueObject.password = this.password;
			_valueObject.email = this.email;
			_valueObject.URL = this.URL;
			return _valueObject;
		}
		

		public function get uid():int{
			return _uid;
		}
		

		
		public function set uid(value:int):void{
			if(value != _uid){
				_uid = value;
				dispatchEvent(new AGORAEvent(AGORAEvent.LOGIN_STATUS_SET));
			}
		}
		
		[Bindable(event="LogInStatus")]
		public function loggedIn():Boolean{
			if(uid){
				return true;
			}else{
				return false;
			}
		}
		
		//---------------- Authentication ------------------------//
		public function authenticate(userData:UserDataVO):void{
			
			var loginRequestService:HTTPService = new HTTPService;
			passHash = MD5.hash(userData.password + _salt);
			loginRequestService.url = AGORAParameters.getInstance().loginURL;
			//loginRequestService.request['username'] = userData.userName;
			//loginRequestService.request['pass_hash'] = passHash;
			trace(userData.userName);
			trace(passHash);
			username = userData.userName;
			loginRequestService.addEventListener(ResultEvent.RESULT, onLoginRequestServiceResult);
			loginRequestService.addEventListener(FaultEvent.FAULT, onLoginRequestServiceFault);
			loginRequestService.send({username: userData.userName, pass_hash: passHash});
		}

		
		protected function onChatFetched(event:AGORAEvent):void{
			FlexGlobals.topLevelApplication.agoraMenu.chat.invalidateProperties();
			FlexGlobals.topLevelApplication.agoraMenu.chat.invalidateDisplayList();
		}
		
		/**
		 * @param event Result Event that is typically ust event 
		 * 
		 * Removes the event listeners from the login result and then assigns values to variable from the database.
		 * If any of those are null then it falls out and fires a USER_INVALID event. In other words, the user MUST 
		 * supply a correct username or password to log in. This method required a rework in the new implementation
		 * for no apparent reason. If just stopped working.
		 */
		protected function onLoginRequestServiceResult(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onLoginRequestServiceResult);
			event.target.removeEventListener(FaultEvent.FAULT, onLoginRequestServiceFault);
			try{				
				uid = event.result.login.ID;
				firstName = event.result.login.firstname;
				lastName = event.result.login.lastname;
				email = event.result.login.email;
				URL = event.result.login.url;
				if(!uid){
					dispatchEvent(new AGORAEvent(AGORAEvent.USER_INVALID));
					return;
				}
				dispatchEvent(new AGORAEvent(AGORAEvent.AUTHENTICATED));
			}catch(e:Error){
				trace("In UserSessionModel.onLoginRequestServiceResult: expected attributes were not present either because of invalid credentials or change in server ");
				dispatchEvent(new AGORAEvent(AGORAEvent.USER_INVALID));
			}
		}
		
		protected function onLoginRequestServiceFault(event:FaultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onLoginRequestServiceResult);
			event.target.removeEventListener(FaultEvent.FAULT, onLoginRequestServiceFault);
			dispatchEvent( new AGORAEvent(AGORAEvent.FAULT));
		}
		
		//---------------- Registration-----------------------------//
		public function register(userData:UserDataVO):void{
			var registrationRequestService:HTTPService = new HTTPService;
			passHash = MD5.hash(userData.password + _salt);
			registrationRequestService.url = AGORAParameters.getInstance().registrationURL;
			registrationRequestService.addEventListener(ResultEvent.RESULT, onRegistrationRequestServiceResult);
			registrationRequestService.addEventListener(FaultEvent.FAULT, onRegistrationRequestServiceFault);
			registrationRequestService.send({username:userData.userName,
				pass_hash:passHash,
				firstname:userData.firstName,
				lastname:userData.lastName,
				email:userData.email,
				url:userData.URL});
		}
		public function changeInfo(userData:UserDataVO,newPass:String):void{
			var changeInfoRequestService:HTTPService = new HTTPService;
			trace (userData.password);
			passHash = MD5.hash(userData.password + _salt);
			trace (userData.userName);
			trace (passHash);
			
			newPass = MD5.hash(newPass + _salt);
			changeInfoRequestService.url = AGORAParameters.getInstance().changeInfoURL;
			changeInfoRequestService.addEventListener(ResultEvent.RESULT, onChangeInfo);
			changeInfoRequestService.addEventListener(FaultEvent.FAULT, onChangeInfo);
			changeInfoRequestService.send({username:userData.userName,
				pass_hash:passHash,
				firstname:userData.firstName,
				lastname:userData.lastName,
				email:userData.email,
				url:userData.URL,
				newpass:newPass});

		}
		protected function onChangeInfo(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onChangeInfo);
			event.target.removeEventListener(FaultEvent.FAULT, onChangeInfo);

			try{
				trace("starting try");
				username = event.result.changeinfo.ID;
				trace("new username"+username);
				firstName = event.result.changeinfo.firstname;
				trace("new firstName"+firstName);
				lastName = event.result.changeinfo.lastname;
				trace("new lastName"+lastName);
				email = event.result.changeinfo.email;
				trace("new email"+email);
				URL = event.result.changeinfo.url;
				trace("new url"+URL);
			}catch(e:Error){
				trace(e.message);
				trace("In UserSessionModel.onLoginRequestServiceResult: expected attributes were not present either because of invalid credentials or change in server ");
				dispatchEvent(new AGORAEvent(AGORAEvent.USER_INVALID));
			}
		}
		protected function onRegistrationRequestServiceResult(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onRegistrationRequestServiceResult);
			event.target.removeEventListener(FaultEvent.FAULT, onRegistrationRequestServiceFault);
			if(event.result.AGORA.hasOwnProperty("error")){
				dispatchEvent(new AGORAEvent(AGORAEvent.REGISTRATION_FAILED, <error text={event.result.AGORA.error.text} />, null));
			}
			else if(event.result.AGORA.login.hasOwnProperty("created")){
				dispatchEvent(new AGORAEvent(AGORAEvent.REGISTRATION_SUCCEEDED, null,null));
			}else{
				dispatchEvent(new AGORAEvent(AGORAEvent.REGISTRATION_FAILED, <error text={AGORAParameters.getInstance().REGISTRATION_FAILED_MESSAGE}/>, null));
			}
		}
		
		protected function onRegistrationRequestServiceFault(event:ResultEvent):void{
			trace(event.result.toXMLString());
			event.target.removeEventListener(ResultEvent.RESULT, onRegistrationRequestServiceResult);
			event.target.removeEventListener(FaultEvent.FAULT, onRegistrationRequestServiceFault);
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		

		

		
		
	}
}