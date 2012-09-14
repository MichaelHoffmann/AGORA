package Model 
{
    import Events.*;
    
    import ValueObjects.*;
    
    import flash.events.*;
    
    import mx.controls.Alert;
    import mx.rpc.events.*;
    import mx.rpc.http.*;
    
    public class ProjectsModel extends flash.events.EventDispatcher
    {
        public function ProjectsModel()
        {
            super();
            this.request = new mx.rpc.http.HTTPService();
            this.request.url = ValueObjects.AGORAParameters.getInstance().projectListURL;
            this.request.resultFormat = "e4x";
            this.request.requestTimeout = 3;
            this.request.addEventListener(mx.rpc.events.ResultEvent.RESULT, this.onResult);
            this.request.addEventListener(mx.rpc.events.FaultEvent.FAULT, this.onFault);
            return;
        }

        public function sendRequest():void
        {
			
            var loc1:*=Model.AGORAModel.getInstance().userSessionModel;
            if (loc1.loggedIn()) 
            {
                this.request.send({"uid":loc1.uid, "pass_hash":loc1.passHash});
            }
            return;
        }

        protected function onResult(arg1:mx.rpc.events.ResultEvent):void
        {
            this.projectList = arg1.result as XML;
            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.MY_PROJECTS_LIST_FETCHED));
            return;
        }

        protected function onFault(arg1:mx.rpc.events.FaultEvent):void
        {
            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.FAULT));
            return;
        }

        public var projectList:XML;

        internal var request:mx.rpc.http.HTTPService;
    }
}
