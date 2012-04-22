package components
{
	import Model.AGORAModel;
	import Model.ProjectListModel;
	import Model.VerifyProjectPasswordModel;
	
	import classes.Language;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.VGroup;
	
	public class ProjectListPanel extends Panel
	{
		private var model:ProjectListModel;
		public var loadingDisplay:Label;
		public var scroller:Scroller;
		public var vContentGroup:VGroup; 
		
		public function ProjectListPanel()
		{
			super();
			model = AGORAModel.getInstance().projectListModel;
		}
		
		override protected function createChildren():void{
			super.createChildren();	
			if(!scroller){
				scroller = new Scroller;
				scroller.x = 10;
				scroller.y = 25;
				this.addElement(scroller);
			}
			if(!vContentGroup){
				vContentGroup = new VGroup;
				vContentGroup.gap = 5;
				scroller.viewport = vContentGroup;
			}
			if(!loadingDisplay){
				loadingDisplay = new Label;
				loadingDisplay.text = Language.lookup("Loading");
				addElement(loadingDisplay);
			}
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			
			vContentGroup.removeAllElements();
			//add elements
			if(model.projectList){
				for each(var projXML:XML in model.projectList.proj){
					var button:Button = new Button;
					button.name = projXML.@ID;
					button.label = projXML.@title;
					button.toolTip = projXML.@creator;
					button.width = 170;
					vContentGroup.addElement(button);
					button.addEventListener('click',function(e:Event):void{
						e.stopImmediatePropagation();
						AGORAModel.getInstance().agoraMapModel.projectID = e.target.name;
						FlexGlobals.topLevelApplication.join_project = new Join_Project;
						PopUpManager.addPopUp(FlexGlobals.topLevelApplication.join_project, DisplayObject(FlexGlobals.topLevelApplication),true);
						PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.join_project);
					}, false, 1,false);
				}
			}
		}
		
		override protected function measure():void{
			super.measure();	
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			loadingDisplay.move(this.getExplicitOrMeasuredWidth()/2 - loadingDisplay.getExplicitOrMeasuredWidth()/2, 5);
		}
	}
}