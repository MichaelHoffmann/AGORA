// ActionScript file

package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class AgoraSearchModel extends EventDispatcher
	{
		public var searchResult:XML;
		public var searchShowResult:XML;
		private var request: HTTPService;
		private var showrequest: HTTPService;
		public var searchParam:String;
		public var level1:int = -1;
		public var level2:int = -1;
		public const maxrows:int =25;
		
		// save configs
		public var type:String;
		public var query:String;
		public var query2:String;
		public var stype:int;
		public var start:int;
		public var b1:String="";
		public var b2:String="";
		public var uvname:String="";
		public var dateC:int=0;
		public var dateM:int=0;
		public var sortBy:int=1;
		public var order:int=1;
		
		
		public function AgoraSearchModel()
		{
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().searchURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onSearchProcessed);
			request.addEventListener(FaultEvent.FAULT, onFault);
			
			showrequest = new HTTPService;
			showrequest.url = AGORAParameters.getInstance().searchShowURL;
			showrequest.resultFormat="e4x";
			showrequest.addEventListener(ResultEvent.RESULT, onSearchShowProcessed);
			showrequest.addEventListener(FaultEvent.FAULT, onFault);
			
		}
		
		private function saveConfig(type:String,query:String,query2:String,stype:int,start:int,b1:String="",b2:String="",uvname:String="",dateC:int=0,dateM:int=0,sortBy:int=1,order:int=1):void{

			this.type = type;
			this.query=query;
			this.query2=query2;
			this.stype=stype;
			this.start=start;
			this.b1=b1;
			this.b2=b2;
			this.uvname=uvname;
			this.dateC=dateC;
			this.dateM=dateM;
			this.sortBy=sortBy;
			this.order=order;
			
		}
		
		public function searchAgora(type:String,query:String,query2:String,stype:int,start:int,b1:String="",b2:String="",uvname:String="",dateC:int=0,dateM:int=0,sortBy:int=1,order:int=1):void{
			
			saveConfig(type,query,query2,stype,start,b1,b2,uvname,dateC,dateM,sortBy,order);
			
			if(start==-1){
				start = (level1-maxrows);
				level2 = level1;
				level1=-1;
			}else if(start == -2){
				start = level2;
				level1=level2;
				level2=-1;
			}else{
				level1=level2=-1;
			}
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				var params:Object = {uid: userSessionModel.uid, pass_hash: userSessionModel.passHash,type:type,query:query,query2:query2,searchType:stype,index:start,b1:b1,b2:b2,uvname:uvname,dateC:dateC,dateM:dateM,sortBy:sortBy,order:order};
				//searchParam = query;
				request.send(params);
			}
		}
		
		public function searchShowAgora(query:String,type:String):void{
			
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				var params:Object = {uid: userSessionModel.uid, pass_hash: userSessionModel.passHash,type:type,query:query};
				showrequest.send(params);
			}
		}
		
		protected function onSearchProcessed(event:ResultEvent):void{
			searchResult = event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.SEARCH_DONE));
		}
		
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		protected function onSearchShowProcessed(event:ResultEvent):void{
			searchShowResult = event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.SEARCHSHOW_DONE));
		}
		
	}
}