package ValueObjects
{
	import mx.collections.ArrayCollection;
	
	public class NodeValueObject
	{
		public var ID:int;
		public var type:String;
		public var author:String;
		public var firstName:String;
		public var lastName:String;
		public var URL:String;
		public var x:int;
		public var y:int;
		public var typed:Boolean;
		public var positive:Boolean;
		public var connectedBy:String;
		public var deleted:Boolean;
		public var nodetexts:Vector.<NodetextValueObject>;
		
		public function NodeValueObject(nodeObject:Object, inserted:Boolean = false)
		{
			try{
				if(nodeObject.hasOwnProperty("ID"))
					ID = nodeObject.ID;
				else
					throw new PropNotFoundError("node object does not have property 'ID'");
				if(!inserted){
					if(nodeObject.hasOwnProperty("Type"))
						type = nodeObject.Type;
					else
						throw new PropNotFoundError("node object does not have property 'Type'");
					if(nodeObject.hasOwnProperty('Author'))
						author = nodeObject.Author;
					else
						throw new PropNotFoundError("node object does not have property 'Author'");
					if(nodeObject.hasOwnProperty('FirstName'))
						firstName = nodeObject.FirstName;
					else
						throw new PropNotFoundError("node object does not have property 'FirstName'");
					if(nodeObject.hasOwnProperty('LastName'))
						lastName = nodeObject.LastName;
					else
						throw new PropNotFoundError("node object does not have property 'FirstName'");
					if(nodeObject.hasOwnProperty('URL'))
						URL = nodeObject.URL;
					else
						throw new PropNotFoundError("node object does not have property 'FirstName'");
					if(nodeObject.hasOwnProperty("x"))
						x = nodeObject.x;
					else
						throw new PropNotFoundError("node object does not have property 'x'");
					if(nodeObject.hasOwnProperty('y'))
						y = nodeObject.y;
					else
						throw new PropNotFoundError("node object does not have property 'y'");
					if(nodeObject.hasOwnProperty('typed'))
						typed = nodeObject.typed == 0? false : true;
					else
						throw new PropNotFoundError("node object does not have property 'type'");
					if(nodeObject.hasOwnProperty('positive'))
						positive = nodeObject.positive == 1? true : false;
					else
						throw new PropNotFoundError("node object does not have property 'positive'");
					if(nodeObject.hasOwnProperty("connected_by"))
						connectedBy = nodeObject.connected_by;
					else
						throw new PropNotFoundError("node object does not have property 'connected_by'");
					if(nodeObject.hasOwnProperty("deleted"))
						deleted = nodeObject.deleted == 1? true: false;
					else
						throw new PropNotFoundError("node object does not have property 'deleted'");
				}
				if(nodeObject.hasOwnProperty("nodetext")){
					nodetexts = new Vector.<NodetextValueObject>;
					if(nodeObject.nodetext is ArrayCollection){
						for each(var obj:Object in nodeObject.nodetext){
							nodetexts.push(new NodetextValueObject(obj, inserted));
						}
					}else{
						nodetexts.push(new NodetextValueObject(nodeObject.nodetext, inserted));
					}
				}else{
					throw new PropNotFoundError("node object does not have nodetext");
				}
			}catch(error:PropNotFoundError){
				throw error;
			}
		}
	}
}