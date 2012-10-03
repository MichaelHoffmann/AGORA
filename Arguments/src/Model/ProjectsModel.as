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
		public var projectList:XML;
		public var userList:XML;
		public var mapList:XML;
		public var subProjectList:XML;
		private var requestChildMap: HTTPService;
		private var requestChildProject: HTTPService;
		private var request: HTTPService;
		public var category: XML;
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
			requestChildProject = new HTTPService;
			requestChildProject.url = AGORAParameters.getInstance().projectDetailsURL;
			requestChildProject.resultFormat="e4x";
			requestChildProject.addEventListener(ResultEvent.RESULT, onProjectFetched);
			requestChildProject.addEventListener(FaultEvent.FAULT, onFault);
			dispatchEvent(new AGORAEvent(AGORAEvent.CHILD_MAP_FETCHED));
        }
		
		public function requestProjDetails(projID:String){
			var projDetails = new HTTPService;
			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			projDetails.resultFormat = "e4x";
			projDetails.url = ValueObjects.AGORAParameters.getInstance().projectDetailsURL;
			projDetails.addEventListener(mx.rpc.events.ResultEvent.RESULT, this.updateMyProjUsers);
			projDetails.addEventListener(mx.rpc.events.FaultEvent.FAULT, this.onFault);
			projDetails.send({"uid":usm.uid, "pass_hash":usm.passHash, "projID":projID});

		}
		public function listProjMaps(projID:String){
			var listProjMaps:HTTPService=new mx.rpc.http.HTTPService();
			var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
			listProjMaps.resultFormat = "e4x";
			listProjMaps.url = ValueObjects.AGORAParameters.getInstance().listProjMaps;
			listProjMaps.addEventListener(mx.rpc.events.ResultEvent.RESULT, updateMyProjMaps);
			listProjMaps.addEventListener(mx.rpc.events.FaultEvent.FAULT, this.onFault);
			listProjMaps.send({"uid":usm.uid, "pass_hash":usm.passHash, "category_id":projID});
			
		}
		public function requestChildCategories(projID:String):void{
			mx.controls.Alert.show(projID);
			var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
			if(usm.loggedIn()){
				var requestChildProject:HTTPService=new mx.rpc.http.HTTPService();
				requestChildProject.resultFormat = "e4x";
				requestChildProject.url = ValueObjects.AGORAParameters.getInstance().childCategoryURL;
				requestChildProject.addEventListener(mx.rpc.events.ResultEvent.RESULT, this.updateMyProjSub);
				requestChildProject.addEventListener(mx.rpc.events.FaultEvent.FAULT, this.onFault);
				var params:Object = {uid: usm.uid, pass_hash: usm.passHash ,projID:projID};
				requestChildProject.send(params);
			}
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
		protected function updateMyProjSub(arg1:mx.rpc.events.ResultEvent):void
		{
			this.subProjectList = arg1.result as XML;
			dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.MY_PROJECTS_SUB_DETAILS));
			return;
		}
		protected function updateMyProjMaps(arg1:mx.rpc.events.ResultEvent):void
		{
			this.mapList = arg1.result as XML;
			dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.MY_PROJECTS_MAP_DETAILS));
			return;
		}
		protected function updateMyProjUsers(arg1:mx.rpc.events.ResultEvent):void
		{
			this.userList = arg1.result as XML;
			dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.MY_PROJECTS_USER_DETAILS));
			return;
		}
        protected function onFault(arg1:mx.rpc.events.FaultEvent):void
        {
            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.FAULT));
            return;
        }

    }
}
