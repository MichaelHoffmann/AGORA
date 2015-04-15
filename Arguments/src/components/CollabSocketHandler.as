package components
{
	import Controller.AGORAController;
	import Controller.LoadController;
	import Controller.UserSessionController;
	
	import Model.AGORAModel;
	import Model.StatementModel;
	import Model.UserSessionModel;
	
	import classes.Language;
	
	import com.adobe.utils.ArrayUtil;
	import com.adobe.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.utils.ArrayUtil;
	
	
	public class CollabSocketHandler extends EventDispatcher
	{
		public var host:String = 'agora.gatech.edu'; // change -- agora.gatech.edu / localhost
		public var mapport:int    = 1766; //for global 1766; for local 1768
		public var times:int =0;			
		protected var socket:Socket;
		protected var collabSocket:Socket;
		private var _mapId:String;
		private var numCollabs:int;
		public var timer:Timer;
		public var nodesUsed:Dictionary;
		public function CollabSocketHandler(){
		//	timer = new Timer(30000);
		//	timer.addEventListener(TimerEvent.TIMER, sendInfoMessage);
			nodesUsed = new Dictionary();
		}
		
		public function get mapId():String
		{
			return _mapId;
		}

		public function set mapId(value:String):void
		{
			_mapId = value;
			numCollabs=0;
		}

		public function MapCollabHandler()
		{
			
		}

		protected function onMapSocketSecurityError(e:SecurityErrorEvent):void {
			if(times==5){
				return;
			}				
			times++;
		}
		
		protected function onMapSocketData(e:ProgressEvent):void {
			// A new message has arrived!
			var message:String = collabSocket.readUTFBytes(collabSocket.bytesAvailable);
			var data:Array = message.split(":");
			if(data.length>0){
				var message = "";
				// Get recent Collab count
				if(data.indexOf("GetC")==0){
					sendInfoMessage();
					return;
				}
				// Get latest data added
				if(data.indexOf("SendCollabs")==0){
				//	Alert.show("got Allert");
					AGORAModel.getInstance().requested = false;
					LoadController.getInstance().fetchMapData();		
					return;
				}
				var posN:int = data.indexOf("nodeInfo");
				var oldNodes:Dictionary = nodesUsed;
				
				if(posN>=0){
					nodesUsed = new  Dictionary();
					for(var i=posN+1,j=posN+2;i<data.length && j<data.length;i++,j++){	
						data+"";
							nodesUsed[data[i]] = data[j];
					}
					setOnlineMarkers(nodesUsed,oldNodes);
				}
				
				var endIn:int = (posN!=-1)?posN:data.length;
				if(posN!=0){
				for(var i=1;i<endIn;i++){
					if(data[i].toString().length>0)
						message+=" "+data[i]+",";
				}
				var ifNum:Boolean = isNaN(Number(data[0]));
				if(ifNum){
					return;
				}
				numCollabs = data[0];
				FlexGlobals.topLevelApplication.rightSidePanel.onlineBox.text = data[0]+" "+Language.lookup("MapCollaborators");
				FlexGlobals.topLevelApplication.rightSidePanel.onlineBox.toolTip = message;
				FlexGlobals.topLevelApplication.rightSidePanel.onlineBoxHtml.text = message;				
				}
				
			}
			
			// update the UI -- Number and Names of Users. 4:1:2:3:4
			//
		}
		
		public function setOnlineMarkers(onlineNodes:Dictionary,oldNodes:Dictionary):void{
				
			for (var key:Object in onlineNodes)
			{
				// set online & tooltip + remove from old list
				if ( oldNodes[key] !=null )
					delete oldNodes[key];
				
				if(FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[key]!=null){
					var apanel:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[key];
					apanel.nodeCollabStatus.visible=true;
					apanel.nodeCollabStatus.toolTip=onlineNodes[key];					
				}
				
			}
			
			
			// remove old ones 
			for (var key:Object in oldNodes)
			{
				if(FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[key]!=null){
					var apanel:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[key];
					apanel.nodeCollabStatus.visible=false;
					apanel.nodeCollabStatus.toolTip="";					
				}					
				delete oldNodes[key];
			}
		}
		public function removeNodesOnline(key:Object):void{
			if(FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[key]!=null){
				var apanel:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[key];
				apanel.nodeCollabStatus.visible=false;
				apanel.nodeCollabStatus.toolTip="";					
			}					
			delete nodesUsed[key];
		}
		public function sendCollabsMessage():void{
			if(collabSocket==null || !collabSocket.connected || numCollabs<=0){
				return;
			}
			sendNodeInfoMessage(0,false,true);
		}
		
		public function sendInfoMessage():void {
			var usm:UserSessionModel= AGORAModel.getInstance().userSessionModel;	
			if(collabSocket==null || !collabSocket.connected){
				// resetting permissions if required ...
				var oldNodes:Dictionary = nodesUsed;
				nodesUsed = new Dictionary();
				setOnlineMarkers(nodesUsed,oldNodes);
				return;
			}
			collabSocket.writeUTFBytes("init:"+mapId+":"+usm.username+"\n");
			collabSocket.flush(); // Windows needs this
			
			
		}		
		
		public function  sendNodeInfoMessage(nodeid:int,completeMode:Boolean=false,collabMode:Boolean=false):void {
			var usm:UserSessionModel= AGORAModel.getInstance().userSessionModel;	
			if(collabSocket==null || !collabSocket.connected)
				return;
			if(collabMode){
				collabSocket.writeUTFBytes("SendCollabs:"+mapId+":"+usm.username+"\n");
			}else{
			if(completeMode)
				collabSocket.writeUTFBytes("initNodeC:"+mapId+":"+usm.username+":"+nodeid+"\n");
			else
				collabSocket.writeUTFBytes("initNode:"+mapId+":"+usm.username+":"+nodeid+"\n");
			}
			collabSocket.flush(); // Windows needs this
		}		
		
		// a function to udpates nodes list.
		// color nodes.
		
		
		protected function onMapSocketConnect(e:Event):void {
			var usm:UserSessionModel= AGORAModel.getInstance().userSessionModel;
			if(collabSocket==null || !collabSocket.connected)
				return;
			
			collabSocket.writeUTFBytes("init:"+mapId+":"+usm.username+"\n");
			collabSocket.flush(); // Windows needs this
			
			//sendNodeInfoMessage(-1);
		}
		
		protected function onSocketMapIOError(e:IOErrorEvent):void {
		}
		
		// every 30 secs send a I am Alive Message
			
		
		
		public function initCollabSocket(reload:Boolean = false):void{			
			
			//if(socket.connected) socket.close();
			if(collabSocket!=null && collabSocket.connected && !reload) return;
			
			// Create new socket connection
			collabSocket = new Socket();
			Security.allowInsecureDomain(true);
			Security.allowDomain("*");
			
			// Event Listeners
			collabSocket.addEventListener(Event.CONNECT, onMapSocketConnect);
			collabSocket.addEventListener(IOErrorEvent.IO_ERROR, onSocketMapIOError);
			collabSocket.addEventListener(ProgressEvent.SOCKET_DATA, onMapSocketData);
			collabSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onMapSocketSecurityError);
			collabSocket.timeout=5000;
			times=1;
			// Connect to socket
			collabSocket.connect(host, mapport);				
		}
		
		public function isNodebeingUsed(node:int):Boolean{
			var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
			
			if(nodesUsed!=null && nodesUsed[node]!=null && nodesUsed[node]){
				if(usm.username.toLocaleLowerCase() != (String)(nodesUsed[node]).toLocaleLowerCase()) {
					Alert.show(Language.lookup("AnotherCollaboratorLockedThisNode") + " Collaborator Name:"+ nodesUsed[node]);
					return true;
				}
			}
			return false;
		}
	}
}