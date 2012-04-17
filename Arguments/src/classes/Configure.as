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
	

	
	public class Configure
	{
		public static var xml:XML;
		private static var ready:Boolean=false;
		
		public static function init():void
		{
			[Embed(source="../../../configure.xml", mimeType="application/octet-stream")]
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
		var output:String = lbl.attribute("text");
		trace("Output is: " + output);
		return output;
		}
	}
}