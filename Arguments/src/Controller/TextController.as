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
		public function escapeText(s:String):String{
			s.replace(/&/g, "&amp");
			s.replace(/\"/g, "&quot");
			//s.replace(/'/g, "&apos;"); //This does not appear to be necessary
			s.replace(/</g, "&lt;");
			s.replace(/>/g, "&gt;");
			s.replace(/&/, "%26");
			return s;
		}
	}
}

class SingletonEnforcer{}