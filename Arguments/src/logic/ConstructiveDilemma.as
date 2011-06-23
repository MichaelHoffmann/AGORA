package logic
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
	import classes.ArgumentPanel;
	public class ConstructiveDilemma extends ParentArg
	{
		
		public function ConstructiveDilemma()
		{
			_langTypes = ["ConstrDil-1(with alternative as claim)","ConstrDil-1(with one proposition as claim)"];
			dbLangTypeNames = ["altclaim", "propclaim"];
			myname = CONST_DILEM;
			//dbName = myname;
			_dbType = "CD";
			
		}
		
		override public function correctUsage():String {
			var output:String = "";
			var i:int;
			/*
			switch(index) {
				case 0: //Either-or with alternative as claim
					output += "Either " + reason[0].input1.text;
					if(exp==true)
						for(i=1;i<reason.length;i++)
							output += " then " + reason[i].input1.text + "; if " + reason[i].input1.text;
					output += " then " + claim.stmt + "; therefore if " + reason[0].input1.text + ", then " + claim.stmt;
					break;
				case 1: //Either-or with one proposition as claim
			}
			*/
			return output;
			
		}
	}
}