package Model 
{
    import Events.*;
    
    import ValueObjects.*;
    
    import classes.Language;
    import flash.events.*;
    
    import mx.controls.Alert;
    import mx.rpc.events.*;
    import mx.rpc.http.*;
    
    public class DeleteProject extends flash.events.EventDispatcher
    {
        public function DeleteProject()
        {
            super();
            this.request = new mx.rpc.http.HTTPService();
            this.request.url = ValueObjects.AGORAParameters.getInstance().delProjURL;
            this.request.resultFormat = "e4x";
            this.request.requestTimeout = 3;
            this.request.addEventListener(mx.rpc.events.ResultEvent.RESULT, this.onResult);
            this.request.addEventListener(mx.rpc.events.FaultEvent.FAULT, this.onFault);
            return;
        }

        public function sendRequest(projID:String):void
        {
            var loc2:*=null;
            var loc1:*=Model.AGORAModel.getInstance().userSessionModel;
            if (loc1.loggedIn()) 
            {
                loc2 = { "projID":projID, "uid":loc1.uid, "pass_hash":loc1.passHash};
                this.request.send(loc2);
            }
            return;
        }

        protected function onResult(arg1:mx.rpc.events.ResultEvent):void
        {



                if (arg1.result.hasOwnProperty("error")) 
                {
					mx.controls.Alert.show(Language.lookup(arg1.result.error.@text));

                    dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.DELETE_PROJECT_FAILED));
                    return;
                }
			

            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.DELETED_PROJECT));
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
