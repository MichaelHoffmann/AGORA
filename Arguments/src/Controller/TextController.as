package Controller
{
	import components.DynamicTextArea;

	public class TextController
	{
		
		private static var instance:TextController;
		
		public function TextController(singletonEnforcer:SingletonEnforcer)
		{
			//Event Listeners
		}
		
		public static function getInstance() :TextController{
			if(instance == null){
				instance = new TextController(new SingletonEnforcer);
			}
			return instance;
		}
			
		//---------------- Text Changed ------------------//
		public function updateModelText(dta:DynamicTextArea):void{
			dta.model.text = dta.text;
		}
	}
}

class SingletonEnforcer{}