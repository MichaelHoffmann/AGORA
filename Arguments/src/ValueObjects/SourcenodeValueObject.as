package ValueObjects
{
	public class SourcenodeValueObject
	{
		public var ID:int;
		public var nodeID:int;
		public var deleted:Boolean;
		
		public function SourcenodeValueObject(sourcenode:Object, inserted:Boolean = false)
		{
			try{
				ID = sourcenode.ID;
				nodeID = sourcenode.nodeID;
				deleted = sourcenode.deleted == 1?true:false;
			}catch(error:Error){
				trace("SourcenodeValueObject::Constructor: Error occurred when reading sourcenode object");
			}
		}
	}
}