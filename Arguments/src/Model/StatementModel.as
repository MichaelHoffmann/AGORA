package Model
{
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Bindable]
	public class StatementModel extends EventDispatcher
	{
		
		public static const DISJUNCTION:String = "Disjunction";
		public static const IMPLICATION:String = "Implication";
		public static const INFERENCE:String = "Inference";
		public static const UNIVERSAL:String = "Universal";
		public static const PARTICULAR:String = "Particular";
		
		private var _statement:SimpleStatementModel;
		private var _statements:Vector.<SimpleStatementModel>;
		private var _negated:Boolean;
		private var _connectingString:String;
		private var _complexStatement:String;
		private var _supportingArguments:Vector.<InferenceModel>;
		private var _inference:InferenceModel;
		private var _firstClaim:Boolean;
		private var _statementType:String;
		private var _ID:int;
		private var _nodeTextID:int;
		private var _nodeTextIDs:Vector.<int>;
		private var _xgrid:int;
		private var _ygrid:int;
		
		
		public function StatementModel(target:IEventDispatcher=null)
		{
			super(target);
			statements = new Vector.<SimpleStatementModel>(0,false);
			supportingArguments = new Vector.<InferenceModel>(0,false);
			nodeTextIDs = new Vector.<int>(0,false);
		}

		
		//--------------------Getters and Setters------------------//
		
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

		public function get nodeTextID():int
		{
			return _nodeTextID;
		}

		public function set nodeTextID(value:int):void
		{
			_nodeTextID = value;
		}

		public function get nodeTextIDs():Vector.<int>
		{
			return _nodeTextIDs;
		}

		public function set nodeTextIDs(value:Vector.<int>):void
		{
			_nodeTextIDs = value;
		}

		public function get ID():int
		{
			return _ID;
		}

		public function set ID(value:int):void
		{
			_ID = value;
		}

		public function get statementType():String
		{
			return _statementType;
		}

		public function set statementType(value:String):void
		{
			_statementType = value;
		}

		public function get firstClaim():Boolean
		{
			return _firstClaim;
		}

		public function set firstClaim(value:Boolean):void
		{
			_firstClaim = value;
		}

		public function get inference():InferenceModel
		{
			return _inference;
		}

		public function set inference(value:InferenceModel):void
		{
			_inference = value;
		}

		public function get supportingArguments():Vector.<InferenceModel>
		{
			return _supportingArguments;
		}

		public function set supportingArguments(value:Vector.<InferenceModel>):void
		{
			_supportingArguments = value;
		}

		public function get complexStatement():String
		{
			return _complexStatement;
		}

		public function set complexStatement(value:String):void
		{
			_complexStatement = value;
		}

		public function get connectingString():String
		{
			return _connectingString;
		}

		public function set connectingString(value:String):void
		{
			_connectingString = value;
		}

		public function get negated():Boolean
		{
			return _negated;
		}

		public function set negated(value:Boolean):void
		{
			_negated = value;
		}

		public function get statements():Vector.<SimpleStatementModel>
		{
			return _statements;
		}

		public function set statements(value:Vector.<SimpleStatementModel>):void
		{
			_statements = value;
		}

		public function get statement():SimpleStatementModel
		{
			return _statement;
		}

		public function set statement(value:SimpleStatementModel):void
		{
			_statement = value;
		}
		
		//----------------------- other public functions -------------//
		public static function getObject(xml:XML):StatementModel{
			//trace(xml);
			return new StatementModel;	
			
		}
		
		public function getXML():XML{
			var xml:XML = <node></node>;
			xml.@Type = statementType;
			xml.@typed = 0;
			xml.@is_positive = negated? 0 : 1;
			xml.@x = xgrid;
			xml.@y = ygrid;
			return xml;
		}
	}
}