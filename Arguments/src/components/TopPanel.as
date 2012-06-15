package components
{
	import Controller.AGORAController;
	
	import Model.AGORAModel;
	
	import ValueObjects.AGORAParameters;
	
	import classes.Language;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import spark.components.Label;
	import spark.components.TextArea;
	
	public class TopPanel extends UIComponent
	{
		public var gotoMenuBtn:Button;
		public var saveAsBtn:Button;
		public var print:Button;
		public var _unhideRSP:Button;
		public var _publishMapButton:Button;
		
		
		private var agoraConstants:AGORAParameters;
		private var background:Sprite;
		
		public function TopPanel()
		{
			super();
			agoraConstants = AGORAParameters.getInstance();
		}
		
		override protected function createChildren():void{
			super.createChildren();
			
			if(!background){
				background = new Sprite;
				addChild(background);
			}
			
			if(!gotoMenuBtn){
				gotoMenuBtn = new Button;
				BindingUtils.bindProperty(gotoMenuBtn, 'label', agoraConstants,'SAVE_AND_HOME');
				gotoMenuBtn.addEventListener(MouseEvent.CLICK, discardChanges);
				addChild(gotoMenuBtn);
			}
			
			if(!saveAsBtn){
				saveAsBtn = new Button;
				BindingUtils.bindProperty(saveAsBtn, 'label', agoraConstants, 'SAVE_AS');
				BindingUtils.bindProperty(saveAsBtn,  'toolTip', agoraConstants, 'SUPPORT_SAVEAS');
				addChild(saveAsBtn);
			}
			
			if(!_publishMapButton){
				_publishMapButton = new Button;
				_publishMapButton.label = Language.lookup("PublishMap");
				_publishMapButton.addEventListener(MouseEvent.CLICK, onPublishMap); 
				addChild(_publishMapButton);
			}
			
			if(!print){
				print = new Button;
				print.label = Language.lookup("PrintMap");
				print.addEventListener(MouseEvent.CLICK, onPrint);
				addChild(print);
			}
			
			if(!_unhideRSP){
				_unhideRSP = new Button;
				_unhideRSP.label = Language.lookup("UnhidePanel");
				_unhideRSP.addEventListener(MouseEvent.CLICK, unhideButton_ClickHandler);
				addChild(_unhideRSP);
			}
		} 
		
		override protected function commitProperties():void{
			super.commitProperties();
		}
		
		override protected function measure():void{
			super.measure();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			var xB:int = 15;
			background.graphics.clear();
			background.graphics.beginFill(0xF7F7F7);
			background.graphics.drawRect(0,0, this.getExplicitOrMeasuredWidth(), 40);
			background.graphics.endFill();
			gotoMenuBtn.setActualSize(gotoMenuBtn.getExplicitOrMeasuredWidth(), 30);
			gotoMenuBtn.move(xB,5);
			xB = xB + gotoMenuBtn.getExplicitOrMeasuredWidth() + 15;
			saveAsBtn.setActualSize(saveAsBtn.getExplicitOrMeasuredWidth(), 30);
			saveAsBtn.move(xB, 5);
			xB = xB + saveAsBtn.getExplicitOrMeasuredWidth() + 15;
			print.setActualSize(print.getExplicitOrMeasuredWidth(), 30);
			print.move(xB, 5);
			xB = xB + print.getExplicitOrMeasuredWidth() + 15;
			_publishMapButton.setActualSize(_publishMapButton.getExplicitOrMeasuredWidth(), 30);
			_publishMapButton.move(xB,5);
			xB = xB + _publishMapButton.getExplicitOrMeasuredWidth() + 15;
			_unhideRSP.setActualSize(_unhideRSP.getExplicitOrMeasuredWidth(),30);
			_unhideRSP.move(this.width - _unhideRSP.width, 5);
			
		}
		
		//------------------------Event Handlers----------------------//
		protected function discardChanges(event:MouseEvent):void{
			AGORAController.getInstance().hideMap();
		}
		
		protected function onPublishMap(event:MouseEvent):void{
			FlexGlobals.topLevelApplication.publishMap = new PublishMapPopUpPanel;
			AGORAModel.getInstance().publishMapModel.sendForTopLevel();
			PopUpManager.addPopUp(FlexGlobals.topLevelApplication.publishMap, DisplayObject(this),true);
			PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.publishMap);
			
		}
		
		protected function onPrint(event:MouseEvent):void{
			AGORAController.getInstance().printMap();
		}
		
		protected function onAddToProject(event:MouseEvent):void{
			FlexGlobals.topLevelApplication.move_map = new MapToProject;
			PopUpManager.addPopUp(FlexGlobals.topLevelApplication.move_map, DisplayObject(FlexGlobals.topLevelApplication),true);
			PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.move_map);
		}
		
		protected function unhideButton_ClickHandler(event:MouseEvent):void{
			FlexGlobals.topLevelApplication.rightSidePanel.visible = true;
		}
	}
}