package components
{
	import Controller.AGORAController;
	import Controller.ArgumentController;
	
	import Model.AGORAModel;
	import Model.CategoryModel;
	import Model.MapMetaData;	
	
	import ValueObjects.CategoryDataV0;
	
	import classes.Language;
	
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.TileGroup;
	import spark.components.VGroup;

	public class CategoryPanel extends Panel
	{
		private var model:CategoryModel;
		public var loadingDisplay:Label;
		public var scroller:Scroller;
		public var vContentGroup:VGroup; 
		public var categoryTiles:TileGroup;
		
		
		public function CategoryPanel()
		{
			super();
			model = AGORAModel.getInstance().categoryModel;
		}
		
		override protected function createChildren():void{
			super.createChildren();	
			if(!scroller){
				scroller = new Scroller;
				scroller.x = 10;
				scroller.y = 25;
				this.addElement(scroller);
			}
/*			if(!vContentGroup){
				vContentGroup = new VGroup;
				vContentGroup.gap = 5;
				scroller.viewport = vContentGroup;
			}
*/
			// Creates a TileGroup layout for the category buttons
			if(!categoryTiles){
				categoryTiles = new TileGroup;
				categoryTiles.horizontalGap = 20;
				categoryTiles.verticalGap = 20;
				categoryTiles.requestedColumnCount = 3;
				categoryTiles.clipAndEnableScrolling = true;
				
				scroller.viewport = categoryTiles;
			}
						
			if(!loadingDisplay){
				loadingDisplay = new Label;
				loadingDisplay.text = Language.lookup("Loading");
				addElement(loadingDisplay);
			}
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			
			categoryTiles.removeAllElements();
			//add elements
			if(model.category){
				for each(var categoryXML:XML in model.category.category){
					var button:Button = new Button;
					button.name = categoryXML.@ID;
					button.label = categoryXML.@Name;
					button.width = 150;
					button.height = 80;
					button.setStyle("chromeColor", 0xA0CADB);
					button.addEventListener('click',function(e:Event):void{
						e.stopImmediatePropagation();
					
						AGORAController.getInstance().fetchDataChildCategory(e.target.label);
						AGORAController.getInstance().fetchDataChildMap(e.target.label);
						var cg:ArrayList = AGORAController.getInstance().categoryChain;
						if(cg.length == 0){
							cg.addItem(new CategoryDataV0(e.target.label, null));
				
						}
						else{
						
							cg.addItem(new CategoryDataV0(e.target.label, (CategoryDataV0)(cg.getItemAt(cg.length-1)).current));
							
						}
						AGORAController.getInstance().categoryChain = cg;
					}, false, 1,false);

					categoryTiles.addElement(button);
				}
				
				
			}
			if(model.map){
				//Alert.show(model.map);
				var mapMetaDataVector:Vector.<MapMetaData> = new Vector.<MapMetaData>(0,false);
				for each(var mapXML:XML in model.map.map){
					mapMetaData = new MapMetaData;
					mapMetaData.mapID = int(mapXML.attribute("ID")); 
					mapMetaData.mapName = mapXML.attribute("title"); 
					//mapMetaData.mapCreator = map.attribute("creator");
					mapMetaDataVector.push(mapMetaData);			
				}
				
			
			mapMetaDataVector.sort(MapMetaData.isGreater);
			for each(var mapMetaData:MapMetaData in mapMetaDataVector){
				var button2:Button = new Button;
				button2.name = mapXML.@ID;
				button2.label = mapXML.@Name;
				button2.width = 150;
				button2.height = 80;
				button2.setStyle("chromeColor", 0xF99653);
				button2.addEventListener('click',function(e:Event):void{e.stopImmediatePropagation();ArgumentController.getInstance().loadMap(e.target.label);}, false, 1,false);
				//button2.addEventListener('click', onMapObjectClicked);
				categoryTiles.addElement(button2);
			}
			
			model.map=new XML;
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
}// ActionScript file