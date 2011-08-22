package components
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
	
	import ValueObjects.AGORAParameters;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	
	import spark.components.Panel;
	
	public class GridPanel extends Panel
	{
		public static var count:int;
		public var gridX:int;
		public var gridY:int;
		public function GridPanel()
		{
			super();
			this.setStyle("dropShadowVisible",false);
			this.setStyle("cornerRadius",4);
			this.setStyle("chromeColor",uint("0xffffff"));
			this.setStyle("backgroundColor",uint("0x999966"));
		}
		override protected function createChildren():void
		{
			super.createChildren();
		}
		
		public function setX(value:int):void{
			y = value * AGORAParameters.getInstance().gridWidth;
		}
		
		public function setY(value:int):void{
			x = value * AGORAParameters.getInstance().gridWidth;
		}
		
	}
}