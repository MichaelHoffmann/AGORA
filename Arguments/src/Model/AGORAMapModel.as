package Model
{
	import Controller.AGORAController;
	import Controller.ArgumentController;
	import Controller.LoadController;
	import Controller.UserSessionController;
	import Controller.logic.LogicFetcher;
	import Controller.logic.ParentArg;
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.CategoryDataV0;
	import ValueObjects.ConnectionValueObject;
	import ValueObjects.MapHistoryValueObject;
	import ValueObjects.MapValueObject;
	import ValueObjects.NodeValueObject;
	import ValueObjects.NodetextValueObject;
	import ValueObjects.SourcenodeValueObject;
	import ValueObjects.TextboxValueObject;
	
	import classes.Language;
	
	import com.adobe.protocols.dict.Dict;
	
	import components.AgoraMap;
	import components.ArgumentPanel;
	import components.CategoryChain;
	import components.InfoBox;
	import components.Map;
	import components.RightSidePanel;
	import components.TopPanel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.HistoryManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.states.State;

	public class AGORAMapModel extends EventDispatcher
	{	
		private var _panelListHash:Dictionary;
		private var _connectionListHash:Dictionary;
		private var _textboxListHash:Dictionary;
		private var _newPanels:ArrayCollection;
		private var _newConnections:ArrayCollection;
		private var _historylist:Vector.<MapHistoryValueObject>;
		
		private var createMapService: HTTPService;
		private var saveMapAsService: HTTPService;
		private var mapToPrivateProjService:HTTPService;
		private var createNodeService: HTTPService;
		private var createFirstClaim: HTTPService;
		private var loadMapService: HTTPService;
		private var updatePositionsService:HTTPService;
		private var updateMapInfoService:HTTPService;
		private var permMapServices:HTTPService;		
		
		public var moveToProject:Boolean;
		private var _name:String;
		private var _description:String;
		private var _timestamp:String;
		private var _ID:int;
		private var _statementWidth:int;
		private var _deletedList:Vector.<Object>;
		private var _mapConstructedFromArgument:Boolean;
		private var _argUnderConstruction:Boolean;
		private var _projID:int;
		private var _tempprojID:int;
		private var _tempprojectID:int;
		private var _tempMapID:int;
		private var _projectID:int;
		private var _parentProjID:int;
		private var _projectPassword:String;
		private var _projectName:String;
		private var _projectType:int;
		private var _projectUsers:Array;
		private var _numberUsers:int;
		private var _showChildren:Dictionary;
		private var _globalComments:Dictionary;
		private var _hide:Dictionary;
		private var _panelListHashTemp:Dictionary;
		private var _addClicked:Boolean;
		private var _check:Boolean;
		private var _newPositions:Dictionary;
		private var _max:int;
		private var _maxy:int;
		private var _mapOwner:String;
		private var _createdTime:String;
		public function AGORAMapModel(target:IEventDispatcher=null)
		{	
			super(target);
			deletedList = new Vector.<Object>;
			//create map service
			createMapService = new HTTPService;
			createMapService.url = AGORAParameters.getInstance().insertURL;
			createMapService.addEventListener(ResultEvent.RESULT,  onMapCreated);
			createMapService.addEventListener(FaultEvent.FAULT, onFault);
			
			mapToPrivateProjService = new HTTPService;
			mapToPrivateProjService.url = AGORAParameters.getInstance().mapToPrivateProjURL;
			mapToPrivateProjService.addEventListener(ResultEvent.RESULT,  onMapMovedToPrivProj);
			mapToPrivateProjService.addEventListener(FaultEvent.FAULT, onFault);
			
			//create first claim service
			createFirstClaim = new HTTPService;
			//Below statement is enabled when the xml is required for 
			//debugging
			//createFirstClaim.resultFormat = "e4x";
			createFirstClaim.url = AGORAParameters.getInstance().insertURL;
			createFirstClaim.addEventListener(ResultEvent.RESULT, onAddFirstClaimResult);
			createFirstClaim.addEventListener(FaultEvent.FAULT, onFault);
			
			//create load map service
			loadMapService = new HTTPService();
			loadMapService.url = AGORAParameters.getInstance().loadMapURL;
			//	loadMapService.resultFormat="e4x";
			loadMapService.addEventListener(ResultEvent.RESULT, onLoadMapModelResult);
			loadMapService.addEventListener(FaultEvent.FAULT, onFault);
			//loadMapService.method = "POST";
			
			//create update positions service
			updatePositionsService = new HTTPService();
			updatePositionsService.url = AGORAParameters.getInstance().insertURL;
			updatePositionsService.resultFormat = "e4x";
			updatePositionsService.addEventListener(ResultEvent.RESULT, updatePositionServiceResult);
			updatePositionsService.addEventListener(FaultEvent.FAULT, onFault);
			//updatePositionsService.method = "POST";
			
			//create update map info service
			updateMapInfoService = new HTTPService;
			updateMapInfoService.url = AGORAParameters.getInstance().nameUpdateURL;
			updateMapInfoService.addEventListener(ResultEvent.RESULT, onMapInfoUpdated);
			updateMapInfoService.addEventListener(FaultEvent.FAULT, onFault);
			
			//save map as service
			saveMapAsService = new HTTPService;
			saveMapAsService.url = AGORAParameters.getInstance().saveMapAsUrl;
			saveMapAsService.addEventListener(ResultEvent.RESULT,  onMapSaveAsCreated);
			saveMapAsService.addEventListener(FaultEvent.FAULT, onFault);
			reinitializeModel();
			statementWidth = 8;
			//create permissions checker map info service
			permMapServices = new HTTPService;
			permMapServices.url = AGORAParameters.getInstance().mapPermURL;
			permMapServices.addEventListener(ResultEvent.RESULT, onMapPermInfoRec);
			permMapServices.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		//-------------------------Getters and Setters--------------------------------//
		
		public function get tempMapID():int
		{
			return _tempMapID;
		}
		public function set tempMapID(value:int):void
		{
			_tempMapID = value;
		}
		public function get createdTime():String
		{
			return _createdTime;
		}
		public function set createdTime(value:String):void
		{
			_createdTime = value;
		}
		public function get mapOwner():String
		{
			return _mapOwner;
		}

		public function set mapOwner(value:String):void
		{
			_mapOwner = value;
		}

		public function get maxy():int
		{
			return _maxy;
		}

		public function set maxy(value:int):void
		{
			_maxy = value;
		}

		public function get max():int
		{
			return _max;
		}

		public function set max(value:int):void
		{
			_max = value;
		}

		public function get newPositions():Dictionary
		{
			return _newPositions;
		}
		public function set newPositions(value:Dictionary):void
		{
			_newPositions = value;
		}
		public function get globalComments():Dictionary
		{
			return _globalComments;
		}
		public function set globalComments(value:Dictionary):void
		{
			_globalComments = value;
		}
public function get check():Boolean
		{
			return _check;
		}

		public function set check(value:Boolean):void
		{
			_check = value;
		}

		public function get addClicked():Boolean
		{
			return _addClicked;
		}

		public function set addClicked(value:Boolean):void
		{
			_addClicked = value;
		}
		public function get historylist():Vector.<MapHistoryValueObject>
		{
			return _historylist;
		}
		public function set historylist(value:Vector.<MapHistoryValueObject>):void
		{
			_historylist = value;
		}
		public function get tempprojID():int
		{
			return _tempprojID;
		}
		public function set tempprojID(value:int):void
		{
			_tempprojID = value;
		}
		public function get tempprojectID():int
		{
			return _tempprojectID;
		}
		public function set tempprojectID(value:int):void
		{
			_tempprojectID = value;
		}
		public function get numberUsers():int
		{
			return _numberUsers;
		}

		public function set numberUsers(value:int):void
		{
			_numberUsers = value;
		}

		public function get projectUsers():Array
		{
			return _projectUsers;
		}

		public function set projectUsers(value:Array):void
		{
			_projectUsers = value;
		}

		public function get argUnderConstruction():Boolean
		{
			return _argUnderConstruction;
		}
		
		public function set argUnderConstruction(value:Boolean):void
		{
			_argUnderConstruction = value;
		}
		
		public function get deletedList():Vector.<Object>
		{
			return _deletedList;
		}
		
		public function set deletedList(value:Vector.<Object>):void
		{
			_deletedList = value;
		}
		
		public function get mapConstructedFromArgument():Boolean
		{
			return _mapConstructedFromArgument;
		}
		
		public function set mapConstructedFromArgument(value:Boolean):void
		{
			_mapConstructedFromArgument = value;
		}
		
		public function get textboxListHash():Dictionary
		{
			return _textboxListHash;
		}
		
		public function set textboxListHash(value:Dictionary):void
		{
			_textboxListHash = value;
		}
		
		public function get statementWidth():int
		{
			return _statementWidth;
		}
		
		public function set statementWidth(value:int):void
		{
			_statementWidth = value;
		}
		
		public function get connectionListHash():Dictionary
		{
			return _connectionListHash;
		}
		
		public function set connectionListHash(value:Dictionary):void
		{
			_connectionListHash = value;
		}
		
		public function get newConnections():ArrayCollection
		{
			return _newConnections;
		}
		
		public function set newConnections(value:ArrayCollection):void
		{
			_newConnections = value;
		}
		
		public function get newPanels():ArrayCollection
		{
			return _newPanels;
		}
		
		public function set newPanels(value:ArrayCollection):void
		{
			_newPanels = value;
		}
		
		public function get panelListHash():Dictionary
		{
			return _panelListHash;
		}
		
		public function set panelListHash(value:Dictionary):void
		{
			_panelListHash = value;
		}
		
		public function get ID():int
		{
			return _ID;
		}
		
		public function set ID(value:int):void
		{
			_ID = value;
		}
		
		public function get timestamp():String
		{
			return _timestamp;
		}
		
		public function set timestamp(value:String):void
		{
			_timestamp = value;
		}
		
		public function get description():String
		{
			return _description;
		}
		
		public function set description(value:String):void
		{
			_description = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		
		//---------------------- Update map info ---------------------------------------------//
		public function updateMapInfo(newTitle:String):void{
			var userModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			updateMapInfoService.send({uid: userModel.uid, pass_hash:userModel.passHash, map_id:ID, title:newTitle, desc: "no", lang:AGORAModel.getInstance().language});
		}
		
		protected function onMapInfoUpdated(event:ResultEvent):void{
			if(event.result.mapinfo.hasOwnProperty("error")){
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_INFO_UPDATE_FAILED, null, null));
			}else if(event.result.mapinfo.hasOwnProperty("errorMapName")){
				Alert.show(Language.lookup('MapNameNotUnique'));
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_INFO_UPDATE_FAILED, null, null));
			}else{
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_INFO_UPDATED, null, null));
			}
			
		}
		
		//----------------------- Create a New Map --------------------------------------------//
		public function createMap(mapName:String):void{
			var xmlForMap:XML = <map id="0" title={mapName}></map>;
			var usModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			this._name = mapName;
			createMapService.send({uid:usModel.uid, pass_hash:usModel.passHash, xml:xmlForMap.toXMLString()});
		}
		//----------------------- Save As a New Map --------------------------------------------//
		public function saveAsMap(mapName:String,mapId:String):void{
			var usModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;			
			saveMapAsService.send({uid:usModel.uid, pass_hash:usModel.passHash, map_id:mapId,newName:mapName});
		}
		public function checkPerm(mapId:String):void{
			var userModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			AGORAModel.getInstance().agoraMapModel.tempMapID=new int(mapId);
			permMapServices.send({uid: userModel.uid, mapid:mapId});
		}
		public function onMapPermInfoRec(event:ResultEvent):void{
			if(event.result.map.hasOwnProperty("error")){
				Alert.show(Language.lookup('MapHelpNoAccess'));
			}else{
				var xmlForMap:XML = <map ID={event.result.map.ID} message="true"></map>;
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_SAVEDAS, xmlForMap, event.result.map));
				//	ArgumentController.getInstance().loadMap("9154");
			}			
		}
		protected function onMapSaveAsCreated(resultEvent:ResultEvent):void{
			if(!resultEvent.result.map.hasOwnProperty('error')){
				var xmlForMap:XML = <map ID={resultEvent.result.map.ID}></map>;
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_SAVEDAS, xmlForMap, resultEvent.result.map));
			}else{
				if(resultEvent.result.map.error.code=="319" || resultEvent.result.map.error.code==319){
					dispatchEvent(new AGORAEvent(AGORAEvent.MAP_SAVEDASFAULT, null, null));
				}
			}
		}
		
		protected function onMapCreated(resultEvent:ResultEvent):void{
		if(!resultEvent.result.map.hasOwnProperty('error')){
			var mapMetaData:MapMetaData = new MapMetaData;
			mapMetaData.mapID = resultEvent.result.map.ID;
			mapMetaData.mapName = resultEvent.result.map.title;
			ID = resultEvent.result.map.ID;
				moveMapToPrivProj();
			//	var usModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			//	mapToPrivateProjService.send({user_id:usModel.uid, pass_hash:usModel.passHash, map_id:ID});
			dispatchEvent(new AGORAEvent(AGORAEvent.MAP_CREATED, null, mapMetaData));
			}else{
				if(resultEvent.result.map.error.code=="319" || resultEvent.result.map.error.code==319){
					dispatchEvent(new AGORAEvent(AGORAEvent.MAP_CREATION_FAILED, null, null));
					}
			}
		}
		protected function onMapMovedToPrivProj(resultEvent:ResultEvent):void{
			var usm:UserSessionModel=Model.AGORAModel.getInstance().userSessionModel;
			var current=usm.selectedTab;
				//FlexGlobals.topLevelApplication.agoraMenu.categories.
				var model:CategoryModel = AGORAModel.getInstance().categoryModel;

				if (moveToProject){
					if(current == Language.lookup("MyContributions"))
					{
						Controller.AGORAController.getInstance().moveMap(this.ID,usm.selectedMyContProjID as String);
						
					}else if(current==Language.lookup("MyPPProjects"))
					{
						Controller.AGORAController.getInstance().moveMap(this.ID,usm.selectedMyProjProjID as String);
						
					}else if (current ==Language.lookup("MainTab"))
					{						
							Controller.AGORAController.getInstance().moveMap(this.ID,usm.selectedWoAProjID.toString());
					}
					// category sockets
					FlexGlobals.topLevelApplication.rightSidePanel.chat.projectsSockHandler.sendNodeInfoMessage();
				}
				moveToProject=false;

		}
		protected function moveMapToPrivProj():void{
			var usModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			mapToPrivateProjService.send({user_id:usModel.uid, pass_hash:usModel.passHash, map_id:ID});
		}
		
		//-----------------------Add First Claim---------------------------------------------//
		public function addFirstClaim():void{
			var mapXML:XML=<map id={ID}>
								<textbox TID="10" text=""/>
								<node TID="1" Type={StatementModel.PARTICULAR} typed="0" is_positive="1"  x="2" y="3">
									<nodetext TID="2" textboxTID="10" />
								</node>
						   </map>;	
			createFirstClaim.send({uid:AGORAModel.getInstance().userSessionModel.uid, pass_hash: AGORAModel.getInstance().userSessionModel.passHash, xml:mapXML});
		}
		
		protected function onAddFirstClaimResult(event:ResultEvent):void{
			if(!event.result.map.hasOwnProperty('error')){
				//create statement model
				var map:MapValueObject = new MapValueObject(event.result.map, true);
				var statementModel:StatementModel = StatementModel.createStatementFromObject(map.nodeObjects[0]);
				
				//-------textboxes & nodetext----------//
				var simpleStatement:SimpleStatementModel = null;
				simpleStatement = SimpleStatementModel.createSimpleStatementFromObject(map.textboxes[0], statementModel);
				//When first statement is created, there will not be any text
				simpleStatement.hasOwn = true;
				simpleStatement.forwardList.push(statementModel.statement);
				statementModel.statements.push(simpleStatement);
				statementModel.nodeTextIDs.push(map.nodeObjects[0].nodetexts[0].ID);
				
				textboxListHash[simpleStatement.ID] = simpleStatement;
				
				//push it to the model
				panelListHash[statementModel.ID] = statementModel;
				newPanels.addItem(statementModel);
				
				//raise event
				dispatchEvent(new AGORAEvent(AGORAEvent.FIRST_CLAIM_ADDED, null, statementModel));
			}else{
				dispatchEvent(new AGORAEvent(AGORAEvent.FIRST_CLAIM_FAILED, null, null));
			}
		}
		
		//----------------------- Notify new statement model -----------------------------//
		public function newStatementAdded(statementModel:StatementModel):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.STATEMENT_ADDED, null, statementModel));
		}
		
		public function newArgumentTypeModelAdded(argumentTypeModel:ArgumentTypeModel):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.ARGUMENT_TYPE_ADDED, null, argumentTypeModel));
		}
		
		//----------------------- Load New Data ----------------------------------------------//
		public function loadMapModel():void{
			var userInfo:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			loadMapService.send({map_id:ID.toString(),timestamp:timestamp, uid:userInfo.uid, pass_hash:userInfo.passHash });		
		}
		
		protected function onLoadMapModelResult(event:ResultEvent):void{
		//	deletedList = new Vector.<Object>;
			var mapXMLRawObject:Object = event.result.map; 				
			try{
				var map:MapValueObject = new MapValueObject(mapXMLRawObject);
			}catch(propNotFoundError:Error){
				trace("Fatal Error: XML is malformed");
				trace(String(propNotFoundError.message));
				dispatchEvent(new AGORAEvent(AGORAEvent.ILLEGAL_MAP, null, null)); 
			}
			try{
				
				//update timestamp
				timestamp = map.timestamp;
				createdTime = map.createdTime;
				name = map.title;
				mapOwner=map.username;
				var rsp:RightSidePanel = FlexGlobals.topLevelApplication.rightSidePanel;
				// Reload panel only when required
				var reloadpanel = event.result.map.reloadRPANEL;
				if( event.result.map.hasOwnProperty("reloadRPANEL") && event.result.map.reloadRPANEL=="0"){
				rsp.showHistoryBoxes=true;
				}
				rsp.mapTitle.text=mapXMLRawObject.title;
				var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
				rsp.clickableMapOwnerInformation.label = mapXMLRawObject.username;
				if(mapXMLRawObject.username== usm.username){
					rsp.mapTitle.enabled=true;
				}else{
					rsp.mapTitle.enabled=false;
				}
				AGORAController.getInstance().getMapChain(map.ID);
				rsp.IdofMap.text = Language.lookup("IdOfTheMapDisplay") + " " + mapXMLRawObject.ID;
				
				rsp.clickableMapOwnerInformation.toolTip = 
					mapXMLRawObject.username + "\n" + mapXMLRawObject.url + '\n' + Language.lookup('MapOwnerURLWarning');
				rsp.clickableMapOwnerInformation.addEventListener(MouseEvent.CLICK, function event(e:Event):void{
					var urllink:String = mapXMLRawObject.url;
					if(urllink!=null && urllink.indexOf("http://") ==-1)
						urllink = "http://"+urllink;			
					navigateToURL(new URLRequest(urllink), 'quote');
				},false, 0, false);
				try{
				rsp.invalidateDisplayList();
				}catch(e:Error){
					Alert.show("error");
				}
				mapXMLRawObject.url;
				if(map.hasOwnProperty("is_hostile")){
				if(map.is_hostile == 1)
				AGORAModel.getInstance().projType = "adversarial";
				else if (map.is_hostile == 0)
					AGORAModel.getInstance().projType = "collaborative";
				}else{
					AGORAModel.getInstance().projType = "adversarial";
				}
				if(!ArgumentController.getInstance().checkPermissionsForMap()){
				FlexGlobals.topLevelApplication.map.topPanel._publishMapHelp.visible=false;
				}else{
					FlexGlobals.topLevelApplication.map.topPanel._publishMapHelp.visible=true;
				}
					
				//Form a map of nodes
				var obj:Object;
				var nodeHash:Dictionary = new Dictionary;
				var textboxHash:Dictionary = new Dictionary;
				
				// try this
				max=maxy=0;
				//read nodes and create Statment Models
				processNode(map.nodeObjects,nodeHash, textboxHash);
				
				//Form a map of connections
				var connectionsHash:Dictionary = new Dictionary;
				
				//parseConnection(map, connectionsHash, nodeHash);
				processConnection(map.connections, connectionsHash, nodeHash);
				
				//read and set text - This should be performed after links are created
				processTextbox(map.textboxes, textboxHash);
				
				trace(max*AGORAParameters.getInstance().gridWidth+" HJHKJHKJ");
				trace(maxy*AGORAParameters.getInstance().gridWidth+" HJHKJHKJ");
			}
			catch(error:Error){
				
				trace(error.message);
				trace("Error in reading update to Map");
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADING_FAILED));
			}
			for each(var ob:NodeValueObject in map.nodeObjects)
			{
				if(ob.type == StatementModel.DEFINITION || ob.type == StatementModel.REFERENCE || ob.type == StatementModel.AMENDMENT || ob.type == StatementModel.COMMENT ||  ob.type == StatementModel.QUESTION || ob.type == StatementModel.SUPPORT || ob.type == StatementModel.LINKTOMAP || ob.type == StatementModel.LINKTORESOURCES || ob.type == StatementModel.REFORMULATION)
				{
					newPositions[ob.ID] = ob; 
				}
			}
			for each(var obj1:StatementModel in showChildren)
			{
				obj1.xgrid = newPositions[obj1.ID].x;
				obj1.ygrid = newPositions[obj1.ID].y;
				newPanels.addItem(obj1);
				panelListHash[obj1.ID] = obj1;
				//panelListHash[obj1.ID].x = newPositions[obj1].x;
				var arg:ArgumentPanel = new ArgumentPanel;
				arg.model = obj1;
				globalComments[arg.model.ID] = arg;
				delete showChildren[obj1.ID];
				check = true;
			}
			
			//add new elements to Model
			for each(var node:StatementModel in nodeHash){
				if(!panelListHash.hasOwnProperty(node.ID)){
					if(node.statementFunction != "Comment" && node.statementFunction!= "Amendment" && node.statementFunction!="Reference" && node.statementFunction!= "Question" && node.statementFunction!= "Definition" && node.statementFunction!= "Reformulation" && node.statementFunction!= "Support" && node.statementFunction!= "LinkToMap" && node.statementFunction!= "LinkToResource" ){
					newPanels.addItem(node);
					check = true;
					panelListHash[node.ID] = node;				
				}
					else if (addClicked == 1)
					{
						newPanels.addItem(node);
						check = true;
						panelListHash[node.ID] = node;
						var arg:ArgumentPanel = new ArgumentPanel;
						arg.model = node;
						globalComments[arg.model.ID] = arg;
						
					}
				}
			}
			
			for each(var connection:ArgumentTypeModel in connectionsHash){	
				if(!connectionListHash.hasOwnProperty(connection.ID)){
					newConnections.addItem(connection);
					connectionListHash[connection.ID] = connection;
				}
			}
			
			for each(var textbox:SimpleStatementModel in textboxHash){
				textboxListHash[textbox.ID] = textbox;
			}
			
			//update enablers after deletsion
			for each(var deletedObject:Object in deletedList){
				if(deletedObject is StatementModel){
					var textLabel1:Dictionary = FlexGlobals.topLevelApplication.map.agoraMap.textLabel;
					if(FlexGlobals.topLevelApplication.map.agoraMap.textLabel[deletedObject.ID])
					{
					FlexGlobals.topLevelApplication.map.agoraMap.textLabel[deletedObject.ID].visible = false;
					delete FlexGlobals.topLevelApplication.map.agoraMap.textLabel[deletedObject.ID];
					}
					var stmtM:StatementModel = deletedObject as StatementModel;
					if(stmtM.statementFunction == StatementModel.STATEMENT){
						var aTM:ArgumentTypeModel = stmtM.argumentTypeModel;
						
						if(aTM.reasonModels.length > 0){
							var logicController:ParentArg = LogicFetcher.getInstance().logicHash[aTM.logicClass];
							logicController.formText(aTM);
						}
					}
					
				}
			}
			// update the map history details .. ..
			historylist = map.historylist;
			dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADED));
		}
		
		//---------------------- Process Node ---------------------------------------------------------//
		protected function processNode(obj:Vector.<NodeValueObject>, nodeHash:Dictionary, textboxHash:Dictionary):Boolean{
			var statementModel:StatementModel;
			for each(var nodeVO:NodeValueObject in obj){
				if(!nodeVO.deleted){
					//Set attributes
					if(!panelListHash.hasOwnProperty(nodeVO.ID)){
						statementModel = StatementModel.createStatementFromObject(nodeVO);
					}else{
						statementModel = panelListHash[nodeVO.ID];
					}
					
					if(nodeVO.type == StatementModel.INFERENCE){
						statementModel.statementFunction = StatementModel.INFERENCE;
					}
					else if(nodeVO.type == StatementModel.OBJECTION){
						statementModel.statementFunction = StatementModel.OBJECTION;
					}
					else if(nodeVO.type == StatementModel.COUNTER_EXAMPLE){
						statementModel.statementFunction = StatementModel.COUNTER_EXAMPLE;
					}
					else if(nodeVO.type == StatementModel.COMMENT){
						statementModel.statementFunction = StatementModel.COMMENT;
					}
					else if(nodeVO.type == StatementModel.AMENDMENT){
						statementModel.statementFunction = StatementModel.AMENDMENT;
					}
					else if(nodeVO.type == StatementModel.REFERENCE){
						statementModel.statementFunction = StatementModel.REFERENCE;
					}
					else if(nodeVO.type == StatementModel.DEFINITION){
						statementModel.statementFunction = StatementModel.DEFINITION;
					}
					else if(nodeVO.type == StatementModel.QUESTION){
						statementModel.statementFunction = StatementModel.QUESTION;
					}
					else if(nodeVO.type == StatementModel.LINKTOMAP){
						statementModel.statementFunction = StatementModel.LINKTOMAP;
					}
					else if(nodeVO.type == StatementModel.LINKTORESOURCES){
						statementModel.statementFunction = StatementModel.LINKTORESOURCES;
					}
					else if(nodeVO.type == StatementModel.REFERENCE){
						statementModel.statementFunction = StatementModel.REFERENCE;
					}
					else if(nodeVO.type == StatementModel.SUPPORT){
						statementModel.statementFunction = StatementModel.SUPPORT;
					}
					else if(nodeVO.type == StatementModel.REFORMULATION){
						statementModel.statementFunction = StatementModel.REFORMULATION;
					}
					else
					{
						statementModel.statementFunction = StatementModel.STATEMENT;	
					}
					
					statementModel.author = nodeVO.author;
					statementModel.firstName = nodeVO.firstName;
					statementModel.lastName = nodeVO.lastName;
					statementModel.URL = nodeVO.URL;
					statementModel.prevauthor = nodeVO.prevauthor;
					statementModel.prevauthorurl = nodeVO.prevauthorurl;
					if(statementModel.statementFunction == StatementModel.STATEMENT){
						statementModel.statementType = nodeVO.type;
					}
					statementModel.xgrid = nodeVO.x;
					statementModel.ygrid = nodeVO.y;
					nodeHash[nodeVO.ID] = statementModel;
					processNodeText(nodeVO, nodeHash, textboxHash);
					max=max<(nodeVO.x+8)?(nodeVO.x+8):max;
					maxy=maxy<(nodeVO.y+8)?(nodeVO.y+8):maxy;
				}
				else{
					if(panelListHash.hasOwnProperty(nodeVO.ID)){
						var statementM:StatementModel = panelListHash[nodeVO.ID];
						if(statementM.statementFunction == StatementModel.STATEMENT){
							if(!statementM.firstClaim){
								var index:int = statementM.argumentTypeModel.reasonModels.indexOf(statementM);
								statementM.argumentTypeModel.reasonModels.splice(index, 1);
							}
						}
						else if(statementM.statementFunction == StatementModel.OBJECTION || statementM.statementFunction == StatementModel.COUNTER_EXAMPLE){
							var i:int = statementM.parentStatement.objections.indexOf(statementM);
							statementM.parentStatement.objections.splice(i, 1);
						}
						else if(statementM.statementFunction == StatementModel.COMMENT || statementM.statementFunction == StatementModel.AMENDMENT || statementM.statementFunction == StatementModel.QUESTION || statementM.statementFunction == StatementModel.REFERENCE || statementM.statementFunction == StatementModel.DEFINITION || statementM.statementFunction == StatementModel.REFORMULATION || statementM.statementFunction == StatementModel.LINKTOMAP || statementM.statementFunction == StatementModel.LINKTORESOURCES || statementM.statementFunction == StatementModel.SUPPORT){
							var i:int = statementM.parentStatement.comments.indexOf(statementM);
							statementM.parentStatement.comments.splice(i, 1);
						}
						deletedList.push(statementM);
						delete panelListHash[nodeVO.ID];
					}
				}
			}
			return true;
		}
		
		protected function processNodeText(nodeVO:NodeValueObject, nodeHash:Dictionary, textboxHash:Dictionary):Boolean{
			var statementModel:StatementModel = nodeHash[nodeVO.ID];
			var simpleStatement:SimpleStatementModel;
			for each(var nodetextVO:NodetextValueObject in nodeVO.nodetexts){
				if(!statementModel.hasStatement(nodetextVO.textboxID)){
					simpleStatement = new SimpleStatementModel;
					simpleStatement.ID = nodetextVO.textboxID;
					//should not push statement into statements[i], if 
					// the statement's parent is an Inference rule.
					//This is because in the formtext function,
					//both the statement and statements[i] are 
					//modified simultaneously.
					simpleStatement.parent = statementModel;
					if(statementModel.statementFunction != StatementModel.INFERENCE){
						simpleStatement.addDependentStatement(statementModel.statement);
					}
					statementModel.statements.push(simpleStatement);
					statementModel.nodeTextIDs.push(nodetextVO.ID);
					textboxHash[simpleStatement.ID] = simpleStatement;
				}	
			}
			return true;
		}
		
		protected function processConnection(objs:Vector.<ConnectionValueObject>, connectionsHash:Dictionary, nodeHash:Dictionary):Boolean{
			var argumentTypeModel:ArgumentTypeModel;
			var result:Boolean;
			
			for each(var obj:ConnectionValueObject in objs){
				if(!obj.deleted){
					if(obj.type != StatementModel.OBJECTION && obj.type != StatementModel.COUNTER_EXAMPLE  && obj.type != StatementModel.COMMENT && obj.type != StatementModel.REFERENCE && obj.type != StatementModel.AMENDMENT && obj.type != StatementModel.DEFINITION && obj.type != StatementModel.QUESTION && obj.type != StatementModel.SUPPORT && obj.type != StatementModel.LINKTOMAP && obj.type != StatementModel.LINKTORESOURCES && obj.type != StatementModel.REFORMULATION){
						
						
						if(!connectionListHash.hasOwnProperty(obj.connID)){
							argumentTypeModel = ArgumentTypeModel.createArgumentTypeFromObject(obj);
						}else{
							argumentTypeModel = connectionListHash[obj.connID];
						}
						
						
						argumentTypeModel.dbType = obj.type;					
						
						
						if(nodeHash.hasOwnProperty(obj.targetnode)){
							argumentTypeModel.claimModel = nodeHash[obj.targetnode];
						}
						else{
							argumentTypeModel.claimModel = panelListHash[obj.targetnode];
						}
						
						if(!argumentTypeModel.claimModel.hasArgument(argumentTypeModel)){
							argumentTypeModel.claimModel.addToSupportingArguments(argumentTypeModel);
						}
						
						argumentTypeModel.xgrid = obj.x;
						argumentTypeModel.ygrid = obj.y;
						
						connectionsHash[obj.connID] = argumentTypeModel;
						processSourceNode(obj, connectionsHash, nodeHash);
						dispatchEvent(new AGORAEvent(AGORAEvent.ARGUMENT_SCHEME_SET, null, argumentTypeModel)); //takes care of linking	
						
						
						}else if(obj.type == StatementModel.OBJECTION || obj.type == StatementModel.COUNTER_EXAMPLE || obj.type == StatementModel.COMMENT || obj.type == StatementModel.REFERENCE || obj.type == StatementModel.AMENDMENT || obj.type == StatementModel.DEFINITION || obj.type == StatementModel.QUESTION || obj.type == StatementModel.SUPPORT || obj.type == StatementModel.LINKTOMAP || obj.type == StatementModel.LINKTORESOURCES || obj.type == StatementModel.REFORMULATION){
						processSourceNode(obj, connectionsHash, nodeHash);
						//linking could be done directly
					}
					
				}
				else{
					if(connectionListHash.hasOwnProperty(obj.connID)){
						var argumentTypeM:ArgumentTypeModel = connectionListHash[obj.connID];
						var claimModel:StatementModel = argumentTypeM.claimModel;
						var index:int = claimModel.supportingArguments.indexOf(argumentTypeM);
						//delete it from claim's list of supporting arguments
						claimModel.supportingArguments.splice(index, 1);
						//add it to deleted list, so that corresponding view components can 
						//be removed from the map view.
						deletedList.push(argumentTypeM);
						//delete it from the hash map of present connections
						delete connectionListHash[obj.connID];
					}
				}
				
			}
			return true;
		}
		
		protected function processSourceNode(obj:ConnectionValueObject, connectionsHash:Dictionary, nodeHash:Dictionary):Boolean{
			if(obj.type != StatementModel.OBJECTION && obj.type != StatementModel.COUNTER_EXAMPLE && obj.type != StatementModel.COMMENT && obj.type != StatementModel.REFERENCE && obj.type != StatementModel.AMENDMENT && obj.type != StatementModel.QUESTION && obj.type != StatementModel.DEFINITION && obj.type != StatementModel.SUPPORT && obj.type != StatementModel.LINKTOMAP && obj.type != StatementModel.LINKTORESOURCES && obj.type != StatementModel.REFORMULATION){
				var argumentTypeModel:ArgumentTypeModel = connectionsHash[obj.connID];
				for each(var argElements:SourcenodeValueObject in obj.sourcenodes){
					if(!argElements.deleted){
						//node read in the current update
						if(nodeHash.hasOwnProperty(argElements.nodeID)){
							if(StatementModel(nodeHash[argElements.nodeID]).statementFunction == StatementModel.INFERENCE){
								argumentTypeModel.inferenceModel = nodeHash[argElements.nodeID];
								StatementModel(nodeHash[argElements.nodeID]).argumentTypeModel = argumentTypeModel;
							}
							else{
								if(!argumentTypeModel.hasReason(argElements.nodeID)){
									argumentTypeModel.reasonModels.push(nodeHash[argElements.nodeID]);
									StatementModel(nodeHash[argElements.nodeID]).argumentTypeModel = argumentTypeModel;
								}
							}
						}
						else{ //read earlier and hence in the global hash
							if(StatementModel(panelListHash[argElements.nodeID]).statementFunction == StatementModel.INFERENCE){
								argumentTypeModel.inferenceModel = panelListHash[argElements.nodeID];
								StatementModel(panelListHash[argElements.nodeID]).argumentTypeModel = argumentTypeModel;
							}
							else{
								if(!argumentTypeModel.hasReason(argElements.nodeID)){
									argumentTypeModel.reasonModels.push(panelListHash[argElements.nodeID]);
									StatementModel(	panelListHash[argElements.nodeID]).argumentTypeModel = argumentTypeModel;
								}
							}
						}
					}
				}
			}
			else if(obj.type == StatementModel.OBJECTION || obj.type == StatementModel.COUNTER_EXAMPLE){
				if(obj.sourcenodes.length != 1){
					trace("objection has more than one sourcenode");
				}
				var objection:StatementModel;
				for each(var sourcenode:SourcenodeValueObject in obj.sourcenodes){
					if(!sourcenode.deleted){
						if(nodeHash.hasOwnProperty(sourcenode.nodeID)){
							objection = nodeHash[sourcenode.nodeID];
						}
						else{ //read earlier
							objection = panelListHash[sourcenode.nodeID];	
						}
					}
				}
				var parentStatement:StatementModel;
				if(nodeHash.hasOwnProperty(obj.targetnode)){
					parentStatement = nodeHash[obj.targetnode];
				}
				else{
					parentStatement = panelListHash[ obj.targetnode];
				}
				parentStatement.addObjectionStatement(objection);
				objection.parentStatement = parentStatement;
			}
			else if(obj.type == StatementModel.COMMENT || obj.type == StatementModel.AMENDMENT || obj.type == StatementModel.REFERENCE || obj.type == StatementModel.DEFINITION || obj.type == StatementModel.QUESTION ||  obj.type == StatementModel.SUPPORT || obj.type == StatementModel.LINKTOMAP || obj.type == StatementModel.LINKTORESOURCES || obj.type == StatementModel.REFORMULATION){
				if(obj.sourcenodes.length != 1){
					trace("objection has more than one sourcenode");
				}
				var objection:StatementModel;
				for each(var sourcenode:SourcenodeValueObject in obj.sourcenodes){
					if(!sourcenode.deleted){
						if(nodeHash.hasOwnProperty(sourcenode.nodeID)){
							objection = nodeHash[sourcenode.nodeID];
						}
						else{ //read earlier
							objection = panelListHash[sourcenode.nodeID];	
						}
					}
				}
				var parentStatement:StatementModel;
				if(nodeHash.hasOwnProperty(obj.targetnode)){
					parentStatement = nodeHash[obj.targetnode];
				}
				else{
					parentStatement = panelListHash[ obj.targetnode];
				}
				parentStatement.addCommentStatement(objection);
				objection.parentStatement = parentStatement;
			}
			return true;
		}
		
		protected function processTextbox(textboxes:Vector.<TextboxValueObject>, textboxHash:Dictionary):Boolean{
			var simpleStatement:SimpleStatementModel;
			for each(var obj:TextboxValueObject in textboxes){
				if(!obj.deleted){
					//fetch simpleStatementModel from Dictionary
					if(textboxHash.hasOwnProperty(obj.ID)){
						simpleStatement = textboxHash[obj.ID];
						if(obj.text == SimpleStatementModel.DEPENDENT_TEXT){
							simpleStatement.hasOwn = false;
						}
						else{
							simpleStatement.hasOwn = true;
						}
					}	
					else{
						simpleStatement = textboxListHash[obj.ID];
					}
					if(simpleStatement){
						if(simpleStatement.hasOwn){
							// handling for collab setter fix
							// collab sockets
							if(simpleStatement.text == obj.text){
								simpleStatement.text = obj.text+" ";								
							}
							// just to make the setter code resetted
							simpleStatement.text = obj.text;
						}			
					}
					else{
						trace(obj.ID + ' is not deleted and not associated with any node');
					}
				}
				else{
					if(textboxListHash.hasOwnProperty(obj.ID)){
						delete textboxListHash[obj.ID];
					}
				}
			}
			return true;
		}
		public function moveYellowStatement(model:Object, diffx:int, diffy:int):void{
			var requestXML:XML = <map ID={ID} />;
			if(model is StatementModel){
				var sm:StatementModel = StatementModel(model);
				var argumentTypeModel:ArgumentTypeModel = sm.argumentTypeModel;
				if(sm.statementFunction==StatementModel.COMMENT || sm.statementFunction == StatementModel.AMENDMENT || sm.statementFunction == StatementModel.REFERENCE || sm.statementFunction == StatementModel.QUESTION || sm.statementFunction == StatementModel.SUPPORT || sm.statementFunction == StatementModel.LINKTOMAP || sm.statementFunction == StatementModel.LINKTORESOURCES || sm.statementFunction == StatementModel.REFORMULATION || sm.statementFunction == StatementModel.DEFINITION){
					//check if this is the first objection
					var parentStatement:StatementModel = sm.parentStatement;
					if(parentStatement != null){
						if(parentStatement.comments.length > 0){
							var desty:int = sm.ygrid + diffy;
							for each(var siblingObjection:StatementModel in parentStatement.comments){
								if(siblingObjection == sm){
									requestXML = moveSupportingStatements(siblingObjection, diffx, desty - siblingObjection.ygrid, requestXML);	
								}
							}
						}
					}
				}
				else{
					dispatchEvent(new AGORAEvent(AGORAEvent.ILLEGAL_MAP));
					return;
				}
			}
			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			updatePositionsService.send({uid: usm.uid, pass_hash: usm.passHash, xml:requestXML});
		}
		
		//----------------------- Updating position -----------------------------------------// 
		public function moveStatement(model:Object, diffx:int, diffy:int):void{
			var requestXML:XML = <map ID={ID} />;
			if(model is ArgumentTypeModel){
				var atm:ArgumentTypeModel = ArgumentTypeModel(model);
				var claimModel:StatementModel = atm.claimModel;
				if( atm == claimModel.supportingArguments[0] ){
					if(claimModel.xgrid == atm.xgrid){
						requestXML = moveSupportingStatements(atm, 0, diffy, requestXML);
					}
					else{
						requestXML = moveSupportingStatements(atm, diffx, diffy, requestXML);
					}
				}else{
					requestXML = moveSupportingStatements(atm, diffx, diffy, requestXML);
				}
			}else if(model is StatementModel){
				var sm:StatementModel = StatementModel(model);
				var argumentTypeModel:ArgumentTypeModel = sm.argumentTypeModel;
				if(sm.statementFunction == StatementModel.STATEMENT){
					if(argumentTypeModel != null){
						var newY:int = sm.ygrid + diffy;
						for each(var reason:StatementModel in argumentTypeModel.reasonModels){
							if(reason == sm ){
								if(reason != argumentTypeModel.reasonModels[0])
								{
									requestXML = moveSupportingStatements(reason, diffx, newY - reason.ygrid, requestXML);	
								}else{
									if(reason.xgrid == argumentTypeModel.xgrid){
										requestXML = moveSupportingStatements(reason, 0, newY - reason.ygrid, requestXML);
									}else{
										requestXML = moveSupportingStatements(reason, diffx, newY - reason.ygrid, requestXML);
									}
								}
							}else{
								requestXML = moveSupportingStatements(reason, 0, newY - reason.ygrid, requestXML); 
							}
						}
					}else{
						requestXML = moveSupportingStatements(sm, diffx, diffy, requestXML);
					}
				}
				else if(sm.statementFunction == StatementModel.INFERENCE){
					requestXML = moveSupportingStatements(sm, diffx, 0, requestXML);
				}
				else if(sm.statementFunction==StatementModel.OBJECTION || sm.statementFunction == StatementModel.COUNTER_EXAMPLE){
					//check if this is the first objection
					var parentStatement:StatementModel = sm.parentStatement;
					if(parentStatement != null){
						if(parentStatement.objections.length > 0){
							var desty:int = sm.ygrid + diffy;
							for each(var siblingObjection:StatementModel in parentStatement.objections){
								if(siblingObjection == sm){
									requestXML = moveSupportingStatements(siblingObjection, diffx, desty - siblingObjection.ygrid, requestXML);	
								}else{
									requestXML = moveSupportingStatements(siblingObjection, 0 , desty - siblingObjection.ygrid, requestXML);
								}
							}
						}
					}
				}
					else if(sm.statementFunction==StatementModel.COMMENT || sm.statementFunction == StatementModel.AMENDMENT || sm.statementFunction == StatementModel.REFERENCE || sm.statementFunction == StatementModel.QUESTION || sm.statementFunction == StatementModel.SUPPORT || sm.statementFunction == StatementModel.LINKTOMAP || sm.statementFunction == StatementModel.LINKTORESOURCES || sm.statementFunction == StatementModel.REFORMULATION || sm.statementFunction == StatementModel.DEFINITION){
					//check if this is the first objection
					var parentStatement:StatementModel = sm.parentStatement;
					if(parentStatement != null){
						if(parentStatement.comments.length > 0){
							var desty:int = sm.ygrid + diffy;
							for each(var siblingObjection:StatementModel in parentStatement.comments){
								if(siblingObjection == sm){
									requestXML = moveSupportingStatements(siblingObjection, diffx, desty - siblingObjection.ygrid, requestXML);	
								}else{
									requestXML = moveSupportingStatements(siblingObjection, 0 , desty - siblingObjection.ygrid, requestXML);
								}
							}
						}
					}
				}
					else{
						dispatchEvent(new AGORAEvent(AGORAEvent.ILLEGAL_MAP));
						return;
					}
				
			}
			
			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			updatePositionsService.send({uid: usm.uid, pass_hash: usm.passHash, xml:requestXML});
		}
		
		protected function updatePositionServiceResult(event:ResultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.POSITIONS_UPDATED, null, null));
		}
		
		/**
		 * After some intense inspection, this function may be the source of all the hangs. It is O(n^2) in the best case
		 * but it definitely grows within the while loop
		 */
		
		protected function moveSupportingStatements(model:Object, diffx:int, diffy:int, requestXML:XML):XML{
			var list:Vector.<Object> = new Vector.<Object>;
			list.push(model);
			var atm:ArgumentTypeModel;
			var reason:StatementModel;
			var inferenceModel:StatementModel;
			var statementModel:StatementModel;
			
			var xml:XML;
			//forming xml for requesting update in positions
			//argument map considered as a tree, and a 
			//depth first traversal is done
			while(list.length > 0){
				var object:Object = list.pop();
				if(object is ArgumentTypeModel){
					atm = ArgumentTypeModel(object);
					xml = atm.getXML();
					xml.@x = int(xml.@x) + diffx;
					xml.@y = int(xml.@y) + diffy;
					requestXML.appendChild(xml);
					list.push(atm.inferenceModel);
					for each(reason in atm.reasonModels){
						list.push(reason);
					}
				}else if(object is StatementModel){
					statementModel = StatementModel(object);
					xml = statementModel.getXML();
					for(var i:int=0; i<statementModel.nodeTextIDs.length; i++){
						xml.appendChild(<nodetext ID={statementModel.nodeTextIDs[i]} textboxID={statementModel.statements[i].ID} />);
						trace(xml);
					}
					
					if(statementModel.statementFunction == StatementModel.INFERENCE){
						var argTM:ArgumentTypeModel = statementModel.argumentTypeModel;
						xml.@y = argTM.ygrid + diffy;
					}
					else{
						xml.@y = int(xml.@y) + diffy;
						trace("hello");
					}
					xml.@x = int(xml.@x) + diffx;
					requestXML.appendChild(xml);
					for each(atm in statementModel.supportingArguments){
						list.push(atm);
					}
					for each(var obj:StatementModel in statementModel.objections){
						list.push(obj);
					}
					for each(var comm:StatementModel in statementModel.comments){
						list.push(comm);
					}
				}
			}
			return requestXML;
		}
		
		//----------------------- Reinitializing the model ----------------------------------//
		public function reinitializeModel():void{
			panelListHash = new Dictionary;
			panelListHashTemp = new Dictionary;
			showChildren =  new Dictionary;
			globalComments =  new Dictionary;
			newPositions = new Dictionary;
			addClicked = 0;
			check = false;
			hide = new Dictionary;
			connectionListHash = new Dictionary;
			textboxListHash = new Dictionary;
			newPanels = new ArrayCollection;
			newConnections = new ArrayCollection;
			timestamp = "0";
			argUnderConstruction = false;
		}
		
		//----------------------- Generic Fault Event  Handler-------------------------------//
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));	
		}

		public function get projectID():int
		{
			return _projectID;
		}

		public function set projectID(value:int):void
		{
			_projectID = value;
		}

		public function get projectPassword():String
		{
			return _projectPassword;
		}

		public function set projectPassword(value:String):void
		{
			_projectPassword = value;
		}

		public function get projID():int
		{
			return _projID;
		}

		public function set parentProjID(value:int):void
		{
			_parentProjID = value;
		}
		
		public function get parentProjID():int
		{
			return _parentProjID;
		}
		
		public function set projID(value:int):void
		{
			_projID = value;
		}

		public function get projectName():String
		{
			return _projectName;
		}

		public function set projectName(value:String):void
		{
			_projectName = value;
		}
		
		public function get projectType():int
		{
			return _projectType;
		}
		
		public function set projectType(value:int):void
		{
			_projectType = value;
		}

		public function get showChildren():Dictionary
		{
			return _showChildren;
		}

		public function set showChildren(value:Dictionary):void
		{
			_showChildren = value;
		}
		
		public function get hide():Dictionary
		{
			return _hide;
		}
		
		public function set hide(value:Dictionary):void
		{
			_hide = value;
		}

		public function get panelListHashTemp():Dictionary
		{
			return _panelListHashTemp;
		}

		public function set panelListHashTemp(value:Dictionary):void
		{
			_panelListHashTemp = value;
		}
		
		
	}
}