package Controller.logic
{
	import Model.AGORAModel;
	
	import ValueObjects.AGORAParameters;
	
	import flash.utils.Dictionary;

	public class LogicFetcher
	{
		
		private static var instance:LogicFetcher;
		public var logicHash:Dictionary;
		
		public function LogicFetcher()
		{
			logicHash = new Dictionary;
			
			logicHash[AGORAParameters.getInstance().MOD_PON] = ModusPonens.getInstance();
			logicHash[AGORAParameters.getInstance().MPIfThen] = ModusPonens.getInstance();
			logicHash[AGORAParameters.getInstance().MPimplies]  = ModusPonens.getInstance();
			logicHash[AGORAParameters.getInstance().MPnecessary] = ModusPonens.getInstance();
			logicHash[AGORAParameters.getInstance().MPonlyif] = ModusPonens.getInstance();
			logicHash[AGORAParameters.getInstance().MPsufficient] = ModusPonens.getInstance();
			logicHash[AGORAParameters.getInstance().MPwhenever] = ModusPonens.getInstance();
			
			//Modus Tollens
			logicHash[AGORAParameters.getInstance().MOD_TOL] = ModusTollens.getInstance();
			logicHash[AGORAParameters.getInstance().MTifthen] = ModusTollens.getInstance();
			logicHash[AGORAParameters.getInstance().MTimplies] = ModusTollens.getInstance();
			logicHash[AGORAParameters.getInstance().MTnecessary] = ModusTollens.getInstance();
			logicHash[AGORAParameters.getInstance().MTonlyif] = ModusTollens.getInstance();
			logicHash[AGORAParameters.getInstance().MTonlyiffor] = ModusTollens.getInstance();
			logicHash[AGORAParameters.getInstance().MTsufficient] = ModusTollens.getInstance();
			logicHash[AGORAParameters.getInstance().MTwhenever] = ModusTollens.getInstance();
			
			//Disjunctive Syllogism
			logicHash[AGORAParameters.getInstance().DIS_SYLL] = DisjunctiveSyllogism.getInstance();
			logicHash[AGORAParameters.getInstance().DisjSyl] = DisjunctiveSyllogism.getInstance();
			
			//Equivalence
			logicHash[AGORAParameters.getInstance().EQ] = Equivalence.getInstance();
			logicHash[AGORAParameters.getInstance().EQiff] = Equivalence.getInstance();
			logicHash[AGORAParameters.getInstance().EQnecsuf] = Equivalence.getInstance();
			
			//Not-All Syllogism
			logicHash[AGORAParameters.getInstance().NOT_ALL_SYLL] = NotAllSyllogism.getInstance();
			logicHash[AGORAParameters.getInstance().NotAllSyll] = NotAllSyllogism.getInstance();
			
			//Conditional Syllogism
			logicHash[AGORAParameters.getInstance().COND_SYLL] = ConditionalSyllogism.getInstance();
			logicHash[AGORAParameters.getInstance().CSifthen] = ConditionalSyllogism.getInstance();
			logicHash[AGORAParameters.getInstance().CSimplies] = ConditionalSyllogism.getInstance();
			
			//Constructive Dilemma
			logicHash[AGORAParameters.getInstance().CONST_DILEM] = ConstructiveDilemma.getInstance();
			logicHash[AGORAParameters.getInstance().CDaltclaim] = ConstructiveDilemma.getInstance();
			logicHash[AGORAParameters.getInstance().CDpropclaim] = ConstructiveDilemma.getInstance();

		}
		
		public static function getInstance():LogicFetcher{
			if(instance == null){
				instance = new LogicFetcher;
			}
			return instance;
		}
		
		
	}
}