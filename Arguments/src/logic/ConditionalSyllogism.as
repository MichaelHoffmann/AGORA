package logic
{
	import mx.utils.ObjectUtil;
	
	public class ConditionalSyllogism
	{
		public static var myname:String = "Conditional Syllogism";
		public var _langTypes:Array;
		
		public function ConditionalSyllogism()
		{
			_langTypes = ["ifThen","implies","whenever","onlyIf","providedThat","sufficientCondition","necessaryCondition"];
		}
	}
}