package components
{
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	public class Reason extends Sprite
	{
		public var nodePadding:Number;
		public var nodeWidth:Number = 250;
		
		public function Reason(text:String,isUniversal:Number)
		{
			if (isUniversal == 1) {
				nodePadding = 30;
			} else {
				nodePadding = 10;
			}
			var claimText:NodeText = new NodeText(text, nodePadding, nodeWidth);
			this.addChild(claimText);
			
			this.graphics.beginFill(0xeee7d9);
			this.graphics.lineStyle(2,0x3f536b);
			
			if (isUniversal == 1) {
				this.graphics.drawEllipse(0,0,nodeWidth,claimText.height+(2*nodePadding));
			} else {
				this.graphics.drawRoundRect(0,0,nodeWidth,claimText.height+(2*nodePadding),15,15);
			}
			this.graphics.endFill();
			this.filters = [new DropShadowFilter(4, 45, 0x666666, 1, 10, 10)];
		}
	}
}