package ValueObjects
{
	public class SourcenodeValueObject
	{
		public var ID:int;
		public var nodeID:int;
		public var deleted:Boolean;
		
		public function SourcenodeValueObject(sourcenode:Object, inserted:Boolean = false)
		{
			if(sourcenode.hasOwnProperty("ID"))
			ID = sourcenode.ID;
			else
				throw new PropNotFoundError("sourcenode does not have an 'ID'");
			if(sourcenode.hasOwnProperty("nodeID"))
			nodeID = sourcenode.nodeID;
			else
				throw new PropNotFoundError("sourcenode does not have property 'nodeID'");
			if(sourcenode.hasOwnProperty("deleted"))
			deleted = sourcenode.deleted == 1?true:false;
			else
				throw new PropNotFoundError("sourcenode does not have property 'deleted'");
		}
	}
}