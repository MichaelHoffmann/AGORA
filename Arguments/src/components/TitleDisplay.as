package components
{
	import Controller.UpdateController;
	
	import Model.AGORAModel;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Button;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.core.UIComponent;
	
	public class TitleDisplay extends UIComponent
	{
		[Bindable]
		private var _title:String;
		private var _textField:TextArea;
		private var _textDisplay:Text;
		private var _stateChangedF:Boolean;
		private var _state:String;
		private var _doneBtn:Button;
		
		public static var EDIT:String = "edit";
		public static var DISPLAY:String = "display";
		
		
		
		public function TitleDisplay()
		{
			super();
			percentWidth = 100;
			state = DISPLAY;
			//title = "Title";
			this.addEventListener(MouseEvent.CLICK, toEdit);
			this.addEventListener(KeyboardEvent.KEY_DOWN, onEnter);
		}

		public function get doneBtn():Button
		{
			return _doneBtn;
		}

		public function set doneBtn(value:Button):void
		{
			_doneBtn = value;
		}

		public function get state():String
		{
			return _state;
		}

		public function set state(value:String):void
		{
			_state = value;
			stateChangedF = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}

		public function get stateChangedF():Boolean
		{
			return _stateChangedF;
		}

		public function set stateChangedF(value:Boolean):void
		{
			_stateChangedF = value;
		}

		public function get textDisplay():Text
		{
			return _textDisplay;
		}

		public function set textDisplay(value:Text):void
		{
			_textDisplay = value;
		}

		public function get textField():TextArea
		{
			return _textField;
		}

		public function set textField(value:TextArea):void
		{
			_textField = value;
		}

		[Bindable]
		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}
		
		protected function onDoneClick(event:MouseEvent):void{
			state = DISPLAY;
			UpdateController.getInstance().updateMapInfo(textField.text);
		}
		
		protected function toEdit(event:MouseEvent):void{
			if(event.target != doneBtn){
				textField.text = title;
				textField.selectionBeginIndex = 0;
				textField.selectionEndIndex = textField.text.length;
				state = EDIT;
				//stage.focus = textField;
				focusManager.setFocus(textField);
			}
		}
		protected function onEnter(event:KeyboardEvent):void{
			if(event.keyCode == Keyboard.ENTER){
				textField.text = textField.text.replace("\n","");
				textField.text = textField.text.replace("\r","");
				state = DISPLAY;
				UpdateController.getInstance().updateMapInfo(textField.text);
			}
		}

		override protected function createChildren():void{
			super.createChildren();
			if(!textField){
				textField = new TextArea;
				textField.verticalScrollPolicy = "on";
				textField.height = 30;
				addChild(textField);
			}	
			
			if(!textDisplay){
				textDisplay = new Text;
				textDisplay.height = 30;
				BindingUtils.bindProperty(textDisplay, 'text', this, 'title');
				addChild(textDisplay);
			}
			 
			if(!doneBtn){
				doneBtn = new Button;
				BindingUtils.bindProperty(this.doneBtn,"label", AGORAParameters.getInstance(), [ 'DONE' ]);
				doneBtn.addEventListener(MouseEvent.CLICK, onDoneClick);
				addChild(doneBtn);
			}
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			if(stateChangedF){
				if(state ==	EDIT){
					try{
						removeChild(textDisplay);
					}catch(w:Error){
						trace(w.toString());
					}
					try{
						removeChild(textField);
					}catch(w:Error){
						trace(w.toString());
					}
					try{
						removeChild(doneBtn);
					}catch(w:Error){
						trace(w.toString());
					}
					addChild(textField);
					addChild(doneBtn);
				}else if(state == DISPLAY){
					try{
						removeChild(textDisplay);
					}catch(w:Error){
						trace(w.toString());
					}
					try{
						removeChild(textField);
					}catch(w:Error){
						trace(w.toString());
					}
					try{
						removeChild(doneBtn);
					}catch(w:Error){
						trace(w.toString());
					}
					addChild(textDisplay);
				}
				stateChangedF = false;
			}
		}
		
		override protected function measure():void{
			super.measure();
			measuredMinHeight = 50;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(state == DISPLAY){
				textDisplay.setActualSize(this.width - doneBtn.measuredWidth - 20, 30);
				textDisplay.move(10,10);
			}
			else if(state == EDIT){
				textField.setActualSize(this.width - doneBtn.measuredWidth - 20,30);
				textField.move(10,0);
				doneBtn.move(textField.x + textField.width + 10,0);
				doneBtn.setActualSize(doneBtn.measuredWidth,30);
			}
		}
	}
}