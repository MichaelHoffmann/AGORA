/*

@Author: Karthik Rangarajan
@Version: 0

@Description: This is a custom event that holds the statement that is a result of user entering a claim, reason, or inference. The custom event can basically be used by anything that wants to return a statement to the main application
*/
package events
{
	import flash.events.Event;

	public class SchemeChangeEvent extends Event
	{
		public var claimIndex:int;
		public function SchemeChangeEvent(type:String,claimIndex:int)
		{
			super(type);
			this.claimIndex = claimIndex;
		}
		
		override public function clone():Event{
			return new SchemeChangeEvent(type,claimIndex);
		}
		
	}
}