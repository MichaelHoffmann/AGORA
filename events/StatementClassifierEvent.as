/*

@Author: Karthik Rangarajan
@Version: 0

@Description: This is a custom event that holds the is fired whenever the user changes his statement from universal to particular or viceversa
*/

package events
{
	import flash.events.Event;

	public class StatementClassifierEvent extends Event
	{
		public var statementType:int;
		public var claimIndex:int;
		public var reasonIndex:int;
		public function StatementClassifierEvent(type:String,statementType:int,claimIndex:int,reasonIndex:int=0)
		{
			super(type);
			this.statementType = statementType;
			this.claimIndex = claimIndex;
			this.reasonIndex = reasonIndex;
		}
		
		override public function clone():Event{
			return new StatementClassifierEvent(type,statementType,claimIndex,reasonIndex);
		}
		
	}
}