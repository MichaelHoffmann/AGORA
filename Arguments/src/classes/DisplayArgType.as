package classes
{
	import mx.containers.Panel;
	import mx.controls.Label;
	
	import spark.components.Button;
	import spark.components.HGroup;

	public class DisplayArgType extends Panel
	{
		public var hgroup:HGroup;
		public var addReasonBtn:Button;
		public function DisplayArgType()
		{
			super();
		}
		override protected function createChildren():void
		{
			
			super.createChildren();
			hgroup = new HGroup;
			addElement(hgroup);
			addReasonBtn = new Button;
			addReasonBtn.label = "+R";
			hgroup.addElement(addReasonBtn);
		}
	}
}