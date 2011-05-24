package classes
{
	import components.ArgSelector;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import logic.*;
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.listClasses.ListData;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
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
		
		public function Inference()
		{
			super();
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
		}
		///Getters and Setters
		
		public function get displayStr():String
		{
			return _displayStr;
		}
		
		public function set displayStr(value:String):void
		{
			_displayStr = value;
			input1.text = _displayStr;
			displayTxt.text = _displayStr;
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
		
		protected function reasonAdded(event:Event):void
		{
			if(reasons.length > 1)
			{
				hasMultipleReasons = true;
			}
			else
			{
				hasMultipleReasons = false;
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
			
			var typeArr:Array = ["Modus Ponens","Modus Tollens","Conditional Syllogism","Disjunctive Syllogism","Not-All Syllogism","Constructive Dilemma"];
			var optionsArr:Array = ["And","Or"];
			if( (!claim.statementNegated) && claim.inference != null)
			{
				typeArr.splice(1,1);
				typeArr.splice(3,1);
			}
			else if(claim.statementNegated && claim.inference != null)
			{
				typeArr = ["Modus Tollens", "Not-All Syllogism"];
			}
			var rootlist:List = myschemeSel.mainSchemes;
			rootlist.dataProvider = typeArr;
			var sublist:List = myschemeSel.typeSelector;
			var oplist:List = myschemeSel.andor;
			oplist.dataProvider = optionsArr;
			rootlist.addEventListener(ListEvent.ITEM_ROLL_OVER,displayTypes);
			sublist.addEventListener(ListEvent.ITEM_CLICK,setType);
			sublist.addEventListener(ListEvent.ITEM_ROLL_OVER,displayOption);
			oplist.addEventListener(ListEvent.ITEM_CLICK,setOption);
			oplist.addEventListener(ListEvent.ITEM_ROLL_OVER,statementOption);
			myschemeSel.addEventListener(MouseEvent.MOUSE_OVER,bringForward);
			myschemeSel.addEventListener(MouseEvent.MOUSE_OUT,goBackward);
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
				tmpInput.forwardList.push(inferenceRule.input1);	//invisible box input forwards to the visible box input1 in inference
				tmp.input1.forwardList.push(tmpInput);
				//this new reason's input1 text forwards to that invisible box
				dispatchEvent(new Event(REASON_ADDED,true,false));
			}catch (e:Error)
			{
				Alert.show(e.toString());
			}
		}
		
		public function addReasonHandler(event:MouseEvent):void
		{
			if(schemeSelected != true)
			{
				Alert.show("Complete the enabler before adding further reasons");
				return;
			}
			if(myArg.isLanguageExp)
			{
				addReason();
			}
			else
			{
				Alert.show("The current language scheme does not allow multiple reasons. Please choose an expandable language type before adding a reason");
			}
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
			input1.visible = false;
			stmtTypeLbl.removeEventListener(MouseEvent.CLICK,toggle);
		}
		public function chooseEnablerText():void
		{
			myschemeSel.visible=true;
			myschemeSel.x = this.gridY*parentMap.layoutManager.uwidth + this.width;
			myschemeSel.y = this.gridX*parentMap.layoutManager.uwidth;
			parentMap.parent.addChild(myschemeSel);
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
			if(myschemeSel.andor.visible==false)
			{
				parentMap.parent.removeChild(myschemeSel);
			}
			schemeSelected = true;
			parentMap.helpText.visible = false;
		}
		
		public function displayTypes(le:ListEvent):void
		{
			myschemeSel.selectedScheme = le.itemRenderer.data.toString();
			var sublist:List = myschemeSel.typeSelector;
			sublist.visible=true;
			
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
					break;
				case ParentArg.NOT_ALL_SYLL:
					myArg = new NotAllSyllogism;
					break;
				case ParentArg.CONST_DILEM:
					myArg = new ConstructiveDilemma;
					break;
			}
			myArg.inference = this;
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
					oplist.visible=true;
					myArg.isLanguageExp = true;
				}
				else
					oplist.visible=false;
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
		
	}
}