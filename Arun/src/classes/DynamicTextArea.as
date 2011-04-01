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
	
	import mx.controls.Alert;
	import mx.controls.TextArea;
	import mx.utils.NameUtil;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	
	public class DynamicTextArea extends TextArea
	{
		private var topPadding:int;
		private var bottomPadding:int;
		private var h:int;
		public var index:int;
		
		public var forwardList:Vector.<DynamicTextArea>; //Arun Kumar chithanar
		public var backwardList:Vector.<DynamicTextArea>;
		
		
		public var panelReference:ArgumentPanel;
		
		public function DynamicTextArea()
		{
			
			super();
			super.horizontalScrollPolicy = "off";
			super.verticalScrollPolicy = "off";
			this.addEventListener(Event.CHANGE,adjustHeightHandler);
			forwardList = new Vector.<DynamicTextArea>(0,false);
			backwardList = new Vector.<DynamicTextArea>(0,false);
			minHeight = 20;
		}
		private function adjustHeightHandler(event:Event):void {
			
			//Arun Kumar chithanar
			updateOthers();
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
			/*
			Same comment above the padding in the previous function applies here as well
			*/
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
			if(this.visible == false && this.panelReference.panelType == ArgumentPanel.INFERENCE)
			{
					
						currInput= forwardList[0];
						//update the string
					
							var infPanel:Inference = Inference(panelReference);
							var s:String = "If ";
							//trace(infPanel.input.length);
							for(var ind:int = 1; ind < infPanel.input.length - 1; ind++)
							{
								s = s + infPanel.input[ind].text + " and ";	
								//trace(infPanel.input[ind]);
							}
							s = s + infPanel.input[ind].text;
							s = s + ", " + infPanel.input[0].text + ".";
							
							currInput.text = s;
							
							currInput.forwardUpdate();
						
				
			}else
			{
				
				if(forwardList.length == 0 )
					return;
					currInput = forwardList[0];
					currInput.text = text;
					//trace(currInput);
					currInput.forwardUpdate();				
			}
				
			
			
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