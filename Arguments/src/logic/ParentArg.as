package logic
{
	import classes.ArgumentPanel;
	import classes.Inference;
	
	import components.ArgSelector;
	
	import mx.utils.ObjectUtil;


	public class ParentArg {
		
	private var _isLanguageExp:Boolean;
	public var myname:String;
	//This is set by the Inference that creates it.
	//Each object of ParentArg belongs only to 
	//one Inference, and it holds a reference to the Inference object.
	public var inference:Inference;
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
	
	public function get isLanguageExp():Boolean
	{
		return _isLanguageExp;
	}
	public function set isLanguageExp(value:Boolean):void
	{
		_isLanguageExp = value;
	}
	
	public var mySelector:ArgSelector;	// reference to be moved from Inference to here - specific argscheme
	
	public function ParentArg()
	{
		
	}
	
	public function createLinks():void
	{
		var	claim:ArgumentPanel = inference.claim;
		var reasons:Vector.<ArgumentPanel> = inference.reasons;
		claim.input1.forwardList.push(inference.input[0]);
		inference.input[0].forwardList.push(inference.inputs[0]);
		for(var i:int=0; i < reasons.length; i++)
		{
			reasons[i].input1.forwardList.push(inference.input[i+1]);
			inference.input[i+1].forwardList.push(inference.inputs[1]);
		}
		inference.implies = true;
	}
	public function correctUsage():String { return "";}
	}
	
}