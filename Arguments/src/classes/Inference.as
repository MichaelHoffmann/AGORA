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
	import components.ArgSelector;
	import components.HelpText;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import logic.*;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.Menu;
	import mx.controls.listClasses.ListData;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.MenuEvent;
	import mx.managers.FocusManager;
	import mx.utils.ArrayUtil;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.SkinnableContainer;
	import spark.components.VGroup;
	
	import classes.Configure;
	import classes.Language;
	
	public class Inference extends ArgumentPanel
	{
		//temporary variable for generating temporary permanent ids
		public static var connections:int;
		//list of reasons
		public var reasons:Vector.<ArgumentPanel>;
		//list of dynamic text areas that are made invisible
		public var input:Vector.<DynamicTextArea>;
		//what is this
		public var argumentClass:String;
		//vgroup
		public var vgroup:VGroup;
		//The statement that is enabled by this enabler and a set of reasons
		public var claim:ArgumentPanel;
		//a reference to the panel that is directly above the Enabler (Inference)
		public var _menuPanel:MenuPanel;
		//The Menu
		public var myschemeSel:ArgSelector;
		//Reference to the specific argument scheme class
		public var myArg:ParentArg;		
		//Is the scheme expandable
		private var _hasMultipleReasons:Boolean;
		//public var connectionID:int;
		//public var connectionIDs:Vector.<int>;
		//Used when constructing the argument beginning with reason
		//Set to true if the user has begun to choose an argument scheme.
		//happens when construct argument is chosen
		private var _selectedBool:Boolean;
		//A scheme has been chosen for this argument and cannot be changed
		//until it becomes an open end
		private var _typed:Boolean;
		public static var REASON_ADDED:String  = "Reason Added";
		public static var REASON_DELETED:String = "Reason Deleted";
		//private var _schemeChangable:Boolean;
		private var _schemeSelected:Boolean;
		//The string that is displayed
		public var _displayStr:String;
		//if adding multiple reasons are allowed
		public var reasonAddable:Boolean;
		
		public var connID:int;
		public var connTID:int;
		
		public var hasConnID:Boolean;
		
		private var addReasonMenuData:XML;
		
		public function Inference()
		{
			super();
			addReasonMenuData = <root><menuitem   label = "... another reason for this argument so that only the combination of all reasons justifies the claim" /></root>;
			//connectionID = connections++;
			//connectionIDs = new Vector.<int>(0,false);
			panelType = ArgumentPanel.INFERENCE;
			state = 0; //Inference is always a Universal statement
			input = new Vector.<DynamicTextArea>(0,false);
			reasons = new Vector.<ArgumentPanel>(0,false);
			
			this.addEventListener(REASON_ADDED,reasonAdded);
			
			this.setStyle("cornerRadius",30);	
			selectedBool = false;
			typed = false;
			schemeSelected = false;
			reasonAddable = false;
			hasConnID = false;
		}
		///Getters and Setters
		
		
		public function get displayStr():String
		{
			return _displayStr;
		}
		
		public function set displayStr(value:String):void
		{
			_displayStr = value;
			displayTxt.text = _displayStr;
			input1.text = _displayStr;
			displayTxt.height = input1.height;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function get connectionType():String
		{
			if(myArg == null)
				return "";
			return myArg.dbType;
		}
		
		public function get selectedBool():Boolean
		{
			return _selectedBool;
		}
		
		public function set selectedBool(value:Boolean):void
		{
			_selectedBool = value;
		}
		
		public function get schemeSelected():Boolean
		{
			return _schemeSelected;
		}
		
		public function set schemeSelected(value:Boolean):void
		{
			_schemeSelected = value;
			setRuleState();
		}
		
		public function get hasMultipleReasons():Boolean
		{
			return _hasMultipleReasons;
		}
		
		public function set hasMultipleReasons(value:Boolean):void
		{
			_hasMultipleReasons = value;
			if(myArg != null)
			{
				if(hasMultipleReasons)	
				{
					myschemeSel.typeSelector.dataProvider = myArg._expLangTypes;
				}
				else
				{
					myschemeSel.typeSelector.dataProvider = myArg._langTypes;
				}
			}
			setRuleState();
		}
		
		public function get typed():Boolean
		{
			return _typed;
		}
		
		public function set typed(value:Boolean):void
		{
			_typed = value;
			changePossibleSchemes();
		}
		
		public function reasonDeleted():void
		{
			if(reasons.length > 1)
			{
				hasMultipleReasons = true;
			}
			else
			{
				hasMultipleReasons = false;
			}
			if(myArg != null)
			{
				myArg.createLinks();
			}
		}
		
		public function reasonAdded(event:Event):void
		{
			if(reasons.length > 1)
			{
				hasMultipleReasons = true;
			}
			else
			{
				hasMultipleReasons = false;
			}
			if(myArg != null)
			{
				myArg.createLinks();
			}
			if(claim.inference == null)
			{
				reasons[reasons.length - 1].makeUnEditable();
				reasons[reasons.length - 1].displayTxt.text = Language.lookup("EnterReason");
			}
			else
			{
				reasons[reasons.length - 1].makeEditable();
			}
			claim.removeEventListener(Inference.REASON_ADDED, reasonAdded);
		}
		
		public function setRuleState():void
		{
			//seting type makes sense only after a particular scheme has been chosen
			//before this, reasons may be empty
			if(schemeSelected){
				if( (reasons.length > 1 || reasons[0].rules.length > 0) && schemeSelected)
				{
					typed = true;
				}
				else 
				{
					typed = false;
					
				}	
			}
			
		}
		
		//This happens when the argument
		//  scheme is fixed
		public function changePossibleSchemes():void
		{
			if(myschemeSel != null){
				if(typed)
				{
					myschemeSel.mainSchemes.visible = false;
					myschemeSel.typeSelector.x = 0;
					myschemeSel.andor.x = myschemeSel.typeSelector.width;
					if(myArg != null)
					{
						if(hasMultipleReasons)
						{
							myschemeSel.typeSelector.dataProvider = myArg._expLangTypes;
						}
						else
						{
							myschemeSel.typeSelector.dataProvider = myArg._langTypes;
						}
					}
					if(myArg is ConditionalSyllogism)
					{
						argType.changeSchemeBtn.enabled = false;
					}
				}
			}
			if(!typed && myschemeSel != null)
			{
				myschemeSel.mainSchemes.visible = true;
				myschemeSel.typeSelector.x = myschemeSel.mainSchemes.width;
				myschemeSel.andor.x = myschemeSel.typeSelector.x + myschemeSel.typeSelector.width;
				if(myArg!=null)
				{
					argType.changeSchemeBtn.enabled = true;
				}
				
			}
			if(myschemeSel != null){
				myschemeSel.invalidateProperties();
				myschemeSel.invalidateSize();
				myschemeSel.invalidateDisplayList();
			}
		}
		
		public function menuCreated(fe:FlexEvent):void
		{ 
		}
		
		public function setArgScheme(event:ListEvent):void
		{
			var scheme:String = event.itemRenderer.data.toString();
			if(scheme == ParentArg.DIS_SYLL || scheme == ParentArg.NOT_ALL_SYLL)
			{
				myschemeSel.visible = false;
				schemeSelected = true;
				parentMap.helpText.visible = false;
			}
			
		}
		
		public function get argType():MenuPanel
		{
			return _menuPanel;
		}
		
		public function set argType(value:MenuPanel):void
		{
			_menuPanel = value;
			_menuPanel.addEventListener(FlexEvent.CREATION_COMPLETE,addToMap);
		}
		
		public function addToMap(fe:FlexEvent):void
		{
			argType.addReasonBtn.addEventListener(MouseEvent.CLICK,addReasonHandler);
			argType.changeSchemeBtn.addEventListener(MouseEvent.CLICK,changeScheme);
		}
		
		public function changeScheme(event:MouseEvent):void
		{
			changeHandler(event);
		}
		
		protected function goToReason(event:FlexEvent):void
		{
			/*
			var panel:ArgumentPanel = ArgumentPanel(event.target);
			panel.makeEditable();
			if(reasons.length > 0)
			{
				if(typed)
				{
					if(myArg.myname == ParentArg.MOD_TOL)
					{
						panel.statementNegated = true;
					}
				}
			}
			*/
		}
		
		protected function reasonInserted(event:Event):void{
			//getting response XML from insert.php
			var responseXML:XML = XML(event.target.data);
			//adding it to insert node
			var xml:XML = <insert></insert>;
			xml.appendChild(responseXML);
			
			//requesting load_map.php with new timestamp
			var urlRequest:URLRequest = new URLRequest;
			urlRequest.url = Configure.lookup("baseURL") + "load_map.php";
			var timestamp:String;
			
			if(parentMap.timestamp == null){
				timestamp = "0";
			}else{
				timestamp = parentMap.timestamp;
			}
			
			var urlRequestVars:URLVariables = new URLVariables("map_id="+parentMap.ID + "&" + "timestamp=" + timestamp);
			urlRequest.data = urlRequestVars;
			urlRequest.method = URLRequestMethod.GET;
			var urlLoader:URLLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, function (event:Event):void{
				var loadResponseVariables:XML = XML(event.target.data);
				var loadXML:XML = <load></load>;
				loadXML.appendChild(loadResponseVariables);
				var insertLoad:XML = <xmldata></xmldata>;
				insertLoad.appendChild(xml);
				insertLoad.appendChild(loadXML);
				addReasonToMap(insertLoad);
			});
			urlLoader.load(urlRequest);
		}
		
		public function addReasonToMap(responseXML:XML):void{
			//var responseXML:XML = XML(event.target.data);
			//trace(responseXML);
			//separate XML for Argument Panel
			var reasonXML:XML = new XML("<map></map>");
			var textboxList:XMLList = responseXML.insert.map.textbox;
			reasonXML.appendChild(textboxList);
			var firstNodeText:XML = responseXML.insert.map.node[0];
			reasonXML.appendChild(firstNodeText);
			
			
			var tmp:ArgumentPanel = new ArgumentPanel();
			tmp._initXML = reasonXML;
			for each( var lXML:XML in responseXML.load.map.node){
				if( lXML.@ID == responseXML.insert.map.node[0].@ID){
					tmp.gridX = lXML.@x;
					tmp.gridY = lXML.@y;
				}
			}
			
			parentMap.layoutManager.registerPanel(tmp);
			parentMap.addElement(tmp);
			tmp.addEventListener(FlexEvent.CREATION_COMPLETE, goToReason);
			
			try{
				reasons.push(tmp);
				//connectionIDs.push(connections++);
				tmp.inference = this;
				//create an invisible box in the inference rule
				var tmpInput:DynamicTextArea = new DynamicTextArea();
				//visual
				parentMap.addElement(tmpInput);
				tmpInput.visible = false;
				
				//logical
				var inferenceRule:Inference = this;
				tmpInput.panelReference = inferenceRule;
				inferenceRule.input.push(tmpInput);		
				
				//set the id
				tmpInput.id = tmp.input1.id;
				
				//binding
				//tmpInput.forwardList.push(inferenceRule.input1);	//invisible box input forwards to the visible box input1 in inference
				//tmp.input1.forwardList.push(tmpInput);
				//this new reason's input1 text forwards to that invisible box
				dispatchEvent(new Event(REASON_ADDED,true,false));
				
			}catch (e:Error)
			{
				Alert.show(e.toString());
			}
		}
		
		public function addReason():void
		{
			var xml:XML = parentMap.getAddReason(this);
			var urlRequest:URLRequest = new URLRequest;
			urlRequest.url = Configure.lookup("baseURL") + "insert.php";
			var urlRequestVars:URLVariables = new URLVariables("uid="+UserData.uid+"&"+"pass_hash="+UserData.passHashStr+"&xml="+ xml);
			urlRequest.data = urlRequestVars;
			urlRequest.method = URLRequestMethod.GET;
			var urlLoader:URLLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, reasonInserted);
			urlLoader.load(urlRequest);
		}
		
		public function addReasonHandler(event:MouseEvent):void
		{
			
			var menu:Menu = Menu.createMenu(null, addReasonMenuData,false);
			menu.labelField = "@label";
			menu.addEventListener(MenuEvent.ITEM_CLICK, function (event:MenuEvent):void {
				if(schemeSelected != true)
				{
					Alert.show("Complete the enabler before adding further reasons");
					return;
				}
				if(myArg._isLanguageExp || (myArg is ModusTollens && reasonAddable == true && myschemeSel.selectedType == myArg._expLangTypes[0]))
				{
					addReason();
				}
				else
				{	
					if(myArg is ModusTollens && myschemeSel.selectedType == myArg._expLangTypes[0])
					{
						Alert.show("Select the language type that determines how the reasons are combined: 'or' or 'and'");
						reasonAddable = true;	
					}
					else
					{
						Alert.show("The current language scheme does not allow multiple reasons. Please choose an expandable language type before adding a reason");
					}
				}
			});
			var globalPosition:Point = parentMap.getGlobalCoordinates(new Point(argType.x,argType.y + argType.height));
			menu.show(globalPosition.x,globalPosition.y);
		}
		
		override public function makeUnEditable():void
		{
		}
		override public function makeEditable():void
		{
		}
		
		override public function onArgumentPanelCreate(e:FlexEvent):void
		{
			super.onArgumentPanelCreate(e);
			doneBtn.removeEventListener(MouseEvent.CLICK,makeUnEditable);
			displayTxt.removeEventListener(MouseEvent.CLICK,lblClicked);
			displayTxt.visible = true;
			displayTxt.toolTip = Language.lookup("Enabler");
			bottomHG.visible = true;
			doneHG.visible = false;
			stmtTypeLbl.removeEventListener(MouseEvent.CLICK,toggle);
			multiStatement = true;
			group.removeElement(msVGroup);
			setIDs();
		}
		
		public function chooseEnablerText():void
		{
			if(myschemeSel.scheme != null){
				setRuleState();
				if(myschemeSel.scheme.length == 0)
				{
					Alert.show("This lanugage type cannot be supported by an argument. Please choose a suitable language type before proceeding...");
					return;
				}
			}
			
			if((myArg is DisjunctiveSyllogism || myArg is NotAllSyllogism) && typed)
			{
				return;
			}
			myschemeSel.visible=true;
			parentMap.setChildIndex(myschemeSel,parentMap.numChildren - 1);
			myschemeSel.x = this.gridY*parentMap.layoutManager.uwidth + this.width;
			myschemeSel.y = this.gridX*parentMap.layoutManager.uwidth;
			myschemeSel.depth = parentMap.parent.numChildren;
			selectedBool = true;
			parentMap.helpText.visible = true;
			parentMap.helpText.x = myschemeSel.x + myschemeSel.width + 20;
			parentMap.helpText.y = myschemeSel.y - 200;
		}
		
		public function changeHandler(e:MouseEvent):void
		{
			chooseEnablerText();
		}
		
		public function setType(le:ListEvent):void
		{
			if(myArg is ModusTollens)
			{
				if(myschemeSel.selectedType != myArg._expLangTypes[0])
				{
					reasonAddable = false;
				}
			}
			if(myschemeSel.andor.visible==false)
			{
				myschemeSel.visible = false;
			}
			schemeSelected = true;
			parentMap.helpText.visible = false;
		}
		
		public function displayTypes(le:ListEvent):void
		{
			setRuleState();
			myschemeSel.selectedScheme = le.itemRenderer.data.toString();
			var sublist:List = myschemeSel.typeSelector;
			sublist.visible = false;
			if(myschemeSel.selectedScheme != ParentArg.DIS_SYLL && myschemeSel.selectedScheme != ParentArg.NOT_ALL_SYLL)
			{
				sublist.visible=true;
			}
			
			displayStr = "";
			
			switch(myschemeSel.selectedScheme)
			{
				case ParentArg.MOD_PON:
					myArg = new ModusPonens;
					break;
				case ParentArg.MOD_TOL:
					myArg = new ModusTollens;
					break;
				case ParentArg.COND_SYLL:
					myArg = new ConditionalSyllogism;
					break;
				case ParentArg.DIS_SYLL:
					myArg = new DisjunctiveSyllogism;
					myArg.inference = this;
					myArg.createLinks();
					myArg._isLanguageExp = true;
					myschemeSel.selectedType = myArg._langTypes[0];
					displayStr = myArg.correctUsage();
					break;
				case ParentArg.NOT_ALL_SYLL:
					myArg = new NotAllSyllogism;
					myArg.inference = this;
					myArg.createLinks();
					myArg._isLanguageExp = true;
					myschemeSel.selectedType = myArg._langTypes[0];
					displayStr = myArg.correctUsage();
					break;
				case ParentArg.CONST_DILEM:
					myArg = new ConstructiveDilemma;
					break;
			}
			
			myArg.inference = this;
			myArg.createLinks();
			
			if(hasMultipleReasons)
			{
				sublist.dataProvider = myArg._expLangTypes;	
			}
			else
			{
				sublist.dataProvider = myArg._langTypes;	
			}
			argType.changeSchemeBtn.label = myArg.myname;
		}
		
		public function displayOption(le:ListEvent):void
		{
			var oplist:List = myschemeSel.andor;
			oplist.visible = false;
			var typeText:String=le.itemRenderer.data.toString();
			myschemeSel.selectedType = typeText;
			myArg._isLanguageExp = false;
			if(myArg.myname == ParentArg.MOD_TOL)
			{
				if(typeText == "Only if") 
				{
					var modusTollens:ModusTollens = ModusTollens(myArg);
					if(hasMultipleReasons || reasonAddable == true)
					{
						oplist.visible=true;
					}
					else
					{
						oplist.visible=false;
					}
				}
			}	
			else if(myArg.myname == ParentArg.MOD_PON)
			{
				for(var i:int = 0 ;i<myArg._expLangTypes.length;i++)
				{
					if(myArg._expLangTypes[i] == typeText) 
					{
						myArg._isLanguageExp = true;
					}
				}
			}
			else if(myArg.myname == ParentArg.DIS_SYLL)
			{
				myArg._isLanguageExp = true;
			}
			else if(myArg.myname == ParentArg.NOT_ALL_SYLL)
			{
				myArg._isLanguageExp = true;
			}
			else if(myArg.myname == ParentArg.COND_SYLL)
			{
				myArg._isLanguageExp = true;
				myArg.createLinks();
			}
			displayStr = myArg.correctUsage();
		}
		
		public function setOption(le:ListEvent):void
		{
			var andor:String = le.itemRenderer.data.toString();
			if(reasons.length > 1)
			{
				typed = true;
			}
			if(andor=="And")
			{
				myschemeSel.selectedOption = ParentArg.EXP_AND;
				if(myArg is ModusTollens)
				{
					var specificArg:ModusTollens = ModusTollens(myArg);
					specificArg.andOr = ParentArg.EXP_AND;
				}
			}
			else if(andor=="Or") 
			{
				myschemeSel.selectedOption = ParentArg.EXP_OR;
				if(myArg is ModusTollens)
				{
					specificArg = ModusTollens(myArg);
					specificArg.andOr = ParentArg.EXP_OR;
				}
			}
			
			myschemeSel.visible = false;
			displayStr = myArg.correctUsage();
			//input1.forwardUpdate();
			schemeSelected = true;
			parentMap.helpText.visible = false;
		}
		
		
		protected function statementOption(le:ListEvent):void
		{
			var andor:String = le.itemRenderer.data.toString();
			if(andor=="And")
			{
				myschemeSel.selectedOption = ParentArg.EXP_AND;
				if(myArg is ModusTollens)
				{
					var specificArg:ModusTollens = ModusTollens(myArg);
					specificArg.andOr = ParentArg.EXP_AND;
				}
			}
			else if(andor=="Or") 
			{
				myschemeSel.selectedOption = ParentArg.EXP_OR;
				if(myArg is ModusTollens)
				{
					specificArg = ModusTollens(myArg);
					specificArg.andOr = ParentArg.EXP_OR;
				}
			}
			displayStr = myArg.correctUsage();
		}
		
		public function bringForward(e:MouseEvent):void
		{
		}
		
		public function goBackward(e:MouseEvent):void
		{
			
		}
		
		public function makeVisible():void{
			this.visible = true;
			this.argType.visible = true;
		}
		
		
	}
}
