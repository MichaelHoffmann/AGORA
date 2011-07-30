package Model
{
	public class InferenceModel extends StatementModel
	{
		private var _typed:Boolean;
		
		public function InferenceModel()
		{
			super();
		}
		
		//---------------------- Forming StatmentModels ---------------//

		public function get typed():Boolean
		{
			return _typed;
		}

		public function set typed(value:Boolean):void
		{
			_typed = value;
		}

		public static function createStatementFromObject(obj:Object):StatementModel{
			var statementModel:InferenceModel = new InferenceModel;
			statementModel.ID = obj.ID;
			return statementModel;
		}
		
	}
}