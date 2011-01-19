package logic
{
	import mx.utils.ObjectUtil;
	
	public class ArgumentSchemes
	{
		
		protected var _claimText:String;
		protected var _reasonText:Array;
		protected var _inferenceText:String;
		protected var _inferencePresent:Boolean;
		protected var _functionsArray:Array;
		protected var _functionNames:Array;
		protected var _reversePos:Boolean;
		public function ArgumentSchemes(claimText:String,reasonText:Array,reversePos:Boolean,inferenceText:String="",inferencePresent:Boolean = false)
		{
			this._claimText = claimText;
			this._reasonText = ObjectUtil.copy(reasonText) as Array;
			this._inferenceText = inferenceText;
			this._inferencePresent = inferencePresent;
			this._reversePos = reversePos;
		}

		
		public function getClaim():String{
			return this._claimText;
		}
		
		public function getReason():Array{
			return this._reasonText;
		}
		
		public function set reversePos(value:Boolean):void{
			this._reversePos = value;
		}
		
		public function get reversePos():Boolean{
			return this._reversePos
		}
		
		public function getInference(selectFunction:String):String{
			var index:int = this._functionNames.indexOf(selectFunction);
			this._functionsArray[index](this._inferencePresent);
			return this._inferenceText;
		}
	}
}