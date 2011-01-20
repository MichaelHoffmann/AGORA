package logic
{
	import mx.utils.ObjectUtil;
	
	public class Equivalence extends ArgumentSchemes
	{
		public function Equivalence(claimText:String,reasonText:Array,reversePos:Boolean,inferenceText:String="",inferencePresent:Boolean = false){
			super(claimText,reasonText,reversePos,inferenceText,inferencePresent);
			//Array holds function names that correspond to the actual function in the functionsArrray
			_functionNames = ["ifOnlyIfP","ifOnlyIfQ","ifOnlyIfNotP","ifOnlyIfNotQ","justInCaseP","justInCaseQ","justInCaseNotP","justInCaseNotQ","necessaryP","necessaryQ","necessaryNotP","necessaryNotQ","equivalentP","equivalentQ","equivalentNotP","equivalentNotQ"];
			//Array that holds the actual functions that should be called according to the language type that is selected
			_functionsArray = [ifOnlyIfP,ifOnlyIfQ,ifOnlyIfNotP,ifOnlyIfNotQ,justInCaseP,justInCaseQ,justInCaseNotP,justInCaseNotQ,necessaryP,necessaryQ,necessaryNotP,necessaryNotQ,equivalentP,equivalentQ,equivalentNotP,equivalentNotQ];
		}
		
		public function ifOnlyIfP(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" if and only if ");
				var newClaimText:Array = argumentArray[1].split(", if you reason from P");
				_claimText = newClaimText[0];
				var newReasonText:Array = new Array;
				newReasonText[0] = argumentArray[0];
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._inferenceText = this._reasonText[0] + " if and only if " + this._claimText;
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _reasonText[0];
				this._inferenceText = this._inferenceText + " if and only if " + this._claimText;
				this._reversePos = false;
			}
		}
		
		public function ifOnlyIfQ(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" if and only if ");
				_claimText = argumentArray[0];
				var newReasonText:Array = argumentArray[1].split(", if you reason from Q");
				_reasonText[0] = newReasonText[0];
				this._inferenceText = this._claimText + " if and only if " + this._reasonText[0];
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _claimText;
				this._inferenceText = this._inferenceText + " if and only if " + this._reasonText[0];
				this._reversePos = true;
			}
		}
		
		public function ifOnlyIfNotP(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" if and only if ");
				var newClaimText:Array = argumentArray[1].split(", if you reason from not-P");
				_claimText = newClaimText[0];
				var newReasonText:Array = new Array;
				newReasonText[0] = argumentArray[0];
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._inferenceText = this._reasonText[0] + " if and only if " + this._claimText;
				_reasonText[0] = "It is not the case that " + _reasonText[0];
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _reasonText[0];
				this._inferenceText = this._inferenceText + " if and only if " + this._claimText;
				_reasonText[0] = "It is not the case that " + _reasonText[0];
				this._reversePos = false;
			}
		}
		
		public function ifOnlyIfNotQ(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" if and only if ");
				_claimText = argumentArray[0];
				var newReasonText:Array = argumentArray[1].split(", if you reason from not-Q");
				_reasonText[0] = newReasonText[0];
				this._inferenceText = this._claimText + " if and only if " + this._reasonText[0];
				_reasonText[0] = "It is not the case that " + _reasonText[0];
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _claimText;
				this._inferenceText = this._inferenceText + " if and only if " + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._reversePos = true;
			}
		}
		
		public function justInCaseP(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" just in case ");
				var newClaimText:Array = argumentArray[1].split(", if you reason from P");
				_claimText = newClaimText[0];
				var newReasonText:Array = new Array;
				newReasonText[0] = argumentArray[0];
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._inferenceText = this._reasonText[0] + " just in case " + this._claimText;
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _reasonText[0];
				this._inferenceText = this._inferenceText + " just in case " + this._claimText;
				this._reversePos = false;
			}
		}
		
		public function justInCaseQ(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" just in case ");
				_claimText = argumentArray[0];
				var newReasonText:Array = argumentArray[1].split(", if you reason from Q");
				_reasonText[0] = newReasonText[0];
				this._inferenceText = this._claimText + " just in case " + this._reasonText[0];
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _claimText;
				this._inferenceText = this._inferenceText + " just in case " + this._reasonText[0];
				this._reversePos = true;
			}
		}
		
		public function justInCaseNotP(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" just in case ");
				var newClaimText:Array = argumentArray[1].split(", if you reason from Not-P");
				_claimText = newClaimText[0];
				var newReasonText:Array = new Array;
				newReasonText[0] = argumentArray[0];
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._inferenceText = this._reasonText[0] + " just in case " + this._claimText;
				_reasonText[0] = "It is not the case that " + _reasonText[0];
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _reasonText[0];
				this._inferenceText = this._inferenceText + " just in case " + this._claimText;
				_reasonText[0] = "It is not the case that " + _reasonText[0];
				this._reversePos = false;
			}
		}
		
		public function justInCaseNotQ(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" just in case ");
				_claimText = argumentArray[0];
				var newReasonText:Array = argumentArray[1].split(", if you reason from Not-Q");
				_reasonText[0] = newReasonText[0];
				this._inferenceText = this._claimText + " just in case " + this._reasonText[0];
				_reasonText[0] = "It is not the case that " + _reasonText[0];
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _claimText;
				this._inferenceText = this._inferenceText + " just in case " + this._reasonText[0];
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._reversePos = true;
			}
		}
		
		public function necessaryP(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" is a necessary and sufficient condition for ");
				var newClaimText:Array = argumentArray[1].split(", if you reason from P");
				_claimText = newClaimText[0];
				var newReasonText:Array = new Array;
				newReasonText[0] = argumentArray[0];
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._inferenceText = this._reasonText[0] + " is a necessary and sufficient condition for " + this._claimText;
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _reasonText[0];
				this._inferenceText = this._inferenceText + " is a necessary and sufficient condition for" + this._claimText;
				this._reversePos = false;
			}
		}
		
		public function necessaryQ(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" is a necessary and sufficient condition for ");
				_claimText = argumentArray[0];
				var newReasonText:Array = argumentArray[1].split(", if you reason from Q");
				_reasonText[0] = newReasonText[0];
				this._inferenceText = this._claimText + " is a necessary and sufficient condition for " + this._reasonText[0];
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _claimText;
				this._inferenceText = this._inferenceText + " is a necessary and sufficient condition for " + this._reasonText;
				this._reversePos = true;
			}
		}
		
		public function necessaryNotP(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" is a necessary and sufficient condition for ");
				var newClaimText:Array = argumentArray[1].split(", if you reason from not-P");
				_claimText = newClaimText[0];
				var newReasonText:Array = new Array;
				newReasonText[0] = argumentArray[0];
				_reasonText = ObjectUtil.copy(newReasonText) as Array;
				this._inferenceText = this._reasonText[0] + " is a necessary and sufficient condition for " + this._claimText;
				_reasonText[0] = "It is not the case that " + _reasonText[0];
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _reasonText[0];
				this._inferenceText = this._inferenceText + " is a necessary and sufficient condition for " + this._claimText;
				_reasonText[0] = "It is not the case that " + _reasonText[0];
				this._reversePos = false;
			}
		}
		
		public function necessaryNotQ(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" is a necessary and sufficient condition for ");
				_claimText = argumentArray[0];
				var newReasonText:Array = argumentArray[1].split(", if you reason from not-Q");
				_reasonText[0] = newReasonText[0];
				this._inferenceText = this._claimText + " is a necessary and sufficient condition for " + this._reasonText[0];
				_reasonText[0] = "It is not the case that " + _reasonText[0];
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = "";
				this._inferenceText = _claimText;
				this._inferenceText = this._inferenceText + " is a necessary and sufficient condition for " + this._reasonText;
				this._reversePos = true;
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
			}
		}
		
		public function equivalentP(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" and ");
				var newClaimText:Array = argumentArray[1].split(" are equivalent");
				_claimText = newClaimText[0];
				_reasonText[0] = argumentArray[0];
				this._inferenceText = this._reasonText[0] + " and " + this._claimText + " are equivalent";
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = this._reasonText[0] + " and " + this._claimText + " are equivaent";
				this._reversePos = false;
			}
		}
		
		public function equivalentQ(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" and ");
				_claimText = argumentArray[0];
				var newReasonText:Array = argumentArray[1].split(" are equivalent");
				_reasonText[0] = newReasonText[0];
				this._inferenceText = this._claimText + " and " + this._reasonText[0] + " are equivalent";
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = this._claimText + " and " + this._reasonText[0] + " are equivalent";
				this._reversePos = true;
			}
		}
		
		public function equivalentNotP(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" and ");
				var newClaimText:Array = argumentArray[1].split(" are equivalent");
				_claimText = newClaimText[0];
				_reasonText[0] = argumentArray[0];
				this._inferenceText = this._reasonText[0] + " and " + this._claimText + " are equivalent";
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._reversePos = false;
			}
			else{
				if(this._reversePos){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = this._reasonText[0] + " and " + this._claimText + " are equivaent";
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._reversePos = false;
			}
		}
		
		public function equivalentNotQ(inferencePresent:Boolean = false):void{
			if(inferencePresent){
				var argumentArray:Array = _inferenceText.split(" and ");
				_claimText = argumentArray[0];
				var newReasonText:Array = argumentArray[1].split(" are equivalent");
				_reasonText[0] = newReasonText[0];
				this._inferenceText = this._claimText + " and " + this._reasonText[0] + " are equivalent";
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._reversePos = true;
			}
			else{
				if(!(this._reversePos)){
					var temp:String = this._claimText;
					this._claimText = this._reasonText[0];
					this._reasonText[0] = temp;
				}
				this._inferenceText = this._claimText + " and " + this._reasonText[0] + " are equivalent";
				this._reasonText[0] = "It is not the case that " + this._reasonText[0];
				this._reversePos = true;
			}
		}
	}
}