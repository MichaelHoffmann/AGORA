package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	// Demonstrates the code required to load external XML
	public class XMLLoader extends Sprite {
		// The variable to which the loaded XML will be assigned
		[Bindable]
		private var loan:XML;
		// The object used to load the XML
		private var urlLoader:URLLoader;
		public var xmlFile:String;
		
		// Constructor
		public function XMLLoader (xmlFile:String) {
			var xmlPath = xmlFile;
			// Specify the location of the external XML
			var urlRequest:URLRequest = new URLRequest(xmlPath);
			// Create an object that can load external text data
			urlLoader = new URLLoader();
			// Register to be notified when the XML finishes loading
			urlLoader.addEventListener(Event.COMPLETE, completeListener);
			// Load the XML
			urlLoader.load(urlRequest);
		}
		// Method invoked automatically when the XML finishes loading
		private function completeListener(e:Event):void {
			// The string containing the loaded XML is assigned to the URLLoader
			// object's data variable (i.e., urlLoader.data). To create a new XML
			// instance from that loaded string, we pass it to the XML constructor
			loan = new XML(urlLoader.data);
			//trace(loan.toXMLString()); // Display the loaded XML, now converted
			// to an XML object
			trace("You have borrowed the following items:");
			//for each (var title:XML in loan..TITLE) {
			//	trace(title);
			//}
		}
	}
}