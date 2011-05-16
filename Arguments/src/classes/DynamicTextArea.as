/*

@Author: Karthik Rangarajan
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
	import mx.utils.NameUtil;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	
	public class DynamicTextArea extends TextArea
	{
		
		public static var count:int;
		
		private var topPadding:int;
		private var bottomPadding:int;
		private var h:int;
		public var index:int;
		
		public var aid:int;
		
		public var forwardList:Vector.<DynamicTextArea>; //Arun Kumar chithanar
		public var backwardList:Vector.<DynamicTextArea>;
		
		
		public var panelReference:ArgumentPanel;
		
		public function DynamicTextArea()
		{
			super();
			aid = count;
			count = count + 1;
			super.horizontalScrollPolicy = "off";
			super.verticalScrollPolicy = "off";
			this.addEventListener(Event.CHANGE,adjustHeightHandler);
			forwardList = new Vector.<DynamicTextArea>(0,false);
			backwardList = new Vector.<DynamicTextArea>(0,false);
			minHeight = 20;
		}
		private function adjustHeightHandler(event:Event):void {
			//Arun Kumar chithanar
			
			dispatchEvent(new UpdateEvent(UpdateEvent.UPDATE_EVENT));
			var paddingTop:String = this.getStyle("paddingTop");
			var paddingBottom:String= this.getStyle("paddingBottom");
			topPadding= int(paddingTop);
			bottomPadding= int(paddingBottom);
			/*
			The padding parameters are required, because text is hidden because of the padding, inspite of the text area being large enough to accomodate the entire text
			*/		
			if(height <= textField.textHeight + textField.getLineMetrics(0).height + topPadding + bottomPadding){
				h = topPadding+bottomPadding+textField.textHeight;
				height = h;
				validateNow();
			}
			if(height >= textField.textHeight + textField.getLineMetrics(0).height+topPadding+bottomPadding){
				if(height>super.minHeight){
					h = topPadding+bottomPadding+textField.textHeight;
					height = h;
				}	
				validateNow();
			}
			updateOthers();
		}
		
		public function forceUpdate():void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		override public function set text(value:String):void{
			textField.text = value;
			validateNow();
			var paddingTop:String = this.getStyle("paddingTop");
			var paddingBottom:String= this.getStyle("paddingBottom");
			topPadding= int(paddingTop);
			bottomPadding= int(paddingBottom);
			if((textField.textHeight + topPadding + bottomPadding)>=super.minHeight){
				height = textField.textHeight+topPadding+bottomPadding;
			}
			validateNow();
		}
		
		public function updateOthers():void
		{
			forwardUpdate();
		}
		
		public function forwardUpdate():void
		{
			var currInput:DynamicTextArea;
			//var flag:int = 0;
			if(this.visible == false && this.panelReference.panelType == ArgumentPanel.INFERENCE && this != panelReference.input1)
			{
				if(forwardList.length>0){
					currInput= forwardList[0];
					var infPanel:Inference = Inference(panelReference);
					var s:String;
					if(infPanel.argType.schemeText!=null) { 
			//			flag=1;
						infPanel.displayStr = infPanel.myArg.correctUsage(infPanel.argType.schemeTextIndex,infPanel.claim.input1.text,infPanel.reasons,infPanel.isExp);
						//trace(sentence);
						//this.panelReference.input1.text = sentence;
					}
					//else visible=false;
					//s = infPanel.sentence;
					//currInput.text = s; 
					currInput.forwardUpdate();
				}
				else
				{
					Alert.show(this);
					Alert.show(forwardList.length);
					Alert.show("Someting went wrong in statement propagation");
				}
				
			}else
			{
				if(forwardList.length == 0 )
					return;
				for(var i:int = 0; i < forwardList.length; i++){
					currInput = forwardList[i];
					currInput.text = text;
					currInput.forwardUpdate();
				}
			}
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
		override public function set height(value:Number):void{
			if(textField == null){
				if(height <= value){
					super.height = value;
				}
			}
			else{
				var paddingTop:String = this.getStyle("paddingTop");
				var paddingBottom:String= this.getStyle("paddingBottom");
				topPadding= int(paddingTop);
				bottomPadding= int(paddingBottom);
				h = topPadding+bottomPadding+textField.textHeight+textField.getLineMetrics(0).height;
				var currentHeight:uint = h;
				if(currentHeight <= super.maxHeight){
					if(textField.textHeight!= textField.getLineMetrics(0).height){
						super.height = currentHeight;
					}
				}
				else{
					super.height = super.maxHeight;
				}
			}
		}
		override public function get text():String{
			return textField.text;
		}
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
	}
}