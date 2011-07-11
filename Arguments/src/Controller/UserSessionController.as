package Controller
{
	import Events.NetworkEvent;
	
	import Model.AGORAModel;
	import Model.UserSessionModel;
	
	import ValueObjects.UserDataVO;
	
	import components.LoginWindow;
	import components.RegisterPanel;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;

	public class UserSessionController
	{	
		public function UserSessionController(){
			
		}
		
		//----------------Displaying Login Box---------------------//
		public function showSignInBox():void{
			FlexGlobals.topLevelApplication.loginWindow = new LoginWindow;
			PopUpManager.addPopUp(FlexGlobals.topLevelApplication.loginWindow, DisplayObject(FlexGlobals.topLevelApplication),true);
			PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.loginWindow);
		}
		
		public function removeSignInBox():void{
			PopUpManager.removePopUp(FlexGlobals.topLevelApplication.loginWindow);
		}
		
		//--------------Displaying Registration Box---------------//
		public function showRegistrationBox():void{
			FlexGlobals.topLevelApplication.registrationWindow = new RegisterPanel;
			PopUpManager.addPopUp(FlexGlobals.topLevelApplication.registrationWindow, DisplayObject(FlexGlobals.topLevelApplication), true);
			PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.registrationWindow);
		}
		
		public function removeRegistrationBox():void{
			PopUpManager.removePopUp(FlexGlobals.topLevelApplication.registrationWindow);	
		}
		
		
		//--------------Login Function--------------------------//
		public function login(userDataVO:UserDataVO):void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			userSessionModel.addEventListener(NetworkEvent.AUTHENTICATED, onAuthentication);
			userSessionModel.addEventListener(NetworkEvent.USER_INVALID, onAuthenticationFailure);
			userSessionModel.addEventListener(NetworkEvent.FAULT, onFault);
			userSessionModel.authenticate(userDataVO);
		}
		
		protected function onAuthentication(event:NetworkEvent):void{
			event.target.removeEventListener(NetworkEvent.AUTHENTICATED, onAuthentication);
			event.target.removeEventListener(NetworkEvent.USER_INVALID, onAuthenticationFailure);
			event.target.removeEventListener(NetworkEvent.FAULT, onFault);
			trace("User Authenticated");
			removeSignInBox();
			var agoraController:AGORAController = new AGORAController;
			agoraController.fetchDataMyMaps();	
		}
		
		protected function onAuthenticationFailure(event:NetworkEvent):void{
			event.target.removeEventListener(NetworkEvent.AUTHENTICATED, onAuthentication);
			event.target.removeEventListener(NetworkEvent.USER_INVALID, onAuthenticationFailure);
			event.target.removeEventListener(NetworkEvent.FAULT, onFault);
			trace("User Authentication Failed");	
			Alert.show("Invalid username/password");
		}
		
		//----------------Registration Function--------------------//
		public function register(userDataVO:UserDataVO):void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			userSessionModel.addEventListener(NetworkEvent.REGISTRATION_SUCCEEDED, onRegistrationRequestSuccess);
			userSessionModel.addEventListener(NetworkEvent.REGISTRATION_FAILED, onRegistrationRequestFailure);
			userSessionModel.addEventListener(NetworkEvent.FAULT, onFault);
			
			userSessionModel.register(userDataVO);
		}
		
		protected function onRegistrationRequestSuccess(event:NetworkEvent):void{
			event.target.removeEventListener(NetworkEvent.REGISTRATION_SUCCEEDED, onRegistrationRequestSuccess);
			event.target.removeEventListener(NetworkEvent.REGISTRATION_FAILED, onRegistrationRequestFailure);
			event.target.removeEventListener(NetworkEvent.FAULT, onFault);
			
			removeRegistrationBox();
			Alert.show("Registration Successful. You may use your username/password to participate in AGORA.");
		}
		
		protected function onRegistrationRequestFailure(event:NetworkEvent):void{
			event.target.removeEventListener(NetworkEvent.REGISTRATION_SUCCEEDED, onRegistrationRequestSuccess);
			event.target.removeEventListener(NetworkEvent.REGISTRATION_FAILED, onRegistrationRequestFailure);
			event.target.removeEventListener(NetworkEvent.FAULT, onFault);
			
			Alert.show("Registration Failed");
		}
		
		//---------------Generic Network Fault----------------------//
		protected function onFault(event:NetworkEvent):void{
			try{
				event.target.removeEventListener(NetworkEvent.REGISTRATION_SUCCEEDED, onRegistrationRequestSuccess);
				event.target.removeEventListener(NetworkEvent.REGISTRATION_FAILED, onRegistrationRequestFailure);
			}catch(error:Error){
				event.target.removeEventListener(NetworkEvent.AUTHENTICATED, onAuthentication);
				event.target.removeEventListener(NetworkEvent.USER_INVALID, onAuthenticationFailure);
			}finally{
				event.target.removeEventListener(NetworkEvent.FAULT, onFault);	
			}
			Alert.show("Could not contact Authenticaion Server. Please make sure you are connected to the Internet");
		}
		
	}
}