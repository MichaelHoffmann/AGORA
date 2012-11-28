package Model 
	{
	    import Events.*;
	    
	    import ValueObjects.*;
	    
	    import flash.events.*;
	    
	    import mx.controls.Alert;
	    import mx.rpc.events.*;
	    import mx.rpc.http.*;
	
	    public class ChainModel extends flash.events.EventDispatcher
		    {
				public var historyXML:XML;
		
		        public function ChainModel()
		        {
						super();
						this.request = new mx.rpc.http.HTTPService();
						this.request.url = ValueObjects.AGORAParameters.getInstance().catChainURL;
						this.request.resultFormat = "e4x";
						this.request.requestTimeout = 3;
						this.request.addEventListener(mx.rpc.events.ResultEvent.RESULT, this.onResult);
						this.request.addEventListener(mx.rpc.events.FaultEvent.FAULT, this.onFault);
						return;
			        }
		
		        public function getChain(theID:int):void
		        {
						var usm:UserSessionModel=Model.AGORAModel.getInstance().userSessionModel;
									var params:* = {"type":"project", "id":theID, "uid":usm.uid, "pass_hash":usm.passHash};
			        	request.send(params);
					}
				public function getChainMap(theID:int):void
				{
						var usm:UserSessionModel=Model.AGORAModel.getInstance().userSessionModel;
						var params:* = {"type":"maps", "id":theID, "uid":usm.uid, "pass_hash":usm.passHash};
						request.send(params);		}
				protected function onResult(arg1:mx.rpc.events.ResultEvent):void
				{		
					if (arg1.result.hasOwnProperty("path")){
						
						historyXML=(arg1.result as XML);
					}else{
						mx.controls.Alert.show("nopath"+historyXML);
					}
						dispatchEvent(new Events.AGORAEvent(Events.AGORAEvent.CHAIN_LOADED));
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