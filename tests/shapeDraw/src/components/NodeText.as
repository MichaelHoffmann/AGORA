package components
{	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class NodeText extends Sprite
	{
		public var nodeTextFormat:TextFormat=new TextFormat("Georgia", 14); //the font format inside nodes
		
		public function NodeText(text:String,padding:Number,width:Number)
		{
			var textField:TextField = new TextField();
			textField.text = text;
			textField.width = width-(2*padding);
			textField.x = textField.y = padding;
			textField.autoSize = 'left';
			textField.multiline = true;
			textField.wordWrap = true;
			textField.selectable = false;
			textField.setTextFormat(nodeTextFormat);
			
			this.addChild(textField);
		}
	}
}