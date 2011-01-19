/*

@Author: Karthik Rangarajan
@Version: 0
Provides the inference based on the logic type and language type selected. 

*/

package classes
{

	public class InferenceProvider
	{
		/*
		Import all the classes from the logic package
		*/
		import logic.*;

		private var _claimText:String;
		private var _reasonText:Array;
		private var _inferenceText:String;
		private var _logicClassNames:Array;
		private var _logicClasses:Array;
		private var _inferencePresent:Boolean;
		private var _reversePos:Boolean;
		/*
		Constructor takes in the claim, reason, and the inference if it is already present
		*/
		public function InferenceProvider(claim:String,reason:Array,reversePos:Boolean=false,inference:String = "",inferencePresent:Boolean = false)
		{
			this._claimText = claim;
			this._reasonText = reason;
			this._inferenceText = inference;
			this._inferencePresent = inferencePresent;
			this._reversePos = reversePos;
			/*
			Array that holds all the possible logic class names so that they can be easily matched to the logicClasses that is used below 
			*/
			_logicClassNames = ["ModusPonens","ModusTollens","Equivalence","DisjunctiveSyllogism","NotBothSyllogism","XORSyllogism"];
			/*
			Holds a reference to all the classes in the package logic that refer to the particular logic types
			*/
			_logicClasses = [ModusPonens,ModusTollens,Equivalence,DisjunctiveSyllogism,NotBothSyllogism,XORSyllogism];
		}		
		
		/*
		/*
		Obtains the inference from the logic classes
		*/
		public function getInferenceText(selectedLogic:String,selectedLanguageType:String):String{
			//Obtain the index of the logic type.
			var index:int = _logicClassNames.indexOf(selectedLogic);
			//Instantiate the corresponding logic class.
			var inferenceObject:Object = new _logicClasses[index](_claimText,_reasonText,_reversePos,_inferenceText,_inferencePresent);
			//Obtain the inference by providing the language type.
			_inferenceText = inferenceObject.getInference(selectedLanguageType);
			//obtain the claim, in case it is changed.
			_claimText = inferenceObject.getClaim();
			//obtain the reason, in case it is changed.
			_reasonText = inferenceObject.getReason();
			//return the inference to the main application.
			_reversePos = inferenceObject.reversePos;
			return _inferenceText;
		}
		
		/*
		Returns the claim to the main application
		*/
		public function get claimText():String{
			return _claimText;
		}
		
		/*
		Returns the reason to the main application
		*/
		public function get reasonText():Array{
			return _reasonText;
		}
		
		public function get reversePos():Boolean{
			return this._reversePos;
		}
		
		public function set reversePos(value:Boolean):void{
			this._reversePos = value;
		}
		/*
		public function setInferencePresent(inferencePresent:Boolean):void{
			this.inferencePresent = inferencePresent;
		}
		*/

	}
}