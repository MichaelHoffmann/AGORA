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
	
	
	public class ProjectsSocketsHandler extends EventDispatcher
	{
		public var host:String = 'agora.gatech.edu'; // change -- agora.gatech.edu / localhost
		public var mapport:int    = 1767; //for global 1767; for local same .. 
		public var times:int =0;			
		protected var projectsSocket:Socket;
		private var _nodeId:String;
		
		public function ProjectsSocketsHandler():void{
			initProjectsSocket();
		}
		
		public function get nodeId():String
		{
			return _nodeId;
		}

		public function set nodeId(value:String):void
		{
			_nodeId = value;
		}

		protected function onMapSocketSecurityError(e:SecurityErrorEvent):void {
			if(times==5){
				return;
			}				
			times++;
		}
		
		protected function onMapSocketData(e:ProgressEvent):void {
			// A new message has arrived!
			var message:String = projectsSocket.readUTFBytes(projectsSocket.bytesAvailable);
			var data:Array = message.split(":");
			if(data.length>1){
				var message = "";								
				// Get latest data added
				if(data.indexOf("update")==0){
					var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
					var current=usm.selectedTab;			
					if(current == Language.lookup("MyContributions"))
					{
						//Alert.show("got Allert"+data[1]+" "+usm.selectedMyContProjID);
						if(data[1]!=null && data[1]==usm.selectedMyContProjID){
						Controller.AGORAController.getInstance().fetchDataMyProjects();
						}
					}
					else if(current==Language.lookup("MyPPProjects"))
					{
					//	Alert.show("got Allert"+data[1]+" "+usm.selectedMyProjProjID);
						if(data[1]!=null && data[1]==usm.selectedMyProjProjID){
						Controller.AGORAController.getInstance().fetchDataMyProjects();
						}
					}else if (current ==Language.lookup("MainTab"))
					{
					//	Alert.show("got Allert"+data[1]+" "+usm.selectedWoAProjID);
						if(data[1]!=null && data[1]==usm.selectedWoAProjID){
						Controller.AGORAController.getInstance().fetchDataMyProjects();
						}
					}

				}
			}
		}
		
		public function sendNodeInfoMessage():void {
			var usm:UserSessionModel= AGORAModel.getInstance().userSessionModel;	
			if(projectsSocket==null || !projectsSocket.connected)
				return;
				projectsSocket.writeUTFBytes("udpate:"+nodeId);
			projectsSocket.flush(); // Windows needs this
		}		
		
		
		protected function onMapSocketConnect(e:Event):void {
			var usm:UserSessionModel= AGORAModel.getInstance().userSessionModel;
			if(projectsSocket==null || !projectsSocket.connected)
				return;
			
			projectsSocket.writeUTFBytes("init:");
			projectsSocket.flush(); // Windows needs this
			
		}
		
		protected function onSocketMapIOError(e:IOErrorEvent):void {
		}
		
		
		
		
		public function initProjectsSocket(reload:Boolean = false):void{			
			
			//if(socket.connected) socket.close();
			if(projectsSocket!=null && projectsSocket.connected && !reload) return;
			
			// Create new socket connection
			projectsSocket = new Socket();
			Security.allowInsecureDomain(true);
			Security.allowDomain("*");
			
			// Event Listeners
			projectsSocket.addEventListener(Event.CONNECT, onMapSocketConnect);
			projectsSocket.addEventListener(IOErrorEvent.IO_ERROR, onSocketMapIOError);
			projectsSocket.addEventListener(ProgressEvent.SOCKET_DATA, onMapSocketData);
			projectsSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onMapSocketSecurityError);
			projectsSocket.timeout=5000;
			times=1;
			// Connect to socket
			projectsSocket.connect(host, mapport);				
		}
		
		
	}
}// ActionScript file