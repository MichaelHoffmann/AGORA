package logic
{
	import mx.utils.ObjectUtil;
	
	public class DisjunctiveSyllogism extends ArgumentSchemes
	{
		public function DisjunctiveSyllogism(claimText:String, reasonText:Array, reversePos:Boolean,inferenceText:String="", inferencePresent:Boolean=false)
		{
			super(claimText, reasonText, reversePos,inferenceText, inferencePresent);
			_functionNames = ["notP","notQ","alternateP","alternateQ"];
			_functionsArray = [notP,notQ,alternateP,alternateQ];
		}
		
		public function notP(inferencePresent:Boolean):void{
			if(inferencePresent){
				var argumentArray:Array = this._inferenceText.split(" or ");
				var newClaimText:Array = argumentArray[1].split(", but maybe both");
				_claimText = newClaimText[0];
				
				var newReasonText:Array = argumentArray[0].split("Either "); 
				var newReasonTextArray:Array = newReasonText[1].split(", and ");
				_reasonText = ObjectUtil.copy(newReasonTextArray) as Array;
				this._inferenceText = "Either " + _reasonText[0] + " or " + this._claimText + ", but maybe both";
				for(var i:int = 0;i<_reasonText.length;i++){
 					_reasonText[i] = "It is not the case that "+_reasonText[i];
 				}
 				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "Either ";
				this._inferenceText = this._inferenceText + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._inferenceText = this._inferenceText + " or " + this._claimText +", but maybe both";
				this._reversePos = false;
			}
		}
		
		public function notQ(inferencePresent:Boolean):void{
			if(inferencePresent){
				var argumentArray:Array = this._inferenceText.split(" or ");
				var newClaimText:Array = argumentArray[0].split("Either "); 
				_claimText = newClaimText[1];
				
				var newReasonText:Array = argumentArray[1].split(", but maybe both"); 
				var newReasonTextArray:Array = newReasonText[0].split(", and ");
				_reasonText = ObjectUtil.copy(newReasonTextArray) as Array;
				this._inferenceText = "Either " + _claimText + " or " + this._reasonText[0] + ", but maybe both";
				for(var i:int = 0;i<_reasonText.length;i++){
 					_reasonText[i] = "It is not the case that "+_reasonText[i];
				}
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				
				this._inferenceText = "Either " + this._claimText + " or ";
				this._inferenceText = this._inferenceText + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._inferenceText = this._inferenceText + ", but maybe both";
				this._reversePos = true;
			}
		}
		
		public function alternateP(inferencePresent:Boolean):void{
			if(inferencePresent){
				var argumentArray:Array = this._inferenceText.split(" unless ");
				var newClaimText:Array = argumentArray[1].split(", if you reason from not-P");
				if(newClaimText[0]==""){
					_claimText = argumentArray[1];
				}
				else{
					_claimText = newClaimText[0];
				}
				
				var newReasonText:Array = argumentArray[0].split(", and ");
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				_inferenceText = _reasonText[0] + " unless " + _claimText;
				for(var i:int = 0;i<_reasonText.length;i++){
 					_reasonText[i] = "It is not the case that "+_reasonText[i];
 				}
 				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = this._inferenceText + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._inferenceText = this._inferenceText + " unless " + this._claimText;
				this._reversePos = false;	
			}
		}
		
		public function alternateQ(inferencePresent:Boolean):void{
			if(inferencePresent){
				var argumentArray:Array = this._inferenceText.split(" unless ");
				_claimText = argumentArray[0];
				
				var newReasonText:Array = argumentArray[1].split(", if you reason from not-Q");
				var newReasonTextArray:Array = new Array();
				if(newReasonText[0]==""){
					newReasonTextArray = argumentArray[1];
				} 
				else{
					newReasonTextArray = newReasonText[0].split(", and ");
				}
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._inferenceText = this._claimText + " unless " + this._reasonText[0];
 				for(var i:int = 0;i<_reasonText.length;i++){
 					_reasonText[i] = "It is not the case that "+_reasonText[i];
 				}
 				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = this._claimText + " unless ";
				this._inferenceText = this._inferenceText + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._reversePos = true;
			}
		}
	}
}