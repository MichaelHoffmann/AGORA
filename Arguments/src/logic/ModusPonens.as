package logic
{	
	import components.ArgSelector;

	public class ModusPonens extends ParentArg
	{
		public function ModusPonens()
		{
			myname = MOD_PON;
			_langTypes = ["If-then","Implies","Whenever","Only-if","Provided-that","Sufficient-condition","Necessary-condition","If-and-only-if",
			"Necessary-and-sufficient-condition","Equivalent"];
		}
		
		
	}
}