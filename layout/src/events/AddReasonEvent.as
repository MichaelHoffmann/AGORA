package events
{	
	import flash.display.Shape;
	import flash.events.Event;
	import mx.controls.Alert;
	
	
	public class AddReasonEvent extends Event
	{
		public var myshape:Shape;
		
		public function AddReasonEvent(type:String)
		{
			super(type);
			Alert.show('inside AddReasonEvent.as');
			
		}
		
		override public function clone():Event
		{
			return new AddReasonEvent(type);
		}
	}
}