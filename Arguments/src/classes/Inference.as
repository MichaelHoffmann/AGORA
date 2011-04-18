package classes
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.listClasses.ListData;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	//import spark.components.List;
	import spark.components.Button;
	import spark.components.VGroup;
	import components.ArgSelector;
	import logic.*;
	
	public class Inference extends ArgumentPanel
	{
		public var reasons:Vector.<ArgumentPanel>;
		public var input:Vector.<DynamicTextArea>;
		public var argumentClass:String;
		public var aLType:Label;
		public var addReason:Button;
		public var vgroup:VGroup;
		public var claim:ArgumentPanel;
		public var argType:DisplayArgType;
		public var myscheme:ArgSelector;
		public var myArg:ParentArg;
		
		public function Inference()
		{
			super();
			panelType = ArgumentPanel.INFERENCE;
			addEventListener(FlexEvent.CREATION_COMPLETE, displayArgumentType);
			input = new Vector.<DynamicTextArea>(0,false);
			reasons = new Vector.<ArgumentPanel>(0,false);
			argType = new DisplayArgType();
			argType.inference = this;
			argType.width = 100;
			argType.addEventListener(FlexEvent.CREATION_COMPLETE,addHandlers);
			myscheme = new ArgSelector();
			this.setStyle("cornerRadius",30);
		}
		
		public function  addHandlers(fe:FlexEvent):void
		{
			argType.addReasonBtn.addEventListener(MouseEvent.CLICK,addReasonHandler);
			//register it to the layout
			//parentMap.layoutManager.registerPanel(argType);
			argType.typeBtn.addEventListener(MouseEvent.CLICK,changeHandler);
		}
		
		private function displayArgumentType(e: FlexEvent) : void
		{
			//aLType = new Label();
			//aLType.text=argumentClass;
			//argType.vgroup.addElement(aLType);
			parentMap.addElement(argType);
		}
		
		public function addReasonHandler(event:MouseEvent):void
		{
				var tmp:ArgumentPanel = new ArgumentPanel();
				parentMap.addElement(tmp);
				try{
					reasons.push(tmp);
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
					//binding
					tmpInput.forwardList.push(inferenceRule.input1);
					tmp.input1.forwardList.push(tmpInput);
					
				}catch (e:Error)
				{
					Alert.show(e.toString());
				}
			
		}
		
		public function changeHandler(e:MouseEvent):void
		{
			myscheme.visible=true;
			myscheme.x = this.gridY*25 + this.width;
			myscheme.y = this.gridX*25;
			parentMap.addElement(myscheme);
			var rootlist:List = myscheme.mainSchemes;
			var sublist:List = myscheme.typeSelector;
			rootlist.addEventListener(ListEvent.ITEM_CLICK,setScheme);
			sublist.addEventListener(ListEvent.ITEM_CLICK,setType);
			rootlist.addEventListener(ListEvent.ITEM_ROLL_OVER,displayTypes);
			//rootlist.addEventListener(ListEvent.ITEM_ROLL_OUT,closeTypes);
			myscheme.addEventListener(MouseEvent.MOUSE_OVER,bringForward);
			myscheme.addEventListener(MouseEvent.MOUSE_OUT,goBackward);
		}
		
		public function setScheme(le:ListEvent):void
		{
			var myclass:String = le.itemRenderer.data.toString();
			argType.title = myclass;
		}
		
		public function setType(le:ListEvent):void
		{
			var temp:DynamicTextArea = new DynamicTextArea();
			temp.text = le.itemRenderer.data.toString();
			trace(temp.text);
			input.push(temp);
		}
		
		public function displayTypes(le:ListEvent):void
		{
			var myclassindex:int = le.rowIndex;
			var sublist:List = myscheme.typeSelector;
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
		}
		
		public function closeTypes(le:ListEvent):void
		{
			var sublist:List = myscheme.typeSelector;
			sublist.visible=false;
		}
		
		public function bringForward(e:MouseEvent):void
		{
			myscheme.visible = true;
			parentMap.setChildIndex(myscheme,parentMap.numChildren - 1);
		}
		
		public function goBackward(e:MouseEvent):void
		{
			//parentMap.setChildIndex(myscheme,0);
			myscheme.visible = false;
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
	}
}