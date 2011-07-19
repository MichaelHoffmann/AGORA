package Controller
{
	public class LoadController
	{
		private static var instance:LoadController;
		
		public function LoadController(singletonEnforcer:SingletonEnforcer)
		{
			instance = this;
		}
		
		//----------------------Get Instance------------------------------//
		public static function getInstance():LoadController{
			if(!instance){
				instance = new LoadController(new SingletonEnforcer);
			}
			return instance;
		}
		

	}
}


class SingletonEnforcer{
	
}