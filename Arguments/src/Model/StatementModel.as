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
		
		private var _statement:String;
		private var _statements:Vector.<String>;
		private var _negated:Boolean;
		private var _connectingString:String;
		private var _complexStatement:String;
		private var _supportingArguments:Vector.<InferenceModel>;
		private var _inference:InferenceModel;
		private var _firstClaim:Boolean;
		private var _statementType:String;
		
		
		//--------------------Getters and Setters------------------//
		public function StatementModel(target:IEventDispatcher=null)
		{
			super(target);
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

		public function get statements():Vector.<String>
		{
			return _statements;
		}

		public function set statements(value:Vector.<String>):void
		{
			_statements = value;
		}

		public function get statement():String
		{
			return _statement;
		}

		public function set statement(value:String):void
		{
			_statement = value;
		}

	}
}