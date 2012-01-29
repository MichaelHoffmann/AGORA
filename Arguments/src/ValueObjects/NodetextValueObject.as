package ValueObjects
{
	public class NodetextValueObject
	{
		public var ID:int;
		public var textboxID:int;
		public var hasOwnText:Boolean;
		
		public function NodetextValueObject(nodetext:Object, inserted:Boolean = false)
		{
			if(nodetext.hasOwnProperty("ID"))
				ID = nodetext.ID;
			else
				throw new PropNotFoundError("nodetext does not have property 'ID'");
			if(!inserted){
				if(nodetext.hasOwnProperty("textboxID")){
					textboxID = nodetext.textboxID;
					hasOwnText = true;
				}else{
					textboxID = 0;
					hasOwnText = false;
				}
			}
		}
	}
}