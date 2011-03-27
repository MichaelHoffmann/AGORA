package classes
{
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Label;
	import mx.events.FlexEvent;

	public class Inference extends ArgumentPanel
	{
		public var argumentClass:String;
		public var aLType:Label;
		
		public static const MODUS_PONENS:String = "modus_ponens";
		public function Inference()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, displayArgumentType);
		}
		private function displayArgumentType(e: FlexEvent) : void
		{
			aLType = new Label();
			aLType.text=argumentClass;
			parentMap.addElement(aLType);
			BindingUtils.bindProperty(input1,"text",claim.input1,"text");
		}
	}
}