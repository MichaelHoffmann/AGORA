/* 
@Author: Karthik Rangarajan
@Version: 0.1

@Description: Provides the inference in case no inference is present, and in case inference is present, provides the claim and reason when it is changed
*/
package logic
{
	import mx.utils.ObjectUtil;
	
	public class ModusPonens extends ArgumentSchemes
	{
		public function ModusPonens(claimText:String,reasonText:Array,reversePos:Boolean,inferenceText:String="",inferencePresent:Boolean = false)
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
				var reasonPos:int = _inferenceText.indexOf("If ");
				var claimPos:int = _inferenceText.indexOf(", then ");
				var newReason:String = _inferenceText.substring(reasonPos+3,claimPos);
				var newReasonText:Array = newReason.split(", and ");
				var newClaimText:String = _inferenceText.substring(claimPos+7,_inferenceText.length);
				_claimText = newClaimText;
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "If ";
				for(var i:int=0;i<_reasonText.length;i++){
					if(i==0){
						this._inferenceText = this._inferenceText + _reasonText[i];
					}
					else{
						this._inferenceText = this._inferenceText + ", and " +this._reasonText[i]; 
					}
				}
				this._inferenceText = this._inferenceText + ", then " + _claimText;
				this._reversePos = false;
			}
		}
		
		public function implies(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var reasonPos:int = 0;
				var claimPos:int = _inferenceText.indexOf(" implies ");
				var newReason:String = _inferenceText.substring(0,claimPos);
				var newReasonText:Array = newReason.split(", and ");
				var newClaimText:String = _inferenceText.substring(claimPos+9,_inferenceText.length);
				_claimText = newClaimText;
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
					this._reversePos = false;
				}
				this._inferenceText = "";
				for(var i:int=0;i<_reasonText.length;i++){
					if(i==0){
						this._inferenceText = this._inferenceText + _reasonText[i];
					}
					else{
						this._inferenceText = this._inferenceText + ", and " +this._reasonText[i]; 
					}
				}
				this._inferenceText = this._inferenceText + " implies " + _claimText;
				this._reversePos = false;
			}
		}
		
/*		Function deleted in accordance with Michael Hoffman's instructions

		public function unless(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var claimPos:int = 0;
				var reasonPos:int = _inferenceText.indexOf(" unless ");
				var newClaimText:String = _inferenceText.substring(0,reasonPos);
				var newReason:String = _inferenceText.substring(reasonPos+8,_inferenceText.length);
				var newReasonText:Array = newReason.split(", and ");
				_claimText = newClaimText;
				_reasonText = newReasonText;
				for(var j:int =0;j<_reasonText.length;j++){
					this._reasonText[j] = "It is not the case that "+this._reasonText[j]; 
				}
			}
			else{
				this._inferenceText = _claimText + " unless ";
				for(var i:int=0;i<_reasonText.length;i++){
					if(i==0){
						this._inferenceText = this._inferenceText + _reasonText[i];
					}
					else{
						this._inferenceText = this._inferenceText + ", and " +this._reasonText[i]; 
					}
				}
				for(j =0;j<_reasonText.length;j++){
					this._reasonText[j] = "It is not the case that "+this._reasonText[j]; 
				}
			}
		}
*/		
		public function whenever(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				this._reversePos = false;
				var reasonPos:int = _inferenceText.indexOf("Whenever ");
				//Pitfall here: if claim or reason have a comma in them, this will capture the wrong one. 
				var claimPos:int = _inferenceText.indexOf(", ");
				var newReason:String = _inferenceText.substring(reasonPos+9,claimPos);
				var newReasonText:Array = newReason.split(", and ");
				var newClaimText:String = _inferenceText.substring(claimPos+2,_inferenceText.length);
				_claimText = newClaimText;
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "Whenever ";
				for(var i:int = 0;i<_reasonText.length;i++){
					if(i==0){
						this._inferenceText = this._inferenceText + _reasonText[i];
					}
					else{
						this._inferenceText = this._inferenceText + ", and " +this._reasonText[i]; 
					}
				}
				this._inferenceText = this._inferenceText + ", " + _claimText;
			}
		}
		
		public function providedThat(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				this._reversePos = true;
				var claimPos:int = 0;
				var inferenceString:String = " provided that ";
				var reasonPos:int = _inferenceText.indexOf(inferenceString);
				var newClaimText:String = _inferenceText.substring(0,reasonPos);
				var newReason:String = _inferenceText.substring((newClaimText.length+inferenceString.length),_inferenceText.length);
				var newReasonText:Array = newReason.split(", and ");
				_claimText = newClaimText;
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = _claimText+" provided that ";
				for(var i:int=0;i<_reasonText.length;i++){
					if(i==0){
						this._inferenceText = this._inferenceText + _reasonText[i];
					}
					else{
						this._inferenceText = this._inferenceText + ", and " +this._reasonText[i]; 
					}
				}
				this._reversePos = true;
			}
		}
		
		public function onlyIf(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				this._reversePos = false;
				var argumentArray:Array = _inferenceText.split(" only if ");
				var inferenceString:String = " only if ";
				var newClaimText:String = argumentArray[1];
				var newReasonText:Array = argumentArray[0].split(", and ");
				_claimText = newClaimText;
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
					this._reversePos = false;
				}
				this._inferenceText = "";
				for(var i:int=0;i<_reasonText.length;i++){
					if(i==0){
						this._inferenceText = this._inferenceText + _reasonText[i];
					}
					else{
						this._inferenceText = this._inferenceText + ", and " +this._reasonText[i]; 
					}
				}
				this._inferenceText = this._inferenceText + " only if " + _claimText;
				this._reversePos = false;
			}
		}
		
		public function sufficientCondition(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" is a sufficient condition for ");
				var inferenceString:String = " is a sufficient condition for ";
				var newClaimText:String = argumentArray[1];
				var newReasonText:Array = argumentArray[0].split(", and ");
				_claimText = newClaimText;
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				for(var i:int=0;i<_reasonText.length;i++){
					if(i==0){
						this._inferenceText = this._inferenceText + _reasonText[i];
					}
					else{
						this._inferenceText = this._inferenceText + ", and " +this._reasonText[i]; 
					}
				}
				this._inferenceText = this._inferenceText + " is a sufficient condition for " + this._claimText;
				this._reversePos = false;
			}
		}
		
		public function necessaryCondition(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var claimPos:int = 0;
				this._reversePos = true;
				var inferenceString:String = " is a necessary condition for ";
				var reasonPos:int = _inferenceText.indexOf(inferenceString);
				var newClaimText:String = _inferenceText.substring(0,reasonPos);
				var newReason:String = _inferenceText.substring((newClaimText.length+inferenceString.length),_inferenceText.length);
				var newReasonText:Array = newReason.split(", and ");
				_claimText = newClaimText;
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
					this._reversePos = true;
				}
				this._inferenceText = "";
				this._inferenceText = _claimText+" is a necessary condition for ";
				for(var i:int=0;i<_reasonText.length;i++){
					if(i==0){
						this._inferenceText = this._inferenceText + _reasonText[i];
					}
					else{
						this._inferenceText = this._inferenceText + ", and " +this._reasonText[i]; 
					}
				}
				this._reversePos = true;
			}
		}
	}
}