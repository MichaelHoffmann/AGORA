package ValueObjects
{
	public class NodetextValueObject
	{
		public var ID:int;
		public var textboxID:int;
		public var hasOwnText:Boolean;
		
		public function NodetextValueObject(nodetext:Object, inserted:Boolean = false)
		{
			try{
				ID = nodetext.ID;
				if(!inserted){
					if(nodetext.hasOwnProperty("textboxID")){
						textboxID = nodetext.textboxID;
						hasOwnText = true;
					}else{
						textboxID = 0;
						hasOwnText = false;
					}
				}
			}catch(error:Error){
				trace("NodetextValueObject::Constructor: Error reading nodetext object");
			}
			
			
		}
	}
}