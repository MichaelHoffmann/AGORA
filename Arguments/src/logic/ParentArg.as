package logic
{
	import classes.ArgumentPanel;
	
	import components.ArgSelector;
	
	import mx.utils.ObjectUtil;


	public class ParentArg {
		
	public var myname:String;
	//In the backend, each of the classes is referred by another name. For example, Modus Ponens is referred to as therefore.
	//Ideally, they could be the same, but the server and client were developed parallelly and then integrated.
	public var dbName:String;
	public var _langTypes:Array;
	public var multipleReasons:Boolean;
	public var _expLangTypes:Array;
	public static var MOD_PON:String = "Modus Ponens";
	public static var MOD_TOL:String = "Modus Tollens";
	public static var COND_SYLL:String = "Conditional Syllogism";
	public static var DIS_SYLL:String = "Disjunctive Syllogism";
	public static var NOT_ALL_SYLL:String = "Not-All Syllogism";
	public static var CONST_DILEM:String = "Constructive Dilemma";
	public static var EXP_AND:String = "and";
	public static var EXP_OR:String = "or";
	
	public var mySelector:ArgSelector;	// reference to be moved from Inference to here - specific argscheme
	
	public function ParentArg()
	{
		multipleReasons = true;
		mySelector = new ArgSelector;
	}	
	
	public function correctUsage(index:int,claim: ArgumentPanel,reason:Vector.<ArgumentPanel>,exp:Boolean):String { return "";}
	}
}