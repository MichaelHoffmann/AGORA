package classes
{
	import spark.layouts.VerticalLayout;

	public class ALayoutManager
	{
		public var heightVector:Vector.<int>;
		public var presentMatrix:Vector.<Vector.<int>>;
		public function ALayoutManager()
		{
			heightVector = new Vector.<int>(0,false);
			presentMatrix = new Vector.<Vector.<int>>(0,false);
		}
	}
}