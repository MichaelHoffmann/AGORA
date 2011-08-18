package components
{
	import Controller.ArgumentController;
	import Controller.ViewController;
	
	import Model.SimpleStatementModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import classes.AButton;
	import classes.Language;
	import classes.UserData;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import logic.ConditionalSyllogism;
	import logic.ParentArg;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.Menu;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.EventListenerRequest;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.managers.DragManager;
	import mx.skins.Border;
	
	import org.osmf.events.GatewayChangeEvent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Panel;
	import spark.components.TextArea;
	import spark.components.VGroup;
	import spark.effects.Resize;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.skins.spark.PanelSkin;
	
	public class ArgumentPanel extends GridPanel
	{
		//model class
		[Bindable]
		private var _model:StatementModel;
		
		//Input boxes
		public var inputs:Vector.<DynamicTextArea>;
		public var changeWatchers:Vector.<ChangeWatcher>;
		//dragging handle	
		
		//Text display elements
		//A statment exists in two states: editable, and non-editable. When
		//the user clicks the done button, it goes to the non-editable state.
		//The input textboxes are hidden and the below Text control is shown.
		public var displayTxt:Text;
		//label for displaying 'It is not the case that' for netaged
		//statements
		public var negatedLbl:Label;
		//Displays the type of this statment
		public var stmtTypeLbl:Label;
		//Displays the user id
		public var userIdLbl:Label;
		
		//control elements
		public var topArea:UIComponent;
		//doneButton
		public var doneBtn:AButton;
		//add button
		public var addBtn:AButton;
		//delete button
		public var deleteBtn:AButton;
		
		//appearance
		//skin of the panel
		public var panelSkin:PanelSkin;
		
		//State Variables
		private var _state:String;
		
		//Takes either INFERENCE or ARGUMENT_PANEL
		public var panelType:String;
		[Bindable]
		private var _statementNegated:Boolean;
		[Bindable]
		private var _statementType:String;
		[Bindable]
		private var _author:String;
		
		//dirty flags
		private var _statementNegatedDF:Boolean;		
		private var _statementsAddedDF:Boolean;
		private var _stateDF:Boolean;
		private var _statementTypeChangedDF:Boolean;
		
		
		
		//constants
		//Type of Panel: this could be found by just using is operator
		public static const ARGUMENT_PANEL:String = "ArgumentPanel"
		//Type of Panel
		public static const INFERENCE:String = "Inference";
		//connecting string constants required for multistatements
		public static const IF_THEN:String = "If-then";
		public static const IMPLIES:String = "Implies";	
		public static const EDIT:String = "Edit";
		public static const DISPLAY:String = "Display";
		
		//References to other objects
		//A reference to the current map diplayed to the user
		public static var parentMap:AgoraMap;
		
		//Containers
		//The logical container that holds the text elements of the statement
		//that is, input boxes and displayTxt
		public var group:Group;
		//multistatement group
		public var msVGroup:VGroup;
		//The enabler which makes this statements support a claim
		public var inference:Inference;
		//contains the add and the delete button
		public var bottomHG:HGroup;
		//the logical container that contains everything above the group container
		public var topHG:HGroup;
		//Within the topHG. It holds the author information and the type of statement
		public var stmtInfoVG:VGroup;
		//Container that holds the done button
		public var doneHG:HGroup;
		//contains the doneHG and bottomHG
		public var btnG:Group;
		
		//Menu data
		//XML string holding the menu data for the add button
		public var addMenuData:XML;
		//XML string holding the menu data for the menu that pops up when user hits the done button
		public var constructArgData:XML;
		
		//other instance variables
		public var connectingStr:String;
		public function ArgumentPanel(type:String = ARGUMENT_PANEL)
		{
			super();
			addMenuData = <root><menuitem label="add an argument for this statement" type="TopLevel" /></root>;
			constructArgData = <root><menuitem label="add another reason" type="TopLevel"/><menuitem label="construct argument" type="TopLevel"/></root>;
			panelType = ArgumentPanel.ARGUMENT_PANEL;			
			
			inputs = new Vector.<DynamicTextArea>;
			changeWatchers = new Vector.<ChangeWatcher>;
			
			//will be set by the object that creates this
			inference = null;
			width = 180;
			minHeight = 100;
			
			state = DISPLAY;
			panelType = type;
			
			//Event handlers
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		//------------------- Getters and Setters -----------------------------//
		public function get author():String
		{
			return _author;
		}
		
		public function set author(value:String):void
		{
			_author = value;
		}
		
		public function get statementNegated():Boolean
		{
			return _statementNegated;
		}
		
		public function set statementNegated(value:Boolean):void
		{
			_statementNegated = value;
			statementNegatedDF = true;
			
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		
		public function get statementType():String
		{
			return _statementType;
		}
		
		[Bindable]
		public function set statementType(value:String):void
		{
			_statementType = value;
			statementTypeChangedDF = true;
			
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function get model():StatementModel{
			return _model;
		}
		
		public function set model(value:StatementModel):void{
			if(model == null){
				_model = value;
				//bind variables
				BindingUtils.bindProperty(this, "statementType", this, ["model","statementType"]);
				BindingUtils.bindProperty(this, "statementNegated", model, ["negated"]);
				BindingUtils.bindProperty(this, "gridX", model, ["xgrid"]);
				BindingUtils.bindSetter(this.setX,model, ["xgrid"]);
				BindingUtils.bindSetter(this.setY, model, ["ygrid"]);
				author = model.author;
				
				statementsAddedDF = true;
				
				invalidateProperties();
				invalidateSize();
				invalidateDisplayList();
			}else{
				trace("Error (ArgumentPanel.as, set model): attempted to reassign the model of statement view. Not allowed.");
			}
			
		}
		
		public function get statementTypeChangedDF():Boolean
		{
			return _statementTypeChangedDF;
		}
		
		public function set statementTypeChangedDF(value:Boolean):void
		{
			_statementTypeChangedDF = value;
		}
		
		public function get state():String
		{
			return _state;
		}
		
		public function set state(value:String):void
		{
			_state = value;
			stateDF = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function get stateDF():Boolean
		{
			return _stateDF;
		}
		
		public function set stateDF(value:Boolean):void
		{
			_stateDF = value;
		}
		
		public function get statementsAddedDF():Boolean
		{
			return _statementsAddedDF;
		}
		
		public function set statementsAddedDF(value:Boolean):void
		{
			_statementsAddedDF = value;
		}
		
		public function get statementNegatedDF():Boolean
		{
			return _statementNegatedDF;
		}
		
		public function set statementNegatedDF(value:Boolean):void
		{
			_statementNegatedDF = value;
		}
		
		//--------------------- Event Handlers ----------------------//
		
		protected function onCreationComplete(event:FlexEvent):void{
			panelSkin = this.skin as PanelSkin;
			panelSkin.topGroup.includeInLayout = false;
			panelSkin.topGroup.visible = false;
			
			//Event Listeners that are appropriate only after the component is 
			//created
			addEventListener(KeyboardEvent.KEY_DOWN, keyEntered);
		}
		
		protected function onDeleteBtnClicked(event:MouseEvent):void{
			
		}
		
		protected function onStmtTypeClicked(event:MouseEvent):void{
			ArgumentController.getInstance().changeType(model.ID);
		}
		
		protected function onAddBtnClicked(event:MouseEvent):void{
			
		}
		
		protected function lblClicked(event:MouseEvent):void
		{
			state = EDIT;
		}
		
		protected function doneBtnClicked(event:MouseEvent):void{
			ArgumentController.getInstance().saveText(model);
		}
		
		protected function keyEntered(event: KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER)	
			{				
				if(state == EDIT){
					ArgumentController.getInstance().saveText(model);
				}
			}
		}
		
		public function beginDrag(mouseEvent: MouseEvent ):void
		{
			try{
				var dPInitiator:ArgumentPanel = this;
				var ds:DragSource = new DragSource();
				var tmpx:int = int(dPInitiator.mouseX);
				var tmpy:int = int(dPInitiator.mouseY);
				ds.addData(tmpx,"x");
				ds.addData(tmpy,"y");
				ds.addData(dPInitiator.model.xgrid,"gx");
				ds.addData(dPInitiator.model.ygrid,"gy");
				DragManager.doDrag(dPInitiator,ds,mouseEvent,null);
			}
			catch(error:Error)
			{
				Alert.show(error.toString());
			}
		}
		
		public function removeEventListeners():void
		{
			
		}
		
		protected function optionClicked(event:MouseEvent):void
		{
		}
		
		protected function hideOption(event:KeyboardEvent):void
		{
		}
		
		
		public function showMenu():void
		{
			var menu:mx.controls.Menu = mx.controls.Menu.createMenu(null,constructArgData,false);
			menu.labelField = "@label";
			var globalPosition:Point = localToGlobal(new Point(0,this.height));
			menu.show(globalPosition.x,globalPosition.y);	
		}
		
		
		//----------------------- Bind Setters -------------------------------------------------//
		protected function setDisplayStatement(value:String):void{
			if(!value){
				if(model.firstClaim){
					displayTxt.text = "[Enter your claim here]";
				}else{
					displayTxt.text = "[Enter your reason here]";
				}
			}
			else{
				displayTxt.text = value;
			}
		}
		
		//----------------------- Life Cycle Methods -------------------------------------------//
		//create children must be overriden to create dynamically allocated children
		override protected function createChildren():void
		{
			//Elements are constructed, initialized with properties, and attached to display list		
			//create the children of MX Panel
			super.createChildren();
			var uLayout:VerticalLayout = new VerticalLayout;
			uLayout.paddingBottom = 10;
			uLayout.paddingLeft = 10;
			uLayout.paddingRight = 10;
			uLayout.paddingTop = 10;
			this.layout = uLayout;
			
			
			userIdLbl = new Label;
			
			stmtTypeLbl = new Label;
			// default setting    	
			
			//stmtTypeLbl.toolTip = Language.lookup("ParticularUniversalClarification");
			//stmtTypeLbl.toolTip = "Please change it before commiting";
			stmtTypeLbl.toolTip = "'Universal statement' is defined as a statement that can be falsified by one counterexample. Thus, laws, rules, and all statements that include 'ought,' 'should,' or other forms indicating normativity, are universal statements. Anything else is treated as a 'particular statement' including statements about possibilities.  The distinction is important only with regard to the consequences of different forms of objections: If the premise of an argument is 'defeated,' then the conclusion and the entire chain of arguments that depends on this premise is defeated as well; but if a premise is only 'questioned' or criticized, then the conclusion and everything depending is only questioned, but not defeated. While universal statements can easily be defeated by a single counterexample, it depends on an agreement among deliberators whether a counterargument against a particular statement is sufficient to defeat it, even though it is always sufficient to question it and to shift, thus, the burden of proof.";
			BindingUtils.bindProperty(stmtTypeLbl, "text",this, ["statementType"]);
			stmtTypeLbl.addEventListener(MouseEvent.CLICK, onStmtTypeClicked);
			
			bottomHG = new HGroup();
			doneHG = new HGroup;
			doneBtn = new AButton;
			doneBtn.label = "Done";
			doneBtn.addEventListener(MouseEvent.CLICK, doneBtnClicked);
			doneHG.addElement(doneBtn);
			
			//TODO: Translate
			displayTxt = new Text;
			displayTxt.width = 150;
			BindingUtils.bindSetter(setDisplayStatement, model, ["statement", "text"]);
			this.displayTxt.addEventListener(MouseEvent.CLICK, lblClicked);
			//Create a UIComponent for clicking and dragging
			topArea = new UIComponent;
			
			topHG = new HGroup();
			addElement(topHG);
			
			//Draw on topArea UIComponent a rectangle
			//to be used for clicking and dragging
			
			topArea.addEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
			topArea.width = 40;
			topHG.addElement(topArea);
			//add a vertical subgroup
			stmtInfoVG = new VGroup;
			stmtInfoVG.gap = 0;
			topHG.addElement(stmtInfoVG);
			
			
			stmtInfoVG.addElement(stmtTypeLbl);
			stmtInfoVG.addElement(userIdLbl);
			
			userIdLbl.text = "AU: " + author;
			var userInfoStr:String = "User Name: " + UserData.userNameStr + "\n" + "User ID: " + UserData.uid;
			userIdLbl.toolTip = userInfoStr;
			
			negatedLbl = new Label;
			negatedLbl.text = "It is not the case that";
			negatedLbl.visible = false;
			//addElement(negatedLbl);
			
			
			group = new Group;
			addElement(group);
			group.addElement(displayTxt);
			
			btnG = new Group;
			addElement(btnG);
			btnG.addElement(bottomHG);
			doneHG = new HGroup;
			doneHG.addElement(doneBtn);
			addBtn = new AButton;
			addBtn.label = "add...";
			
			bottomHG.addElement(addBtn);
			deleteBtn = new AButton;
			deleteBtn.label = "delete...";
			deleteBtn.addEventListener(MouseEvent.CLICK,onDeleteBtnClicked);
			bottomHG.addElement(deleteBtn);
			addBtn.addEventListener(MouseEvent.CLICK, onAddBtnClicked);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(panelType == ARGUMENT_PANEL){
				var dta:DynamicTextArea;
				var simpleStatement:SimpleStatementModel;
				//check if new statements were added
				if(statementsAddedDF){
					//clear flag
					statementsAddedDF = false;
					//remove inputs
					for each(dta in inputs){
						try{
							group.removeElement(dta);
						}catch(error:Error){
							trace("error: Trying to remove an element that is not present");
						}
					}
					inputs.splice(0,inputs.length);
					
					//for each statement add an input text
					for each(simpleStatement in model.statements){
						dta = new DynamicTextArea;
						//add model
						dta.model = simpleStatement;
						//push that into inputs
						inputs.push(dta);
					}	
				}
				
				userIdLbl.width = this.explicitWidth - 60;
				if(statementTypeChangedDF){
					statementTypeChangedDF = false;
					if(statementType == StatementModel.UNIVERSAL){
						this.setStyle("cornerRadius", 30);
					}
					else{
						this.setStyle("cornerRadius", 0);
					}
				}
				
				if(stateDF){
					stateDF = false;
					if(state == EDIT){
						group.removeAllElements();
						btnG.removeAllElements();
						
						if(statementNegated){
							group.addElement(negatedLbl);
						}
						for each(dta in inputs){
							group.addElement(dta);
							stage.focus = dta;
						}	
						btnG.addElement(doneHG);
					}
					else if(state == DISPLAY){
						//remove inputs
						group.removeAllElements();
						//remove buttons
						btnG.removeAllElements();
						//add label
						group.addElement(displayTxt);
						//add button
						btnG.addElement(bottomHG);
					}
				}
			}
			else{
				//remove all textboxes
				inputs.splice(0,inputs.length);
				//remove inputs
				group.removeAllElements();
				//remove buttons
				btnG.removeAllElements();
				//add label
				group.addElement(displayTxt);
				//add button
				btnG.addElement(bottomHG);
				//set corner radius
				this.setStyle("cornerRadius", 30);
			}
		}
		
		override protected function measure():void{
			//call parent's measure
			super.measure();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			topArea.graphics.beginFill(0xdddddd,1.0);
			topArea.graphics.drawRect(0,0,40,stmtInfoVG.height);		
		}
	}
	
}
