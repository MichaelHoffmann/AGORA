package Controller.logic
{
	import flash.utils.Dictionary;

	public class LogicFetcher
	{
		
		private static var instance:LogicFetcher;
		public var logicHash:Dictionary;
		
		public function LogicFetcher()
		{
			logicHash = new Dictionary;
			
			logicHash[ParentArg.MOD_PON] = ModusPonens.getInstance();
			logicHash[ParentArg.MPIfThen] = ModusPonens.getInstance();
			logicHash[ParentArg.MPimplies]  = ModusPonens.getInstance();
			logicHash[ParentArg.MPnecessary] = ModusPonens.getInstance();
			logicHash[ParentArg.MPonlyif] = ModusPonens.getInstance();
			logicHash[ParentArg.MPsufficient] = ModusPonens.getInstance();
			logicHash[ParentArg.MPwhenever] = ModusPonens.getInstance();
			
			//Modus Tollens
			logicHash[ParentArg.MOD_TOL] = ModusTollens.getInstance();
			logicHash[ParentArg.MTifthen] = ModusTollens.getInstance();
			logicHash[ParentArg.MTimplies] = ModusTollens.getInstance();
			logicHash[ParentArg.MTnecessary] = ModusTollens.getInstance();
			logicHash[ParentArg.MTonlyif] = ModusTollens.getInstance();
			logicHash[ParentArg.MTonlyiffor] = ModusTollens.getInstance();
			logicHash[ParentArg.MTsufficient] = ModusTollens.getInstance();
			logicHash[ParentArg.MTwhenever] = ModusTollens.getInstance();
			
			//Disjunctive Syllogism
			logicHash[ParentArg.DIS_SYLL] = DisjunctiveSyllogism.getInstance();
			logicHash[ParentArg.DisjSyl] = DisjunctiveSyllogism.getInstance();
			
			//Equivalence
			logicHash[ParentArg.EQ] = Equivalence.getInstance();
			logicHash[ParentArg.EQiff] = Equivalence.getInstance();
			logicHash[ParentArg.EQnecsuf] = Equivalence.getInstance();
			
			//Not-All Syllogism
			logicHash[ParentArg.NOT_ALL_SYLL] = NotAllSyllogism.getInstance();
			logicHash[ParentArg.NotAllSyll] = NotAllSyllogism.getInstance();
			
			//Conditional Syllogism
			logicHash[ParentArg.COND_SYLL] = ConditionalSyllogism.getInstance();
			logicHash[ParentArg.CSifthen] = ConditionalSyllogism.getInstance();
			logicHash[ParentArg.CSimplies] = ConditionalSyllogism.getInstance();
			
			//Constructive Dilemma
			logicHash[ParentArg.CONST_DILEM] = ConstructiveDilemma.getInstance();
			logicHash[ParentArg.CDaltclaim] = ConstructiveDilemma.getInstance();
			logicHash[ParentArg.CDpropclaim] = ConstructiveDilemma.getInstance();

		}
		
		public static function getInstance():LogicFetcher{
			if(instance == null){
				instance = new LogicFetcher;
			}
			return instance;
		}
		
		
	}
}