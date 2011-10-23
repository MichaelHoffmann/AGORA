package Model
{
	import Controller.UserSessionController;
	import Controller.logic.ConditionalSyllogism;
	import Controller.logic.DisjunctiveSyllogism;
	import Controller.logic.ModusPonens;
	import Controller.logic.ModusTollens;
	import Controller.logic.NotAllSyllogism;
	import Controller.logic.ParentArg;
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ArgumentScheme;
	import ValueObjects.MapValueObject;
	import ValueObjects.NodeValueObject;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.charts.chartClasses.StackedSeries;
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	[Bindable]
	public class ArgumentTypeModel extends EventDispatcher
	{
		private var _logicHash:Object;
		private var _inferenceModel:StatementModel;
		private var _claimModel:StatementModel;
		private var _reasonModels:Vector.<StatementModel>;
		private var _dbType:String;
		private var _logicClass:String;
		private var _ID:int;
		private var _xgrid:int;
		private var _ygrid:int;
		private var _language:String;
		private var _lSubOption:String;
		//always true for arguments made on other clients
		private var _reasonsCompleted:Boolean;
		
		
		
		private var addReasonService:HTTPService;
		private var updateConnectionService:HTTPService;
		//beware of using it simultaneously with two functions that repeatedly produce
		//tids
		private var tid:int;
		
		public function ArgumentTypeModel(target:IEventDispatcher=null)
		{
			super(target);
			reasonsCompleted = true;
			reasonModels = new Vector.<StatementModel>;
			
			addReasonService = new HTTPService;
			
			addReasonService.url = AGORAParameters.getInstance().insertURL;
			addReasonService.addEventListener(ResultEvent.RESULT, addReasonServiceResult);
			addReasonService.addEventListener(FaultEvent.FAULT, onFault);
			
			updateConnectionService = new HTTPService;
			updateConnectionService.url = AGORAParameters.getInstance().insertURL;
			updateConnectionService.addEventListener(ResultEvent.RESULT, updateConnectionServiceResult);
			updateConnectionService.addEventListener(FaultEvent.FAULT, onFault);
			
			
			
			
			AGORAModel.getInstance().agoraMapModel.newArgumentTypeModelAdded(this);
		}
		
		
		//-------------------- Getters and Setters -----------------------//
		
		public function get lSubOption():String{
			return _lSubOption;
		}
		public function set lSubOption(value:String):void{
			_lSubOption = value;
		}
		
		public function get language():String
		{
			return _language;
		}
		
		public function set language(value:String):void
		{
			_language = value;
		}
		
		public function get reasonsCompleted():Boolean
		{
			return _reasonsCompleted;
		}
		
		public function set reasonsCompleted(value:Boolean):void
		{
			_reasonsCompleted = value;
		}
		
		public function get ygrid():int
		{
			return _ygrid;
		}
		
		public function set ygrid(value:int):void
		{
			_ygrid = value;
		}
		
		public function get xgrid():int
		{
			return _xgrid;
		}
		
		public function set xgrid(value:int):void
		{
			_xgrid = value;
		}
		
		public function get ID():int
		{
			return _ID;
		}
		
		public function set ID(value:int):void
		{
			_ID = value;
		}
		
		
		public function get logicClass():String{
			return _logicClass;
		}
		
		public function set logicClass(value:String):void
		{
			_logicClass = value;
		}
		
		
		public function get reasonModels():Vector.<StatementModel>
		{
			return _reasonModels;
		}
		
		public function set reasonModels(value:Vector.<StatementModel>):void
		{
			_reasonModels = value;
		}
		
		public function get claimModel():StatementModel
		{
			return _claimModel;
		}
		
		public function set claimModel(value:StatementModel):void
		{
			_claimModel = value;
		}
		
		public function get inferenceModel():StatementModel
		{
			return _inferenceModel;
		}
		
		public function set inferenceModel(value:StatementModel):void
		{
			_inferenceModel = value;
		}
		
		public function set dbType(value:String):void{
			var object:ArgumentScheme = AGORAModel.getInstance().schemeAndLanguage[value];
			if(object != null){
				logicClass = object.scheme;
				language = object.language;
				lSubOption = object.aslConnector;
			}
		}
		
		public function get dbType():String{
			var  dbScheme:String = AGORAModel.getInstance().dbSchemeHashMap[logicClass];
			var  dbLanguage:String = AGORAModel.getInstance().dbLanguageHashMap[language];
			var  dbLanguageSubOption:String = "";
			if(language == AGORAParameters.getInstance().ONLY_IF){
				if(reasonModels.length > 1){
					if(lSubOption == AGORAParameters.getInstance().AND){
						return dbScheme + "onlyifand";
					}
					else{
						return dbScheme + "onlyifor";
					}	
				}
			}
			else{
				return dbScheme + "onlyif";
			}
			return dbScheme + (dbLanguage==null?"":dbLanguage) + dbLanguageSubOption;
		}
		
		//------------------------ adding a reason ------------------------//
		public function addReason(x:int, y:int):void{
			var reasonXML:XML;
			var textboxXML:XML;
			
			if(logicClass == null || logicClass.length == 0){
				trace("ArgumentTypeModel::addReason: no logic class");
			}
			
			var inputXML:XML = 	<map ID={AGORAModel.getInstance().agoraMapModel.ID}>			
								</map>;
			
			if(logicClass == AGORAParameters.getInstance().COND_SYLL){
				inputXML.appendChild(<textbox TID="1" text={SimpleStatementModel.DEPENDENT_TEXT} />);
			}
			
			inputXML.appendChild(<textbox TID="2" text="" />);
			
			reasonXML = <node TID= "3" Type="Particular" typed="0" is_positive="1" x={x} y={y}>
						</node>;
			
			if(logicClass == AGORAParameters.getInstance().COND_SYLL){
				reasonXML.appendChild(<nodetext TID="4" textboxTID="1" />);
			}
			
			reasonXML.appendChild(<nodetext TID="5" textboxTID="2" />);
			inputXML.appendChild(reasonXML);
			
			var inferenceXML:XML = inferenceModel.getXML();
			inferenceXML = getNodeTexts(inferenceModel, inferenceXML);
			var nodetextXML:XML = <nodetext TID="11" textboxTID="10" />;
			inferenceXML.appendChild(nodetextXML);
			var textboxXMLInference:XML = <textbox TID="10" text={SimpleStatementModel.DEPENDENT_TEXT} />;
			
			
			inputXML.appendChild(textboxXMLInference);
			inputXML.appendChild(inferenceXML);
			
			
			var connectionXML:XML = <connection ID={ID} type={(logicClass == null || logicClass.length == 0)? 'Unset':dbType} targetnodeID={claimModel.ID} x={xgrid} y={ygrid}>
										<sourcenode TID={7} nodeTID="3" />
									</connection>;
			
			inputXML.appendChild(connectionXML);
			trace(inputXML.toXMLString());	
			var userModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			addReasonService.send({uid: userModel.uid, pass_hash: userModel.passHash, xml: inputXML});
		}
		
		protected function addReasonServiceResult(event:ResultEvent):void{
			if(event.result.map.hasOwnProperty("error")){
				dispatchEvent(new AGORAEvent(AGORAEvent.REASON_ADDITION_NOT_ALLOWED, null, null));
				return;
			}
			var map:MapValueObject = new MapValueObject(event.result.map, true);
			//trace(event.result.toXMLString());
			
			var statementModel:StatementModel;
			for each(var nodeVO:NodeValueObject in map.nodeObjects){
				if(!AGORAModel.getInstance().agoraMapModel.panelListHash.hasOwnProperty(nodeVO.ID)){
					statementModel = StatementModel.createStatementFromObject(nodeVO);
					statementModel.argumentTypeModel = this;
					AGORAModel.getInstance().agoraMapModel.panelListHash[statementModel.ID] = statementModel;
					AGORAModel.getInstance().agoraMapModel.newPanels.addItem(statementModel);
					reasonModels.push(statementModel);		
				}
			}
			dispatchEvent(new AGORAEvent(AGORAEvent.REASON_ADDED, null, statementModel));
		}
		
		private function getNodeTexts(statementModel:StatementModel, statementModelXML:XML):XML{
			for(var i:int=0; i<statementModel.nodeTextIDs.length; i++){
				var xml:XML = <nodetext  ID={statementModel.nodeTextIDs[i]} textboxID={statementModel.statements[i].ID} />;
				if(statementModelXML != null){
					statementModelXML.appendChild(xml);
				}
				else{
					trace("Look into the variable");
				}
			}
			
			return statementModelXML;
		} 
		
		//-------------------------- Generic Fault method ----------------//
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));		
		}
		
		//-------------------------- other public methods -----------------//
		public function hasReason(id:int):Boolean{
			for each(var statementModel:StatementModel in reasonModels){
				if(id == statementModel.ID){
					return true;
				}
			}
			return false;
		}
		
		public function isTyped():Boolean{
			if(reasonModels.length > 1){		
				return true;
			}
			for each(var reason:StatementModel in reasonModels){
				if(reason.supportingArguments.length > 0){
					return true;
				}
			}
			return false;
		}
		
		public function isLanguageTyped():Boolean{
			if(inferenceModel.supportingArguments.length > 0){
				for each(var argumentTypeModel:ArgumentTypeModel in inferenceModel.supportingArguments){
					if( argumentTypeModel.logicClass is ConditionalSyllogism){
						return true;
					}
				}
			}
			return false;
		}
		
		
		public function getXML():XML{
			var inputXML:XML = <connection ID={ID} type={dbType} targetnodeID={claimModel.ID} x={xgrid} y={ygrid} />;
			return inputXML;
		}
		
		
		//-------------------------- Update Connection ---------------------//
		public function updateConnection():void{
			var inputXML:XML = <map ID={AGORAModel.getInstance().agoraMapModel.ID}/>;
			tid=1;
			inputXML.appendChild(getXML());
			//trace(inputXML.toXMLString());
			//convert temporary boxes to proper ones
			if(logicClass == AGORAParameters.getInstance().COND_SYLL){
				inputXML = substituteTemporaryBoxes(claimModel, inputXML);
				for each(var reason:StatementModel in reasonModels){
					inputXML = substituteTemporaryBoxes(reason, inputXML);
				}
			}
			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			updateConnectionService.send({uid: usm.uid, pass_hash: usm.passHash, xml: inputXML});
		}
		protected function updateConnectionServiceResult(event:ResultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.ARGUMENT_SAVED, null, this));
		}
		
		private function substituteTemporaryBoxes(statementModel:StatementModel, requestXML:XML):XML{
			var outputXML:XML = statementModel.getXML();
			for(var i:int=0; i<statementModel.statements.length; i++){
				if(statementModel.statements[i].ID == SimpleStatementModel.TEMPORARY){
					requestXML.appendChild(<textbox TID={tid} text={statementModel.statements[i].hasOwn? statementModel.statements[i].text:SimpleStatementModel.DEPENDENT_TEXT} />);
					outputXML.appendChild(<nodetext TID={tid+1} textboxTID={tid} />	);
				}
				else{
					outputXML.appendChild(<nodetext ID={statementModel.nodeTextIDs[i]} textboxID={statementModel.statements[i].ID} />);
				}
				tid = tid + 1;
			}
			
			requestXML.appendChild(outputXML);
			return requestXML;
		}
		
		//-------------------------- Creation mehtods ----------------------//
		public static function createArgumentTypeFromObject(obj:Object):ArgumentTypeModel{
			var argumentTypeModel:ArgumentTypeModel = new ArgumentTypeModel;
			argumentTypeModel.ID = obj.connID;
			return argumentTypeModel;
		}
	}
}