package classes
{
	import flash.events.TextEvent;
	
	import mx.controls.Text;

	public class Binder
	{
		private var input:DynamicTextArea;
		private var output:DynamicTextArea;
		public function Binder(arg1:DynamicTextArea, arg2:DynamicTextArea )
		{
			input=arg1;
			output=arg2;
			input.addEventListener(TextEvent.TEXT_INPUT, updateTextOutput);
			output.addEventListener(TextEvent.TEXT_INPUT,updateTextInput);
		}
		private function updateTextOutput(event:TextEvent):void
		{
			output.text = input.text;
		}
		private function updateTextInput(event:TextEvent):void
		{
			input.text = output.text;
		}
	}
}