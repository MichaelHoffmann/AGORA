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
		public static const ENGLISH:String = "EN-US";
		public static const RUSSIAN:String = "RUS";
		public static var language:String = ENGLISH;
		
		
		public function Language()
		{
		}
		//Variables goes here
		public static var ready:Boolean=false;
		private static var xml:XML=new XML;
		/*
			XML is a global variable so that it only has to be loaded once. This will save speed and bandwidth.
		*/
		
		public static function readXMLData():void
		{
			trace("Now reading XML data...");
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
			ready=true;
		}
		
		/**The key function. Use this to look up a label from the translation document according to the set language.*/
		public static function lookup(label:String):String{
			trace("Now looking up:" + label);
			var lbl:XMLList = xml.descendants(label);
			var lang:XMLList = lbl.descendants(language);
			var output:String = lang.attribute("text");
			trace("Output is: " + output);
			return output;
		}
		
	}
}