package Model 
{
    import Events.*;
    
    import ValueObjects.*;
    
    import classes.Language;
    import flash.events.*;
    
    import mx.controls.Alert;
    import mx.rpc.events.*;
    import mx.rpc.http.*;
    
    public class EditProject extends flash.events.EventDispatcher
    {
        public function EditProject()
        {
            super();
            request = new mx.rpc.http.HTTPService();
            request.url = ValueObjects.AGORAParameters.getInstance().pushProjectsURL;
            request.resultFormat = "e4x";
            request.requestTimeout = 3;
            request.addEventListener(mx.rpc.events.ResultEvent.RESULT, this.onResult);
            request.addEventListener(mx.rpc.events.FaultEvent.FAULT, this.onFault);
            return;
        }
		public function changeType():void
		{
			var loc2:*=null;
			var loc1:*=Model.AGORAModel.getInstance().userSessionModel;
			if (loc1.loggedIn()) 
			{
				var usm:UserSessionModel=Model.AGORAModel.getInstance().userSessionModel;
				var current=usm.selectedTab;
				if(current == Language.lookup("MyContributions"))
				{
					loc2 = { "projID":loc1.selectedMyContProjID,"uid":loc1.uid, "pass_hash":loc1.passHash,"is_hostile":Model.AGORAModel.getInstance().agoraMapModel.projectType,"changeType":true};
				}else if(current==Language.lookup("MyPPProjects"))
				{
					loc2 = { "projID":loc1.selectedMyProjProjID,"uid":loc1.uid, "pass_hash":loc1.passHash,"is_hostile":Model.AGORAModel.getInstance().agoraMapModel.projectType,"changeType":true};
				}else if (current ==Language.lookup("MainTab"))
				{						
					loc2 = { "projID":loc1.selectedWoAProjID,"uid":loc1.uid, "pass_hash":loc1.passHash,"is_hostile":Model.AGORAModel.getInstance().agoraMapModel.projectType,"changeType":true};
				}
				this.request.send(loc2);
			}
			return;
		}
        public function rename(newName:String):void
        {
            var loc2:*=null;
            var loc1:*=Model.AGORAModel.getInstance().userSessionModel;
            if (loc1.loggedIn()) 
            {
				var usm:UserSessionModel=Model.AGORAModel.getInstance().userSessionModel;
				var current=usm.selectedTab;
				if(current == Language.lookup("MyContributions"))
				{
					loc2 = { "projID":loc1.selectedMyContProjID,"title":newName, "uid":loc1.uid, "pass_hash":loc1.passHash,"is_hostile":Model.AGORAModel.getInstance().agoraMapModel.projectType};					
				}else if(current==Language.lookup("MyPPProjects"))
				{
                loc2 = { "projID":loc1.selectedMyProjProjID,"title":newName, "uid":loc1.uid, "pass_hash":loc1.passHash,"is_hostile":Model.AGORAModel.getInstance().agoraMapModel.projectType};
				}else if (current ==Language.lookup("MainTab"))
				{						
					loc2 = { "projID":loc1.selectedWoAProjID,"title":newName, "uid":loc1.uid, "pass_hash":loc1.passHash,"is_hostile":Model.AGORAModel.getInstance().agoraMapModel.projectType};
				}
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
					Alert.show(arg1.result.proj.error.@text);
                    dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.EDIT_PROJECT_FAILED));
                    return;
                }
            }

			
            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.EDITED_PROJECT));
            return;
        }

        protected function onFault(arg1:mx.rpc.events.FaultEvent):void
        {
            dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.EDIT_PROJECT_FAILED));
            return;
        }

        internal var request:mx.rpc.http.HTTPService;
    }
}
