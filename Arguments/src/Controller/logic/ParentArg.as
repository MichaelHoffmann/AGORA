package Controller.logic
{
	import Model.ArgumentTypeModel;
	
	import components.ArgSelector;
	import components.ArgumentPanel;
	import components.DynamicTextArea;
	import components.Inference;
	
	import flash.utils.Dictionary;
	
	import flashx.textLayout.operations.SplitParagraphOperation;
	
	import mx.utils.ObjectUtil;
	
	
	public class ParentArg {
		
		private static var instance:ParentArg;
		
		//In the backend, each of the classes is referred by another name. For example, Modus Ponens is referred to as therefore.
		//Ideally, they could be the same, but the server and client were developed parallelly and then integrated.
		public var langTypes:Array;
		public var expLangTypes:Array;
		
		public static var MOD_PON:String = "Modus Ponens";
		public static var MOD_TOL:String = "Modus Tollens";
		public static var COND_SYLL:String = "Conditional Syllogism";
		public static var DIS_SYLL:String = "Disjunctive Syllogism";
		public static var NOT_ALL_SYLL:String = "Not-All Syllogism";
		public static var CONST_DILEM:String = "Constructive Dilemma";
		public static var EXP_AND:String = "and";
		public static var EXP_OR:String = "or";
		
		public static const MPIfThen:String = "MPifthen";
		public static const MPimplies:String = "MPimplies";
		public static const MPwhenever:String = "MPwhenever";
		public static const MPonlyif:String = "MPonlyif";
		public static const MPprovidedthat:String = "MPprovidedthat";
		public static const MPsufficient:String = "MPsufficient";
		public static const MPnecessary:String = "MPnecessary";
		public static const MTifthen:String = "MTifthen";
		public static const MTimplies:String = "MTimplies";
		public static const MTwhenever:String = "MTwhenever";
		public static const MTonlyif:String = "MTonlyif";
		public static const MTonlyiffor:String = "MTonlyiffor";
		public static const MTprovidedthat:String = "MTprovidedthat";
		public static const MTsufficient:String = "MTsufficient";
		public static const MTnecessary:String = "MTnecessary";
		public static const DisjSyl:String = "DisjSyl";
		public static const NotAllSyll:String = "NotAllSyl";
		public static const EQiff:String = "EQiff";
		public static const EQnecsuf:String = "EQnecsuf";
		public static const EQ:String = "EQ";
		public static const CSifthen:String = "CSifthen";
		public static const CSimplies:String = "CSimplies";
		public static const CDaltclaim:String = "CDaltclaim";
		public static const CDpropclaim:String = "CDpropclaim";
		public static const Unset:String = "Unset";
		
		public function ParentArg(){
			instance = this;
		}
		
		public static function getInstance():ParentArg{
			if(instance == null){
				instance = new ParentArg;
			}
			return instance;
		}
		
		//---------------- Getters and Setters ----------------------//
		public function get hasLanguageTypeOptions():Boolean{
			return true;
		}
		
		
		//--------------- Other Public Fucntion --------------------//
		public function getConstrainedArray(argumentTypeModel:ArgumentTypeModel):Array{
			var array:Array = new Array;
			var logicController:ParentArg = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
			array.concat(logicController.getLabel);
			return array;
		}
		
		public function getFullArray():Array{
			var array:Array = [MOD_PON, MOD_TOL, DIS_SYLL, COND_SYLL, NOT_ALL_SYLL];
			return array;
		}
		
		public function getPositiveArray():Array{
			var array:Array = [MOD_PON, DIS_SYLL];
			return array;
		}
		
		public function getNegativeArray():Array{
			var array:Array = [MOD_TOL, NOT_ALL_SYLL];
			return array;
		}
		
		public function getImplicationArray():Array{
			var array:Array = [MOD_PON, DIS_SYLL, COND_SYLL];
			return array;
		}
		
		public function getDisjunctionPositiveArray():Array{
			var array:Array = [MOD_PON, DIS_SYLL];
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
		
		public function hasLanguageOptions():Boolean{
			if(this is DisjunctiveSyllogism || this is NotAllSyllogism){
				return false;
			}else{
				return true;
			}
		}
	}
}