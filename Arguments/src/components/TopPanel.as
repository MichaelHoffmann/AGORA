package components
{
	import Controller.AGORAController;
	import Controller.ArgumentController;
	
	import Model.AGORAModel;
	
	import ValueObjects.AGORAParameters;
	
	import classes.Language;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.ControlBar;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Spacer;
	import mx.controls.Text;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.TextArea;
	import spark.components.VGroup;
	
	public class TopPanel extends UIComponent
	{
		public var gotoMenuBtn:Button;
		public var saveAsBtn:Button;
		public var print:Button;
		public var _unhideRSP:Button;
		
		public var _whatYouShouldKnowBeforeYouStartBtn:Button;
		public var _aboutUsBtn:Button;
		public var _faqBtn:Button;
		public var _contactUsBtn:Button;
		public var _helpBtn:Button;
		public var _publishMapHelp:Button;
		
		
		private var agoraConstants:AGORAParameters;
		private var background:Sprite;
		private var hpanel:Panel;

		
		public function TopPanel()
		{
			super();
			publishMapPanel();
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
				BindingUtils.bindProperty(gotoMenuBtn,  'toolTip', agoraConstants, 'SUPPORT_SAVEANDHOME');
				gotoMenuBtn.addEventListener(MouseEvent.CLICK, discardChanges);
				addChild(gotoMenuBtn);
			}
			
			if(!saveAsBtn){
				saveAsBtn = new Button;
				saveAsBtn.visible=true;
				BindingUtils.bindProperty(saveAsBtn, 'label', agoraConstants, 'SAVE_AS');
				BindingUtils.bindProperty(saveAsBtn,  'toolTip', agoraConstants, 'SUPPORT_SAVEAS');
				saveAsBtn.addEventListener(MouseEvent.CLICK, saveMapAs);
				addChild(saveAsBtn);
			}
			
			
			if(!print){
				print = new Button;
				print.label = Language.lookup("PrintMap");
				print.toolTip = Language.lookup("PrintMapHelp");
				print.addEventListener(MouseEvent.CLICK, onPrint);
				addChild(print);
			}
			
			
			
			if(!_whatYouShouldKnowBeforeYouStartBtn){
				_whatYouShouldKnowBeforeYouStartBtn = new Button;
				_whatYouShouldKnowBeforeYouStartBtn.label = Language.lookup("BeforeYouStart");
				_whatYouShouldKnowBeforeYouStartBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					navigateToURL(new URLRequest('http://agora.gatech.edu/?page_id=255'), 'quote');
				}
				);
				addChild(_whatYouShouldKnowBeforeYouStartBtn);
			}
			
			if(!_publishMapHelp){
				_publishMapHelp = new Button;
				_publishMapHelp.label = Language.lookup("PublishMapHelp");
				_publishMapHelp.addEventListener(MouseEvent.CLICK, publishMapTrigger);
				addChild(_publishMapHelp);
			}
			
			if(!_unhideRSP){
				_unhideRSP = new Button;
				_unhideRSP.label = Language.lookup("UnhidePanel");
				_unhideRSP.visible = false;
				_unhideRSP.addEventListener(MouseEvent.CLICK, unhideButton_ClickHandler);
				addChild(_unhideRSP);
			}
			if(!_aboutUsBtn){
				_aboutUsBtn = new Button;
				_aboutUsBtn.id="aboutUsBtn";
				_aboutUsBtn.label=Language.lookup('AboutUs');
				_aboutUsBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
					{
					navigateToURL(new URLRequest('http://agora.gatech.edu/?page_id=6'), 'quote');
					}
				);
				
				addChild(_aboutUsBtn);
			}
			if(!_faqBtn){
				_faqBtn = new Button;
				_faqBtn.id="faqBtn"
				_faqBtn.label=Language.lookup('FAQ');
				_faqBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					navigateToURL(new URLRequest('http://agora.gatech.edu/?page_id=250'), 'quote');
				}
				);
				addChild(_faqBtn);
			}
			if(!_contactUsBtn){
				_contactUsBtn = new Button;
				_contactUsBtn.id="contactUsBtn";
				_contactUsBtn.label=Language.lookup('ContactUS');
				_contactUsBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					navigateToURL(new URLRequest('http://agora.gatech.edu/?page_id=24'), 'quote');
				}
				);
				addChild(_contactUsBtn);
			}
			if(!_helpBtn){
				_helpBtn = new Button;
				_helpBtn.id="helpBtn";
				_helpBtn.label=Language.lookup('Help');
				_helpBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					navigateToURL(new URLRequest('http://agora.gatech.edu/?page_id=240'), 'quote');
				}
				);
				addChild(_helpBtn);
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
			gotoMenuBtn.toolTip=Language.lookup('SaveAndHomeHelp');
			xB = xB + gotoMenuBtn.getExplicitOrMeasuredWidth() + 15;
			saveAsBtn.setActualSize(saveAsBtn.getExplicitOrMeasuredWidth(), 30);
			saveAsBtn.move(xB, 5);
			xB = xB + saveAsBtn.getExplicitOrMeasuredWidth() + 15;
			print.setActualSize(print.getExplicitOrMeasuredWidth(), 30);
			print.move(xB, 5);
			print.toolTip=Language.lookup('PrintMapHelp');

			xB = xB + print.getExplicitOrMeasuredWidth() + 15;
			_whatYouShouldKnowBeforeYouStartBtn.setActualSize(_whatYouShouldKnowBeforeYouStartBtn.getExplicitOrMeasuredWidth(), 30);
			_whatYouShouldKnowBeforeYouStartBtn.move(xB, 5);
			xB = xB + _whatYouShouldKnowBeforeYouStartBtn.getExplicitOrMeasuredWidth() + 15;
			
			_publishMapHelp.setActualSize(_publishMapHelp.getExplicitOrMeasuredWidth(), 30);
			_publishMapHelp.move(xB, 5);
			xB = xB + _publishMapHelp.getExplicitOrMeasuredWidth() + 15;
			
			_faqBtn.setActualSize(_faqBtn.getExplicitOrMeasuredWidth(), 30);
			_faqBtn.move(xB, 5);
			xB = xB + _faqBtn.getExplicitOrMeasuredWidth() + 15;
			xB = xB + _aboutUsBtn.getExplicitOrMeasuredWidth() + 15;
			_faqBtn.setActualSize(_faqBtn.getExplicitOrMeasuredWidth(), 30);
			_faqBtn.move(xB, 5);
			xB = xB + _faqBtn.getExplicitOrMeasuredWidth() + 15;
			_contactUsBtn.setActualSize(_contactUsBtn.getExplicitOrMeasuredWidth(), 30);
			_contactUsBtn.move(xB, 5);
			xB = xB + _contactUsBtn.getExplicitOrMeasuredWidth() + 15;
			_helpBtn.setActualSize(_helpBtn.getExplicitOrMeasuredWidth(), 30);
			_helpBtn.move(xB, 5);
			xB = xB + _helpBtn.getExplicitOrMeasuredWidth() + 15;
			_unhideRSP.setActualSize(_unhideRSP.getExplicitOrMeasuredWidth(),30);
			_unhideRSP.move(this.width - _unhideRSP.width, 5);
			
		}
		
		//------------------------Event Handlers----------------------//
		protected function discardChanges(event:MouseEvent):void{
			FlexGlobals.topLevelApplication.rightSidePanel.visible = true;
			AGORAController.getInstance().hideMap();
		}
		
		protected function onPrint(event:MouseEvent):void{
			AGORAController.getInstance().printMap();
		}
		
		protected function publishMapPanel():void
		{
				var vb:VBox = new VBox();
				var label:Text = new Text();
				var cb:ControlBar = new ControlBar();
				var s:Spacer = new Spacer();
				
				var b1:Button = new Button();
				b1.label = Language.lookup("PublishMapbtn");
				b1.name="pb_Btn";
				b1.addEventListener(MouseEvent.CLICK, pbMap);
				
				var b2:Button = new Button();
				b2.label = Language.lookup("Back");
				b2.addEventListener(MouseEvent.CLICK, closePopUp);				
				
				cb.addChild(s);
				
				label.htmlText = Language.lookup('NewMapToolTiphtml');
				vb.setStyle("paddingBottom", 2);
				vb.setStyle("paddingLeft", 12);
				vb.setStyle("paddingRight", 2);
				vb.setStyle("paddingTop", 12);
				
				vb.addChild(label);
				var hg:HGroup = new HGroup();	
				hg.name="pb_BtnG";
				hg.addElement(b1);
				hg.addElement(b2);
				vb.addChild(hg);
				hpanel = new Panel();
				hpanel.title = Language.lookup('PublishMapHelp');
				hpanel.width = 620;
				hpanel.height = 450;
				hpanel.addElement(vb);
				hpanel.addElement(cb);
			
		}
		
		private function pbMap(ev:MouseEvent):void{
			if(!FlexGlobals.topLevelApplication.publishMap){
				FlexGlobals.topLevelApplication.publishMap = new PublishMapPopUpPanel();
			}
			
			FlexGlobals.topLevelApplication.publishMap.mapID = AGORAModel.getInstance().agoraMapModel.ID;	
			AGORAModel.getInstance().publishMapModel.sendForTopLevel();
			PopUpManager.addPopUp(FlexGlobals.topLevelApplication.publishMap,FlexGlobals.topLevelApplication.agoraMenu,true);
			PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.publishMap);
		}
		
		private function publishMapTrigger(ev:MouseEvent):void{
			// permissions check !
			if(!ArgumentController.getInstance().checkPermissionsForMap()){
				var vg:VBox = (VBox)(hpanel.getElementAt(0));
				var hg:HGroup =(HGroup)(vg.getElementAt(1));
				hg.getElementAt(0).visible=false;				
				_publishMapHelp.label = Language.lookup("PublishMapHelpNoAccess");
			}else{
				_publishMapHelp.label = Language.lookup("PublishMapHelp");
			}
				
			PopUpManager.addPopUp(hpanel, this, true);
			PopUpManager.centerPopUp(hpanel);
		}
		
		private function closePopUp(evt:MouseEvent):void {
			PopUpManager.removePopUp(hpanel);
		}
		
		protected function saveMapAs(event:MouseEvent):void{
			FlexGlobals.topLevelApplication.saveAsMapBox = new saveMapAsPanel;
			PopUpManager.addPopUp(FlexGlobals.topLevelApplication.saveAsMapBox, DisplayObject(FlexGlobals.topLevelApplication),true);
			PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.saveAsMapBox);
		}
		protected function onAddToProject(event:MouseEvent):void{
			FlexGlobals.topLevelApplication.move_map = new MapToProject;
			PopUpManager.addPopUp(FlexGlobals.topLevelApplication.move_map, DisplayObject(FlexGlobals.topLevelApplication),true);
			PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.move_map);
		}
		
		protected function unhideButton_ClickHandler(event:MouseEvent):void{
			FlexGlobals.topLevelApplication.rightSidePanel.visible = true;
			_unhideRSP.visible = false;
			FlexGlobals.topLevelApplication.map.agora.width = stage.stageWidth-40 - FlexGlobals.topLevelApplication.rightSidePanel.width;
		}
	}
}