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
				if(inserted){
					connID = connectionObject.ID;
				}
				if(!inserted){
					connID = connectionObject.connID;
					type = connectionObject.type;
					targetnode = connectionObject.targetnode;
					
					x = connectionObject.x;
					y = connectionObject.y;
					deleted = connectionObject.deleted == 1? true:false;
					var sourcenode:SourcenodeValueObject;
					if(connectionObject.hasOwnProperty("sourcenode")){
						sourcenodes = new Vector.<SourcenodeValueObject>;
						if(connectionObject.sourcenode is ArrayCollection){
							for each(var obj:Object in connectionObject.sourcenode){
								sourcenode = new SourcenodeValueObject(obj, inserted);
								sourcenodes.push(sourcenode);
							}
						}else{
							sourcenode = new SourcenodeValueObject(connectionObject.sourcenode, inserted);
							sourcenodes.push(sourcenode);
						}
					}
				}
			}catch(error:Error){
				trace("ConnectionValueObject::Constructor: Error occurred when reading connection object");				
			}
		}
	}
}