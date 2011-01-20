package logic
{
	import mx.utils.ObjectUtil;
	
	public class NotBothSyllogism extends ArgumentSchemes
	{
		public function NotBothSyllogism(claimText:String, reasonText:Array, reversePos:Boolean,inferenceText:String="", inferencePresent:Boolean=false)
		{
			super(claimText, reasonText, reversePos,inferenceText, inferencePresent);
			_functionNames = ["notP","notQ"];
			_functionsArray = [notP,notQ];
		}
		
		public function notQ(inferencePresent:Boolean):void{
			if(inferencePresent){
				var argumentArray:Array = this._inferenceText.split(" and ");
				var claimTextArray:Array = argumentArray[0].split("Not both ");
				_claimText = ObjectUtil.copy(claimTextArray[1]) as String;
				
				var reasonTextArray:Array = argumentArray[1].split(", but maybe none of both");
				var newReasonText:Array = reasonTextArray[0].split(", and ");
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._inferenceText = "Not both " + _claimText + " and " + _reasonText[0] + ", but maybe none of both";
				_reasonText[0] = _reasonText[0];
				this._reversePos = true;
				_claimText = "It is not the case that " + _claimText;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._reversePos = true;
				this._inferenceText = "Not both " + _claimText + " and ";
				this._inferenceText = this._inferenceText + _reasonText[0];
				_reasonText[0] = _reasonText[0];
				_claimText = "It is not the case that " + _claimText;
				this._inferenceText = this._inferenceText + ", but maybe none of both";
				
			}
		}
		
		public function notP(inferencePresent:Boolean):void{
			if(inferencePresent){
				var argumentArray:Array = this._inferenceText.split(" and ");
				var newClaimText:Array = argumentArray[1].split(", but maybe none of both");
				this._claimText = newClaimText[0];
				
				var newReasonTextArray:Array = argumentArray[0].split("Not both ");
				var newReasonText:Array = newReasonTextArray[1].split(", and ");
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._inferenceText = "Not both " + _reasonText[0] + " and " + _claimText + ", but maybe none of both";
				_reasonText[0] = _reasonText[0];
				this._reversePos = false;
				_claimText = "It is not the case that " + _claimText;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
					this._reversePos = true;
				}
				this._reversePos = false;
				this._inferenceText = "Not both ";
				this._inferenceText = this._inferenceText + _reasonText[0];
				_reasonText[0] = _reasonText[0];
				this._inferenceText = this._inferenceText + " and " + this._claimText + ", but maybe none of both";
				_claimText = "It is not the case that " + _claimText;
			}
		}
		
	}
}