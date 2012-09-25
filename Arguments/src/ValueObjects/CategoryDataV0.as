package ValueObjects
{
	public class CategoryDataV0
	{
		public var parent:String;
		public var current:String;
		public var parentID:String;
		public var currentID:String;
		public function CategoryDataV0(current:String,currentID:String, parent:String,parentID:String)
		{
			this.parent = parent;
			this.parentID = parentID;
			this.currentID=currentID;
			this.current = current;
		}
	}
}