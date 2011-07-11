package Model
{
	public class AGORAModel
	{
		public static var reference:AGORAModel;
		public var mapListModel:MapListModel;
		public var myMapsModel:MyMapsModel;
		public var userSessionModel:UserSessionModel;
		
		public function AGORAModel(singletonEnforcement:SingletonEnforcementClass)
		{
			mapListModel = new MapListModel;
			myMapsModel = new MyMapsModel;
			userSessionModel = new UserSessionModel;
			reference = this;
		}
		public static function getInstance():AGORAModel{
			if(!reference){
				reference = new AGORAModel(new SingletonEnforcementClass);
			}
			return reference;
		}
	}
}

class SingletonEnforcementClass{
	public function SingletonEnforcementClass(){
	}
}