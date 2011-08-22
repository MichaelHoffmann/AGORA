package Model
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import logic.ConditionalSyllogism;
	import logic.DisjunctiveSyllogism;
	import logic.ModusPonens;
	import logic.ModusTollens;
	import logic.NotAllSyllogism;
	import logic.ParentArg;
	
	import mx.collections.ArrayCollection;
	
	public class ArgumentTypeModel extends EventDispatcher
	{
		private var _logicHash:Object;
		private var _inferenceModel:InferenceModel;
		private var _claimModel:StatementModel;
		private var _reasonModels:Vector.<StatementModel>;
		private var _typed:Boolean;
		private var _languageTyped:Boolean;
		private var _formed:Boolean;
		private var _logicClass:ParentArg;
		private var _dbType:String;
		private var _argumentMenu:ArrayCollection;
		private var _ID:int;
		private var _xgrid:int;
		private var _ygrid:int;
		
		public function ArgumentTypeModel(target:IEventDispatcher=null)
		{
		
			super(target);
		}

		//-------------------- Getters and Setters -----------------------//

		public function get dbType():String
		{
			return _dbType;
		}

		public function set dbType(value:String):void
		{
			_dbType = value;
			logicClass = ParentArg.getInstance().logicHash[_dbType];
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

		public function get formed():Boolean
		{
			return _formed;
		}

		public function set formed(value:Boolean):void
		{
			_formed = value;
		}

		public function get languageTyped():Boolean
		{
			return _languageTyped;
		}

		public function set languageTyped(value:Boolean):void
		{
			_languageTyped = value;
		}

		public function get typed():Boolean
		{
			return _typed;
		}

		public function set typed(value:Boolean):void
		{
			_typed = value;
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

		public function get inferenceModel():InferenceModel
		{
			return _inferenceModel;
		}

		public function set inferenceModel(value:InferenceModel):void
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
		
		//-------------------------- Creation mehtods ----------------------//
		public static function createArgumentTypeFromObject(obj:Object):ArgumentTypeModel{
			var argumentTypeModel:ArgumentTypeModel = new ArgumentTypeModel;
			argumentTypeModel.ID = obj.ID;
			return argumentTypeModel;
		}
		

	}
}