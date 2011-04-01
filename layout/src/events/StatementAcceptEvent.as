/*

@Author: Karthik Rangarajan
@Version: 0

@Description: This is a custom event that holds the statement that is a result of user entering a claim, reason, or inference. The custom event can basically be used by anything that wants to return a statement to the main application
*/
package events
{
	import flash.events.Event;

	public class StatementAcceptEvent extends Event
	{
		public var statement:String;
		public var claimIndex:int;
		public var reasonIndex:int;
		public function StatementAcceptEvent(type:String,statement:String,index:int,reasonIndex:int = 0)
		{
			super(type);
			this.statement = statement;
			this.claimIndex = index;
			this.reasonIndex = reasonIndex;
		}
		
		override public function clone():Event{
			return new StatementAcceptEvent(type,statement,claimIndex,reasonIndex);
		}
		
	}
}