/*

@Author: Karthik Rangarajan
@Version: 0

@Description: This is a custom event that holds the logic type and the language type of the selected argument scheme

*/
package events
{
	import flash.events.Event;
	
	public class SchemeSelectedEvent extends Event
	{
		public var claimIndex:int;
		public var logicType:String;
		public var languageType:String;
		public var languageForm:String;
		public function SchemeSelectedEvent(type:String,logicType:String,languageType:String,languageForm:String='',claimIndex:int = 0)
		{
			super(type);
			this.logicType= logicType;
			this.languageType = languageType;
			this.languageForm = languageForm;
			this.claimIndex = claimIndex;
		}
		
		override public function clone():Event{
			return new SchemeSelectedEvent(type,logicType,languageType,languageForm,claimIndex);
		}
		
	}
}