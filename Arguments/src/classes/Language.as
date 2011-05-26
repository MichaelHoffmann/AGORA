package classes
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	public class Language
	{
		//I will set the language to either GERMAN, RUSSIAN or ENGLISH
		//based on this, you could read the values into the variables
		//by default, the language is EN-US
		
		public static const GERMAN:String = "GER";
		public static const EN_US:String = "EN-US";
		public static const RUSSIAN:String = "RUS";
		public static var language:String = EN_US;
		
		
		public function Language()
		{
		}
		//Variables goes here
		public static var intro:String;
		private static var xml:XML=new XML;
		
		public static function readXMLData():void
		{
			
			var rq:URLRequest = new URLRequest("http://agora.gatech.edu/dev/translation.xml");
			var urlLoader:URLLoader = new URLLoader;
			//check the path and name of the file
			urlLoader.load(rq);
			urlLoader.addEventListener(Event.COMPLETE, loadVariables);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				Alert.show("Communication Error");
			});
		}
		
		public static function loadVariables(event:Event):void
		{
			xml=XML(event.target.data);
			trace("XML loaded.");
			lookup("Label");
		}
		
		public static function lookup(label:String):void{
			trace("Now looking up:" + label);
			trace(xml.descendants(label));
		}
		
	}
}