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
		public function XMLEscapeText(s:String):String{
			s = s.replace(/%/g, "%25"); //must be first
			s = s.replace(/&/g, "&amp;");//must be before the various &s are added in
			s = s.replace(/\"/g, "&quot;");
			//s = s.replace(/'/g, "&apos;"); //This does not appear to be necessary
			s = s.replace(/</g, "&lt;");
			s = s.replace(/>/g, "&gt;");
			s = s.replace(/&/g, "%26"); //must be last
			return s;
		}
		public function escapeAmpersands(s:String):String{
			s = s.replace(/&/g, "%26");
			return s;
		}
	}
}

class SingletonEnforcer{}