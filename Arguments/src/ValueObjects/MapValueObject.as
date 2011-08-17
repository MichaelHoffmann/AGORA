package ValueObjects
{
	import mx.collections.ArrayCollection;
	
	public class MapValueObject
	{
		public var ID:int;
		public var deleted:Boolean;
		public var title:String;
		public var username:String;
		public var timestamp:String;
		public var textboxes:Vector.<TextboxValueObject>;
		public var nodeObjects:Vector.<NodeValueObject>;
		public var connections:Vector.<ConnectionValueObject>;
		
		public function MapValueObject(mapObject:Object)
		{
			textboxes = new Vector.<TextboxValueObject>;
			nodeObjects = new Vector.<NodeValueObject>;
			connections = new Vector.<ConnectionValueObject>;
			
			ID = mapObject.ID;
			deleted = mapObject.deleted == 0? false:true;
			//title = mapObject.title;
			username = mapObject.username;
			timestamp = mapObject.timestamp;
			
			var obj:Object;
			
			if(mapObject.hasOwnProperty("textbox")){
				if(mapObject.textbox is ArrayCollection){
					for each(obj in mapObject.textbox){
						textboxes.push(new TextboxValueObject(obj));
					}
				}else{
					textboxes.push(new TextboxValueObject(mapObject.textbox));
				}
			}
			
			if(mapObject.hasOwnProperty("node")){
				if(mapObject.node is ArrayCollection){
					for each(obj in mapObject.node){
						nodeObjects.push(new NodeValueObject(obj));
					}
				}else{
					nodeObjects.push(new NodeValueObject(mapObject.node));
				}
			}
			
			if(mapObject.hasOwnProperty("connection")){
				if(mapObject.connection is ArrayCollection){
					for each(obj in mapObject.connection){
						connections.push(new ConnectionValueObject(obj));	
					}
				}else{
					connections.push(new ConnectionValueObject(mapObject.connection));
				}
			}
		}
	}
}