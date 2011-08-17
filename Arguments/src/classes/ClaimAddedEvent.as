package classes
{
	import flash.events.Event;
	import components.ArgumentPanel;
	
	public class ClaimAddedEvent extends Event
	{
		public var argumentPanel:ArgumentPanel;
		public static const CLAIM_ADDED:String = "claim added";
		public function ClaimAddedEvent(type:String,  aP:ArgumentPanel, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.argumentPanel = aP;
		}
		override public function clone():Event{
			return new ClaimAddedEvent(type,argumentPanel,bubbles,cancelable);
		}
	}
}