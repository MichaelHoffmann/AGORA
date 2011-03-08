include "Textbox.as"

public function completeHandler(e:Event):void {
	var xml:XML = new XML(e.target.data)
	trace(xml);
}
public function init():void {
	var uv:URLVariables = new URLVariables();
	uv.map_id = 1; 
	var rq:URLRequest = new URLRequest("http://localhost/load_map.php");
	rq.method = URLRequestMethod.POST;
	rq.data=uv;
	var ldr:URLLoader = new URLLoader();
	ldr.dataFormat = URLLoaderDataFormat.TEXT;
	ldr.addEventListener(Event.COMPLETE, completeHandler);
	ldr.load(rq);
}