package ValueObjects
{
	public class TextboxValueObject
	{
		public var ID:int;
		public var text:String;
		public var deleted: Boolean;
		public function TextboxValueObject(textboxObject:Object, inserted:Boolean = false)
		{
			if(textboxObject.hasOwnProperty("ID")){
				ID = textboxObject.ID;
			}else{
				throw new PropNotFoundError("textbox object doesn't have property 'ID'");
			}
			if(!inserted){
				if(textboxObject.hasOwnProperty("text")){
					text = textboxObject.text;	
				}else{
					throw new PropNotFoundError("textboxObject does not have property 'text'");
				}
				if(textboxObject.hasOwnProperty("deleted")){
					deleted = textboxObject.deleted == 1? true:false;
				}
				else{
					throw new PropNotFoundError("textboxObject does not have property 'deleted'");
				}
			}
		}
	}
}