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
			if(inserted){
				if(connectionObject.hasOwnProperty("ID"))
					connID = connectionObject.ID;
				else
					throw new PropNotFoundError("connectionObject does not have property 'ID'");
				
			}
			//note that the server's xml has different attributes
			//in responses to insert.php and to a load.php
			if(!inserted){
				if(connectionObject.hasOwnProperty("connID"))
					connID = connectionObject.connID;
				else
					throw new PropNotFoundError("connectionObject does not have property 'connID'");
				if(connectionObject.hasOwnProperty('type'))
					type = connectionObject.type;
				else
					throw new PropNotFoundError("connectionObject does not have property 'type'");
				if(connectionObject.hasOwnProperty("targetnode"))
					targetnode = connectionObject.targetnode;
				else
					throw new PropNotFoundError("connectionObject does not have property 'targetnode'");
				if(connectionObject.hasOwnProperty('x'))
					x = connectionObject.x;
				else
					throw new PropNotFoundError("connectionObject does not have property 'x'");
				if(connectionObject.hasOwnProperty("y"))
					y = connectionObject.y;
				else
					throw new PropNotFoundError("connectionObject does not have property  'y'");
				if(connectionObject.hasOwnProperty("deleted")){
					deleted = connectionObject.deleted == 1? true:false;
				}else{
					throw new PropNotFoundError("connectionObject does not have property 'deleted'");
				}
				try{
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
					else{
						//connections can be without sourcenodes!
					}
				}catch(error:PropNotFoundError){
					throw error;
				}
				
			}
		}
	}
}