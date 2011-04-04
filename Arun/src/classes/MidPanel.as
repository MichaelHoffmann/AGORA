package classes
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.events.FlexEvent;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Panel;
	import spark.components.VGroup;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.skins.spark.PanelSkin;
	
public class MidPanel extends Panel
{
	public var schemeLabel:Label;
	public var buttonArea:Panel;
	public var reasonButton:spark.components.Button;
	public var argButton:spark.components.Button;
	public var panelSkin:PanelSkin;
	public var panelSkin1:PanelSkin;
	public var claim:ArgumentPanel;
	
	public var gridX:int;
	public var gridY:int;

	public static var parentMap:AgoraMap;

	
	public function MidPanel()
	{
		super();
		var uLayout:VerticalLayout = new VerticalLayout;
		uLayout.paddingBottom = 10;
		uLayout.paddingLeft = 10;
		uLayout.paddingRight = 10;
		uLayout.paddingTop = 10;
		width = 100;
		minHeight = 100;
		this.layout = uLayout;
		
		schemeLabel = new Label();
		
	}
	
	override protected function createChildren():void
	{
			super.createChildren();	
			schemeLabel = new Label();
			schemeLabel.text = "trial";
			addElement(schemeLabel);

			var bLayout:HorizontalLayout = new HorizontalLayout;
			buttonArea = new Panel;
			buttonArea.layout = bLayout;
			reasonButton = new spark.components.Button;	//add reason to orig claim
			argButton = new spark.components.Button; //modify argScheme
			buttonArea.addElement(reasonButton);
			buttonArea.addElement(argButton);
			buttonArea.height = 20;
			addElement(buttonArea);
			this.reasonButton.label="+reason";
			this.reasonButton.addEventListener(MouseEvent.CLICK,addReasonHandler);
			this.argButton.label="argScheme";
			this.argButton.addEventListener(MouseEvent.CLICK,argHandler);	
	}
	
	public function onMidPanelCreate(e:FlexEvent):void
	{
		//remove the default title bar provided by mx
		panelSkin = this.skin as PanelSkin;
		panelSkin.topGroup.includeInLayout = false;
		panelSkin.topGroup.visible = false;
		panelSkin1 = this.buttonArea.skin as PanelSkin;
		panelSkin1.topGroup.includeInLayout = false;
		panelSkin1.topGroup.visible = false;
	}
	
	public function addReasonHandler(e:FlexEvent):void
	{
		Alert.show("argButton clicked");
	}
	
	public function argHandler(e:FlexEvent):void
	{
		Alert.show("argButton clicked");
	}
}
}