package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class ProjectsModel extends EventDispatcher
	{
		public var projectList:XML;
		private var request:HTTPService;
		
		/**
		 * Creates the ProjectsModel(PM) object. Simply instantiates the HTTP Request and configures it to use the appropriate 
		 * configurations. The timeout for the PM is 3 seconds, which prevents the hanging issue experienced with listMaps from
		 * affecting the call to the PHP. 
		 * 
		 * This also adds the event listeners to the request; where it goes is discernable by the resulting function call. The 
		 * methods for both the failure and success are contained within this class. See those comments for more detail.
		 * 
		 * Success: onResult
		 * Failure: onFault 
		 */
		public function ProjectsModel()
		{
			super();
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().myProjectsURL;
			request.resultFormat = "e4x";
			request.requestTimeout = 3;
			request.addEventListener(ResultEvent.RESULT, onResult);
			request.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		/**
		 * Method that officially sends the request to the PHP on the server. Here, we send both the user's ID and
		 * the password hash so that we can tell if they are logged in or not. If they are, dispatch the appropriate
		 * event and if they are not, do nothing.
		 */
		public function sendRequest():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				request.send({uid: userSessionModel.uid, pass_hash: userSessionModel.passHash});	
			}
		}
		
		/**
		 * This is an event driven function that is called when the PHP returns without an error.
		 * It first places the result of the event into the projectList variable and then broadcasts
		 * that that we are now finished and have fetched the data from the projects.
		 */
		protected function onResult(event:ResultEvent):void{
			projectList = event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.MY_PROJECTS_LIST_FETCHED));
		}
		
		/**
		 * If the PHP call resulted in an error, comes to here and broadcasts that we have faulted. 
		 */
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
	}
}