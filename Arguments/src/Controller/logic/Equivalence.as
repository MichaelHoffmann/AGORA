package Controller.logic
{
	public class Equivalence extends ParentArg
	{
		private static var instance:Equivalence;
		
		public function Equivalence()
		{
			super();
		}
		
		public static function getInstance():Equivalence{
			if(instance == null){
				instance = new Equivalence;
			}
			return instance;
		}
	}
}