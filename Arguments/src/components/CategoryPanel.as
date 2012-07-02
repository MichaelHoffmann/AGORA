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
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.core.FlexGlobals;
	import mx.skins.Border;
	
	import spark.components.Button;
	import spark.components.Group;
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
			loadingDisplay = new Label;
			model = AGORAModel.getInstance().categoryModel;
			/*Setting the UI components to the proper places and sizes*/
			this.percentHeight = this.percentWidth = 100;
			scroller.percentHeight = scroller.percentWidth = 100;
			scroller.x = scroller.y = 25;
			categoryTiles.percentHeight = 100;
			categoryTiles.percentWidth = 100;
			mapPanel.percentWidth = 50;
			projectPanel.percentWidth = 50;
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
			mapPanel.removeAllElements();
			//add elements
			if(model.category){
				if(model.category.@category_count == 0 || model.category.category.@is_project == 1){
					is_project_level = true;
					this.categoryTiles.layout = new HorizontalLayout;
					categoryTiles.addElement(mapPanel);
					categoryTiles.addElement(projectPanel);
					if(model.map != null){
						populateMaps();
					}
				} else {
					is_project_level = false;
					
					categoryTiles.layout = tl;
					trace("Changing back to normal layout");
				}
				//Loop over the categories that were pulled from the DB
				
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
						if(categoryXML.@is_project == 1){
							AGORAModel.getInstance().agoraMapModel.projectID = e.target.name;
							AGORAModel.getInstance().agoraMapModel.projID = e.target.name;
							AGORAController.getInstance().verifyProjectMember(e.target.label);
						} else {
							AGORAController.getInstance().fetchDataChildCategory(e.target.label, true);
						}
						trace("From for loop, count is: " + categoryXML.@category_count);
					}, false, 1,false);
					//Add the button related to the category to the view
					if(is_project_level){
						button.width = undefined;
						button.height = undefined;
						projectPanel.addElement(button);
					}
					else categoryTiles.addElement(button);
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
			rsp.clickableMapOwnerInformation.toolTip = 
				thisMapInfo.firstname + " " + thisMapInfo.lastname + "\n" + thisMapInfo.url + '\n' + Language.lookup('MapOwnerURLWarning');
			rsp.clickableMapOwnerInformation.addEventListener(MouseEvent.CLICK, function event(e:Event):void{
				navigateToURL(new URLRequest(thisMapInfo.url), 'quote');
			},false, 0, false);
			rsp.mapTitle.text = event.target.label;
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