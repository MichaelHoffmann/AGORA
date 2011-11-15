package Model
{
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.UserDataVO;
	
	import com.adobe.crypto.MD5;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
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
		
		protected function onLoginRequestServiceResult(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onLoginRequestServiceResult);
			event.target.removeEventListener(FaultEvent.FAULT, onLoginRequestServiceFault);
			try{
				//trace(event.result.toXMLString());
				uid = event.result.login.ID;
				firstName = event.result.login.firstname;
				lastName = event.result.login.lastname;
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
		
		protected function onRegistrationRequestServiceResult(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onRegistrationRequestServiceResult);
			event.target.removeEventListener(FaultEvent.FAULT, onRegistrationRequestServiceFault);
			if(event.result.AGORA.login.hasOwnProperty("created")){
				dispatchEvent(new AGORAEvent(AGORAEvent.REGISTRATION_SUCCEEDED));
			}else{
				dispatchEvent(new AGORAEvent(AGORAEvent.REGISTRATION_FAILED));
			}
		}
		
		protected function onRegistrationRequestServiceFault(event:ResultEvent):void{
			//trace(event.result.toXMLString());
			event.target.removeEventListener(ResultEvent.RESULT, onRegistrationRequestServiceResult);
			event.target.removeEventListener(FaultEvent.FAULT, onRegistrationRequestServiceFault);
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		
	}
}