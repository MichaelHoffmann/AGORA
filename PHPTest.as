

public function completeHandler(e:Event):void {
	var xml:XML = new XML(e.target.data);
	trace(xml);
	
	var textboxes:Array = new Array();
	var nodes:Array = new Array();
	var connections:Array = new Array();
	
	trace("Preparing to break down into the data...");
	for(var i:int = 0; i<xml.child("textbox").length(); i++)
	{
		var textbox:XML = xml.child("textbox")[i];
		trace(textbox.toXMLString());
	}
	for(i = 0; i<xml.child("node").length(); i++)
	{
		var node:XML = xml.child("node")[i];
		trace(node.toXMLString());
		for(var j:int =0; j<node.child("nodetext").length(); j++)
		{
			//Add the referenced textbox entries to your node
		}
	}
	for(i = 0; i<xml.child("connection").length(); i++)
	{
		var connection:XML = xml.child("connection")[i];
		trace(connection.toXMLString());
		for(j=0; j<node.child("sourcenode").length(); j++)
		{
			//Add the referenced node entries to your connection
		}
	}
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

