package ValueObjects
{
	import flash.sampler.NewObjectSample;
	
	import mx.collections.ArrayCollection;
	
	public class ConnectionValueObject
	{
		public var connID:int;
		public var type:String;
		public var targetnode:int;
		public var x:int;
		public var y:int;
		public var deleted:Boolean;
		public var sourcenodes:Vector.<SourcenodeValueObject>;
		
		public function ConnectionValueObject(connectionObject:Object, inserted:Boolean = false)
		{
			try{
				connID = connectionObject.ID;
				type = connectionObject.type;
				targetnode = connectionObject.targetnode;
				x = connectionObject.x;
				y = connectionObject.y;
				deleted = connectionObject.deleted == 1? true:false;
				if(connectionObject.hasOwnProperty("sourcenode")){
					sourcenodes = new Vector.<SourcenodeValueObject>;
					if(connectionObject.sourcenode is ArrayCollection){
						for each(var obj:Object in connectionObject.sourcenode){
							var  sourcenode:SourcenodeValueObject = new SourcenodeValueObject(obj, inserted);
							sourcenodes.push(sourcenode);
						}
					}else{
						trace("ConnectionValueObject::Constructor: Error. A connection cannot exist with only one node. ConnID: " + connID);
					}
				}
			}catch(error:Error){
				trace("ConnectionValueObject::Constructor: Error occurred when reading connection object");				
			}
		}
	}
}