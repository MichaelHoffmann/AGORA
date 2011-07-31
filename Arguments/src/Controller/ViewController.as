package Controller
{
	import Model.SimpleStatementModel;
	
	import classes.ArgumentPanel;
	import classes.DynamicTextArea;
	
	import flash.events.KeyboardEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;

	public class ViewController
	{
		private static var instance:ViewController;
		public function ViewController(singletonEnforcer:SingletonEnforcer)
		{
			//event handlers	
		}
		
		public static function getInstance():ViewController{
			if(instance == null){
				instance = new ViewController(new SingletonEnforcer);
			}
			return instance;
		}
	
		//---------------- Bind a new dta to a simpleStatementModel------------//
		public function getNewDynamicTextArea(simpleStatement:SimpleStatementModel, changeWatcher:ChangeWatcher):DynamicTextArea{
			var dta:DynamicTextArea = new DynamicTextArea;
			dta.model = simpleStatement;
			return dta;
		}		
	}
}

class SingletonEnforcer{}