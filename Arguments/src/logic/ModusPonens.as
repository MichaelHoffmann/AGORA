package logic
{
	import mx.utils.ObjectUtil;
	
	public class ModusPonens
	{
		public static var myname:String = "Modus Ponens";
		public static var _langTypes:Array;
		
		public function ModusPonens()
		{
			_langTypes = ["If-then","Implies","Whenever","Only-if","Provided-that","Sufficient-condition","Necessary-condition","If-and-only-if",
			"Necessary-and-sufficient-condition","Equivalent"];
		}
	}
}