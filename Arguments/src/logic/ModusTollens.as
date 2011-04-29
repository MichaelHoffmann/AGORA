package logic
{
	
	public class ModusTollens extends ParentArg
	{
		public function ModusTollens()
		{
			myname = MOD_TOL;
			//_langTypes = ["If-then","Implies","Whenever","Only-if","Only-if-Exp-And","Only-if-Exp-Or","Provided-that","Sufficient-condition","Necessary-condition"];
			_langTypes = ["If-then","Implies","Whenever","Only if","Provided that","Sufficient condition","Necessary condition"];
			_expLangTypes = ["Only if"];	// Expandable with both And and Or

		}
		
		
	}
}