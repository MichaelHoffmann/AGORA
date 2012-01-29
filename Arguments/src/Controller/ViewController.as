package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.SimpleStatementModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.ArgumentPanel;
	import components.DynamicTextArea;
	
	import flash.events.KeyboardEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.controls.Alert;

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
		
		//---------------------------- Editing Text -------------------------------------//
		public function changeToEdit(argumentPanel:ArgumentPanel):void{
			if(AGORAModel.getInstance().userSessionModel.username.toLowerCase() === argumentPanel.author.toLocaleLowerCase()){
				argumentPanel.toEditState();
			}
			else{
				Alert.show(AGORAParameters.getInstance().EDIT_OTHER);
			}
		}
			
	}
}

class SingletonEnforcer{}