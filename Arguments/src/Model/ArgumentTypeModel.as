package Model
{
	import Controller.logic.ConditionalSyllogism;
	import Controller.logic.DisjunctiveSyllogism;
	import Controller.logic.ModusPonens;
	import Controller.logic.ModusTollens;
	import Controller.logic.NotAllSyllogism;
	import Controller.logic.ParentArg;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
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
		
		public function ArgumentTypeModel(target:IEventDispatcher=null)
		{
			super(target);
			reasonsCompleted = true;
			reasonModels = new Vector.<StatementModel>;
			
			addReasonService = new HTTPService;
			addReasonService.url = AGORAParameters.getInstance().insertURL;
			addReasonService.addEventListener(ResultEvent.RESULT, addReasonServiceResult);
			addReasonService.addEventListener(FaultEvent.FAULT, onFault);
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

		public function get dbType():String{
			return _dbType;
		}
		
		public function set dbType(value:String):void{
			_dbType = value;
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
		
		//------------------------ adding a reason ------------------------//
		public function addReason(x:int):void{
			var reasonXML:XML;
			var textboxXML:XML;
			
			if(logicClass == null || logicClass.length == 0){
				trace("ArgumentTypeModel::addReason: no logic class");
				return;
			}
			
			ygrid = this.reasonModels[0].ygrid;
			
			var inputXML:XML = 	<map ID={AGORAModel.getInstance().agoraMapModel.ID}>
											</map>;
			
			if(logicClass == ParentArg.COND_SYLL){
				inputXML.appendChild(<textbox TID="1" text={SimpleStatementModel.DEPENDENT_TEXT} />);
			}
			
			inputXML.appendChild(<textbox TID="2" text="" />);
			
			reasonXML = <node TID= "3" Type="Particular" typed="0" is_positive="1" x={x} y={ygrid}>
						</node>;
			
			
			if(logicClass == ParentArg.COND_SYLL){
				reasonXML.appendChild(<nodetext TID="4" textboxTID="1" />);
			}
			
			reasonXML.appendChild(<nodetext TID="5" textboxTID="2" />);
			
			inputXML.appendChild(reasonXML);
			
		}
		
		protected function addReasonServiceResult(event:ResultEvent):void{
			
		}
		
		//-------------------------- Generic Fault method ----------------//
		protected function onFault(event:FaultEvent):void{
			
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
			if(reasonModels.length > 1 || claimModel.supportingArguments.length > 1){		
				return true;
			}else{
				return false;
			}
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
		
		//-------------------------- Update Connection ---------------------//
		public function updateConnection():void{
			
		}
		
		//-------------------------- Creation mehtods ----------------------//
		public static function createArgumentTypeFromObject(obj:Object):ArgumentTypeModel{
			var argumentTypeModel:ArgumentTypeModel = new ArgumentTypeModel;
			argumentTypeModel.ID = obj.connID;
			return argumentTypeModel;
		}
		

	}
}