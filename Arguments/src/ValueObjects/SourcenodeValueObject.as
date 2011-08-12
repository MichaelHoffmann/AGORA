package ValueObjects
{
	public class SourcenodeValueObject
	{
		var ID:int;
		var nodeID:int;
		var deleted:Boolean;
		public function SourcenodeValueObject(sourcenode:Object)
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