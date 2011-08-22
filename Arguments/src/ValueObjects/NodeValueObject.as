package ValueObjects
{
	import mx.collections.ArrayCollection;
	
	public class NodeValueObject
	{
		public var ID:int;
		public var type:String;
		public var author:String;
		public var x:int;
		public var y:int;
		public var typed:Boolean;
		public var positive:Boolean;
		public var connectedBy:String;
		public var deleted:Boolean;
		public var nodetexts:Vector.<NodetextValueObject>;
		
		public function NodeValueObject(nodeObject:Object)
		{
			try{
				ID = nodeObject.ID;
				type = nodeObject.Type;
				author = nodeObject.Author;
				x = nodeObject.x;
				y = nodeObject.y;
				typed = nodeObject.typed == 0? false : true;
				positive = nodeObject.positive == 1? true : false;
				connectedBy = nodeObject.connected_by;
				deleted = nodeObject.deleted == 1? true: false; 
				if(nodeObject.hasOwnProperty("nodetext")){
					nodetexts = new Vector.<NodetextValueObject>;
					if(nodeObject.nodetext is ArrayCollection){
						for each(var obj:Object in nodeObject.nodetext){
							nodetexts.push(new NodetextValueObject(obj));
						}
					}else{
						nodetexts.push(new NodetextValueObject(nodeObject.nodetext));
					}
				}
			}catch(error:Error){
				trace("NodeValueObject::Constructor: Error reading nodeObject");
			}
		}
	}
}