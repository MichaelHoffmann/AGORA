package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.UserSessionModel;
	
	import ValueObjects.UserDataVO;
	
	import components.LoginWindow;
	import components.RegisterPanel;
	import classes.Language;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	
	public class UserSessionController
	{	
		private static var instance:UserSessionController;
		
		//----------------Constructor---------------------//
		public function UserSessionController(singletonEnforcer:SingletonEnforcer){
			instance = this;
			AGORAModel.getInstance().userSessionModel.addEventListener(AGORAEvent.AUTHENTICATED, onAuthentication);
			AGORAModel.getInstance().userSessionModel.addEventListener(AGORAEvent.USER_INVALID, onAuthenticationFailure);
			AGORAModel.getInstance().userSessionModel.addEventListener(AGORAEvent.FAULT, onFault);
			AGORAModel.getInstance().userSessionModel.addEventListener(AGORAEvent.REGISTRATION_SUCCEEDED, onRegistrationRequestSuccess);
			AGORAModel.getInstance().userSessionModel.addEventListener(AGORAEvent.REGISTRATION_FAILED, onRegistrationRequestFailure);
			AGORAModel.getInstance().userSessionModel.addEventListener(AGORAEvent.FAULT, onFault);
		}
		
		//----------------get Instance ----------------------------//
		public static function getInstance():UserSessionController{
			if(!instance){
				instance = new UserSessionController(new SingletonEnforcer);
			}
			return instance;
		}
		
		//----------------Displaying Login Box---------------------//
		public function showSignInBox(message:String = null):void{
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
			userSessionModel.authenticate(userDataVO);
		}
		
		protected function onAuthentication(event:AGORAEvent):void{
			trace("User Authenticated");
			removeSignInBox();
			var agoraController:AGORAController = AGORAController.getInstance();
			agoraController.fetchDataMyMaps();
			agoraController.fetchDataMyProjects();
		}
		
		protected function onAuthenticationFailure(event:AGORAEvent):void{
			trace("User Authentication Failed");	
			Alert.show(Language.lookup("LoginFailed"));
		}
		
		//----------------Registration Function--------------------//
		public function register(userDataVO:UserDataVO):void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			userSessionModel.register(userDataVO);
		}
		
		protected function onRegistrationRequestSuccess(event:AGORAEvent):void{
			removeRegistrationBox();
			Alert.show(Language.lookup("RegisterSuccess"));
		}
		
		protected function onRegistrationRequestFailure(event:AGORAEvent):void{
			//TODO: Get the appropriate text from the XML
			trace(event.xmlData.text);
			Alert.show(event.xmlData.@text);
			Alert.show(Language.lookup("RegisterFailed"));
		}
		
		//---------------Generic Network Fault----------------------//
		protected function onFault(event:AGORAEvent):void{
			Alert.show(Language.lookup("NetworkError"));
		}
		
		//---------------Other public methods----------------------//
		public function getSignInBtnText(uid:int):String{
			if(uid == 0){
				return "Sign In";
			}
			else{
				return "Sign Out";
			}
			
		}
		
		public function signInSignOut():void{
			if(AGORAModel.getInstance().userSessionModel.loggedIn()){
				AGORAModel.getInstance().userSessionModel.uid = 0;
				FlexGlobals.topLevelApplication.agoraMenu.myMaps.invalidateSkinState();
				FlexGlobals.topLevelApplication.invalidateProperties();
				FlexGlobals.topLevelApplication.invalidateDisplayList();
			}
			else{
				showSignInBox();
			}
		}
	}
}


class SingletonEnforcer{
	
}
