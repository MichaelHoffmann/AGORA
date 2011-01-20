package logic
{
	import mx.utils.ObjectUtil;
	
	public class XORSyllogism extends ArgumentSchemes
	{
		public function XORSyllogism(claimText:String, reasonText:Array, reversePos:Boolean,inferenceText:String="", inferencePresent:Boolean=false)
		{
			super(claimText, reasonText, reversePos,inferenceText, inferencePresent);
			_functionNames = ["notQ","notP","alternateP","alternateQ"];
			_functionsArray = [notQ,notP,alternateP,alternateQ];
		}
		
		public function alternateQ(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" or ");
				var claimTextArray:Array = argumentArray[0].split("Either ");
				_claimText = claimTextArray[1];
				
				var newReasonText:Array = argumentArray[1].split(", but not both");
				var reasonText:Array = new Array();
				
				this._inferenceText = "Either " + _claimText + " or " + newReasonText[0] + ", but not both";
				reasonText[0] = "It is not the case that " + newReasonText[0];
				_reasonText = ObjectUtil.copy(reasonText) as Array;
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._reversePos = true;
				this._inferenceText = "Either " + _claimText + " or " + _reasonText[0] + ", but not both";
				_reasonText[0] = "It is not the case that " + _reasonText[0];
			}
		}
		
		
		public function alternateP(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" or ");
				var newClaimTextArray:Array = argumentArray[1].split(", but not both");
				_claimText = newClaimTextArray[0];
				
				var newReasonText:Array = argumentArray[0].split("Either "); 
				
				var reasonText:Array = new Array();
				this._inferenceText = "Either " + newReasonText[1] + " or " + _claimText + ", but not both";
				reasonText[0] = "It is not the case that " + newReasonText[1];
				_reasonText = ObjectUtil.copy(reasonText) as Array;
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "Either " + _reasonText[0] + " or " + _claimText + ", but not both";
				_reasonText[0] = "It is not the case that " + _reasonText[0];
				this._reversePos = false;
			}
		}
		
		public function notP(inferencePresent:Boolean):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" or ");
				var newClaimTextArray:Array = argumentArray[1].split(", but not both");
				_claimText = newClaimTextArray[0];
				
				var newReasonText:Array = argumentArray[0].split("Either ");
				var reasonText:Array = new Array();
				
				this._inferenceText = "Either " + newReasonText[1] + " or " + _claimText + ", but not both";
				
				reasonText[0] = newReasonText[1];
				_claimText = "It is not the case that " + newClaimTextArray[0];
				_reasonText = ObjectUtil.copy(reasonText) as Array;
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "Either " + _reasonText[0] + " or " + _claimText + ", but not both";
				this._reversePos = false;
			}
		}
		
		public function notQ(inferencePresent:Boolean):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" or ");
				var claimTextArray:Array = argumentArray[0].split("Either ");
				_claimText = claimTextArray[1];
				
				
				var newReasonText:Array = argumentArray[1].split(", but not both");
				var reasonText:Array = new Array();
				reasonText[0] = newReasonText[0];
				
				this._inferenceText = "Either " + _claimText + " or " + reasonText[0] + ", but not both";
				
				_claimText = "It is not the case that " + claimTextArray[1];
				
				_reasonText = ObjectUtil.copy(reasonText) as Array;
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "Either " + _claimText + " or " + _reasonText + ", but not both";
				this._reversePos = true;
			}

		}
		
	}
}