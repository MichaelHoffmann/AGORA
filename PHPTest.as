

public function completeHandler(e:Event):void {
	trace("Entered the handler");
	var xml:XML = new XML(e.target.data);
	trace("Reached this line");
	trace(xml.child("textbox")[0].toXMLString());
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

