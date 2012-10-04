package Model 
{
    import Events.*;
    
    import ValueObjects.*;
    
    import flash.events.*;
    
    import mx.controls.Alert;
    import mx.rpc.events.*;
    import mx.rpc.http.*;
    
    public class SelectAsAdmin extends flash.events.EventDispatcher
    {
        public function SelectAsAdmin()
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

        public function sendRequest(newAdmin:String):void
        {
            var loc2:*=null;
            var loc1:*=Model.AGORAModel.getInstance().userSessionModel;
            if (loc1.loggedIn()) 
            {
                loc2 = {"action":"makeAdmin","newAdminUserId":newAdmin, "projID":loc1.selectedMyProjProjID, "uid":loc1.uid, "pass_hash":loc1.passHash};
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
                    dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.ADMIN_CHANGE_FAILED));
                    return;
                }
            }
			
			if (arg1.result.hasOwnProperty("userError")) 
			{
						Alert.show("Users not found:"+arg1.result.userError.@message);
			}
			
            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.ADMIN_CHANGED));
            return;
        }

        protected function onFault(arg1:mx.rpc.events.FaultEvent):void
        {
            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.ADMIN_CHANGE_FAILED));
            return;
        }

        internal var request:mx.rpc.http.HTTPService;
    }
}
