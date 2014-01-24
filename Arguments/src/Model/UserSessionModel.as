package Model
{
	
	import Controller.UserSessionController;
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ChatDataVO;
	import ValueObjects.UserDataVO;
	
	import classes.Language;
	
	import com.adobe.crypto.MD5;
	
	import components.ForgotPasswordPopUpPanel;
	import components.RegisterPanel;
	import components.ResetPasswordPanel;
	import components.TopPanel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.sampler.NewObjectSample;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	import mx.utils.ArrayUtil;
	
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
		public var selectedMyProjProjID:String;
		public var selectedWoAProjID:int;
		public var selectedMyContProjID:String;
		public var selectedTab:String=Language.lookup("MainTab");
		private var _hidemaptemp:Boolean=false;
		private var _securityAnswerSet:Boolean=false;
		private var _securityCodeNum:int=100;
		private var _securityAnswer:String="";
		private var _historyMapsVisited:Vector.<Object>;

		private static var _salt:String = "AGORA";
		

		public function UserSessionModel(target:IEventDispatcher=null)
		{

			_valueObject = new UserDataVO;
			historyMapsVisited = new Vector.<Object>;
			super(target);
		}
		
		//Getters and setters

		public function get hidemaptemp():Boolean
		{
			return _hidemaptemp;
		}

		public function set hidemaptemp(value:Boolean):void
		{
			_hidemaptemp = value;
		}

		public function get historyMapsVisited():Vector.<Object>
		{
			return _historyMapsVisited;
		}
		public function set historyMapsVisited(value:Vector.<Object>):void
		{
			_historyMapsVisited = value;
		}

		public function get securityAnswer():String
		{
			return _securityAnswer;
		}

		public function set securityAnswer(value:String):void
		{
			_securityAnswer = value;
		}

		public function get securityCodeNum():int
		{
			return _securityCodeNum;
		}

		public function set securityCodeNum(value:int):void
		{
			_securityCodeNum = value;
		}

		public function get securityAnswerSet():Boolean
		{
			return _securityAnswerSet;
		}

		public function set securityAnswerSet(value:Boolean):void
		{
			_securityAnswerSet = value;
		}

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
				securityAnswerSet = event.result.login.secQCode;
				securityCodeNum = event.result.login.secQCodeNum;
				securityAnswer = event.result.login.secQCodeAns;
				username=event.result.login.userName;
				if(!uid){
					dispatchEvent(new AGORAEvent(AGORAEvent.USER_INVALID));
					return;
				}
				dispatchEvent(new AGORAEvent(AGORAEvent.AUTHENTICATED));
			}catch(e:Error){
				trace("In UserSessionModel.onLoginRequestServiceResult: expected attributes were not present either because of invalid credentials or change in server ");
				dispatchEvent(new AGORAEvent(AGORAEvent.USER_INVALID));
			}
			//getProjects();
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
				url:userData.URL,secQ:userData.securityQs,secA:userData.securityAns});
		}
		public function changeInfo(userData:UserDataVO,newPass:String):void{
			var changeInfoRequestService:HTTPService = new HTTPService;
			
			if(newPass==null || newPass==""){
				newPass="";
			}else{
				newPass = MD5.hash(newPass + _salt);				
			}
			passHash = MD5.hash(userData.password + _salt);			
			changeInfoRequestService.url = AGORAParameters.getInstance().changeInfoURL;
			changeInfoRequestService.addEventListener(ResultEvent.RESULT, onChangeInfo);
			changeInfoRequestService.addEventListener(FaultEvent.FAULT, onRegistrationRequestServiceFault);
			changeInfoRequestService.send({username:userData.userName,
				pass_hash:passHash,
				firstname:userData.firstName,
				lastname:userData.lastName,
				email:userData.email,
				url:userData.URL,
				newpass:newPass,secQ:userData.securityQs,secA:userData.securityAns});
		}
		
		public function changeSecInfo(userData:UserDataVO):void{
			var changeInfoRequestService:HTTPService = new HTTPService;
	//		passHash = MD5.hash(userData.password + _salt);
			changeInfoRequestService.url = AGORAParameters.getInstance().changeInfoURL;
			changeInfoRequestService.addEventListener(ResultEvent.RESULT, onSECChangeInfo);
			changeInfoRequestService.addEventListener(FaultEvent.FAULT, onRegistrationRequestServiceFault);
			changeInfoRequestService.send({username:userData.userName,
				pass_hash:passHash,
				firstname:userData.firstName,
				lastname:userData.lastName,
				email:userData.email,
				url:userData.URL,
				secQ:userData.securityQs,secA:userData.securityAns});
		}


		protected function onChangeInfo(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onChangeInfo);
			event.target.removeEventListener(FaultEvent.FAULT,onRegistrationRequestServiceFault		);
			try{
				// check error
				if(event.result.agora.hasOwnProperty("error")){
					if(event.result.agora.error.text == "UserNamePassWordNotMatching"){
						mx.controls.Alert.show(Language.lookup(event.result.agora.error.text));
					}else{
					mx.controls.Alert.show(event.result.agora.error.text);
					}
					return;
				}				
				// else change the data 
				if(event.result.agora.hasOwnProperty("success")){
						firstName = event.result.agora.success.firstname;
						lastName = event.result.agora.success.lastname;
						email = event.result.agora.success.email;
						URL = event.result.agora.success.url;
						securityAnswerSet = event.result.agora.success.secQCode;
						securityCodeNum = event.result.agora.success.secQCodeNum;
						securityAnswer = event.result.agora.success.secQCodeAns;
						mx.controls.Alert.show(Language.lookup("RegChange"));
				}
			//	securityAnswerSet = event.result.agora.success.securityAnswerSet;
			}catch(e:Error){
				trace(e.message);
			}
		}
		
		protected function onSECChangeInfo(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onSECChangeInfo);
			event.target.removeEventListener(FaultEvent.FAULT,onRegistrationRequestServiceFault		);
			
			try{
				
				// check error
				if(event.result.agora.hasOwnProperty("error")){
					if(event.result.agora.error.text == "UserNamePassWordNotMatching"){
						Alert.show(Language.lookup(event.result.agora.error.text));
					}else{
					Alert.show(event.result.agora.error.text);
					}
				}
				
				// change status if not				
				if(event.result.agora.hasOwnProperty("success")){
					securityAnswerSet = event.result.agora.success.secQCode;
					securityCodeNum = event.result.agora.success.secQCodeNum;
					securityAnswer = event.result.agora.success.secQCodeAns;
					mx.controls.Alert.show(Language.lookup("RegChange"));
				}				
							}catch(e:Error){
				trace(e.message);
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
			event.target.removeEventListener(ResultEvent.RESULT, onRegistrationRequestServiceResult);
			event.target.removeEventListener(FaultEvent.FAULT, onRegistrationRequestServiceFault);
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		
		// added methods for forgot password flow
		public function getUserName(userName:String):void{			
			var forgotpwdreq:HTTPService = new HTTPService;
			forgotpwdreq.url = AGORAParameters.getInstance().forgotpasswordURL;
			forgotpwdreq.addEventListener(ResultEvent.RESULT, onFPUserFound);
			forgotpwdreq.addEventListener(FaultEvent.FAULT, onFPReqFailed);
			forgotpwdreq.send({username:userName,"action":"searchuser"});			
		}
		
		protected function onFPUserFound(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onFPUserFound);
			event.target.removeEventListener(FaultEvent.FAULT, onFPReqFailed);
			if(event.result.AGORA.hasOwnProperty("error")){
				Alert.show(Language.lookup('FPUserNotFound'));
				var fgtwindow:ForgotPasswordPopUpPanel = FlexGlobals.topLevelApplication.forgotpwdWindow;
				fgtwindow.FP_userName.setFocus();
				dispatchEvent(new AGORAEvent(AGORAEvent.FORGOT_PASSWORD_SEARCHUSERERROR, <error text={event.result.AGORA.error.text} />, null));
			}else if(event.result.AGORA.hasOwnProperty("securityQs")){
				Alert.show(Language.lookup(event.result.AGORA.securityQs.text));
				dispatchEvent(new AGORAEvent(AGORAEvent.FORGOT_PASSWORD_SEARCHUSERERROR, <securityQs text={event.result.AGORA.securityQs.text} />, null));
			}
			else{
				var fgtwindow:ForgotPasswordPopUpPanel = FlexGlobals.topLevelApplication.forgotpwdWindow;
				var secQStrIndex = fgtwindow.secCodes.indexOf(event.result.AGORA.success.securityQNum);
				fgtwindow.FP_secQuestion.text = fgtwindow.secQstn[secQStrIndex];
				fgtwindow.FP_secAnswer.setFocus();
				dispatchEvent(new AGORAEvent(AGORAEvent.FORGOT_PASSWORD_SEARCHUSER,<success uid={event.result.AGORA.success.userId} secQs={event.result.AGORA.success.securityQNum} />, null));
			}
		}
		
		protected function onFPReqFailed(event:Event):void{
			event.target.removeEventListener(ResultEvent.RESULT, onFPUserFound);
			event.target.removeEventListener(FaultEvent.FAULT, onFPReqFailed);
			dispatchEvent(new AGORAEvent(AGORAEvent.FORGOT_PASSWORD_SEARCHUSERERROR));
		}
		
		
		public function checkSecAnswer(userName:String,secAnswer:String):void{			
			var forgotpwdreq:HTTPService = new HTTPService;
			forgotpwdreq.url = AGORAParameters.getInstance().forgotpasswordURL;
			forgotpwdreq.addEventListener(ResultEvent.RESULT, onFPSAFound);
			forgotpwdreq.addEventListener(FaultEvent.FAULT, onFPSAFailed);
			forgotpwdreq.send({username:userName,secanswer:secAnswer,"action":"resetPasswordLink"});			
		}
		
		protected function onFPSAFound(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onFPSAFound);
			event.target.removeEventListener(FaultEvent.FAULT, onFPSAFailed);
			
			if(event.result.AGORA.hasOwnProperty("error")){
				Alert.show(Language.lookup('FPUserNotFound'));
				dispatchEvent(new AGORAEvent(AGORAEvent.FORGOT_PASSWORD_SECQERROR, <error text={event.result.AGORA.error.text} />, null));
			}else if(event.result.AGORA.hasOwnProperty("securityQans")){
				Alert.show(Language.lookup(event.result.AGORA.securityQans.text));
				dispatchEvent(new AGORAEvent(AGORAEvent.FORGOT_PASSWORD_SECQERROR, <securityQans text={event.result.AGORA.securityQans.text} />, null));
				var fgtwindow:ForgotPasswordPopUpPanel = FlexGlobals.topLevelApplication.forgotpwdWindow;
				fgtwindow.FP_securityDiv.enabled=true;
				fgtwindow.OK_btn.enabled=true;
				fgtwindow.FP_secAnswer.setFocus();
			}else if(event.result.AGORA.hasOwnProperty("success")){
				dispatchEvent(new AGORAEvent(AGORAEvent.FORGOT_PASSWORD_SECQUESTION));
			}
		}
		
		protected function onFPSAFailed(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onFPSAFound);
			event.target.removeEventListener(FaultEvent.FAULT, onFPSAFailed);
			dispatchEvent(new AGORAEvent(AGORAEvent.FORGOT_PASSWORD_SECQERROR));
		}
		
		public function testTicket(ticket:String):void{
			var forgotpwdreq:HTTPService = new HTTPService;
			forgotpwdreq.url = AGORAParameters.getInstance().forgotpasswordURL;
			forgotpwdreq.addEventListener(ResultEvent.RESULT, onTicketValid);
			forgotpwdreq.addEventListener(FaultEvent.FAULT, onTicketInvalid);
			forgotpwdreq.send({"ticket":ticket,"action":"checkticket"});		
		}
		
		protected function onTicketValid(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onTicketValid);
			event.target.removeEventListener(FaultEvent.FAULT, onTicketInvalid);
			if(event.result.AGORA.hasOwnProperty("error")){
				var fgtwindow:ResetPasswordPanel = FlexGlobals.topLevelApplication.resetPanel;
				fgtwindow.RP_displayDiv.visible=false;
				fgtwindow.RP_infoMsg.text="reset password link has expired.";
			}else{
				var fgtwindow:ResetPasswordPanel = FlexGlobals.topLevelApplication.resetPanel;
				fgtwindow.RP_displayDiv.visible=true;
				fgtwindow.RP_infoMsg.text='Hi '+event.result.AGORA.success.username+' you can reset your password below.';
			}
		}
		
		protected function onTicketInvalid(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onTicketValid);
			event.target.removeEventListener(FaultEvent.FAULT, onTicketInvalid);			
		}
		
		public function savePassword(ticket:String,newpwd:String):void{
			var forgotpwdreq:HTTPService = new HTTPService;
			forgotpwdreq.url = AGORAParameters.getInstance().forgotpasswordURL;
			forgotpwdreq.addEventListener(ResultEvent.RESULT, onSavePasswordSuccess);
			forgotpwdreq.addEventListener(FaultEvent.FAULT, onSavePasswordNotSuccess);
			var newpassHash:String = MD5.hash(newpwd + _salt);
			forgotpwdreq.send({"ticket":ticket,"action":"savepwd","newpwd":newpassHash});		
		}
				
		protected function onSavePasswordSuccess(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onSavePasswordSuccess);
			event.target.removeEventListener(FaultEvent.FAULT, onSavePasswordNotSuccess);
			if(event.result.AGORA.hasOwnProperty("error")){
				Alert.show(Language.lookup('FPPwdSaveFailed'));
			}else{
				Alert.show(Language.lookup('FPPwdSaved'));
				// redirect
				AGORAModel.getInstance().userSessionModel.uid = 0;
				FlexGlobals.topLevelApplication.invalidateProperties();
				FlexGlobals.topLevelApplication.invalidateDisplayList();
				navigateToURL(new URLRequest('http://agora.gatech.edu/'),"_self");
			}
		}
		
		protected function onSavePasswordNotSuccess(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onSavePasswordSuccess);
			event.target.removeEventListener(FaultEvent.FAULT, onSavePasswordNotSuccess);
		}
		
		
	}
}