package Controller
{
	import Events.AGORAEvent;
	
	import Model.SimpleStatementModel;
	import Model.StatementModel;
	
	import components.ArgumentPanel;
	import components.DynamicTextArea;
	
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
		
		//--------------- add event handlers to the statement model -----------//
		public function configureStatementModel(statementModel:StatementModel):void{
			statementModel.addEventListener(AGORAEvent.TEXT_SAVED, ArgumentController.getInstance().textSaved);
			statementModel.addEventListener(AGORAEvent.FAULT, ArgumentController.getInstance().onFault);
		}
	}
}

class SingletonEnforcer{}