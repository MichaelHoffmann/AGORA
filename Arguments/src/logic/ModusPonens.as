package logic
{	
	import components.ArgSelector;

	public class ModusPonens extends ParentArg
	{
		public function ModusPonens()
		{
			myname = MOD_PON;
			/*_langTypes = ["If-then","If-then-Exp-And","Implies","Whenever","Whenever-Exp-And","Only-if","Provided-that","Provided-that-Exp-And","Sufficient-condition","Necessary-condition","If-and-only-if",
			"Necessary-and-sufficient-condition","Equivalent"];*/
			_langTypes = ["If-then","If-then-Exp","Implies","Whenever","Whenever-Exp","Only-if","Provided-that","Provided-that-Exp","Sufficient-condition","Necessary-condition","If-and-only-if",
				"Necessary-and-sufficient-condition","Equivalent"];
		}
		
		
	}
}