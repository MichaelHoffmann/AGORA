package Model
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class SimpleStatementModel extends EventDispatcher
	{
		[Bindable]
		private var _text:String;
		[Bindable]
		private var _forwardList:Vector.<SimpleStatementModel>;
		private var _ID:int;
		
		public function SimpleStatementModel(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		//------------------------Getters/Setters-------------------------//
		public function get text():String{
			return _text;
		}
		public function set text(value:String):void{
			_text = value;
		}
		
		public function get ID():int{
			return _ID;
		}
		public function set ID(value:int):void{
			_ID = value;
		}
	}
}