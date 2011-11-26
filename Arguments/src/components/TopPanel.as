package components
{
	import Controller.AGORAController;
	
	import ValueObjects.AGORAParameters;
	
	import classes.Language;
	
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Button;
	import mx.core.UIComponent;

	public class TopPanel extends UIComponent
	{
		public var gotoMenuBtn:Button;
		public var saveAsBtn:Button;
		public var title:TitleDisplay;
		
		private var agoraConstants:AGORAParameters;
		
		public function TopPanel()
		{
			super();
			agoraConstants = AGORAParameters.getInstance();
		}
		
		override protected function createChildren():void{
			super.createChildren();
			
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
			
			if(!title){
				title = new TitleDisplay;
				addChild(title);
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
			gotoMenuBtn.setActualSize(gotoMenuBtn.getExplicitOrMeasuredWidth(), 30);
			gotoMenuBtn.move(15,5);
			saveAsBtn.setActualSize(saveAsBtn.getExplicitOrMeasuredWidth(), 30);
			saveAsBtn.move(15 + gotoMenuBtn.getExplicitOrMeasuredWidth() + 15, 5);
			title.setActualSize(title.getExplicitOrMeasuredWidth(), title.getExplicitOrMeasuredHeight());
			title.move( 15 + gotoMenuBtn.getExplicitOrMeasuredWidth() + 15 + saveAsBtn.getExplicitOrMeasuredWidth() + 15,5);
		}
		
		//------------------------Event Handlers----------------------//
		protected function discardChanges(event:MouseEvent):void{
			AGORAController.getInstance().hideMap();
		}
	}
}