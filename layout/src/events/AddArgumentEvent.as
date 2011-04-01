package events
{
	import flash.events.Event;
	
	public class AddArgumentEvent extends Event
	{
		public function AddArgumentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}