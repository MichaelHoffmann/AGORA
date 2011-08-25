package Controller.logic
{
	import Model.ArgumentTypeModel;

	public class Equivalence extends ParentArg
	{
		private static var instance:Equivalence;
		
		public function Equivalence()
		{
			super();
		}
		
		public static function getInstance():Equivalence{
			if(instance == null){
				instance = new Equivalence;
			}
			return instance;
		}
		
		override public function formText(argumentTypeModel:ArgumentTypeModel):void{
			
		}
	}
}