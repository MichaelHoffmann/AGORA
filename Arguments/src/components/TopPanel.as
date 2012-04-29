package components
{
	import Controller.AGORAController;
	
	import Model.AGORAModel;
	
	import ValueObjects.AGORAParameters;
	
	import classes.Language;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Button;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import spark.components.Label;
	import spark.components.TextArea;
	
	public class TopPanel extends UIComponent
	{
		public var gotoMenuBtn:Button;
		public var saveAsBtn:Button;
		public var title:TitleDisplay;
		public var print:Button;
		public var addToProject:TextArea;
		public var projectLabel:Label;
		public var submitAddToProject:Button;
		
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
			
			if(!title){
				title = new TitleDisplay;
				addChild(title);
			}	
			
			if(!print){
				print = new Button;
				print.label = Language.lookup("PrintMap");
				print.addEventListener(MouseEvent.CLICK, onPrint);
				addChild(print);
			}
			
			if(!projectLabel){
				projectLabel = new Label;
				projectLabel.text = "Move map into project using unique project identifier in parenthesis next to the project name";
				projectLabel.height = projectLabel.getExplicitOrMeasuredHeight() - 5;
				addChild(projectLabel);
			}
			if(!addToProject){
				addToProject = new TextArea;
				addToProject.height = 20;
				addChild(addToProject);
				
				
			}
			
			if(!submitAddToProject){
				submitAddToProject = new Button;
				submitAddToProject.label = "Submit";
				submitAddToProject.addEventListener('click',onAddToProject);
				addChild(submitAddToProject);
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
			title.setActualSize(title.getExplicitOrMeasuredWidth(), title.getExplicitOrMeasuredHeight());
			title.move(xB,5);
			xB = xB + title.getExplicitOrMeasuredWidth() + 15;
			projectLabel.setActualSize(projectLabel.getExplicitOrMeasuredWidth(), projectLabel.getExplicitOrMeasuredHeight());
			projectLabel.move(xB,5);
			addToProject.setActualSize(addToProject.getExplicitOrMeasuredWidth(), addToProject.getExplicitOrMeasuredHeight());
			addToProject.move(xB,7);
			xB = xB + projectLabel.getExplicitOrMeasuredWidth() + 15;
			submitAddToProject.setActualSize(submitAddToProject.getExplicitOrMeasuredWidth(), submitAddToProject.getExplicitOrMeasuredHeight());
			submitAddToProject.move(xB,5);
			
		}
		
		//------------------------Event Handlers----------------------//
		protected function discardChanges(event:MouseEvent):void{
			AGORAController.getInstance().hideMap();
		}
		
		protected function onPrint(event:MouseEvent):void{
			AGORAController.getInstance().printMap();
		}
		
		protected function onAddToProject(event:MouseEvent):void{
			//Send data to the database
		}
	}
}