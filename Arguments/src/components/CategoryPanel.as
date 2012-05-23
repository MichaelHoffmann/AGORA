package components
{
	import Controller.AGORAController;
	import Controller.ArgumentController;
	
	import Model.AGORAModel;
	import Model.CategoryModel;
	import Model.MapMetaData;
	
	import ValueObjects.CategoryDataV0;
	
	import classes.Language;
	
	import components.AGORAMenu;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.FlexGlobals;
	
	import spark.components.Group;
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.TileGroup;
	import spark.components.VGroup;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;

	public class CategoryPanel extends Panel
	{
		private var model:CategoryModel;
		public var loadingDisplay:Label;
		public var scroller:Scroller;
		public var categoryTiles:Group;
		
		
		public function CategoryPanel()
		{
			super();
			this.percentHeight = this.percentWidth = 100;
			model = AGORAModel.getInstance().categoryModel;
			scroller = new Scroller;
			scroller.x = scroller.y = 25;
			scroller.percentHeight = scroller.percentWidth = 100;
			categoryTiles = new Group;
			categoryTiles.percentHeight = 100;
			categoryTiles.percentWidth = 100;
			var tl:TileLayout = new TileLayout();
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
			var cg:ArrayList = AGORAController.getInstance().categoryChain; //Array list of the current category hierarchy
			//add elements
			if(model.category){
				//Loop over the categories that were pulled from the DB

				for each(var categoryXML:XML in model.category.category){
					/*Create and setup buttons corresponding to categories*/
					var button:Button = new Button;
					button.name = categoryXML.@ID; //The ID (unique DB identifier) of the category
					button.label = categoryXML.@Name; //The title of the category (e.g. Philosophy, Biology, or Projects)
					button.width = 150;
					button.height = 80;
					button.setStyle("chromeColor", 0xA0CADB);
					/*If the category that was clicked is NOT projects, load the child categories and maps*/
					
					//if(categoryXML.@ID!=6){ //UNCOMMENT THIS LINE AND THE ELSE AND THE CLOSING CURLY ABOUT 20 LINES DOWN TO ADD ALL PROJECTS BACK
					button.addEventListener('click',function(e:Event):void{
						//Begin private inner click event function for button
						trace("button " + e.target.label + " clicked");
						e.stopImmediatePropagation();	
						AGORAController.getInstance().fetchDataChildCategory(e.target.label);
						/*Adjust the category chain. Find the instantiation in AGORAController. cg is a legacy name*/
						if(cg.length == 0){
							cg.addItem(new CategoryDataV0(e.target.label, null));
						}else{	
							cg.addItem(new CategoryDataV0(e.target.label, (CategoryDataV0)(cg.getItemAt(cg.length-1)).current));	
						}
						FlexGlobals.topLevelApplication.agoraMenu.createMapBtn.enabled = true;
						FlexGlobals.topLevelApplication.rightSidePanel.categoryChain.addCategory(e.target.label);
						AGORAController.getInstance().categoryChain = cg;
													
					}, false, 1,false);
					/*If the category clicked was the project list, load up the project list*/
					/*}else{ //UNCOMMENT THIS BLOCK TO ADD PROJECTS BACK
						button.addEventListener('click',function(e:Event):void{
							//Begin private inner click event function for button
							trace("button " + e.target.label + " clicked");
							e.stopImmediatePropagation();
							FlexGlobals.topLevelApplication.agoraMenu.mainPanel.visible=true;
							FlexGlobals.topLevelApplication.agoraMenu.tabNav.setVisible(false,true);
							var cg:ArrayList = AGORAController.getInstance().categoryChain;
							//Populates the category chain. See above
							if(cg.length == 0){
								cg.addItem(new CategoryDataV0(e.target.label, null));
							}
							else{	
								cg.addItem(new CategoryDataV0(e.target.label, (CategoryDataV0)(cg.getItemAt(cg.length-1)).current));						
							}
							AGORAController.getInstance().categoryChain = cg;
						}, false, 1,false);
					} */ //UNCOMMENT THIS BLOCK END
						//Add the button related to the category to the view
						categoryTiles.addElement(button);
				}				
			}
			if(model.map != null)
				populateMaps();
			
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
				categoryTiles.addElement(mapButton);
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