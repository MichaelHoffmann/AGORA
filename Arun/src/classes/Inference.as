package classes
{
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Label;
	import mx.events.FlexEvent;

	public class Inference extends ArgumentPanel
	{
		public var input:Vector.<DynamicTextArea>;
		public var argumentClass:String;
		public var argType:String;
		public var aLType:Label;
		public static const MODUS_PONENS:String = "modus_ponens";
		public function Inference()
		{
			super();
			panelType = ArgumentPanel.INFERENCE;
			addEventListener(FlexEvent.CREATION_COMPLETE, displayArgumentType);
			input = new Vector.<DynamicTextArea>(0,false);
		}
		private function displayArgumentType(e: FlexEvent) : void
		{
			aLType = new Label();
			aLType.text=argumentClass;
			parentMap.addElement(aLType);
		}
		
		override public function getString():String
		{
			var s:String;
			for(var i:int = 0; i < input.length; i++)
			{
				s = s + input[i].text;
			}
			return s;
		}
		
		public function formClaim ():void
		{
			
		}
	}
}