package Controller.logic
{
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.SimpleStatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.ArgSelector;
	import components.ArgumentPanel;
	import components.DynamicTextArea;
	
	import flash.utils.Dictionary;
	
	import flashx.textLayout.operations.SplitParagraphOperation;
	
	import mx.utils.ObjectUtil;
	
	
	public class ParentArg {
		
		private static var instance:ParentArg;
		private var _label:String;
		
		//In the backend, each of the classes is referred by another name. For example, Modus Ponens is referred to as therefore.
		//Ideally, they could be the same, but the server and client were developed parallelly and then integrated.
		public var langTypes:Array;
		public var expLangTypes:Array;
		
	
		
		public function ParentArg(){
			instance = this;
		}
		
		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
		}

		public static function getInstance():ParentArg{
			if(instance == null){
				instance = new ParentArg;
			}
			return instance;
		}
		
		//---------------- Getters and Setters ----------------------//

		
		
		//--------------- Other Public Fucntion --------------------//
		public function getConstrainedArray(argumentTypeModel:ArgumentTypeModel):Array{
			//var array:Array = new Array;
			var logicController:ParentArg = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
			var array:Array = [logicController.getLabel()];
			return array;
		}
		
		public function getFullArray():Array{
			var array:Array = [AGORAParameters.getInstance().MOD_PON, AGORAParameters.getInstance().MOD_TOL, AGORAParameters.getInstance().DIS_SYLL, AGORAParameters.getInstance().COND_SYLL, AGORAParameters.getInstance().NOT_ALL_SYLL];
			return array;
		}
		
		public function getPositiveArray():Array{
			var array:Array = [AGORAParameters.getInstance().MOD_PON, AGORAParameters.getInstance().DIS_SYLL];
			return array;
		}
		
		public function getNegativeArray():Array{
			var array:Array = [AGORAParameters.getInstance().MOD_TOL, AGORAParameters.getInstance().NOT_ALL_SYLL];
			return array;
		}
		
		public function getImplicationArray():Array{
			var array:Array = [AGORAParameters.getInstance().MOD_PON, AGORAParameters.getInstance().DIS_SYLL, AGORAParameters.getInstance().COND_SYLL];
			return array;
		}
		
		public function getDisjunctionPositiveArray():Array{
			var array:Array = [AGORAParameters.getInstance().MOD_PON, AGORAParameters.getInstance().DIS_SYLL];
			return array;
		}
		
		public function getLabel():String{
			return "";
		}
		
		public function formText(argumentTypeModel:ArgumentTypeModel):void{
			
		}
		
		public function formTextWithSubOption(argumentTypeModel:ArgumentTypeModel):void{
			
		}
	
		public function deleteLinks(argumentTypeModel:ArgumentTypeModel):void{
				
		}
		
		public function link(argumentTypeModel:ArgumentTypeModel):void{
			
		}
		
		protected function removeDependence(simpleStatementModel:SimpleStatementModel, notNeededStatement:SimpleStatementModel):void{
			var position:int = simpleStatementModel.forwardList.indexOf(notNeededStatement, 0);
			simpleStatementModel.forwardList.splice(position, 1);
		}
		
		public function hasLanguageOptions():Boolean{
			if(this is DisjunctiveSyllogism || this is NotAllSyllogism){
				return false;
			}else{
				return true;
			}
		}
	}
}