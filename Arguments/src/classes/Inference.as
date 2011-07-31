package classes
{
	import Model.InferenceModel;
	
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
	
	public class Inference extends ArgumentPanel
	{
		
		private var _inferenceModel:InferenceModel;
		//temporary variable for generating temporary permanent ids
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

		public static var REASON_ADDED:String  = "Reason Added";
		public static var REASON_DELETED:String = "Reason Deleted";
		private var _schemeSelected:Boolean;
		//The string that is displayed
		public var _displayStr:String;

		private var addReasonMenuData:XML;
		
		public function Inference()
		{
			super();
			addReasonMenuData = <root><menuitem   label = "... another reason for this argument so that only the combination of all reasons justifies the claim" /></root>;
			panelType = ArgumentPanel.INFERENCE;
			
			
			this.setStyle("cornerRadius",30);	
			//schemeSelected = false;
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
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		/*
		public function get connectionType():String
		{
			if(myArg == null)
				return "";
			return myArg.dbType;
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
				
		public function setRuleState():void
		{
			//seting type makes sense only after a particular scheme has been chosen
			//before this, reasons may be empty
		}
		
		//This happens when the argument
		//  scheme is fixed
		public function changePossibleSchemes():void
		{
	
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
		
		public function changeScheme(event:MouseEvent):void
		{
			changeHandler(event);
		}
		
		
		
		
		override public function makeUnEditable():void
		{
		}
		override public function makeEditable():void
		{
		}
		*/
		/*
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
		
		
		public function statementOption(le:ListEvent):void
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
		
	 */	
	}
}