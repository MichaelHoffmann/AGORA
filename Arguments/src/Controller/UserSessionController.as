package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.UserSessionModel;
	
	import ValueObjects.UserDataVO;
	
	import classes.Language;
	import flash.net.*;
	import components.LoginWindow;
	import components.Projects;
	import components.RegisterPanel;
	
	import flash.display.DisplayObject;
	import flash.net.URLRequest;
	
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
			FlexGlobals.topLevelApplication.registrationWindow.init();
			PopUpManager.addPopUp(FlexGlobals.topLevelApplication.registrationWindow, DisplayObject(FlexGlobals.topLevelApplication), true);
			PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.registrationWindow);
		}
		
		public function removeRegistrationBox():void{
			PopUpManager.removePopUp(FlexGlobals.topLevelApplication.registrationWindow);	
		}
		
		//--------------Login as Guest Function-----------------//
		public function signInAsGuest():void{
			FlexGlobals.topLevelApplication.agoraMain.setVisible(false,true);
			FlexGlobals.topLevelApplication.agoraMenu.setVisible(true,true);
			FlexGlobals.topLevelApplication.rightSidePanel.setVisible(true,true);
			var userDataVO:UserDataVO = new UserDataVO;
			userDataVO.password = "guest";
			userDataVO.userName = "Guest";
			login(userDataVO);
		}
		//--------------Login Function--------------------------//
		public function login(userDataVO:UserDataVO):void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			userSessionModel.authenticate(userDataVO);
		}
		
		
		protected function onAuthentication(event:AGORAEvent):void{
			trace("User Authenticated");
			removeSignInBox();
			FlexGlobals.topLevelApplication.agoraMain.setVisible(false,true);
			FlexGlobals.topLevelApplication.agoraMenu.setVisible(true,true);
			FlexGlobals.topLevelApplication.rightSidePanel.setVisible(true,true);
			var agoraController:AGORAController = AGORAController.getInstance();
			agoraController.fetchDataMyMaps();
			agoraController.fetchDataMyProjects();
		}
		
		protected function onAuthenticationFailure(event:AGORAEvent):void{
			trace("User Authentication Failed. Wrong Username/Password combination");	
			Alert.show(Language.lookup("LoginFailed"));
		}
		
		//----------------Registration Function--------------------//
		public function register(userDataVO:UserDataVO):void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			userSessionModel.register(userDataVO);
		}
		public function changeInfo(userDataVO:UserDataVO, newPass:String):void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			userSessionModel.changeInfo(userDataVO,newPass);
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
			trace("Getting the text for the sign in button");
			if(uid == 0 || AGORAModel.getInstance().userSessionModel.username == "Guest"){
				//The reason this is unspaced is so that when it returns, the calling function can then pass it straight to Language.lookup(...)
				return "SignIn"; 
			}
			else{
				//The reason this is unspaced is so that when it returns, the calling function can then pass it straight to Language.lookup(...)
				return "SignOut";
			}
			
		}
		
		public function getRegisterBtnText(uid:int):String{
			trace("Getting the text for the register button");
			if(uid == 0 || AGORAModel.getInstance().userSessionModel.username == "Guest"){
				//The reason this is unspaced is so that when it returns, the calling function can then pass it straight to Language.lookup(...)
				return "RegisterAsNew"; 
			}
			else{
				//The reason this is unspaced is so that when it returns, the calling function can then pass it straight to Language.lookup(...)
				return "ChangeRegData";
			}
			
		}
		
		public function signInSignOut():void{
			if(AGORAModel.getInstance().userSessionModel.loggedIn() && AGORAModel.getInstance().userSessionModel.username != "Guest"){
				AGORAModel.getInstance().userSessionModel.uid = 0;
				FlexGlobals.topLevelApplication.invalidateProperties();
				FlexGlobals.topLevelApplication.invalidateDisplayList();
				var urlRequest:URLRequest = new URLRequest(FlexGlobals.topLevelApplication.url);
				 navigateToURL(urlRequest,"_self");
				

			}
			else{
				showSignInBox();
			}
		}
	}
}


class SingletonEnforcer{
	
}
