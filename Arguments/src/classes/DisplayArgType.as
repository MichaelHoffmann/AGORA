package classes
{
	import mx.containers.Panel;
	import mx.controls.Label;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.VGroup;

	public class DisplayArgType extends GridPanel
	{
		public var vgroup:VGroup;
		public var hgroup:HGroup;
		public var addReasonBtn:Button;
		public var inference:Inference;
		public var type:Label;
		
		public function DisplayArgType()
		{
			super();
		}
		override protected function createChildren():void
		{
			
			super.createChildren();
			type = new Label;
			vgroup = new VGroup;
			addElement(vgroup);
			vgroup.addElement(type);
			type.text = "modus_ponens";
			hgroup = new HGroup;
			vgroup.addElement(hgroup);
			addReasonBtn = new Button;
			addReasonBtn.label = "+R";
			hgroup.addElement(addReasonBtn);
			height = 100;
		}
	}
}