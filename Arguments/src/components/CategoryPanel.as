package components
{
	import Model.AGORAModel;
	import Model.CategoryModel;
	
	import classes.Language;
	
	import flash.events.Event;
	
	import mx.controls.Button;
	import mx.controls.Label;
	
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.TileGroup;
	import spark.components.VGroup;
	import mx.controls.Alert;
	import Controller.AGORAController;
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
					button.addEventListener('click',function(e:Event):void{e.stopImmediatePropagation();AGORAController.getInstance().fetchDataChildCategory(e.target.label);AGORAController.getInstance().fetchDataChildMap(e.target.label);}, false, 1,false);

					categoryTiles.addElement(button);
				}
				
				
			}
			if(model.map){
				//Alert.show(model.map);
				for each(var mapXML:XML in model.map.map){
					
					var button2:Button = new Button;
					button2.name = mapXML.@ID;
					button2.label = mapXML.@Name;
					button2.width = 150;
					button2.height = 80;
					//button2.addEventListener('click',function(e:Event):void{e.stopImmediatePropagation();AGORAController.getInstance().fetchDataChildCategory(e.target.label);}, false, 1,false);
					
					categoryTiles.addElement(button2);
				}
			}
			model.map=new XML;
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