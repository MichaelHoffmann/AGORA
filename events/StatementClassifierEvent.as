// ActionScript file
package events{
	
	import flash.events.Event;
	/**
	 * Warning: This class was reverse-engineered from the code that uses it.
	 * We do not have the original (at this time).
	 * 
	 * It may not have all the functionality it needs for later code. 
	 * 
	 * @author Joshua Justice
	 */	
	public class StatementClassifierEvent extends Event
	{
		//public var statement:String;
		public var statementType:int; //1 is Particular, 0 is Universial
		public var claimIndex:int;
		public var reasonIndex:int;
		public function StatementClassifierEvent(type:String,statementType:int,claimIndex:int,reasonIndex:int = 0)
		{
			super(type);
			this.statementType = statementType;
			this.claimIndex = claimIndex;
			this.reasonIndex = reasonIndex;
		}
	}
}