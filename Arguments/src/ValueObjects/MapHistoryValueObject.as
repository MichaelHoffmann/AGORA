package ValueObjects
{
	public class MapHistoryValueObject
	{
		public var mapId:int;
		public var owner:String;
		public var mapName:String;
		public var ownerUrl: String;
		public function MapHistoryValueObject(history:Object)
		{
			if(history.hasOwnProperty("mapOwner")){
				owner = history.mapOwner;
			}else{
				throw new PropNotFoundError("history object doesn't have property 'mapOwner'");
			}
			
			if(history.hasOwnProperty("mapOwnerUrl")){
				ownerUrl = history.mapOwnerUrl;
			}else{
				throw new PropNotFoundError("history object doesn't have property 'mapOwnerUrl'");
			}
			
			if(history.hasOwnProperty("mapId")){
				mapId = history.mapId;
			}else{
				throw new PropNotFoundError("history object doesn't have property 'mapId'");
			}
			
			if(history.hasOwnProperty("mapName")){
				mapName = history.mapName;
			}else{
				throw new PropNotFoundError("history object doesn't have property 'mapname'");
			}
			
				}
	}
}