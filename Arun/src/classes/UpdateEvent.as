package classes
{
	import flash.events.Event;
	
	public class UpdateEvent extends Event
	{
		public static const UPDATE_EVENT:String = "update_event";
		public function UpdateEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		public override function clone():Event
		{
			return new UpdateEvent(type, bubbles, cancelable);
		}
	}
}