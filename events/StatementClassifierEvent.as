// ActionScript file
package events{
	
	import flash.events.Event;
	
	public class StatementClassifierEvent extends Event
	{
		//public var statement:String;
		public var statementType:int;
		public var claimIndex:int;
		public var reasonIndex:int;
		public function StatementClassifierEvent(type:String,statementType:int,index:int,reasonIndex:int = 0)
		{
			super(type);
			this.statementType = statementType;
			this.claimIndex = index;
			this.reasonIndex = reasonIndex;
		}
	}
		
}