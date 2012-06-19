package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class PublishMapModel extends EventDispatcher
	{
		public var category:XML;
		private var request: HTTPService;
		private var requestChildren: HTTPService;
		public function PublishMapModel(target:IEventDispatcher=null)
		{
			super(target);
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().categoryURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onCategoryFetched);
			request.addEventListener(FaultEvent.FAULT, onFault);
			requestChildren = new HTTPService;
			requestChildren.url = AGORAParameters.getInstance().childCategoryURL;
			requestChildren.resultFormat="e4x";
			requestChildren.addEventListener(ResultEvent.RESULT, onCategoryFetched);
			requestChildren.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function sendForTopLevel():void{
			request.send();
		}
		public function sendForChildren(categoryName:String):void{
			requestChildren.send({parentCategory: "'" + categoryName + "'"});
		}
		protected function onCategoryFetched(event:ResultEvent):void{
			category= event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.CATEGORY_FETCHED_FOR_PUBLISH));
		}
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
	}
}