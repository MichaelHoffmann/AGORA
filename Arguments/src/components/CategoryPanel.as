package components
{
	import Controller.AGORAController;
	import Controller.ArgumentController;
	
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.CategoryModel;
	import Model.MapMetaData;
	
	import ValueObjects.CategoryDataV0;
	
	import classes.Language;
	
	import components.AGORAMenu;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.skins.Border;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.TileGroup;
	import spark.components.VGroup;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	
	public class CategoryPanel extends Panel
	{
		private var model:CategoryModel;
		public var loadingDisplay:Label;
		public var scroller:Scroller;
		public var categoryTiles:Group;
		private var mapPanel:VGroup;
		private var projectPanel:VGroup;
		private var createProjectPanel : HGroup;
		private var projectMemberPanel : VGroup;
		private var projectTypePanel : VGroup;
		private var mapPanelBtn:Button;
		private var is_project_level:Boolean;
		private var tl:TileLayout;
		private var mapMetaDataVector:Vector.<MapMetaData>;

		private var rsp:RightSidePanel;
		public function CategoryPanel()
		{
			super();
			/*Instantiations in order of depth in UI field*/
			scroller = new Scroller;
			categoryTiles = new Group;
			tl = new TileLayout();
			mapPanel = new VGroup;
			projectPanel = new VGroup;
			projectMemberPanel = new VGroup;
			projectTypePanel : new VGroup;
			createProjectPanel = new HGroup;
			projectTypePanel = new VGroup;
			loadingDisplay = new Label;
			mapPanelBtn = new Button();
			model = AGORAModel.getInstance().categoryModel;
			/*Setting the UI components to the proper places and sizes*/
			this.percentHeight = this.percentWidth = 100;
			scroller.percentHeight = scroller.percentWidth = 100;
			scroller.x = scroller.y = 25;
			categoryTiles.percentHeight = 100;
			categoryTiles.percentWidth = 100;
			mapPanel.percentWidth = 25;
			projectPanel.percentWidth = 25;
			createProjectPanel.percentWidth = 50;
			projectMemberPanel.percentWidth = 25;
			projectTypePanel.percentWidth = 25;
			/*Editing how the layout will be for the buttons*/		
			tl.requestedColumnCount = 3;
			tl.requestedRowCount = 3;
			tl.horizontalAlign="center";
			tl.verticalAlign = "middle";
			tl.columnAlign="justifyUsingWidth";
			tl.rowAlign="justifyUsingHeight";
			categoryTiles.layout = tl;
			/*Adding the category tiles elemet as viewport of scroller*/
			scroller.viewport = categoryTiles;
			/*Making scroller part of this UI component*/
			this.addElement(scroller);
			/*Setting up loading display*/
			loadingDisplay.text = Language.lookup("Loading");
			addElement(loadingDisplay);
			
			rsp = FlexGlobals.topLevelApplication.rightSidePanel;
		}
		
		
		override protected function commitProperties():void{
			super.commitProperties();
			categoryTiles.removeAllElements();
			projectPanel.removeAllElements();
			projectMemberPanel.removeAllElements();
			projectTypePanel.removeAllElements();
			
			mapPanel.removeAllElements();
			//add elements
			if(model.category){
				
				if(model.category.@category_count == 0 || model.category.category[0].@is_project == 1){

					is_project_level = true;
					this.categoryTiles.layout = new HorizontalLayout;
					if(model.project.proj.users.userDetail[0])
					{
					categoryTiles.addElement(projectPanel);
					categoryTiles.addElement(projectTypePanel);
					categoryTiles.addElement(mapPanel);
					categoryTiles.addElement(projectMemberPanel);
					mapPanelBtn.label = Language.lookup('MapsinProject');
					var currProjButton:Button = new Button();
					//currProjButton.setStyle("chromeColor", 0xA0CADB);
					currProjButton.label = AGORAController.getInstance().categoryChain.getItemAt(AGORAController.getInstance().categoryChain.length-1).current;
					projectPanel.addElement(currProjButton);

					}
					else
					{ 					
						mapPanelBtn.label = Language.lookup('ArgMaps');
						var projectPanelBtn:Button = new Button();
						projectPanelBtn.label = Language.lookup('Project');
						projectPanelBtn.setStyle("chromeColor", 0xFFFFFF);
						projectPanel.addElementAt(projectPanelBtn,0);
						mapPanel.percentWidth=50;
						mapPanel.percentWidth=50;
						categoryTiles.addElement(mapPanel);
						categoryTiles.addElement(projectPanel);
					}
					
					if(model.map != null){
						mapPanelBtn.setStyle("chromeColor", 0xFFFFFF);
						mapPanel.addElement(mapPanelBtn);
						populateMaps();
					}
				} else {
					is_project_level = false;
					
					categoryTiles.layout = tl;
					trace("Changing back to normal layout");
				}
				//Loop over the categories that were pulled from the DB
				if(is_project_level)
				{
					

					var btnType: Button = new Button();
					btnType.label = Language.lookup('ProjType');
					btnType.setStyle("chromeColor", 0xFFFFFF);
						
					var btnProjType: Button = new Button();
					//label1.setStyle("skinClass",TextWrapSkin);
					btnProjType.setStyle("chromeColor", 0xA0CADB);	
					btnProjType.height = undefined;
					btnProjType.width = undefined;
					if(model.project.proj.@isHostile == 0)
						btnProjType.label = "adversarial" ;
					else if(model.project.proj.@isHostile == 1)
						btnProjType.label = "collaborative";
					projectTypePanel.addElement (btnType);
					projectTypePanel.addElement (btnProjType);

					var btnUsers: Button = new Button();
					btnUsers.label = Language.lookup('ProjectMembers');
					btnUsers.setStyle("chromeColor",0xFFFFFF);
					projectMemberPanel.addElement (btnUsers);
					
				for each (var projectXML:XML in model.project.proj.users.userDetail)
				{
					var btnProjMembers:Button = new Button();
					btnProjMembers.height = undefined;
					btnProjMembers.width = undefined;
					btnProjMembers.label = projectXML.@name ;
					btnProjMembers.setStyle("chromeColor", 0xF99653);
									
					projectMemberPanel.addElement (btnProjMembers);
				}
				}
				for each(var categoryXML:XML in model.category.category){
					trace("Adding buttons");
					/*Create and setup buttons corresponding to categories*/
					var button:Button = new Button;
					button.setStyle("skinClass",TextWrapSkin);
					button.height = 100;
					button.width = 200;
					button.name = categoryXML.@ID; //The ID (unique DB identifier) of the category
					button.label = categoryXML.@Name; //The title of the category (e.g. Philosophy, Biology, or Projects)

					button.setStyle("chromeColor", 0xA0CADB);					
					button.addEventListener('click',function(e:Event):void{
						//Begin private inner click event function for button
						trace("button \"" + e.target.label + "\" clicked");
						e.stopImmediatePropagation();	
						//Checks to see if the current category is a project
						AGORAModel.getInstance().agoraMapModel.projectID = e.target.name;
						AGORAModel.getInstance().agoraMapModel.projID = e.target.name;
						if(categoryXML.@is_project == 1){

							
							AGORAController.getInstance().verifyProjectMember(e.target.label);
											} 
						else {
							
							AGORAController.getInstance().fetchDataChildCategory(e.target.label, true);
						}
						trace("From for loop, count is: " + categoryXML.@category_count);
					}, false, 1,false);
					//Add the button related to the category to the view
					if(is_project_level){
						button.width = undefined;
						button.height = undefined;
						projectPanel.addElement(button);
						
						FlexGlobals.topLevelApplication.agoraMenu.createProjBtn.enabled = true;
						FlexGlobals.topLevelApplication.agoraMenu.createProjBtn.visible = true;
					
					}
					else 
					{
						FlexGlobals.topLevelApplication.agoraMenu.createProjBtn.enabled = false;
						FlexGlobals.topLevelApplication.agoraMenu.createProjBtn.visible = false;
						categoryTiles.addElement(button);
					}
				}
				if(is_project_level){
					FlexGlobals.topLevelApplication.agoraMenu.clickthroughCategories.visible=false;
					FlexGlobals.topLevelApplication.agoraMenu.createProjBtn.enabled = true;
					FlexGlobals.topLevelApplication.agoraMenu.createProjBtn.visible = true;
					
				}
				else 
				{
					FlexGlobals.topLevelApplication.agoraMenu.clickthroughCategories.visible=true;	
					FlexGlobals.topLevelApplication.agoraMenu.clickthroughCategories.setStyle("chromeColor", 0xF99653);
					FlexGlobals.topLevelApplication.agoraMenu.createProjBtn.enabled = false;
					FlexGlobals.topLevelApplication.agoraMenu.createProjBtn.visible = false;
				}
				
				trace("The category count is: " + (model.category.@category_count));
				
			}
			
		}		
		
		/**
		 * 
		 */
		private function populateMaps():void{
			mapMetaDataVector = new Vector.<MapMetaData>(0,false);
			var mapList:XML = model.map;
			trace("loading maps for the project");
			for each (var map:XML in mapList.map)
			{
				//var mapObject:Object = new Object;
				mapMetaData = new MapMetaData;
				trace("map " +  map.@Name + " being loaded");
				mapMetaData.mapID = map.@ID;
				mapMetaData.mapName = map.@Name;
				mapMetaData.mapCreator = map.@creator;
				mapMetaData.firstname = map.@firstname;
				mapMetaData.lastname = map.@lastname;
				mapMetaData.url = map.@url;
				mapMetaDataVector.push(mapMetaData);						
			}
			
			mapMetaDataVector.sort(MapMetaData.isGreater);
			var i:int = 0;
			for each(var mapMetaData:MapMetaData in mapMetaDataVector){
				var mapButton:Button = new Button;
				mapButton.setStyle("chromeColor", 0xF99653);
				mapButton.percentWidth = 100;
				mapButton.name = mapMetaData.mapID.toString();
				mapButton.label = mapMetaData.mapName;
				mapButton.id = i.toString();
				mapButton.addEventListener(MouseEvent.CLICK, onMapObjectClicked);
				trace("map " + mapMetaData.mapName + " officially added as a button");
				mapButton.toolTip = mapMetaData.mapName;
				mapPanel.addElement(mapButton);
				i++;
			}			
		}
		
		
		protected function onMapObjectClicked(event:MouseEvent):void{
			var thisMapInfo:MapMetaData = mapMetaDataVector[parseInt((Button) (event.target).id)];
			rsp.clickableMapOwnerInformation.label = thisMapInfo.mapCreator;
			rsp.mapTitle.text=thisMapInfo.mapName;
			rsp.clickableMapOwnerInformation.toolTip = 
				thisMapInfo.firstname + " " + thisMapInfo.lastname + "\n" + thisMapInfo.url + '\n' + Language.lookup('MapOwnerURLWarning');
			rsp.clickableMapOwnerInformation.addEventListener(MouseEvent.CLICK, function event(e:Event):void{
				navigateToURL(new URLRequest(thisMapInfo.url), 'quote');
			},false, 0, false);
			rsp.invalidateDisplayList();
			mapMetaDataVector = null;
			ArgumentController.getInstance().loadMap(event.target.name);
		}
		
	
		
		override protected function measure():void{
			super.measure();	
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			loadingDisplay.move(this.getExplicitOrMeasuredWidth()/2 - loadingDisplay.getExplicitOrMeasuredWidth()/2, 5);
		}
		
	}
}// ActionScript file