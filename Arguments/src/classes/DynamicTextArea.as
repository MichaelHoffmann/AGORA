/*
@Version: 0.1
/*
This class is derived from the TextArea component to provide text boxes that resize automatically on user input, without displaying scrollbars, or hiding text.
*/
package classes
{
	import flash.events.Event;
	import flash.events.TextEvent;
	import logic.ParentArg;
	import mx.controls.Alert;
	import mx.controls.TextArea;
	import mx.core.mx_internal;
	import mx.utils.NameUtil;
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	public class DynamicTextArea extends TextArea
	{
		public static var count:int;
		private var topPadding:int;
		private var bottomPadding:int;
		private var h:int;
		public var index:int;
		private var modified:Boolean;
		private var _text:String;
		public var aid:int;
		public var ID:int;
		public var TID:int;
		public var hasID:Boolean;
		public var forwardList:Vector.<DynamicTextArea>;
		public var backwardList:Vector.<DynamicTextArea>;
		public var panelReference:ArgumentPanel;
		
		public function DynamicTextArea()
		{
			super();
			modified=false;
			super.horizontalScrollPolicy = "off";
			super.verticalScrollPolicy = "off";
			this.addEventListener(Event.CHANGE,adjustHeightHandler);
			forwardList = new Vector.<DynamicTextArea>(0,false);
			backwardList = new Vector.<DynamicTextArea>(0,false);
			minHeight = 20;
			hasID = false;
		}
		
		private function adjustHeightHandler(event:Event):void
		{
			dispatchEvent(new UpdateEvent(UpdateEvent.UPDATE_EVENT));
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function forceUpdate():void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		override public function set text(value:String):void
		{
			super.text = value;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		
		public function update():void{
			var s:String;
			var infPanel:Inference = Inference(panelReference);
			this.text = infPanel.displayStr;
		}
		
		public function backwardUpdate():void
		{
			for(var i:int = 0; i < backwardList.length; i++)
			{
				var currInput:DynamicTextArea = backwardList[i];
				currInput.text = this.text;
				currInput.backwardUpdate();
			}
		}
		
		/*
		Not bothering with adding padding parameters in the below function, since I make the assumption that HTML text is almost never inside the text area that I use
		*/
		
		override public function set htmlText(value:String):void{
			textField.htmlText = value;
			validateNow();
			height = textField.textHeight;
			validateNow();
		}
		
		/*
		override public function get text():String{
			return textField.text;
		}
		*/
		override public function get htmlText():String{
			return textField.htmlText;
		}
		override public function set maxHeight(value:Number):void{
			super.maxHeight = value;
		}
		override public function set minHeight(value:Number):void{
			super.minHeight = value;
		}
		override public function toString():String{
			return NameUtil.displayObjectToString(this);
		}
		
		override protected function measure():void{
			super.measure();
			var lineHeight:uint = 10;
			this.measuredMinHeight = 100;
			for(var i:int = 0; i < this.mx_internal::getTextField().numLines; i++)
			{
				lineHeight = lineHeight + this.mx_internal::getTextField().getLineMetrics(i).height;
			}
			this.measuredHeight = lineHeight;
			this.verticalScrollPolicy = "off";
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();	
		}
	}
}