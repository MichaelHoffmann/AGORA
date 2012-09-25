package Model 
{
    import Events.*;
    import ValueObjects.*;
    import flash.events.*;
    import mx.rpc.events.*;
    import mx.rpc.http.*;
    
    public class RemoveUsers extends flash.events.EventDispatcher
    {
        public function RemoveUsers()
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
                loc2 = {"action":"remove", "projID":loc1.selectedMyProjProjID, "uid":loc1.uid, "pass_hash":loc1.passHash, "usersList[]":Model.AGORAModel.getInstance().agoraMapModel.projectUsers};
                this.request.send(loc2);
            }
            return;
        }

        protected function onResult(arg1:mx.rpc.events.ResultEvent):void
        {
            if (arg1.result.hasOwnProperty("proj")) 
            {
                if (arg1.result.proj.hasOwnProperty("error")) 
                {
                    dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.REMOVE_USERS_FAILED));
                    return;
                }
            }
            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.REMOVED_USERS));
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
