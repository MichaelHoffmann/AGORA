package ValueObjects
{
	import mx.collections.ArrayCollection;
	
	public class MapValueObject
	{
		public var ID:int;
		public var is_hostile:int;
		public var deleted:Boolean;
		public var title:String;
		public var username:String;
		public var timestamp:String;
		public var textboxes:Vector.<TextboxValueObject>;
		public var nodeObjects:Vector.<NodeValueObject>;
		public var connections:Vector.<ConnectionValueObject>;
		
		public function MapValueObject(mapObject:Object, inserted:Boolean = false)
		{
			textboxes = new Vector.<TextboxValueObject>;
			nodeObjects = new Vector.<NodeValueObject>;
			connections = new Vector.<ConnectionValueObject>;
			if(!inserted){
				if(mapObject.hasOwnProperty("ID")){
					ID = mapObject.ID;
				}else{
					throw new PropNotFoundError("Map does not have property ID");
				}
				/*
				if(mapObject.hasOwnProperty("deleted")){
					deleted = mapObject.deleted == 0? false:true;
				}else{
					throw new PropNotFoundError("Map does not have property 'deleted'");
				}
				*/
				if(mapObject.hasOwnProperty("title")){
					title = mapObject.title;
				}else{
					throw new PropNotFoundError("Map does not have property 'title'");
				}
				if(mapObject.hasOwnProperty("is_hostile")){
					if(mapObject.is_hostile == "")
						is_hostile = 1;
					else
					is_hostile = mapObject.is_hostile;
				}else{
					throw new PropNotFoundError("Map does not have property 'is_hostile'");
				}
				if(mapObject.hasOwnProperty("username")){
					username = mapObject.username;	
				}else{
					throw new PropNotFoundError("Map does not have property 'username'");
				}
				if(mapObject.hasOwnProperty("timestamp")){
					timestamp = mapObject.timestamp;
				}else{
					throw new PropNotFoundError("Map does not have property 'timestamp'");
				}
			}
			var obj:Object;
			try{
				if(mapObject.hasOwnProperty("textbox")){
					if(mapObject.textbox is ArrayCollection){
						for each(obj in mapObject.textbox){
							textboxes.push(new TextboxValueObject(obj,inserted));
						}
					}else{
						textboxes.push(new TextboxValueObject(mapObject.textbox,inserted));
					}
				}
				
				if(mapObject.hasOwnProperty("node")){
					if(mapObject.node is ArrayCollection){
						for each(obj in mapObject.node){
							nodeObjects.push(new NodeValueObject(obj,inserted));
					}
					}else{
						nodeObjects.push(new NodeValueObject(mapObject.node, inserted));
					}
				}
				
				if(mapObject.hasOwnProperty("connection")){
					if(mapObject.connection is ArrayCollection){
						for each(obj in mapObject.connection){
							connections.push(new ConnectionValueObject(obj, inserted));	
						}
					}else{
						connections.push(new ConnectionValueObject(mapObject.connection, inserted));
					}
				}
			}catch(error: PropNotFoundError){
				throw error;
			}
		}
	}
}