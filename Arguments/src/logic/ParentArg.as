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
	import classes.DynamicTextArea;
	import classes.Inference;
	
	import components.ArgSelector;
	
	import flashx.textLayout.operations.SplitParagraphOperation;
	
	import mx.utils.ObjectUtil;
	
	
	public class ParentArg {
		
		public var _isLanguageExp:Boolean;
		public var myname:String;
		//This is set by the Inference that creates it.
		//Each object of ParentArg belongs only to 
		//one Inference, and it holds a reference to the Inference object.
		public var inference:Inference;
		//In the backend, each of the classes is referred by another name. For example, Modus Ponens is referred to as therefore.
		//Ideally, they could be the same, but the server and client were developed parallelly and then integrated.
		//public var dbName:String;
		public var _langTypes:Array;
		public var dbLangTypeNames:Array;
		public var multipleReasons:Boolean;
		public var _expLangTypes:Array;
		public static var MOD_PON:String = "Modus Ponens";
		public static var MOD_TOL:String = "Modus Tollens";
		public static var COND_SYLL:String = "Conditional Syllogism";
		public static var DIS_SYLL:String = "Disjunctive Syllogism";
		public static var NOT_ALL_SYLL:String = "Not-All Syllogism";
		public static var CONST_DILEM:String = "Constructive Dilemma";
		public static var EXP_AND:String = "and";
		public static var EXP_OR:String = "or";
		public var _dbType:String;
		
		public function setIsExp():void{
			if(inference.myschemeSel.selectedType != null){
				for each(var langType:String in _expLangTypes){
					if(langType == inference.myschemeSel.selectedType){
						_isLanguageExp = true;	
					}
				}
			}
		}
		
		
		public function get dbType():String
		{
			for(var i:int=0; i<_langTypes.length; i++)
			{
				if(inference.myschemeSel.selectedType == _langTypes[i])
				{
					return _dbType+dbLangTypeNames[i];
				}
			}
			return "Unset";
		}
		
		public function getOption(dbString:String):String
		{
			return "";
		}
		
		public function getLanguageType(dbString:String):String
		{
			for(var i:int=0;i<dbLangTypeNames.length;i++)
			{
				if(dbString.indexOf(dbLangTypeNames[i]) >= 0)
				{
					return _langTypes[i];
				}
				
			}
			return "";
		}
		
		public var mySelector:ArgSelector;	// reference to be moved from Inference to here - specific argscheme
		
		public function ParentArg()
		{
			_dbType = "Unset";	
		}
		
		public function deleteLinks():void
		{
			var dta:DynamicTextArea;
			for(var i:int=0; i < inference.input.length; i++)
			{
				dta = inference.input[i];
				dta.forwardList.splice(0,dta.forwardList.length);
			}
			for(i=0; i < inference.inputs.length; i++)
			{
				dta = inference.inputs[i];
				dta.forwardList.splice(0,dta.forwardList.length);
			}
			for(i=0; i < inference.reasons.length; i++)
			{
				var reason:ArgumentPanel = inference.reasons[i];
				reason.input1.forwardList.splice(0,reason.input1.forwardList.length);
				for(var m:int=0; m < reason.inputs.length; m++)
				{
					dta = reason.inputs[m];
					dta.forwardList.splice(0, dta.forwardList.length);
				}
			}
			var claim:ArgumentPanel = inference.claim;
			dta = claim.input1;
			claim.input1.forwardList.splice(0,claim.input1.forwardList.length);
			for(i=0; i<claim.inputs.length; i++)
			{
				dta = claim.inputs[i];
				dta.forwardList.splice(0,dta.forwardList.length);
			}
		}
		
		public function link(dta:DynamicTextArea, box:DynamicTextArea):void
		{
			for(var i:int=0; i < dta.forwardList.length; i++)
			{
				if(dta.forwardList[i] == box)
					return;
			}
			dta.forwardList.push(box);
		}
		
		public function addInitialReasons():void{};
		
		public function createLinks():void
		{
			var	claim:ArgumentPanel = inference.claim;
			var reasons:Vector.<ArgumentPanel> = inference.reasons;
			claim.input1.forwardList.push(inference.input[0]);
			inference.input[0].forwardList.push(inference.inputs[0]);
			for(var i:int=0; i < reasons.length; i++)
			{
				reasons[i].input1.forwardList.push(inference.input[i+1]);
				inference.input[i+1].forwardList.push(inference.inputs[1]);
			}
			inference.implies = true;
		}
		public function correctUsage():String { return "";}
	}
}