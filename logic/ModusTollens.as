/* 
@Author: Karthik Rangarajan
@Version: 0.1

@Description: Provides the inference in case no inference is present, and in case inference is present, provides the claim and reason when it is changed
*/
package logic
{
	import mx.utils.ObjectUtil;
	
	public class ModusTollens extends ArgumentSchemes
	{
		public function ModusTollens(claimText:String,reasonText:Array,reversePos:Boolean,inferenceText:String="",inferencePresent:Boolean = false)
		{
			super(claimText,reasonText,reversePos,inferenceText,inferencePresent);
			//Array holds function names that correspond to the actual function in the functionsArrray
			_functionNames = ["ifThen","implies","whenever","onlyIf","providedThat","sufficientCondition","necessaryCondition"];
			//Array that holds the actual functions that should be called according to the language type that is selected
			_functionsArray = [ifThen,implies,whenever,onlyIf,providedThat,sufficientCondition,necessaryCondition];
		}
		/*
		Common algorithm for all functions defined below:
			*If inference is present, recover the claim and reason from the presented inference text. Right now, the best way I have figured out to do it is by obtaining the positions of the language elements, and then obtaining the claim and reason from these positions
			*If inference is not present, insert the claim and reason in the appropriate places after or before tha language elements
			*Once the inference is obtained, make any changes necessary to the claim and reason as are defined by the language rules
		*/
		public function ifThen(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var claimPos:int = _inferenceText.indexOf("If ");
				//Possible pitfall in the above line. If user uses a comma in his claim, then it will end up taking the wrong reason
				var reasonPos:int = _inferenceText.indexOf(", then ");
				var newClaimText:String = _inferenceText.substring(claimPos+3,reasonPos);
				var newReason:String = _inferenceText.substring(reasonPos+7,_inferenceText.length);
				var newReasonText:Array = newReason.split(", and ");
				_claimText = newClaimText;
				_reasonText = newReasonText;
				for(var j:int =0;j<_reasonText.length;j++){
					this._reasonText[j] = "It is not the case that "+this._reasonText[j]; 
				}
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
			else{
				this._inferenceText = "If ";
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = this._inferenceText + this._claimText + ", then ";
				this._inferenceText = this._inferenceText + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
		}
		
		public function implies(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var claimPos:int = 0;
				var reasonPos:int = _inferenceText.indexOf(" implies ");
				var newClaimText:String = _inferenceText.substring(0,reasonPos);
				var newReason:String = _inferenceText.substring(reasonPos+9,_inferenceText.length);
				var newReasonText:Array = newReason.split(", and ");
				_claimText = newClaimText;
				_reasonText = newReasonText;
				for(var j:int =0;j<_reasonText.length;j++){
					this._reasonText[j] = "It is not the case that "+this._reasonText[j]; 
				}
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = this._claimText + " implies ";
				this._inferenceText = this._inferenceText + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
		}
		
		public function whenever(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var claimPos:int = _inferenceText.indexOf("Whenever ");
				var reasonPos:int = _inferenceText.indexOf(", ");
				var newClaimText:String = _inferenceText.substring(claimPos+9,reasonPos);
				var newReason:String = _inferenceText.substring(reasonPos+2,_inferenceText.length);
				var newReasonText:Array = newReason.split(", and ");
				_claimText = newClaimText;
				_reasonText = newReasonText;
				for(var j:int =0;j<_reasonText.length;j++){
					this._reasonText[j] = "It is not the case that "+this._reasonText[j]; 
				}
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "Whenever " + this._claimText + " ";
				this._inferenceText = this._inferenceText + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
		}
		
		public function providedThat(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var claimPos:int = 0;
				var inferenceString:String = " provided that ";
				var reasonPos:int = _inferenceText.indexOf(inferenceString);
				var newClaimText:String = _inferenceText.substring(0,reasonPos);
				var newReason:String = _inferenceText.substring((reasonPos+inferenceString.length),_inferenceText.length);
				var newReasonText:Array = newReason.split(", and ");
				_claimText = newClaimText;
				_reasonText = newReasonText;
				for(var j:int =0;j<_reasonText.length;j++){
					this._reasonText[j] = "It is not the case that "+this._reasonText[j]; 
				}
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
					this._reversePos = true;
				}
				this._inferenceText = "";
				this._inferenceText = this._inferenceText + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._inferenceText = this._inferenceText +  " provided that " + this._claimText;
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
		}
		
		public function onlyIf(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var claimPos:int = 0;
				var inferenceString:String = " only if ";
				var reasonPos:int = _inferenceText.indexOf(inferenceString);
				var newClaimText:String = _inferenceText.substring(0,reasonPos);
				var newReason:String = _inferenceText.substring((reasonPos+inferenceString.length),_inferenceText.length);
				var newReasonText:Array = newReason.split(", and ");
				_claimText = newClaimText;
				_reasonText = newReasonText;
				for(var j:int =0;j<_reasonText.length;j++){
					this._reasonText[j] = "It is not the case that "+this._reasonText[j]; 
				}
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
					this._reversePos = true;
				}
				this._inferenceText = this._claimText + " only if ";
				this._inferenceText = this._inferenceText + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = false;
			}
		}
		
		public function sufficientCondition(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var claimPos:int = 0;
				var inferenceString:String = " is a sufficient condition for ";
				var reasonPos:int = _inferenceText.indexOf(inferenceString);
				var newClaimText:String = _inferenceText.substring(0,reasonPos);
				var newReason:String = _inferenceText.substring((reasonPos+inferenceString.length),_inferenceText.length);
				var newReasonText:Array = newReason.split(", and ");
				_claimText = newClaimText;
				_reasonText = newReasonText;
				for(var j:int =0;j<_reasonText.length;j++){
					this._reasonText[j] = "It is not the case that "+this._reasonText[j]; 
				}
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
					this._reversePos = true;
				}
				this._inferenceText = this._claimText + " is a sufficient condition for ";
				this._inferenceText = this._inferenceText + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
			}
		}
		
		public function necessaryCondition(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var claimPos:int = 0;
				var inferenceString:String = " is a necessary condition for ";
				var reasonPos:int = _inferenceText.indexOf(inferenceString);
				var newClaimText:String = _inferenceText.substring(0,reasonPos);
				var newReason:String = _inferenceText.substring((reasonPos+inferenceString.length),_inferenceText.length);
				var newReasonText:Array = newReason.split(", and ");
				_claimText = newClaimText;
				_reasonText = newReasonText;
				for(var j:int =0;j<_reasonText.length;j++){
					this._reasonText[j] = "It is not the case that "+this._reasonText[j]; 
				}
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = true;
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
				this._inferenceText = this._inferenceText + " is a necessary condition for " + this._claimText;
				this._claimText = "It is not the case that "+this._claimText;
				this._reversePos = false;
			}
		}
		
		
	}
}