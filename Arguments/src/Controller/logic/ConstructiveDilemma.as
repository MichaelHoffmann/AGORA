package Controller.logic
{
	import Model.ArgumentTypeModel;
	
	import components.ArgumentPanel;

	public class ConstructiveDilemma extends ParentArg
	{
		private static var instance:ConstructiveDilemma;
		
		public function ConstructiveDilemma()
		{
			langTypes = ["ConstrDil-1(with alternative as claim)","ConstrDil-1(with one proposition as claim)"];
			//dbLangTypeNames = ["altclaim", "propclaim"];
			//myname = CONST_DILEM;
			//dbName = myname;
			//_dbType = "CD";
			
		}
		
		public static function getInstance():ConstructiveDilemma{
			if(instance==null){
				instance = new ConstructiveDilemma;
			}
			return instance;
		}
		
		override public function formText(argumentTypeModel:ArgumentTypeModel):void{
				
		}
		
		/*
		override public function correctUsage():String {
			var output:String = "";
			var i:int;
			switch(index) {
				case 0: //Either-or with alternative as claim
					output += "Either " + reason[0].input1.text;
					if(exp==true)
						for(i=1;i<reason.length;i++)
							output += " then " + reason[i].input1.text + "; if " + reason[i].input1.text;
					output += " then " + claim.stmt + "; therefore if " + reason[0].input1.text + ", then " + claim.stmt;
					break;
				case 1: //Either-or with one proposition as claim
			}
		
			return output;
			
		}
		*/
	}
}