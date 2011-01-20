package components
{
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	public class Enabler extends Sprite
	{	
		public var nodePadding:Number = 30;
		public var nodeWidth:Number = 250;

		public function Enabler(text:String)
		{
			var enablerText:NodeText = new NodeText(text,nodePadding,nodeWidth);
			this.addChild(enablerText);
			
			this.graphics.beginFill(0xeee7d9);
			this.graphics.lineStyle(2,0x3f536b);
			this.graphics.drawEllipse(0,0,nodeWidth,enablerText.height+(2*nodePadding));
			this.graphics.endFill();
			this.filters = [new DropShadowFilter(4, 45, 0x666666, 1, 10, 10)];
		}
	}
}