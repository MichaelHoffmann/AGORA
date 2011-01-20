// ActionScript file
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.text.TextField;

private var txt:TextField=new TextField();
private var nodePadding:Number = 30;
private var nodeWidth:Number = 250;
private var nodeTextFormat:TextFormat=new TextFormat("Georgia", 14);
private var box:Sprite=new Sprite();

public function drawClaim(nodeText:String):void {
	txt.selectable=false;
	txt.width=nodeWidth-(2*nodePadding);
	txt.autoSize='left';
	txt.text=nodeText;
	txt.multiline=true;
	txt.wordWrap=true;
	txt.setTextFormat(nodeTextFormat);
	txt.x=txt.y=nodePadding;
	
	
	box.addChild(txt);
	box.graphics.beginFill(0xeee7d9);
	box.graphics.lineStyle(2,0x3f536b);
	box.graphics.drawEllipse(0,0,nodeWidth,txt.height+(2*nodePadding));
	box.graphics.endFill();
	box.filters = [new DropShadowFilter(4, 45, 0x666666, 1, 10, 10)];
	
	//con.addChild(box);
}