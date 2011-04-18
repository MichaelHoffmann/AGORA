package logic
{
	import mx.utils.ObjectUtil;
	
	public class ModusPonens
	{
		public static var myname:String = "Modus Ponens";
		public var _langTypes:Array;
		
		public function ModusPonens()
		{
			_langTypes = ["ifThen","implies","whenever","onlyIf","providedThat","sufficientCondition","necessaryCondition"];
		}
	}
}