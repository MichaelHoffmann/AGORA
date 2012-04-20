package ValueObjects
{
	public class CategoryDataV0
	{
		public var parent:String;
		public var current:String;
		public function CategoryDataV0(current:String, parent:String)
		{
			this.parent = parent;
			this.current = current;
		}
	}
}