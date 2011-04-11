package classes
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.VGroup;
	public class Inference extends ArgumentPanel
	{
		public var reasons:Vector.<ArgumentPanel>;
		public var input:Vector.<DynamicTextArea>;
		public var argumentClass:String;
		public var aLType:Label;
		public var addReason:Button;
		public var vgroup:VGroup;
		public var claim:ArgumentPanel;
		public static const MODUS_PONENS:String = "modus_ponens";
		public var argType:DisplayArgType;
		
		public function Inference()
		{
			super();
			panelType = ArgumentPanel.INFERENCE;
			addEventListener(FlexEvent.CREATION_COMPLETE, displayArgumentType);
			input = new Vector.<DynamicTextArea>(0,false);
			reasons = new Vector.<ArgumentPanel>(0,false);
			argType = new DisplayArgType();
			argType.width = 100;
			argType.addEventListener(FlexEvent.CREATION_COMPLETE,addHandlers);
		}
		
		public function  addHandlers(fe:FlexEvent):void
		{
			argType.addReasonBtn.addEventListener(MouseEvent.CLICK,addReasonHandler);
		}
		
		private function displayArgumentType(e: FlexEvent) : void
		{
			aLType = new Label();
			aLType.text=argumentClass;
			argType.addElement(aLType);
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