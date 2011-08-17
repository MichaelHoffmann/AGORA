package ValueObjects
{
	public class TextboxValueObject
	{
		public var ID:int;
		public var text:String;
		public var deleted: Boolean;
		public function TextboxValueObject(textboxObject:Object)
		{
			//no value must be undefined
			try{
				trace(textboxObject);
				ID = textboxObject.ID;
				text = textboxObject.text;
				deleted = textboxObject.deleted == 1? true:false;
			}catch(error:Error){
				trace("TextboxValueObject::Constructor: Error reading textboxObject.");	
			}	
		}
	}
}