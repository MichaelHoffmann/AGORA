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
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.SkinnableContainer;
	import spark.components.VGroup;
	
	public class Inference extends ArgumentPanel
	{
		//
		public static var connections:int;
		public var reasons:Vector.<ArgumentPanel>;
		public var input:Vector.<DynamicTextArea>;
		public var argumentClass:String;
		public var scheme:Button;
		public var vgroup:VGroup;
		public var claim:ArgumentPanel;
		public var argType:DisplayArgType;
		public var myschemeSel:ArgSelector;
		public var myArg:ParentArg;		//argType.schemeText stores the language type
		public var sentence:String;
		public var isExp:Boolean;
		public var connectionID:int;
		public var connectionIDs:Vector.<int>;
		
		
		public function Inference()
		{
			super();
			
			connectionID = connections++;
			
			connectionIDs = new Vector.<int>(0,false);
			
			panelType = ArgumentPanel.INFERENCE;
			state = 0; 		// Inference is always a Universal statement
			addEventListener(FlexEvent.CREATION_COMPLETE, displayArgumentType);
			input = new Vector.<DynamicTextArea>(0,false);
			reasons = new Vector.<ArgumentPanel>(0,false);
			argType = new DisplayArgType();
			argType.inference = this;
			argType.width = 100;
			argType.addEventListener(FlexEvent.CREATION_COMPLETE,addHandlers);
			myschemeSel = new ArgSelector();
			this.setStyle("cornerRadius",30);
			scheme = new Button;
			scheme.label = "Scheme...";
			this.bottomH.addElement(scheme);
			this.bottomH.removeElement(this.doneBtn);
			scheme.addEventListener(MouseEvent.CLICK,changeHandler);	
			sentence = "";
			
		}
		
		public function addHandlers(fe:FlexEvent):void
		{
			argType.addReasonBtn.addEventListener(MouseEvent.CLICK,addReasonHandler);
			//register it to the layout
			//parentMap.layoutManager.registerPanel(argType);
		}
		
		private function displayArgumentType(e: FlexEvent) : void
		{
			parentMap.addElement(argType);
		}
		
		public function addReasonHandler(event:MouseEvent):void
		{
				var tmp:ArgumentPanel = new ArgumentPanel();
				parentMap.addElement(tmp);
				try{
					reasons.push(tmp);
					
					connectionIDs.push(connections++);
					
					//trace(this);
					//trace(tmp);
					tmp.inference = this;
					parentMap.layoutManager.registerPanel(tmp);
					
					//create an invisible box in the inference rule
					var tmpInput:DynamicTextArea = new DynamicTextArea();
					//visual
					//inferenceRule.logicalContainer.addElement(tmpInput);
					//inferenceRule.logicalContainer.removeElement(tmpInput);
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
					tmp.input1.forwardList.push(tmpInput);				//this new reason's input1 text forwards to that invisible box.
					
				}catch (e:Error)
				{
					Alert.show(e.toString());
				}
			
		}
		
		public function changeHandler(e:MouseEvent):void
		{
			myschemeSel.visible=true;
			myschemeSel.x = this.gridY*25 + this.width;
			myschemeSel.y = this.gridX*25;
			parentMap.addElement(myschemeSel);			
			var rootlist:List = myschemeSel.mainSchemes;
			if(myArg!=null) {
			rootlist.dataProvider = myArg.myname;
			scheme.toolTip = "Only change in language type is allowed"; }
			var sublist:List = myschemeSel.typeSelector;
			var oplist:List = myschemeSel.andor;
			rootlist.addEventListener(ListEvent.ITEM_ROLL_OVER,displayTypes);
			//rootlist.addEventListener(ListEvent.ITEM_CLICK,setScheme);
			sublist.addEventListener(ListEvent.ITEM_CLICK,setType);
			sublist.addEventListener(ListEvent.ITEM_ROLL_OVER,displayOption);
			oplist.addEventListener(ListEvent.ITEM_CLICK,setOption);
			//rootlist.addEventListener(ListEvent.ITEM_ROLL_OUT,closeTypes);
			myschemeSel.addEventListener(MouseEvent.MOUSE_OVER,bringForward);
			myschemeSel.addEventListener(MouseEvent.MOUSE_OUT,goBackward);
			
			//var sc:SkinnableContainer = new SkinnableContainer();
		}
		
		public function setType(le:ListEvent):void
		{
			argType.schemeText = le.itemRenderer.data.toString();
			if(myschemeSel.andor.visible==false)
				myschemeSel.visible = false;
			input1.visible=true;
			input1.update();
		}
		
		public function displayTypes(le:ListEvent):void
		{
			var myclassindex:int = le.rowIndex;
			var sublist:List = myschemeSel.typeSelector;
			sublist.visible=true;
			switch(myclassindex)
			{
				case 0: myArg = new ModusPonens; break;
				case 1: myArg = new ModusTollens; break;
				case 2: myArg = new ConditionalSyllogism; break;
				case 3: myArg = new DisjunctiveSyllogism; break;
				case 4: myArg = new NotAllSyllogism; break;
				case 5: myArg = new ConstructiveDilemma;
				
			}
			sublist.dataProvider = myArg._langTypes;
			argType.title = myArg.myname;		//set scheme
		}
		
		public function displayOption(le:ListEvent):void
		{
			var oplist:List = myschemeSel.andor;
			var typeText:String=le.itemRenderer.data.toString();
			argType.schemeText = typeText;
			argType.schemeTextIndex = le.rowIndex;
			//var splits:Array = new Array;
			//splits = typeText.split("-");
			//if(splits[splits.length-1] == "Exp")
			if(myArg.myname == ParentArg.MOD_TOL)
				if(typeText == "Only if") {
					oplist.visible=true; isExp = true; }
				else
					oplist.visible=false;
			else if(myArg.myname == ParentArg.MOD_PON)
				for(var i:int;i<myArg._expLangTypes.length;i++)
					if(myArg._expLangTypes[i] == typeText) {
						argType.connText = ParentArg.EXP_AND;	// Modus Ponens expanded only with AND
						isExp = true; }
			
			sentence = myArg.correctUsage(argType.schemeTextIndex,this.claim.input1.text,this.reasons,isExp);
		}
		
		public function setOption(le:ListEvent):void
		{
			var andor:String = le.itemRenderer.data.toString();
			if(andor=="And") argType.connText = ParentArg.EXP_AND;
			else if(andor=="Or") argType.connText = ParentArg.EXP_OR;
			myschemeSel.visible = false;
			input1.visible=true;
			
			// construct the argument with claim, reason(s), inference and conjunction
			//sentence = myArg.correctUsage(argType.schemeTextIndex,this.claim.input1.text,this.reasons,isExp,argType.connText);
			
			input1.forwardUpdate();
		}
		
		/*public function closeTypes(le:ListEvent):void
		{
			var sublist:List = myschemeSel.typeSelector;
			sublist.visible=false;
		}*/
		
		public function bringForward(e:MouseEvent):void
		{
			myschemeSel.visible = true;
			parentMap.setChildIndex(myschemeSel,parentMap.numChildren - 1);
		}
		
		public function goBackward(e:MouseEvent):void
		{
			parentMap.setChildIndex(myschemeSel,0);
			//myschemeSel.visible = false;
		}
		
		override public function getString():String
		{
			var s:String;
			for(var i:int = 0; i < input.length; i++)
			{
				s = s + input[i].text;
			}
			return s;
		}
		
		public function formClaim ():void
		{
			
		}
		
		public function makeVisible():void{
			this.visible = true;
			this.argType.visible = true;
		}
		
	}
}