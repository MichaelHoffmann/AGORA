package classes
{
	import flash.events.MouseEvent;
	
	import spark.components.Panel;
	
	public class GridPanel extends Panel
	{
		public static var count:int;
		public var gridX:int;
		public var gridY:int;
		public var aid:int;
		public function GridPanel()
		{
			count = count + 1;
			aid = count;
			super();
			this.setStyle("dropShadowVisible",false);
			this.setStyle("cornerRadius",4);
			this.setStyle("chromeColor",uint("0xffffff"));
			this.setStyle("backgroundColor",uint("0x999966"));
		}
		override protected function createChildren():void
		{
			super.createChildren();
		}
	}
}