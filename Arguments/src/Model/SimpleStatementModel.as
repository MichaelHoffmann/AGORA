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
		
		private var _hasOwn:Boolean;
		
		public function SimpleStatementModel(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		//------------------------Getters/Setters-------------------------//
		
		public function get hasOwn():Boolean
		{
			return _hasOwn;
		}

		public function set hasOwn(value:Boolean):void
		{
			_hasOwn = value;
		}

		public function get text():String{
			return _text;
		}
		public function set text(value:String):void{
			_text = value;
		}
		
		public function get forwardList():Vector.<SimpleStatementModel>{
			return _forwardList;
		}
		
		public function set forwardList(value:Vector.<SimpleStatementModel>):void{
			_forwardList = value;
		}
		
		public function get ID():int{
			return _ID;
		}
		public function set ID(value:int):void{
			_ID = value;              
		}
		
		//------------------ get simple statment --------------------------//
		public static function createSimpleStatementFromXML(xml:XML):SimpleStatementModel{
			var simpleStatement:SimpleStatementModel = new SimpleStatementModel;
			simpleStatement.ID = xml.@ID;
			simpleStatement.text = xml.@text;
			return simpleStatement;
		}
		
		public static function createSimpleStatementFromObject(obj:Object):SimpleStatementModel{
			var simpleStatement:SimpleStatementModel = new SimpleStatementModel;
			simpleStatement.ID = obj.ID;
			simpleStatement.text = obj.text;
			return simpleStatement;
		}
	}
}