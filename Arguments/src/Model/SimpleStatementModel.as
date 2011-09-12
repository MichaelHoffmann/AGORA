package Model
{
	import Controller.logic.LogicFetcher;
	import Controller.logic.ParentArg;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Bindable]
	public class SimpleStatementModel extends EventDispatcher
	{
		public static const TEMPORARY:int = -1;
		private var _text:String;
		private var _forwardList:Vector.<SimpleStatementModel>;
		
		private var _ID:int;
		
		private var _TID:int;
		
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
		
		public function get TID():int
		{
			return _TID;
		}
		
		public function set TID(value:int):void
		{
			_TID = value;
		}
		
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
		
		public function get positiveText():String{
			return _text;	
		}
		
		public function get text():String{
			if(this.parent.negated && parent.statement === this && parent.statementFunction != StatementModel.INFERENCE){
				return "It is not the case that " + _text;
			}else{
				return _text;
			}
		}
		
		public function set text(value:String):void{
			_text = value;
			updateStatementTexts();
			
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
		public function updateStatementTexts():void{
			for each(var simpleStatement:SimpleStatementModel in forwardList){
				if(simpleStatement.parent.statements.length >= 2 && simpleStatement.parent.statement == simpleStatement && simpleStatement.parent.statementFunction != StatementModel.INFERENCE)
				{
					if(simpleStatement.parent.connectingString == StatementModel.IMPLICATION){
						simpleStatement.text = AGORAParameters.getInstance().IF + " " + simpleStatement.parent.statements[0].text + ", " + AGORAParameters.getInstance().THEN + " " + simpleStatement.parent.statements[1].text; 
					}
					if(parent.connectingString == StatementModel.DISJUNCTION){
						var vtext:String = parent.statements[0].text;
						for(var i:int = 1; i < parent.statements.length; i++){
							vtext = " " + AGORAParameters.getInstance().OR + " " + vtext ;
						}
						simpleStatement.text = vtext;
					}	
				}
				else if(simpleStatement.parent.statementFunction == StatementModel.INFERENCE){
					if(simpleStatement.parent.argumentTypeModel.logicClass != null){
						var logicController:ParentArg = LogicFetcher.getInstance().logicHash[simpleStatement.parent.argumentTypeModel.logicClass];
						logicController.formText(simpleStatement.parent.argumentTypeModel);
					}
				}
				else{
					simpleStatement.text = text;
					
				}
			}
		}
		
		public function addDependentStatement(simpleStatement:SimpleStatementModel):void{
			//push it only if it's not already there.
			/*
			for each(var simpleStatementModel:SimpleStatementModel in forwardList){
			if(simpleStatementModel == simpleStatement){
			return;
			}
			}
			forwardList.push(simpleStatement);
			*/
			if(forwardList.indexOf(simpleStatement) == -1){
				forwardList.push(simpleStatement);
			}
		}
		
		//redundant. Should be removed
		public function addToDependancyList(simpleStatementModel:SimpleStatementModel):void{
			if(forwardList.indexOf(simpleStatementModel) == -1){
				forwardList.push(simpleStatementModel);
			}
		}
		
		//------------------ get simple statment --------------------------//
		public static function createSimpleStatementFromObject(obj:Object, statementModel:StatementModel):SimpleStatementModel{
			var simpleStatement:SimpleStatementModel = new SimpleStatementModel;
			simpleStatement.ID = obj.ID;
			simpleStatement.parent = statementModel;
			return simpleStatement;
		}
	}
}