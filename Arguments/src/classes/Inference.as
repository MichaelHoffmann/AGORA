package classes
{
	import components.ArgSelector;
	import components.HelpText;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
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
	import mx.utils.ArrayUtil;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.SkinnableContainer;
	import spark.components.VGroup;
	
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
		public var connectionID:int;
		public var connectionIDs:Vector.<int>;
		//Used when constructing the argument beginning with reason
		//Set to true if the user has begun to choose an argument scheme.
		//happens when construct argument is chosen
		private var _selectedBool:Boolean;
		//A scheme has been chosen for this argument and cannot be changed
		//until it becomes an open end
		private var _typed:Boolean;
		public static var REASON_ADDED:String  = "Reason Added";
		//private var _schemeChangable:Boolean;
		private var _schemeSelected:Boolean;
		//The string that is displayed
		public var _displayStr:String;
		//if adding multiple reasons are allowed
		public var reasonAddable:Boolean;
		
		private var addReasonMenuData:XML;
		
		public function Inference()
		{
			super();
			addReasonMenuData = <root><menuitem   label = "... another reason for this argument so that only the combination of all reasons justifies the claim" /></root>;
			connectionID = connections++;
			connectionIDs = new Vector.<int>(0,false);
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
		}
		///Getters and Setters
		
		override public function get stmt():String
		{
			return _displayStr;
		}
		
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
			if(claim.firstClaim)
			{
				reasons[reasons.length - 1].makeUnEditable();
				reasons[reasons.length - 1].displayTxt.text = "[Enter your reason]";
			}
			else
			{
				reasons[reasons.length - 1].makeEditable();
			}
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
		
		override public function addHandler(event:MouseEvent):void
		{
			if(implies)	
			{
				if(myschemeSel.selectedType!="If-then" && myschemeSel.selectedType != "Implies")
				{
					//TODO: translate
					Alert.show("This language type cannot be supported. Please change the language type before proceeding");
					return;
				}
			}
			else 
			{
				if(!implies && myschemeSel.selectedType != "Either-or")
				{
					//TODO: translate
					Alert.show("This language type cannot be supported. Please change the language type before proceeding");
					return;
				}
			}
			argType.changeSchemeBtn.enabled = false;
			super.addHandler(event);
		}
		
		//This happens when the argument
		//  scheme is fixed
		public function changePossibleSchemes():void
		{
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
			if(!typed && myschemeSel != null)
			{
				myschemeSel.mainSchemes.visible = true;
				myschemeSel.typeSelector.x = myschemeSel.mainSchemes.width;
				myschemeSel.andor.x = myschemeSel.typeSelector.x + myschemeSel.typeSelector.width;
			}
		}
		
		public function menuCreated(fe:FlexEvent):void
		{ 
			//Sometimes only one posisble scheme is possible.
			//In those situations, they are created automatically, instead
			//of giving the user a menu
			var typeArr:Array = ["Modus Ponens","Modus Tollens","Conditional Syllogism","Disjunctive Syllogism","Not-All Syllogism"];
			var optionsArr:Array = ["And","Or"];
			if( (!claim.statementNegated) && claim.inference != null)
			{
				//typeArr.splice(1,1);
				//typeArr.splice(3,1);
				typeArr.splice(typeArr.indexOf(ParentArg.MOD_TOL,0),1);
				typeArr.splice(typeArr.indexOf(ParentArg.NOT_ALL_SYLL,0),1);
			}
			else if(claim.statementNegated && claim.inference != null)
			{
				typeArr = ["Modus Tollens", "Not-All Syllogism"];
			}
			
			if(!claim.multiStatement && (claim.inference != null || claim.userEntered == true) && !claim.statementNegated )
			{
				typeArr.splice(typeArr.indexOf(ParentArg.COND_SYLL,0),1);
			}
			else if(claim.multiStatement && claim.inference != null)
			{
				typeArr = [];
				typeArr.splice(0,0,"Conditional Syllogism");
			}
			
			if(claim.multiStatement && claim.inference != null)
			{
				//claim is a multistatement and claim is of type P->Q
				//Only one possible scheme - conditional syllogism
				if(claim.implies)
				{
					typeArr = ["Conditional Syllogism"];
					//the language type is already determined
					//It is that of the enabler.
					//feasibility of adding is already checked
					myschemeSel.selectedScheme = ParentArg.COND_SYLL;
					var infClaim:Inference = Inference(claim);
					myschemeSel.selectedType = infClaim.myschemeSel.selectedType;
					//var array:Array = new Array;
					//array.splice(0,0,infClaim,myschemeSel.selectedType);
					//myschemeSel.typeSelector.dataProvider = array;
					argType.changeSchemeBtn.label=ParentArg.COND_SYLL;					
					argType.changeSchemeBtn.enabled = false;
					myArg = new ConditionalSyllogism;
					myArg.isLanguageExp = true;
					myArg.inference = this;
					myArg.addInitialReasons();
					myArg.createLinks();
					selectedBool = true;
					schemeSelected = true;
					parentMap.option.visible = false;
					this.visible = true;
					reasons[0].makeEditable();
				}
				else
				{
					typeArr = ["Constructive Dilemma"];
				}
				
			}
			myschemeSel.scheme = typeArr;
			var sublist:List = myschemeSel.typeSelector;
			var oplist:List = myschemeSel.andor;
			oplist.dataProvider = optionsArr;
			myschemeSel.mainSchemes.addEventListener(ListEvent.ITEM_ROLL_OVER,displayTypes);
			myschemeSel.mainSchemes.addEventListener(ListEvent.ITEM_CLICK,setArgScheme);
			sublist.addEventListener(ListEvent.ITEM_CLICK,setType);
			sublist.addEventListener(ListEvent.ITEM_ROLL_OVER,displayOption);
			oplist.addEventListener(ListEvent.ITEM_CLICK,setOption);
			oplist.addEventListener(ListEvent.ITEM_ROLL_OVER,statementOption);
			myschemeSel.addEventListener(MouseEvent.MOUSE_OVER,bringForward);
			myschemeSel.addEventListener(MouseEvent.MOUSE_OUT,goBackward);
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
		}
		
		
		public function addReason():void
		{
			var tmp:ArgumentPanel = new ArgumentPanel();
			parentMap.addElement(tmp);
			tmp.addEventListener(FlexEvent.CREATION_COMPLETE, goToReason);		
			try{
				reasons.push(tmp);
				connectionIDs.push(connections++);
				tmp.inference = this;
				parentMap.layoutManager.registerPanel(tmp);
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
				if(myArg.isLanguageExp || (myArg is ModusTollens && reasonAddable == true && myschemeSel.selectedType == myArg._expLangTypes[0]))
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
			//enabler is never edited
		}
		override public function makeEditable():void
		{
			//enabler is never edited
		}
		
		override public function onArgumentPanelCreate(e:FlexEvent):void
		{
			super.onArgumentPanelCreate(e);
			doneBtn.removeEventListener(MouseEvent.CLICK,makeUnEditable);
			displayTxt.removeEventListener(MouseEvent.CLICK,lblClicked);
			displayTxt.visible = true;
			displayTxt.toolTip = "The statement in this text box is called the \"enabler\". An \"enabler\" is the premise in an argument that guarantees that the reason provided (or a combination of reasons) is sufficient to justify the claim. The enabler is always a universal statement. It guarantees that an argument is logically valid."
			bottomHG.visible = true;
			doneHG.visible = false;
			stmtTypeLbl.removeEventListener(MouseEvent.CLICK,toggle);
			multiStatement = true;
			group.removeElement(msVGroup);
		}
		
		public function chooseEnablerText():void
		{
			if(myschemeSel.scheme != null){
				if(myschemeSel.scheme.length == 0)
				{
					Alert.show("This lanugage type cannot be supported by an argument. Please choose a suitable language type before proceeding...");
					return;
				}
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
				//parentMap.parent.removeChild(myschemeSel);
				myschemeSel.visible = false;
			}
			schemeSelected = true;
			parentMap.helpText.visible = false;
		}
		
		public function displayTypes(le:ListEvent):void
		{
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
					myArg.isLanguageExp = true;
					myschemeSel.selectedType = myArg._langTypes[0];
					displayStr = myArg.correctUsage();
					break;
				case ParentArg.NOT_ALL_SYLL:
					myArg = new NotAllSyllogism;
					myArg.inference = this;
					myArg.createLinks();
					myArg.isLanguageExp = true;
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
			myArg.isLanguageExp = false;
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
						myArg.isLanguageExp = true;
					}
				}
			}
			else if(myArg.myname == ParentArg.DIS_SYLL)
			{
				myArg.isLanguageExp = true;
			}
			else if(myArg.myname == ParentArg.NOT_ALL_SYLL)
			{
				myArg.isLanguageExp = true;
			}
			else if(myArg.myname == ParentArg.COND_SYLL)
			{
				myArg.isLanguageExp = true;
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
			input1.forwardUpdate();
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
			//Alert.show("Argument Panel");
		}
		
		public function makeVisible():void{
			this.visible = true;
			this.argType.visible = true;
		}
		
		override protected function deleteThis(event:MouseEvent):void
		{
			this.selfDestroy();
		}
		
		override public function selfDestroy():void
		{
			//it may also be supported by further arguments
			for(var i:int=rules.length-1; i >= 0; i--)
			{
				//delete(rules[i]);
				rules[i].selfDestroy();
			}
			for(i = reasons.length-1; i >= 0; i--)
			{
				//delete(reasons[i]);
				reasons[i].selfDestroy();
			}
			claim.rules.splice(claim.rules.indexOf(this),1);
			//remove menu panel
			parentMap.layoutManager.panelList.splice(parentMap.layoutManager.panelList.indexOf(argType),1);
			parentMap.removeChild(argType);
			parentMap.layoutManager.panelList.splice(parentMap.layoutManager.panelList.indexOf(this),1);
			parentMap.removeChild(this);
			trace(this + ' destroyed');
		}
	}
}