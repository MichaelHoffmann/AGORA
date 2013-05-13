package components
{
	import Controller.AGORAController;
	import Controller.ArgumentController;
	import Controller.UserSessionController;
	
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.CategoryModel;
	import Model.MapMetaData;
	import Model.MoveProject;
	
	import ValueObjects.CategoryDataV0;
	

	import classes.Language;
	
	import components.AGORAMenu;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.skins.Border;
	
	import org.osmf.layout.HorizontalAlign;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.TileGroup;
	import spark.components.VGroup;
	import spark.layouts.ColumnAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.RowAlign;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	
	public class MoveProjectPopUpPanel extends Panel
	{
		private var model:MoveProject;
		public var scroller:Scroller;
		public var categoryTiles:Group;
		private var tl:TileLayout;
		public var cancelButton:Button;
		public var okayButton:Button;
		private var bottomButtonGroup:HGroup;
		private var groupContainer:VGroup;
		private var categoryData:CategoryDataV0;
		private var currCatID:int;
		private var howToUseThisFeatureLabel:Label;
		public var informationLabel:Label;
		public var projectID:int;
		
		public function MoveProjectPopUpPanel(projectID:int=-1)
		{
			super();
			if(projectID != -1) this.projectID = projectID;
		//////3	else this.projectID = AGORAModel.getInstance().myProjectsModel.;
			howToUseThisFeatureLabel = new Label;
			informationLabel = new Label;
			/*Instantiations in order of depth in UI field*/
			scroller = new Scroller;
			categoryTiles = new Group;
			tl = new TileLayout();
			model = AGORAModel.getInstance().moveProjectModel;
			
			/*Setting the UI components to the proper places and sizes*/
			this.height = 300;
			this.width = 750;
			scroller.percentHeight = scroller.percentWidth = 100;
			scroller.x = scroller.y = 25;
			categoryTiles.percentHeight = 100;
			categoryTiles.percentWidth = 100;
			
			/*Editing how the layout will be for the buttons*/		
			tl.requestedColumnCount = 3;
			tl.requestedRowCount = 3;
			tl.horizontalAlign="center";
			tl.verticalAlign = "middle";
			
			categoryTiles.layout = tl;
			
			/*Adding the category tiles elemet as viewport of scroller*/
			scroller.viewport = categoryTiles;
			
			/*Making the two bottom buttons*/
			cancelButton = new Button();
			cancelButton.addEventListener(MouseEvent.CLICK,removePupUp);
			cancelButton.id = "cancelButton";
			okayButton = new Button();
			okayButton.id = "okayButton";
			cancelButton.label = Language.lookup('Back');
			okayButton.label = Language.lookup('Submit');
			okayButton.visible = false;
			okayButton.addEventListener(MouseEvent.CLICK,submitPublish);
			
			/*Making the groups*/
			bottomButtonGroup = new HGroup();
			groupContainer = new VGroup();
			
			/*Sets up the horizontal group of bottom buttons*/
			bottomButtonGroup.addElement(okayButton);
			bottomButtonGroup.addElement(cancelButton);
			bottomButtonGroup.horizontalAlign = "center";
			bottomButtonGroup.verticalAlign = "bottom";
			
			/*Set up the correct location of the two individual components and adds them to the panel*/
			scroller.verticalCenter = 0;
			scroller.top = 100;
			scroller.horizontalCenter = 0;
			categoryTiles.horizontalCenter = 0;
			bottomButtonGroup.bottom = 0;
			bottomButtonGroup.horizontalCenter=0;
			groupContainer.horizontalAlign = HorizontalAlign.CENTER;
			groupContainer.horizontalCenter = 0;
			howToUseThisFeatureLabel.text = Language.lookup("ClickThroughCategory");
			groupContainer.addElement(howToUseThisFeatureLabel);
			groupContainer.addElement(informationLabel);
			this.addElement(groupContainer);
			this.addElement(scroller);
			this.addElement(bottomButtonGroup);
		}
		
		
		override protected function commitProperties():void{
			super.commitProperties();
			categoryTiles.removeAllElements();
			//begin sequence of adding elements
			if(model.category){
				okayButton.visible = false;
				if(model.category.@category_count == 0){
					okayButton.visible = true;
				}
				
				/*if(model.category.@project_count == 0){
					okayButton.visible = false;
				}*/
				
				if(model.category.@category_count > 0 || model.category.@project_count >0){
				//	okayButton.visible = false;
					//Loop over the categories that were pulled from the DB
					for each(var categoryXML:XML in model.category.category){
						/*Create and setup buttons corresponding to categories*/
						var button:Button = new Button;
						button.name = categoryXML.@ID; //The ID (unique DB identifier) of the category
						button.label = categoryXML.@Name; //The title of the category (e.g. Philosophy, Biology, or Projects)
						if(categoryXML.@ID ==6){  // disabling Projects
							continue;
						}
						if(categoryXML.@ID>9 || categoryXML.@ID == 42){
							button.label = categoryXML.@Name; //The title of the category except level1 (e.g. Philosophy, Biology, or Projects)
						}else{
							button.label = Language.lookup("Category"+categoryXML.@ID); //The title of the category Level1 (e.g. Philosophy, Biology, or Projects)	
						}
						button.setStyle("chromeColor", 0xA0CADB);					
						button.addEventListener('click',function(e:Event):void{
							//Begin private inner click event function for button
							e.stopImmediatePropagation();
							AGORAController.getInstance().fetchDataChildCategoryForMoveProject(e.target.label,e.target.name);
							currCatID = e.target.name;
						}, false, 1,false);
						//Add the button related to the category to the view
						categoryTiles.addElement(button);
					}
				} 	
			}
		}				
		
		protected function onMapObjectClicked(event:MouseEvent):void{
			ArgumentController.getInstance().loadMap(event.target.name);					
		}
		
		protected function removePupUp(event:MouseEvent):void{
			projectID = -1;
			informationLabel.text = "";
			cancelButton.label = Language.lookup('Back');
			PopUpManager.removePopUp(this);
		}
		
		protected function submitPublish(event:MouseEvent):void{
		//////3	if(projectID == -1) projectID = AGORAModel.getInstance().myProjectsModel.;
			AGORAController.getInstance().moveProject(projectID,currCatID);
		}
		
		override protected function measure():void{
			super.measure();	
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
	}
}// ActionScript file