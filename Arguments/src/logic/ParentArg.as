package logic
{
	import components.ArgumentPanel;
	import components.DynamicTextArea;
	import components.Inference;
	
	import components.ArgSelector;
	
	import flashx.textLayout.operations.SplitParagraphOperation;
	
	import mx.utils.ObjectUtil;
	
	
	public class ParentArg {
		
		private static var instance:ParentArg;
		private  var _logicHash:Object;
		
		
		public var _isLanguageExp:Boolean;
		public var myname:String;
		//This is set by the Inference that creates it.
		//Each object of ParentArg belongs only to 
		//one Inference, and it holds a reference to the Inference object.
		public var inference:Inference;
		//In the backend, each of the classes is referred by another name. For example, Modus Ponens is referred to as therefore.
		//Ideally, they could be the same, but the server and client were developed parallelly and then integrated.
		//public var dbName:String;
		public var _langTypes:Array;
		public var dbLangTypeNames:Array;
		public var multipleReasons:Boolean;
		public var _expLangTypes:Array;
		public static var MOD_PON:String = "Modus Ponens";
		public static var MOD_TOL:String = "Modus Tollens";
		public static var COND_SYLL:String = "Conditional Syllogism";
		public static var DIS_SYLL:String = "Disjunctive Syllogism";
		public static var NOT_ALL_SYLL:String = "Not-All Syllogism";
		public static var CONST_DILEM:String = "Constructive Dilemma";
		public static var EXP_AND:String = "and";
		public static var EXP_OR:String = "or";
		public var _dbType:String;
		
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
			//Modus Ponens 
			_logicHash[ParentArg.MPIfThen] = ModusPonens.getInstance();
			_logicHash[ParentArg.MPimplies]  = ModusPonens.getInstance();
			_logicHash[ParentArg.MPnecessary] = ModusPonens.getInstance();
			_logicHash[ParentArg.MPonlyif] = ModusPonens.getInstance();
			_logicHash[ParentArg.MPsufficient] = ModusPonens.getInstance();
			_logicHash[ParentArg.MPwhenever] = ModusPonens.getInstance();
			
			//Modus Tollens
			_logicHash[ParentArg.MTifthen] = ModusTollens.getInstance();
			_logicHash[ParentArg.MTimplies] = ModusTollens.getInstance();
			_logicHash[ParentArg.MTnecessary] = ModusTollens.getInstance();
			_logicHash[ParentArg.MTonlyif] = ModusTollens.getInstance();
			_logicHash[ParentArg.MTonlyiffor] = ModusTollens.getInstance();
			_logicHash[ParentArg.MTsufficient] = ModusTollens.getInstance();
			_logicHash[ParentArg.MTwhenever] = ModusTollens.getInstance();
			
			//Disjunctive Syllogism
			_logicHash[ParentArg.DisjSyl] = DisjunctiveSyllogism.getInstance();
			
			//Equivalence
			_logicHash[ParentArg.EQ] = Equivalence.getInstance();
			_logicHash[ParentArg.EQiff] = Equivalence.getInstance();
			_logicHash[ParentArg.EQnecsuf] = Equivalence.getInstance();
			
			//Not-All Syllogism
			_logicHash[ParentArg.NotAllSyll] = NotAllSyllogism.getInstance();
			
			//Conditional Syllogism
			_logicHash[ParentArg.CSifthen] = ConditionalSyllogism.getInstance();
			_logicHash[ParentArg.CSimplies] = ConditionalSyllogism.getInstance();
			
			//Constructive Dilemma
			_logicHash[ParentArg.CDaltclaim] = ConstructiveDilemma.getInstance();
			_logicHash[ParentArg.CDpropclaim] = ConstructiveDilemma.getInstance();
			
			
		}
		
		public function get logicHash():Object
		{
			return _logicHash;
		}

		public function set logicHash(value:Object):void
		{
			_logicHash = value;
		}

		public static function getInstance():ParentArg{
			if(instance == null){
				instance = new ParentArg;
			}
			return instance;
		}
		
		public function setIsExp():void{
			if(inference.myschemeSel.selectedType != null){
				for each(var langType:String in _expLangTypes){
					if(langType == inference.myschemeSel.selectedType){
						_isLanguageExp = true;	
					}
				}
			}
		}
		
		public function get dbType():String
		{
			for(var i:int=0; i<_langTypes.length; i++)
			{
				if(inference.myschemeSel.selectedType == _langTypes[i])
				{
					return _dbType+dbLangTypeNames[i];
				}
			}
			return "Unset";
		}
		
		public function getOption(dbString:String):String
		{
			return "";
		}
		
		public function getLanguageType(dbString:String):String
		{
			for(var i:int=0;i<dbLangTypeNames.length;i++)
			{
				if(dbString.indexOf(dbLangTypeNames[i]) >= 0)
				{
					return _langTypes[i];
				}
				
			}
			return "";
		}
		
		public var mySelector:ArgSelector;	// reference to be moved from Inference to here - specific argscheme
	
		public function deleteLinks():void{
			
		}
		
		public function link():void{
			
		}
		
		/*
		public function deleteLinks():void
		{
			
			var dta:DynamicTextArea;
			for(var i:int=0; i < inference.input.length; i++)
			{
				dta = inference.input[i];
				dta.forwardList.splice(0,dta.forwardList.length);
			}
			for(i=0; i < inference.inputs.length; i++)
			{
				dta = inference.inputs[i];
				dta.forwardList.splice(0,dta.forwardList.length);
			}
			for(i=0; i < inference.reasons.length; i++)
			{
				var reason:ArgumentPanel = inference.reasons[i];
				reason.input1.forwardList.splice(0,reason.input1.forwardList.length);
				for(var m:int=0; m < reason.inputs.length; m++)
				{
					dta = reason.inputs[m];
					dta.forwardList.splice(0, dta.forwardList.length);
				}
			}
			var claim:ArgumentPanel = inference.claim;
			dta = claim.input1;
			claim.input1.forwardList.splice(0,claim.input1.forwardList.length);
			for(i=0; i<claim.inputs.length; i++)
			{
				dta = claim.inputs[i];
				dta.forwardList.splice(0,dta.forwardList.length);
			}
		}
		
		public function link(dta:DynamicTextArea, box:DynamicTextArea):void
		{
			for(var i:int=0; i < dta.forwardList.length; i++)
			{
				if(dta.forwardList[i] == box)
					return;
			}
			dta.forwardList.push(box);
		}
		*/
		
		public function addInitialReasons():void{};
		
		public function createLinks():void
		{
			/*
			var	claim:ArgumentPanel = inference.claim;
			var reasons:Vector.<ArgumentPanel> = inference.reasons;
			//claim.input1.forwardList.push(inference.input[0]);
			inference.input[0].forwardList.push(inference.inputs[0]);
			for(var i:int=0; i < reasons.length; i++)
			{
			//	reasons[i].input1.forwardList.push(inference.input[i+1]);
				inference.input[i+1].forwardList.push(inference.inputs[1]);
			}
			*/
			//inference.implies = true;
		}
		//inference.implies = true;
		public function correctUsage():String { return "";}
	}
}