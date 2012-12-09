package components
{
	import classes.Language;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import mx.controls.Text;
	import mx.core.UIComponent;

	import spark.components.Button;
	import mx.managers.PopUpManager;

	public class InfoBox extends UIComponent
	{
		private var bgSprite:Sprite;
		private var OKButton:Button;
		private var _textBox:TextField;
		private var _boxWidth:int;
		private var _helptext:String;
		private var textChangedDF:Boolean;
		
		public function InfoBox()
		{
			super();
		}

		public function get helptext():String
		{
			return _helptext;
		}

		public function get boxWidth():int
		{
			return _boxWidth;
		}
		public function set boxWidth(value:int):void
		{
			_boxWidth = value;
		}
		public function set text(value:String):void{
			if(value != null){
				_helptext = value;
				textChangedDF = true;
				invalidateProperties();
				invalidateSize();
				invalidateDisplayList();
			}
		}
		
		override protected function createChildren():void{
			super.createChildren();
			bgSprite = new Sprite;
			addChild(bgSprite);
			
			_textBox = new TextField;
			_textBox.x = 10;
			_textBox.y = 20;
			_textBox.width = boxWidth - 30;
			_textBox.multiline = true;
			_textBox.autoSize = TextFieldAutoSize.LEFT;
			_textBox.wordWrap = true;
			addChild(_textBox);
			
			OKButton = new Button;
			//add an event listener
			OKButton.addEventListener(MouseEvent.CLICK, onOKButtonClicked);
			OKButton.label = Language.lookup("OK");
			addChild(OKButton);
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			if(textChangedDF == true){
				textChangedDF = false;
				_textBox.text = _helptext;
			}
		}
		
		override protected function measure():void{
			super.measure();
			//add for padding.
			this.measuredHeight = 20;
			//add for text
			this.measuredHeight += _textBox.textHeight;
			//add for bottom padding
			this.measuredHeight += 20;
			//add for button
			this.measuredHeight += 30;
			//set the width
			this.measuredWidth = boxWidth;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			//draw background
			bgSprite.graphics.clear();
			bgSprite.graphics.beginFill(0xffff00);
			bgSprite.graphics.drawRect(0,0,measuredWidth, measuredHeight);
			bgSprite.graphics.endFill();
			
			//set the height and width of button
			OKButton.setActualSize(OKButton.getExplicitOrMeasuredWidth(), OKButton.getExplicitOrMeasuredHeight());
			
			//move the box
			var buttonposx:int = this.measuredWidth/2 - this.OKButton.width/2;
			var buttonposy:int = this._textBox.y + this._textBox.textHeight + 20;
			OKButton.move(buttonposx,buttonposy);
		}
		
		
		//--------------------- Event Handlers -----------------------------------------//
		protected function onOKButtonClicked(event:MouseEvent):void{
			
			this.visible=false;
		}
	}
}