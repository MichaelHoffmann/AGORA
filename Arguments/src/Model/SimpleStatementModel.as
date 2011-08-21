package Model
{
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Bindable]
	public class SimpleStatementModel extends EventDispatcher
	{
		private var _text:String;
		private var _forwardList:Vector.<SimpleStatementModel>;
		
		private var _ID:int;
		
		private var _hasOwn:Boolean;
		
		private var _parent:StatementModel;
		
		public static const DEPENDENT_TEXT:String = "$#$DependentText$#$";
		
		
		
		public function SimpleStatementModel(target:IEventDispatcher=null)
		{
			super(target);
			forwardList = new Vector.<SimpleStatementModel>;
			ID = 0;
			hasOwn = true;
		}
		
		//------------------------Getters/Setters-------------------------//
		
		public function get parent():StatementModel
		{
			return _parent;
		}

		public function set parent(value:StatementModel):void
		{
			_parent = value;
		}

		public function get hasOwn():Boolean
		{
			return _hasOwn;
		}

		public function set hasOwn(value:Boolean):void
		{
			_hasOwn = value;
		}

		public function get text():String{
			return _text;
		}
		
		public function set text(value:String):void{
			if(hasOwn){
				_text = value;
			}
			else if(!parent is InferenceModel){
				
			}
			else{
				_text = "";
				if(parent.statements.length == 1){
					_text = value;
				}
				else{
					if(parent.connectingString == StatementModel.IMPLICATION){
						_text = AGORAParameters.getInstance().IF + " " + parent.statements[0] + ", " + AGORAParameters.getInstance().THEN + " " + parent.statements[1]; 
					}
					if(parent.connectingString == StatementModel.DISJUNCTION){
						_text = parent.statements[0].text;
						for(var i:int = 1; i < parent.statements.length; i++){
							_text =  _text + " " + AGORAParameters.getInstance().OR;
						}
					}
					else{
					}
				}	
			}
			trace(this.forwardList.length);
			for each(var simpleStatement:SimpleStatementModel in forwardList){
				simpleStatement.text = _text;
				trace(simpleStatement.text);
			}
		}
		
		public function get forwardList():Vector.<SimpleStatementModel>{
			return _forwardList;
		}
		
		public function set forwardList(value:Vector.<SimpleStatementModel>):void{
			_forwardList = value;
		}
		
		public function get ID():int{
			return _ID;
		}
		public function set ID(value:int):void{
			_ID = value;              
		}
		//------------------ other public functions -----------------------//
		
		
		
		//------------------ get simple statment --------------------------//
		public static function createSimpleStatementFromObject(obj:Object, statementModel:StatementModel):SimpleStatementModel{
			var simpleStatement:SimpleStatementModel = new SimpleStatementModel;
			simpleStatement.ID = obj.ID;
			simpleStatement.parent = statementModel;
			return simpleStatement;
		}
	}
}