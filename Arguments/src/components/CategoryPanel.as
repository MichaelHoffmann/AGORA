package components
{
	import Controller.AGORAController;
	import Controller.ArgumentController;
	
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.CategoryModel;
	import Model.MapMetaData;
	import Model.UserSessionModel;
	
	import Skins.LeftAlignTextButtonSkin;
	
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
		
		private var createMapBtn:Button;
		private var mapPanel:VGroup;
		private var subprojectPanel:VGroup;
		private var createProjectPanel : HGroup;
		private var projectMemberPanel : VGroup;
		private var projectTypePanel : VGroup;
		private var mapPanelLbl:Label;
		private var is_project_level:Boolean;
		private var tl:TileLayout;
		private var mapMetaDataVector:Vector.<MapMetaData>;
		private var projectPanelLbl:Label;
		private var projectTitlePanel: HGroup;
		private var projectPanel :VGroup;
		public var  pView:ProjectView;
		private var rsp:RightSidePanel;
		private var bottomButtons:HGroup;
		private var bottomStuff:VGroup;
		private var vGroupContainer:VGroup;
		private var clickthroughCategories:Label;
		private var createProjBtn:Button;
		private var _layerView:Boolean = false;
		public function CategoryPanel()
		{
			super();
			/*Instantiations in order of depth in UI field*/
			scroller = new Scroller;
			categoryTiles = new Group;
			tl = new TileLayout();
			mapPanel = new VGroup;
			subprojectPanel = new VGroup;
			projectPanelLbl = new Label();
			projectPanel = new VGroup();
			projectTitlePanel = new HGroup();
			projectMemberPanel = new VGroup;
			createProjectPanel = new HGroup;
			projectTypePanel = new VGroup;
			loadingDisplay = new Label;
			mapPanelLbl = new Label();
			bottomButtons = new HGroup();
			bottomStuff = new VGroup();
			
			model = AGORAModel.getInstance().categoryModel;
			/*Setting the UI components to the proper places and sizes*/
			this.percentHeight = this.percentWidth = 100;
			scroller.percentHeight = scroller.percentWidth = 100;
			scroller.x = scroller.y = 25;
			categoryTiles.percentHeight = 100;
			categoryTiles.percentWidth = 100;
			mapPanel.percentWidth =33 ;
			projectPanel.percentWidth = 33;
			//subprojectPanel.percentWidth = 33;
			createProjectPanel.percentWidth = 50;
			projectMemberPanel.percentWidth = 33;
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
			vGroupContainer=new VGroup();
			this.addElement(vGroupContainer);
			vGroupContainer.addElement(scroller);
			var refreshBtn:Button=new Button();
			 createMapBtn=new Button();
			 createProjBtn=new Button();
			createMapBtn.addEventListener(MouseEvent.CLICK,function(e:Event):void{
				
				var userSession:UserSessionModel = AGORAModel.getInstance().userSessionModel;
				if(userSession.username == "Guest"){
					Alert.show(Language.lookup('GuestCreateMapError'));
					return;
				} 
				AGORAModel.getInstance().agoraMapModel.moveToProject=true;
				Controller.AGORAController.getInstance().createMap(e);
			});	
			createProjBtn.addEventListener(MouseEvent.CLICK,function(e:Event):void{
				var userSession:UserSessionModel = AGORAModel.getInstance().userSessionModel;
				if(userSession.username == "Guest"){
					Alert.show(Language.lookup('GuestCreateMapError'));
					return;
				} 
			Controller.AGORAController.getInstance().createProj(e)});	
			bottomButtons.addElement(refreshBtn);
			bottomStuff.addElement(bottomButtons);
			refreshBtn.addEventListener(MouseEvent.CLICK,function(e:Event):void{
			Controller.AGORAController.getInstance().updateProject(e)});
			createProjBtn.label=Language.lookup('NewProject');
			createMapBtn.label=Language.lookup('NewMap');
			refreshBtn.label=Language.lookup('Refresh');
			bottomButtons.addElement(createProjBtn);
			bottomButtons.addElement(createMapBtn);
			bottomButtons.addElement(refreshBtn);
			bottomStuff.left=0;
			bottomStuff.right=0;
			bottomButtons.left=0;
			bottomButtons.right=0;
			vGroupContainer.left=0;
			vGroupContainer.top=0;
			vGroupContainer.bottom=0;
			vGroupContainer.right=0;
			vGroupContainer.addElement(bottomStuff);
			bottomButtons.horizontalAlign="center";
			bottomStuff.horizontalAlign="center";
			vGroupContainer.horizontalAlign="center";
			clickthroughCategories = new Label();
			clickthroughCategories.text=Language.lookup('CreateProject')
			bottomStuff.addElement(clickthroughCategories);
			/*Setting up loading display*/
			loadingDisplay.text = Language.lookup("Loading");
			addElement(loadingDisplay);
			pView=new ProjectView();
			pView.visible=false;
			addElement(pView);
			rsp = FlexGlobals.topLevelApplication.rightSidePanel;
		}
		
		
		public function get layerView():Boolean
		{
			return _layerView;
		}

		public function set layerView(value:Boolean):void
		{
			_layerView = value;
		}

		override protected function commitProperties():void{
			super.commitProperties();
			pView.visible=false;

			categoryTiles.removeAllElements();
			subprojectPanel.removeAllElements();
			projectTitlePanel.removeAllElements();
			projectPanel.removeAllElements();
			projectMemberPanel.removeAllElements();
			projectTypePanel.removeAllElements();
			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			mapPanel.removeAllElements();
			layerView=false;
			
			//add elements

			if(model.category){
				if(model.category.@category_count == 0 || model.category.category[0].@is_project == 1){
					bottomButtons.visible=true;
					createProjBtn.visible=true;
					createMapBtn.label=Language.lookup("NewMap");
					is_project_level = true;
					this.categoryTiles.layout = new HorizontalLayout;
					if(model.project && model.project.proj[0])
					{
						pView.visible=true
						bottomButtons.visible=false;						
					}
					else
					{ 				
						mapPanelLbl.text = Language.lookup('ArgMaps');
						mapPanel.paddingTop = 0;
						subprojectPanel.paddingTop = 0;
						projectPanelLbl.text = Language.lookup('Project');
						subprojectPanel.addElementAt(projectPanelLbl,0);
						mapPanel.percentWidth=50;
						mapPanel.percentWidth=50;
						categoryTiles.addElement(mapPanel);
						categoryTiles.addElement(subprojectPanel);
						layerView=true;
					}
					
					if(model.map != null){
						mapPanel.addElement(mapPanelLbl);
						populateMaps();
					}
				} else {
					is_project_level = false;
					pView.visible=false;
					categoryTiles.layout = tl;
					trace("Changing back to normal layout");
				}
				//Loop over the categories that were pulled from the DB
				var otherPos:int = -1;
				for each(var categoryXML:XML in model.category.category){
					trace("Adding buttons 1890"+categoryXML.@Name);
					/*Create and setup buttons corresponding to categories*/
					var button:Button = new Button;
					button.setStyle("skinClass",TextWrapSkin);
					button.height = 100;
					button.width = 200;
					button.name = categoryXML.@ID; //The ID (unique DB identifier) of the category
					if(categoryXML.@ID ==6){  // disabling Projects
						continue;
					}
					
					if(categoryXML.@ID>9 || categoryXML.@ID == 42){
					button.label = categoryXML.@Name; //The title of the category except level1 (e.g. Philosophy, Biology, or Projects)
					}else{
						button.label = Language.lookup("Category"+categoryXML.@ID); //The title of the category Level1 (e.g. Philosophy, Biology, or Projects)	
					}
					if(categoryXML.@ID==9 || categoryXML.@ID==20)
						otherPos = categoryTiles.numElements;
					button.setStyle("chromeColor", 0xA0CADB);					
					button.addEventListener('click',function(e:Event):void{
						//Begin private inner click event function for button
						trace("button \"" + e.target.label + "\" clicked");
						e.stopImmediatePropagation();	
						//Checks to see if the current category is a project
						usm.selectedWoAProjID=e.target.name;
						AGORAModel.getInstance().agoraMapModel.tempprojectID = AGORAModel.getInstance().agoraMapModel.projectID;
						AGORAModel.getInstance().agoraMapModel.tempprojID = AGORAModel.getInstance().agoraMapModel.projID;
						AGORAModel.getInstance().agoraMapModel.projectID = e.target.name;
						AGORAModel.getInstance().agoraMapModel.projID = e.target.name;

						if(categoryXML.@is_project == 1){
							AGORAController.getInstance().verifyProjectMember(e.target.label,e.target.name);
						} 
						else {
							AGORAController.getInstance().fetchDataChildCategory(e.target.label,e.target.name);
						}
						trace("From for loop, count is: " + categoryXML.@category_count);
					}, false, 1,false);
					//Add the button related to the category to the view
					if(is_project_level){
						button.width = 300;
						button.height = 24;
						button.setStyle("skinClass",LeftAlignTextButtonSkin);
					   	subprojectPanel.paddingLeft = 25;
						subprojectPanel.addElement(button);
					
					}
					else 
					{  
						categoryTiles.addElement(button);						
					}
				}

				if(is_project_level){
					clickthroughCategories.visible=false;
					bottomStuff.visible=true;					
				}
				else 
				{
					bottomStuff.visible=true;
					createProjBtn.visible=false;
					createMapBtn.label=Language.lookup("NewMap");
					clickthroughCategories.visible=true;

					if(otherPos!=-1){
						var btn:Button = (Button)(categoryTiles.getElementAt(otherPos));
						categoryTiles.removeElementAt(otherPos);
						categoryTiles.addElement(btn);
					}
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
		
		public function showpView():void{
			categoryTiles.removeAllElements();
			subprojectPanel.removeAllElements();
			projectTitlePanel.removeAllElements();
			projectPanel.removeAllElements();
			projectMemberPanel.removeAllElements();
			projectTypePanel.removeAllElements();
			pView.visible=true;
			bottomStuff.visible=false;
			pView.flushall();

		}
		protected function onMapObjectClicked(event:MouseEvent):void{
			var thisMapInfo:MapMetaData = mapMetaDataVector[parseInt((Button) (event.target).id)];
			rsp.clickableMapOwnerInformation.label = thisMapInfo.mapCreator;
			rsp.mapTitle.text=thisMapInfo.mapName;
			rsp.IdofMap.text = Language.lookup("IdOfTheMapDisplay") + " " + thisMapInfo.mapID;
			
			rsp.clickableMapOwnerInformation.toolTip = 
				thisMapInfo.url + '\n' + Language.lookup('MapOwnerURLWarning');
			
			var urllink:String = thisMapInfo.url;
			if(thisMapInfo.url!=null && thisMapInfo.url.indexOf("http://") ==-1)
				urllink = "http://"+thisMapInfo.url;
			
			rsp.clickableMapOwnerInformation.addEventListener(MouseEvent.CLICK, function event(e:Event):void{
				navigateToURL(new URLRequest(urllink), 'quote');
			},false, 0, false);
			rsp.invalidateDisplayList();
			//mapMetaDataVector = null;
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