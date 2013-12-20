package Model 
{
    import Events.*;
    
    import ValueObjects.*;
    
    import classes.Language;
    
    import flash.events.*;
    
    import mx.controls.Alert;
    import mx.rpc.events.*;
    import mx.rpc.http.*;
    
    public class AddUsers extends flash.events.EventDispatcher
    {
        public function AddUsers()
        {
            super();
            this.request = new mx.rpc.http.HTTPService();
            this.request.url = ValueObjects.AGORAParameters.getInstance().projUsersURL;
            this.request.resultFormat = "e4x";
            this.request.requestTimeout = 3;
            this.request.addEventListener(mx.rpc.events.ResultEvent.RESULT, this.onResult);
            this.request.addEventListener(mx.rpc.events.FaultEvent.FAULT, this.onFault);
            return;
        }

        public function sendRequest():void
        {
            var loc2:*=null;
            var loc1:*=Model.AGORAModel.getInstance().userSessionModel;
            if (loc1.loggedIn()) 
            {
				var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
				var sendProjID:int;
				var selectedTab:String=usm.selectedTab;
				if (selectedTab == Language.lookup("MainTab")){
					loc2 = {"action":"add", "projID":loc1.selectedWoAProjID, "uid":loc1.uid, "pass_hash":loc1.passHash, "usersList[]":Model.AGORAModel.getInstance().agoraMapModel.projectUsers};
				}else{
                loc2 = {"action":"add", "projID":loc1.selectedMyProjProjID, "uid":loc1.uid, "pass_hash":loc1.passHash, "usersList[]":Model.AGORAModel.getInstance().agoraMapModel.projectUsers};
				}
				
				this.request.send(loc2);
            }
            return;
        }

        protected function onResult(arg1:mx.rpc.events.ResultEvent):void
        {
            if (arg1.result.hasOwnProperty("project")) 
            {
                if (arg1.result.proj.hasOwnProperty("error")) 
                {
                    dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.ADD_USERS_FAILED));
                    return;
                }
            }
			
			if (arg1.result.hasOwnProperty("userError")) 
			{
						Alert.show("Users not found:"+arg1.result.userError.@message);
			}

			if (arg1.result.hasOwnProperty("addAdminError")) 
			{
				Alert.show(Language.lookup(arg1.result.addAdminError.@message));
			}
			
            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.ADDED_USERS));
            return;
        }

        protected function onFault(arg1:mx.rpc.events.FaultEvent):void
        {
            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.FAULT));
            return;
        }

        internal var request:mx.rpc.http.HTTPService;
    }
}
