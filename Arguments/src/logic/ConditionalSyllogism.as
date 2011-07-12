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
	import classes.Language;
	
	import mx.controls.Alert;
	
	
	public class ConditionalSyllogism extends ParentArg
	{		
		public var built:Boolean;	
		
		public function ConditionalSyllogism()
		{
			_langTypes = ["If-then","Implies"];
			dbLangTypeNames = ["ifthen","implies"];
			_expLangTypes = ["If-then", "Implies"];
			myname = COND_SYLL;
			_dbType = "CS";
			built = false;
			// Both types here are expandable. like a chain rule
		}
		
		override public function addInitialReasons():void
		{
			if(inference == null)
			{
				//Help for programming. Translation not required. 
				Alert.show("Error: This logic class is not associated with an enabler");
				return;
			}
			var claim:ArgumentPanel = inference.claim;
			var reasons:Vector.<ArgumentPanel> = inference.reasons;
			if(!reasons[0].multiStatement)
			{
				reasons[0].multiStatement = true;
				reasons[0].implies = true;
				reasons[0].inputs[1].editable = false;
				reasons[0].connectingStr = inference.myschemeSel.selectedType;
			}
		}
		
		override public function createLinks():void
		{
			var i:int;
			var claim:ArgumentPanel = inference.claim;
			var reason:ArgumentPanel = inference.reasons[0];
			
			if(inference.claim.statementNegated)
			{
				inference.claim.statementNegated = false;
			}
			
			for(i=0; i < inference.reasons.length; i++)
			{
				if(inference.reasons[i].statementNegated)
				{
					inference.reasons[i].statementNegated = false;
				}
			}
			
			if(claim.inference == null && claim.rules.length == 1 && claim.userEntered == false && reason.userEntered == false && !(claim is Inference))
			{
				trace('user entered:' + claim.userEntered);
				claim.multiStatement = true;
				claim.implies = true;
				addInitialReasons();
				claim.inputs[0].text = "Q";
				claim.inputs[1].text = "P";
				claim.makeUnEditable();
				reason.inputs[0].text = "S";
				reason.inputs[1].text = "R";
				reason.makeUnEditable();
			}
			
			inference.claim.connectingStr = inference.myschemeSel.selectedType;
			inference.claim.makeUnEditable();
			inference.reasons[0].connectingStr = inference.myschemeSel.selectedType;
			inference.reasons[0].makeUnEditable();
			
			for(i=0; i < inference.reasons.length; i++)
			{
				if(!inference.reasons[i].multiStatement)
				{
					inference.reasons[i].multiStatement = true;
					inference.reasons[i].implies = true;
					inference.reasons[i].connectingStr = inference.claim.connectingStr;
					inference.reasons[i].makeUnEditable();
					inference.reasons[i].inputs[1].editable = false;
					//trace(inference.reasons[i].displayTxt.visible);
				}
			}
			
			
			if(inference.claim.multiStatement)
			{
				//link: claim's premise to first reason's premise
				link(inference.claim.inputs[1],inference.reasons[0].inputs[1]);
				for(i = 0; i < inference.reasons.length - 1; i++)
				{
					//a reson's conclusion is the next reasons premise
					//all of them are implies boxes
					link(inference.reasons[i].inputs[0],inference.reasons[i+1].inputs[1]);
					inference.reasons[i].inputs[0].forwardUpdate();	
				}
				//link(inference.reasons[i].inputs[0],inference.inputs[1]);
				link(inference.reasons[i].inputs[0],inference.input[0]);
				inference.reasons[i].inputs[0].forwardUpdate();	
				//claim's conclusion to enabler's conclusion
				link(inference.claim.inputs[0],inference.input[0]);
				link(inference.claim.inputs[1],inference.input[0]);
				link(inference.input[0],inference.input1);
				inference.claim.inputs[1].forwardUpdate();	
				inference.claim.inputs[0].forwardUpdate();
				
			}
		}
		
		override public function correctUsage():String {
			var output:String = "";
			var i:int;
			
			switch(inference.myschemeSel.selectedType)
			{
				case _langTypes[0]:
					inference.inputs[1].text = inference.reasons[inference.reasons.length - 1].inputs[0].text;
					if(inference.claim.multiStatement)
					{
						inference.inputs[0].text = inference.claim.inputs[0].text;
					}
					output = Language.lookup("ArgIfCap") + inference.inputs[1].text +
						"," +  Language.lookup("ArgThen") +  inference.inputs[0].text;
					inference.inputs[1].forwardUpdate();
					inference.inputs[0].forwardUpdate();
					break;
				case _langTypes[1]:
					inference.inputs[1].text = inference.reasons[inference.reasons.length - 1].inputs[0].text;
					if(inference.claim.multiStatement)
					{
						inference.inputs[0].text = inference.claim.inputs[0].text;
					}
					output = inference.inputs[1].text + Language.lookup("ArgImplies") + inference.inputs[0].text;
					inference.inputs[1].forwardUpdate();
					inference.inputs[0].forwardUpdate();
			}
			return output;
		}
	}
}