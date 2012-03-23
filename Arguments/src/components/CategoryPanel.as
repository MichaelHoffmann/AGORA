package components
{
	import Model.AGORAModel;
	import Model.CategoryModel;
	
	import classes.Language;
	
	import mx.controls.Button;
	import mx.controls.Label;
	
	//import org.osmf.events.GatewayChangeEvent;
	
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.VGroup;
	
	public class CategoryPanel extends Panel
	{
		private var model:CategoryModel;
		public var loadingDisplay:Label;
		public var scroller:Scroller;
		public var vContentGroup:VGroup; 
		
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
			if(model.category){
				for each(var categoryXML:XML in model.category.category){
					var button:Button = new Button;
					button.name = categoryXML.@ID;
					button.label = categoryXML.@Name;
					button.width = 200;
					button.height = 80;
					vContentGroup.addElement(button);
				
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
}// ActionScript file