/*
@Version: 0.1
/*
This class is derived from the TextArea component to provide text boxes that resize automatically on user input, without displaying scrollbars, or hiding text.
*/
package components
{
	import Controller.TextController;
	
	import Model.SimpleStatementModel;
	
	import com.adobe.utils.StringUtil;
	
	import flash.events.Event;
	import flash.ui.Keyboard;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.controls.TextArea;
	import mx.core.mx_internal;
	
	//import org.osmf.layout.AbsoluteLayoutFacet;
	
	public class DynamicTextArea extends TextArea
	{
		private var _model:SimpleStatementModel;
		private var topPadding:int;
		private var bottomPadding:int;
		private var h:int;
		public var index:int;
		private var modified:Boolean;
		
		public function DynamicTextArea()
		{
			super();
			modified=false;
			super.horizontalScrollPolicy = "off";
			super.verticalScrollPolicy = "off";
		}
		
		public function get model():SimpleStatementModel
		{
			return _model;
		}

		public function set model(value:SimpleStatementModel):void
		{
			_model = value;
			//Bind values
			BindingUtils.bindProperty(this, "text", model, ["text"]);
			//set event Listeners
			addEventListener(Event.CHANGE, update);
		}
		
		override public function set text(value:String):void{
			if(value != null){
				//For Windows and Linux
				if(value.charAt(value.length - 1) == '\n'){
					value = value.substr(0,value.length - 1);
				}
				//For Mac and Windows(\r\n)
				if(value.charAt(value.length - 1) == '\r'){
					value = value.substr(0,value.length - 1);
				}
				super.text = value;
			}else{
				super.text = value;
			}
			dispatchEvent(new Event(Event.CHANGE));
			invalidateSize();
			invalidateDisplayList();
		}
		
		protected function update(event:Event):void{
			TextController.getInstance().updateModelText(this);
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