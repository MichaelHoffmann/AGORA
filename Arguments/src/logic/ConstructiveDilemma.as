package logic
{
	import mx.utils.ObjectUtil;
	
	public class ConstructiveDilemma
	{
		public static var myname:String = "Constructive Dilemma";
		public var _langTypes:Array;
		
		public function ConstructiveDilemma()
		{
			_langTypes = ["ifThen","implies","whenever","onlyIf","providedThat","sufficientCondition","necessaryCondition"];
		}
	}
}