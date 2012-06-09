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
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.FlexGlobals;
	import mx.skins.Border;
	
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
		public function CategoryPanel()
		{
			super();
			this.percentHeight = this.percentWidth = 100;
			model = AGORAModel.getInstance().categoryModel;
			scroller = new Scroller;
			scroller.x = scroller.y = 25;
			scroller.percentHeight = scroller.percentWidth = 100;
			mapPanel = new VGroup;
			projectPanel = new VGroup;
			categoryTiles = new Group;
			categoryTiles.percentHeight = 100;
			categoryTiles.percentWidth = 100;
			tl = new TileLayout();
			tl.requestedColumnCount = 3;
			tl.requestedRowCount = 3;
			tl.horizontalAlign="center";
			tl.verticalAlign = "middle";
			tl.columnAlign="justifyUsingWidth";
			tl.rowAlign="justifyUsingHeight";
			categoryTiles.layout = tl;
			scroller.viewport = categoryTiles;
			this.addElement(scroller);
			loadingDisplay = new Label;
			loadingDisplay.text = Language.lookup("Loading");
			addElement(loadingDisplay);
		}
		
		
		override protected function commitProperties():void{
			super.commitProperties();
			categoryTiles.removeAllElements();
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
					categoryTiles.removeAllElements();
					categoryTiles.layout = tl;
				}
				//Loop over the categories that were pulled from the DB
				trace();
				for each(var categoryXML:XML in model.category.category){
					/*Create and setup buttons corresponding to categories*/
					var button:Button = new Button;
					button.name = categoryXML.@ID; //The ID (unique DB identifier) of the category
					button.label = categoryXML.@Name; //The title of the category (e.g. Philosophy, Biology, or Projects)
					button.width = 150;
					button.height = 80;
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
					if(is_project_level) projectPanel.addElement(button);
					else categoryTiles.addElement(button);
				}
				trace("The category count is: " + (model.category.@category_count));
				
			}
			
		}		
		
		/**
		 * 
		 */
		private function populateMaps():void{
			var mapMetaDataVector:Vector.<MapMetaData> = new Vector.<MapMetaData>(0,false);
			var mapList:XML = model.map;
			trace("loading maps for the project");
			for each (var map:XML in mapList.map)
			{
				//var mapObject:Object = new Object;
				mapMetaData = new MapMetaData;
				trace("map " +  map.@Name + " being loaded");
				mapMetaData.mapID = map.@ID;//int(map.attribute("ID")); 
				mapMetaData.mapName = map.@Name;//map.attribute("title");
				//mapMetaData.mapCreator = map.attribute("creator");
				mapMetaDataVector.push(mapMetaData);						
			}
			
			mapMetaDataVector.sort(MapMetaData.isGreater);
			for each(var mapMetaData:MapMetaData in mapMetaDataVector){
				var mapButton:Button = new Button;
				mapButton.width = 150;
				mapButton.height = 80;
				mapButton.setStyle("chromeColor", 0xF99653);
				mapButton.name = mapMetaData.mapID.toString();
				mapButton.label = mapMetaData.mapName;
				mapButton.addEventListener(MouseEvent.CLICK, onMapObjectClicked);
				trace("map " + mapMetaData.mapName + " officially added as a button");
				
				//mapButton.toolTip = mapMetaData.mapCreator;
				mapPanel.addElement(mapButton);
			}
			/*
			* These cured our source of error for maps pouring over the screen and not loading.
			* The cause was related to a persistant map list constantly being called.
			*/
			mapList.map = null;
			mapMetaDataVector = null;
			mapMetaData = null;
			model.map = null;
			
		}
		
		
		protected function onMapObjectClicked(event:MouseEvent):void{
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