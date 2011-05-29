package classes
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
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
		
		public static var xml:XML;
		private static var ready:Boolean=false;
		
		public static function init():void
		{
			//[Embed(source="translation.xml", mimeType="application/octet-stream")]
			const MyData:Class;
			var byteArray:ByteArray = new MyData() as ByteArray;
			var x:XML = new XML(byteArray.readUTFBytes(byteArray.length));
			xml = x;
			ready=true;
		}

		
		/**The key function. Use this to look up a label from the translation document according to the set language.*/
		/*
		public static function lookup(label:String):String{
			if(!ready){
				init();				
			}
			trace("Now looking up:" + label);
			var lbl:XMLList = xml.descendants(label);
			var lang:XMLList = lbl.descendants(language);
			var output:String = lang.attribute("text");
			trace("Output is: " + output);
			return output;
		}
		*/
		
	}
}