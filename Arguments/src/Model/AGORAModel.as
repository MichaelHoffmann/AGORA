package Model
{
	import Events.AGORAEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class AGORAModel extends EventDispatcher
	{
		private static var reference:AGORAModel;
		
		public var mapListModel:MapListModel;
		public var myMapsModel:MyMapsModel;
		public var userSessionModel:UserSessionModel;
		
		
		private var _state:int;
		public static const MENU:int = 0;
		public  static const MAP:int = 1;
		
		
		//-------------------------------------Constructor------------------------------------------------------//
		public function AGORAModel(singletonEnforcement:SingletonEnforcementClass, target:IEventDispatcher=null)
		{
			super(target);
			
			mapListModel = new MapListModel;
			myMapsModel = new MyMapsModel;
			userSessionModel = new UserSessionModel;
			state = MENU;
			reference = this;
		}
		
		
		
		//-----------------------------Getters and Setters--------------------------------------------------------//
		public function get state():int
		{
			return _state;
		}

		public function set state(value:int):void
		{
			if(_state != value){
			 	_state = value;
				dispatchEvent(new AGORAEvent(AGORAEvent.APP_STATE_SET));
			}
		}

		
		//----------------------------Get Instance--------------------------------------------------------//
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