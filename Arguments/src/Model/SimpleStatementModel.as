package Model
{
	import Controller.logic.LogicFetcher;
	import Controller.logic.ParentArg;
	
	import ValueObjects.AGORAParameters;
	
	import classes.Language;
	
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
		
		public var setAdditionalReasonConditionalText:String = "";
		
		
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
		//For setting it in conditional syllogism
		public function set positiveText(value:String):void{
			_text = value;
		}
		
		public function get text():String{
			if(this.parent.negated && parent.statement === this && parent.statementFunction != StatementModel.INFERENCE){
				return Language.lookup("ArgNotCase") + _text;
			}
			else if(parent.statement === this && parent.argumentTypeModel!=null)
			{
				if(parent.argumentTypeModel.logicClass == AGORAParameters.getInstance().COND_SYLL && parent.statementFunction != StatementModel.INFERENCE)
				{
					if(parent.firstReason == false && parent.argumentTypeModel.reasonModels.length>1)
					{
						//For subsequent reasons, to ensure that only the positive text changes and not anything else
						//find which index the calling statement (parent) is and then return that string
						var i:int=0;
						var flag:int = 0;
						var rex:RegExp = /[\s\r\n]*/gim;
						for(i=0;i<parent.argumentTypeModel.reasonModels.length;i++)
						{
							if(parent.argumentTypeModel.reasonModels[i]== parent)
							{
								flag=1;
								break;	
							}
							else
								flag = 0;
						}
					
						//set the string to the previous argument 
						var statement1:String = parent.argumentTypeModel.reasonModels[i-1].statement.positiveText;
						var statement2:String = parent.argumentTypeModel.reasonModels[i].statement.positiveText;
						if (statement1 !=null)
						{
							statement1 = statement1.replace(rex,'');
						}
						if (statement2!=null)
						{
							statement2 = statement2.replace(rex,'');
						}
						
						if (statement1==statement2 || (statement1.search(statement2)!=-1 && statement2!=""))
						{
							var a:String = "";
							if (parent.statement.setAdditionalReasonConditionalText == null)
								a = "";
							else
								a = parent.statement.setAdditionalReasonConditionalText;
							parent.argumentTypeModel.reasonModels[i].statement.positiveText = a;
							parent.argumentTypeModel.reasonModels[i].statements[0].positiveText = a;
							return "If "+parent.argumentTypeModel.reasonModels[i-1].statement.positiveText+" then "+a;
						}
						else
						{
							//trace(parent.argumentTypeModel.reasonModels[i-1].statement.positiveText.search(parent.argumentTypeModel.reasonModels[i].statement.positiveText));	
							parent.statement.setAdditionalReasonConditionalText = _text;	//store the latest text here, which you get when actually editing the reason
							parent.argumentTypeModel.reasonModels[i].statements[0].positiveText = _text;
							parent.argumentTypeModel.reasonModels[i].statement.positiveText = _text;
							return "If "+parent.argumentTypeModel.reasonModels[i-1].statement.positiveText+" then "+parent.argumentTypeModel.reasonModels[i].statement.positiveText;
						}
						
					}
					else{
							return  "If "+parent.argumentTypeModel.claimModel.statements[0].text+" then "+ _text;
					}	
				}		
			}
			return _text;
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
				//conditional syllogism and constructive dilemma
				if(simpleStatement.parent.statements.length >= 2 && simpleStatement.parent.statement == simpleStatement && simpleStatement.parent.statementFunction != StatementModel.INFERENCE)
				{
					if(simpleStatement.parent.connectingString == StatementModel.IMPLICATION){
					// bug fix
						if(simpleStatement.parent.argumentTypeModel.claimModel.argumentTypeModel.logicClass == AGORAParameters.getInstance().MOD_TOL){
						var positiveTextStr:String = simpleStatement.parent.statements[0].text;
						positiveTextStr = (positiveTextStr!=null && positiveTextStr.indexOf(Language.lookup("ArgNotCase"))==0)?positiveTextStr.substr(Language.lookup("ArgNotCase").length):positiveTextStr;
							simpleStatement.text = AGORAParameters.getInstance().IF + positiveTextStr + AGORAParameters.getInstance().THEN  + simpleStatement.parent.statements[1].text;
						}else{					
						simpleStatement.text = AGORAParameters.getInstance().IF + simpleStatement.parent.argumentTypeModel.claimModel.statements[0].text + AGORAParameters.getInstance().THEN  + simpleStatement.parent.statements[0].text; 
						}
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
				if (simpleStatement!=null)
					trace(simpleStatement.text);
			}
			if (simpleStatement!=null)
				trace(simpleStatement.text);
		}
		
		public function addDependentStatement(simpleStatement:SimpleStatementModel):void{
			//push it only if it's not already there.
			
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