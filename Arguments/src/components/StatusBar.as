package components
{
	import classes.Language;
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	
	public class StatusBar extends UIComponent
	{
		public var status:Label;
		public var bgmc:MovieClip;
		public function StatusBar()
		{
			super();
		}
		
		override protected function createChildren():void{
			super.createChildren();
			if(!bgmc){
				bgmc = new MovieClip;
				addChild(bgmc);
			}
			if(!status){
				status = new Label;
				status.text = Language.lookup("Loading");
				addChild(status);
			}	
		}
		
		override protected function measure():void{
			super.measure();
			this.measuredWidth = status.getExplicitOrMeasuredWidth() + 10;
			this.measuredHeight = status.getExplicitOrMeasuredHeight() + 5;
		}
		
		override protected function commitProperties():void{
			super.commitProperties();	
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			bgmc.graphics.clear();
			bgmc.graphics.beginFill(0xf6e2c6,1);
			bgmc.graphics.drawRect(1,1,this.getExplicitOrMeasuredWidth()-1, this.getExplicitOrMeasuredHeight()-1);
			bgmc.graphics.endFill();
			bgmc.graphics.drawRect(0,0,this.getExplicitOrMeasuredWidth(), this.getExplicitOrMeasuredHeight());	
			status.setActualSize(status.getExplicitOrMeasuredWidth(), this.getExplicitOrMeasuredHeight());
			status.move(5,2.5);
		}
		
		public function displayLoading():void{
			status.text = Language.lookup("Loading");
			visible = true;
			CursorManager.setBusyCursor();
		}
		
		public function displayError():void{
			CursorManager.removeBusyCursor();
			status.text = Language.lookup("NetworkError");
			visible = true;
		}
		
		public function hideStatus():void{
			visible = false;
			CursorManager.removeBusyCursor();
		}
	}
}