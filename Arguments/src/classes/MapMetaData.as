package classes
{
	public class MapMetaData
	{
		public var mapID:Number;
		public var mapName:String;
		
		public function MapMetaData()
		{
		}
		
		public static function isGreater(x:MapMetaData, y:MapMetaData):int{
			if(x.mapName.toLowerCase() > y.mapName.toLowerCase()){
				return 1;
			}
			else if(x.mapName.toLowerCase() == y.mapName.toLowerCase()){
				return 0;
			} 
			else{
				return -1;
			}
		}
		
	}
}