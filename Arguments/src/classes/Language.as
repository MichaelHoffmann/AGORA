package classes
{
	/**
	 AGORA - an interactive and web-based argument mapping tool that stimulates reasoning, 
	 reflection, critique, deliberation, and creativity in individual argument construction 
	 and in collaborative or adversarial settings. 
	 Copyright (C) 2011 Georgia Institute of Technology
	 
	 This program is free software: you can redistribute it and/or modify
	 it under the terms of the GNU Affero General Public License as
	 published by the Free Software Foundation, either version 3 of the
	 License, or (at your option) any later version.
	 
	 This program is distributed in the hope that it will be useful,
	 but WITHOUT ANY WARRANTY; without even the implied warranty of
	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 GNU Affero General Public License for more details.
	 
	 You should have received a copy of the GNU Affero General Public License
	 along with this program.  If not, see <http://www.gnu.org/licenses/>.
	 
	 */
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
		public static var language:String = RUSSIAN;
		
		public static var xml:XML;
		private static var ready:Boolean=false;
		
		public static function init():void
		{
			[Embed(source="../../../translation.xml", mimeType="application/octet-stream")]
			const MyData:Class;
			var byteArray:ByteArray = new MyData() as ByteArray;
			var x:XML = new XML(byteArray.readUTFBytes(byteArray.length));
			xml = x;
			ready=true;
		}
	
		/**The key function. Use this to look up a label from the translation document according to the set language.*/
		
		public static function lookup(label:String):String{
			if(!ready){
				init();				
			}
			trace("Now looking up:" + label);
			var lbl:XMLList = xml.descendants(label);
			var lang:XMLList = lbl.descendants(language);
			var output:String = lang.attribute("text");
			if(!output){
				output = "error | ошибка | Fehler --- There was a problem getting the text for this item. The label was: " + label;
			}
			trace("Output is: " + output);
			return output;
		}
	}
}