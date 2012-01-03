package components
{
	import classes.Language;
	
	import flash.text.TextField;
	
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	
	public class StatusBar extends UIComponent
	{
		public var status:TextField;
		public function StatusBar()
		{
			super();
		}
		
		override protected function createChildren():void{
			super.createChildren();
			if(!status){
				status = new TextField;
				status.height = 15;
				status.text = Language.lookup("Loading");
				status.visible = false;
				status.background = true;
				status.backgroundColor = 0xf6e2c6;
				addChild(status);
			}
		}
		
		override protected function measure():void{
			super.measure();
			this.measuredWidth = status.width + 10;
			this.measuredHeight = 15;
		}
		
		override protected function commitProperties():void{
			super.commitProperties();	
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			status.x = 0;
			status.y = 0;
		}
		
		public function displayLoading():void{
			status.text = Language.lookup("Loading");
			status.visible = true;
			CursorManager.setBusyCursor();
		}
		
		public function displayError():void{
			CursorManager.removeBusyCursor();
			status.text = Language.lookup("NetworkError");
			status.visible = true;
		}
		
		public function hideStatus():void{
			status.visible = false;
			CursorManager.removeBusyCursor();
		}
	}
}