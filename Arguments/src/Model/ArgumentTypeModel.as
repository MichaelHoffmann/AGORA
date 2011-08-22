package Model
{
	import Controller.logic.ConditionalSyllogism;
	import Controller.logic.DisjunctiveSyllogism;
	import Controller.logic.ModusPonens;
	import Controller.logic.ModusTollens;
	import Controller.logic.NotAllSyllogism;
	import Controller.logic.ParentArg;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class ArgumentTypeModel extends EventDispatcher
	{
		private var _logicHash:Object;
		private var _inferenceModel:StatementModel;
		private var _claimModel:StatementModel;
		private var _reasonModels:Vector.<StatementModel>;
		private var _logicClass:ParentArg;
		private var _dbType:String;
		private var _argumentMenu:ArrayCollection;
		private var _ID:int;
		private var _xgrid:int;
		private var _ygrid:int;
		//always true for arguments made on other clients
		private var _reasonsCompleted:Boolean;
		
		public function ArgumentTypeModel(target:IEventDispatcher=null)
		{
			super(target);
			reasonsCompleted = true;
			reasonModels = new Vector.<StatementModel>;
		}

		//-------------------- Getters and Setters -----------------------//
		public function get reasonsCompleted():Boolean
		{
			return _reasonsCompleted;
		}

		public function set reasonsCompleted(value:Boolean):void
		{
			_reasonsCompleted = value;
		}

		public function get dbType():String
		{
			return _dbType;
		}

		public function set dbType(value:String):void
		{
			_dbType = value;
			//logicClass = ParentArg.getInstance().logicHash[_dbType];
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

		public function get argumentMenu():ArrayCollection
		{
			return _argumentMenu;
		}

		public function set argumentMenu(value:ArrayCollection):void
		{
			_argumentMenu = value;
		}

		public function get logicClass():ParentArg
		{
			return _logicClass;
		}

		public function set logicClass(value:ParentArg):void
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
		
		//-------------------------- Creation mehtods ----------------------//
		public static function createArgumentTypeFromObject(obj:Object):ArgumentTypeModel{
			var argumentTypeModel:ArgumentTypeModel = new ArgumentTypeModel;
			argumentTypeModel.ID = obj.connID;
			return argumentTypeModel;
		}
		

	}
}