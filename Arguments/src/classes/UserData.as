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
	import components.LoginWindow;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;

	public class UserData
	{
		public static var userNameStr:String ="";
		public static var _passHashStr:String="";
		public static var valid:int = 0;;
	    private static var _uid:int = 0; // read only outside the class
		public static var timestamp:String="";
		
		public function UserData()
		{
		}
		public static function set passHashStr(value:String):void
		{
			_passHashStr = value;
		}
		public static function get passHashStr(): String
		{
			return _passHashStr;
		}
		public static function get uid():int
		{
			return _uid;	
		}
		
		private static function verifyUser(event:Event, object:LoginWindow):void
		{
			var xml:XML = XML(event.target.data);
			if(xml.@ID.length() == 1)
			{
				_uid = xml.@ID[0];
			}
			else
			{
				userNameStr = "";
			}
			object.verifyLogin();
		}
		
		public static function isValid():Boolean
		{
			if(_uid != 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private static function errorHandler(event:IOErrorEvent, object:LoginWindow):void
		{
			Alert.show("Error occurred when trying to contact server");
			object.verifyLogin();
		}
		
		public static function validateUser(userName:String, passHash:String, object:LoginWindow):void
		{
			userNameStr = userName;
			var urlLoader:URLLoader = new URLLoader;
			var request:URLRequest = new URLRequest;
			request.url = "http://agora.gatech.edu/dev/login.php";
			request.data = new URLVariables("username="+userName+"&pass_hash="+passHash);
			passHashStr = passHash;
			request.method = URLRequestMethod.GET;
			urlLoader.addEventListener(Event.COMPLETE,function(event:Event):void{verifyUser(event,object)});
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,function(event:IOErrorEvent):void{errorHandler(event,object)});
			urlLoader.load(request);
		}
		
		
	}
}