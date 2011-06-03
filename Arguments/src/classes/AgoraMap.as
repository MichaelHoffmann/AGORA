//This class is the canvas on which everything will be drawn
package classes
{
	import components.HelpText;
	import components.Option;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	public class AgoraMap extends Canvas
	{
		public var layoutManager:ALayoutManager = null;
		public var drawUtility:UIComponent = null;
		public var ID:int;
		public var option:Option;
		public var helpText:HelpText;
		private static var _tempID:int;
		public var initXML:XML;
		public function AgoraMap()
		{
			layoutManager = new ALayoutManager;	
			addEventListener(DragEvent.DRAG_ENTER,acceptDrop);
			addEventListener(DragEvent.DRAG_DROP,handleDrop );
			addEventListener(FlexEvent.CREATION_COMPLETE, mapCreated);
			_tempID = 0;
		}
		
		private function mapCreated(event:FlexEvent):void
		{
			//setMapID();
		}
		
		public function getAP():XML
		{
			var xml:XML=<map><textbox text=""/><textbox text=""/><textbox text=""/><node TID="1" Type="Standard" x="2" y="3"><nodetext/><nodetext /><nodetext /></node></map>;
			xml.@ID = ID;
			var textboxesList:XMLList = xml.textbox;
			for each(var textbox:XML in textboxesList)
			{
				textbox.@TID = tempID;
			}
			xml.node.@TID = tempID;
			var nodetextlist:XMLList = xml.node.nodetext;
			for each(var nodetext:XML in nodetextlist)
			{
				nodetext.@TID = tempID;
			}
			for(var i:int = 0; i < nodetextlist.length(); i++)
			{
				nodetextlist[i].@textboxTID = textboxesList[i].@TID;
			}
			return xml;
		}
		
		public function getConnection( claim:ArgumentPanel):XML
		{
			var xml:XML = <map><textbox text=""/><textbox text=""/><textbox text=""/><node Type="Standard" x="0" y="0"><nodetext/><nodetext/><nodetext/></node><node Type="Inference" x="0" y="0"></node><connection type="Unset" x="0" y="0" /></map>
			//setting the ID of the map
			xml.@ID = ID;
			trace('in get connection');
			trace(xml.@ID);
			//temporary IDs for the three new textboxes
			var textboxesList:XMLList = xml.textbox;
			for each(var textbox:XML in textboxesList)
			{
				textbox.@TID = tempID;
			}
			var nodeList:XMLList = xml.node;
			for each(var node:XML in nodeList)
			{
				node.@TID = tempID;
			}
			//set the node text for the reason box (standard)
			var reasonNode:XML = nodeList[0];
			var nodetextList:XMLList = reasonNode.nodetext;
			for each(var nodetext:XML in nodetextList)
			{
				nodetext.@TID = tempID;
			}
			for(var i:int = 0; i < nodetextList.length(); i++)
			{
				nodetextList[i].@textboxTID = textboxesList[i].@TID;
			}
			
			//add a connection
			var newConnXML:XML = xml.connection[0];
			newConnXML.@TID = tempID;
			newConnXML.@targetnodeID = claim.ID;
			for(i=0; i<nodeList.length(); i++)
			{
				var sourcenodeXML:XML = <sourcenode />;
				sourcenodeXML.@TID = tempID;
				sourcenodeXML.@nodeTID = nodeList[i].@TID;
				newConnXML.appendChild(sourcenodeXML);
			}
			//trace(xml);
			return xml;
		}
		
		public function getAddReason(inference:Inference):XML
		{
			var requestXML:XML=<map><textbox text=""/><node Type="Standard" x="0" y="0"><nodetext/></node><node Type="Inference"><nodetext/></node><connection><sourcenode/></connection></map>;
			return <xml />;
		}
		
		public static function get tempID():int
		{
			_tempID = _tempID + 1;
			return 	_tempID - 1;
		}
		
		public function panelCreated(event:FlexEvent):void{
			var panel:ArgumentPanel = event.target as ArgumentPanel;
		}

		public function pushToServer(xml:XML):void
		{
			var urlLoader:URLLoader = new URLLoader;
			var request:URLRequest = new URLRequest;
			request.url = "http://agora.gatech.edu/dev/insert.php";
			request.data = new URLVariables("uid="+UserData.uid+"&pass_hash="+UserData.passHashStr+"&xml="+xml.toXMLString());
			request.method = URLRequestMethod.GET;
			urlLoader.load(request);	
		}
		
		public function getGlobalCoordinates(point:Point):Point
		{
			return localToGlobal(point);
		}
		
		public function getMapXml():XML
		{
			var xml:XML = new XML("<map id=\""+ID+"\"></map>");
			for( var i:int=0; i<layoutManager.panelList.length; i++)
			{
				var panel:GridPanel = layoutManager.panelList[i] as GridPanel;
				//The panel may be an inference a reason/claim  or displayArgType
				if(panel is Inference)
				{
					//do nothing
				}
					//note an Inference is also an Argument Panel, because Inference is a more specific type. So
					//it should come before in the else-if structure.
				else if(panel is ArgumentPanel)
				{
					var argumentPanel:ArgumentPanel = ArgumentPanel(panel);
					var currTextBox:DynamicTextArea = argumentPanel.input1;
					var currXML:XML = <textbox></textbox>;
					currXML.@ID = currTextBox.aid;
					currXML.@text = currTextBox.text;
					xml = xml.appendChild(currXML);
				}	
			}
			
			for(i=0; i  < layoutManager.panelList.length; i++)
			{
				panel = layoutManager.panelList[i] as GridPanel;
				if(!(panel is MenuPanel)){
					currXML= <node></node>;
					currXML.@ID = panel.aid;
					if(panel is Inference)
					{
						var inferencePanel:Inference = Inference(panel);
						currXML.@Type = "Inference";
						for(var j:int=0; j < inferencePanel.input.length; j++)
						{
							var nodeText:XML = <nodetext></nodetext>;
							nodeText.@textboxID = inferencePanel.input[j].aid;
							currXML = currXML.appendChild(nodeText);
						}
					}
					else if(panel is ArgumentPanel)
					{
						argumentPanel = ArgumentPanel(panel);
						currXML.@Type = "Standard";	
						nodeText = <nodetext></nodetext>;
						nodeText.@textboxID = argumentPanel.input1.aid;
						currXML = currXML.appendChild(nodeText);
					}
					currXML.@x = panel.gridX;
					currXML.@y = panel.gridY;
					xml = xml.appendChild(currXML);
				}
				
				pushToServer(xml);
				
			}
			
			//print connections
			for(i=0; i<layoutManager.panelList.length; i++)
			{
				panel = layoutManager.panelList[i] as GridPanel;
				if(panel is MenuPanel)
				{
					currXML = <connection></connection>;
					var argType:MenuPanel = MenuPanel(panel);
					currXML.@argID = argType.aid;
					currXML.@type = argType.inference.myArg.dbType;
					currXML.@targetnodeID = argType.inference.claim.aid;
					currXML.@x = argType.gridX;
					currXML.@y = argType.gridY;	
					for(j = 0; j < argType.inference.reasons.length; j++)
					{
						nodeText=<sourcenode></sourcenode>;
						nodeText.@ID = argType.inference.connectionIDs[j];
						nodeText.@nodeTID = argType.inference.reasons[j].aid;
						currXML = currXML.appendChild(nodeText);
					}
					nodeText=<sourcenode></sourcenode>;
					nodeText.@ID = argType.inference.connectionID;
					nodeText.@nodeTID = argType.inference.aid;
					currXML = currXML.appendChild(nodeText);
					xml = xml.appendChild(currXML);
				}	
			}
			Alert.show(xml.toXMLString());
			return xml;
		}
		
		public function load(xmlData:XML):void{
			//var xmlData:XML = new XML(event.target.data);
			
			var textboxes:XMLList = xmlData.textbox;
			var textbox_map:Object = new Object;
			
			//read all text boxes
			for each (var xml:XML in textboxes)
			{
				textbox_map[xml.attribute("ID")] = xml.attribute("text");
			}
			
			for(var obj:String in textbox_map)
			{
				//trace(obj);
			}
			for each(var object:Object in textbox_map)
			{
				//trace(String(object));
			}
			
			var nodes_map:Object = new Object;
			var nodes:XMLList = xmlData.node;
			
			
			//read all nodes. This includes setting the text of the node
			//by reading the text in the corresponding textbox node
			for each ( xml in nodes)
			{
				var argumentPanel:ArgumentPanel = null;
				if(xml.attribute("Type") == "Inference")
				{
					argumentPanel = new Inference;
					var inferencePanel:Inference = Inference(argumentPanel);
					inferencePanel.argType = new MenuPanel;
					addElement(inferencePanel);
					addElement(inferencePanel.argType);
				}
				else{
					argumentPanel = new ArgumentPanel;
					addElement(argumentPanel);// try moving addElements to one place so that to optimize code
					argumentPanel.input1.text = textbox_map[xml.nodetext.attribute("ID")];
				}
				nodes_map[xml.attribute("ID")] = argumentPanel;
				argumentPanel.gridY = xml.attribute("y");
				argumentPanel.gridX = xml.attribute("x");				
				layoutManager.panelList.push(argumentPanel);
			}
			
			var connections_map:Object = new Object;
			var connections:XMLList = xmlData.connection;
			for each( xml in connections)
			{
				//find the target node - claim
				var claim:ArgumentPanel = nodes_map[xml.attribute("targetnode")];
				//find the inference node
				var inference:Inference = null;
				var sources:XMLList = xml.sourcenode;
				var panel:ArgumentPanel;
				for each ( var sourcenode:XML in sources )
				{
					panel = nodes_map[sourcenode.attribute("nodeID")];
					if( panel is Inference){
						inference = Inference(panel);
						inference.argType.gridY = xml.attribute("y");
						inference.argType.gridX = xml.attribute("x");
						layoutManager.addSavedPanel(inference.argType);
					}
				}
				claim.rules.push(inference);
				inference.claim = claim;
				var dta:DynamicTextArea = new DynamicTextArea;
				addElement(dta);
				dta.visible = false;
				dta.panelReference = inference;
				inference.input.push(dta);
				dta.forwardList.push(inference.input1);
				claim.input1.forwardList.push(dta);
				//forward update should be called only after all links are created.
				//That is, wait for the reasons to be added too.
				//Not doing this might result in accessing illegal memory
				
				for each ( sourcenode in sources )
				{
					panel = nodes_map[sourcenode.attribute("nodeID")];
					if(!(panel is Inference)){
						inference.reasons.push(panel);
						panel.inference = inference;
						dta = new DynamicTextArea;
						addElement(dta);
						dta.visible=false;
						dta.panelReference = inference;
						inference.input.push(dta);
						dta.forwardList.push(inference.input1);
						panel.input1.forwardList.push(dta);
						panel.input1.forwardUpdate();
					}
				}
				claim.input1.forwardUpdate();
			}
			layoutManager.layoutComponents();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			drawUtility = new UIComponent();
			this.parent.addChild(drawUtility);
			option = new Option;
			addChild(option);
			option.visible = false;
			
			helpText = new HelpText;
			addChild(helpText);
			helpText.visible = false;
		}
		public function acceptDrop(d:DragEvent):void
		{
			DragManager.acceptDragDrop(Canvas(d.currentTarget));
		}
		
		public function handleDrop(dragEvent:DragEvent):void
		{	
			try{
				
				var currentStage:Canvas = Canvas(dragEvent.currentTarget);
				var akcdragInitiator1:GridPanel =  dragEvent.dragInitiator as GridPanel;
				var dragSource:DragSource = dragEvent.dragSource;
				var tmpx:int = int(dragSource.dataForFormat("x"));
				var tmpy:int = int(dragSource.dataForFormat("y"));
				tmpx = currentStage.mouseX -  tmpx;
				tmpy = currentStage.mouseY - tmpy;
				
				var tmpGridX:int = layoutManager.getGridPositionX(tmpy);//In the logical co ordinates x and y are along different axes
				var tmpGridY:int = layoutManager.getGridPositionY(tmpx);//Got to change this though ;-)
				
				var diffX:int = tmpGridX - int(dragSource.dataForFormat("gx"));
				var diffY:int = tmpGridY - int(dragSource.dataForFormat("gy"));
				
				if(akcdragInitiator1 is Inference)
				{
					var akcdragInitiator:ArgumentPanel = ArgumentPanel(dragEvent.dragInitiator);
					//figure out if it's allowed
					var currInference:Inference = Inference(akcdragInitiator);
					var lLimit:int = currInference.claim.gridY + layoutManager.getGridSpan(currInference.width);
					var uLimit:int = currInference.reasons[0].gridY - layoutManager.getGridSpan(currInference.width) - 1; 
					if(tmpGridY >= lLimit && tmpGridY <= uLimit)
					{
						currInference.gridX = tmpGridX;
						if(currInference.rules.length > 0 )
						{
							layoutManager.moveConnectedPanels(currInference, diffX, 0);
						}
					}
				}
					
				else if(akcdragInitiator1 is ArgumentPanel)
				{
					akcdragInitiator = akcdragInitiator1 as ArgumentPanel;
					akcdragInitiator.gridY = tmpGridY;
					if(akcdragInitiator.inference == null)
					{
						akcdragInitiator.gridX = tmpGridX;
					}
					else
					{
						layoutManager.alignReasons(akcdragInitiator,tmpGridY);
					}
					for(var i:int=0; i < akcdragInitiator.rules.length; i++)
					{
						
						akcdragInitiator.rules[i].gridY = akcdragInitiator.rules[i].gridY + diffY;
						
						akcdragInitiator.rules[i].argType.gridY = akcdragInitiator.rules[i].argType.gridY + diffY;
						if(akcdragInitiator.inference == null)
						{
							akcdragInitiator.rules[i].argType.gridX=akcdragInitiator.rules[i].argType.gridX + diffX;
							akcdragInitiator.rules[i].gridX = akcdragInitiator.rules[i].gridX + diffX;
							layoutManager.moveConnectedPanels(akcdragInitiator.rules[i],diffX,diffY);
						}
						else
						{
							layoutManager.moveConnectedPanels(akcdragInitiator.rules[i], 0, diffY);
						}
						
					}
				}
				else if(akcdragInitiator1 is MenuPanel)
				{
					var argdisplay:MenuPanel = akcdragInitiator1 as MenuPanel;
					if(argdisplay.inference != argdisplay.inference.claim.rules[0]){
						argdisplay.gridX = argdisplay.gridX + diffX;
						argdisplay.inference.gridX = argdisplay.inference.gridX + diffX;
						layoutManager.moveConnectedPanels(argdisplay.inference,diffX,0);
					}
				}
				
			}catch(error:Error)
			{
				Alert.show(error.message.toString());
			}
			layoutManager.layoutComponents();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			connectRelatedPanels();
		}
		
		public function addable():Boolean
		{
			if(option.visible == true)
				return false;
			else
				return true;
		}
		
		public function connectRelatedPanels():void
		{
			
			var panelList:Vector.<GridPanel> = layoutManager.panelList;
			drawUtility.depth = this.numChildren;
			drawUtility.graphics.clear();
			drawUtility.graphics.lineStyle(2,0,1);
			
			
			for(var i:int=0; i<panelList.length; i++)
			{
				//Drawing an arrow. Arrows are always pointing towards the left on the claim.
				var tmp1:GridPanel = panelList[i];
				if(tmp1 is ArgumentPanel){
					var tmp:ArgumentPanel = tmp1 as ArgumentPanel;
					var m:int;
					for(m = 0; m < tmp.rules.length; m++)
					{
						//for each  rule
						var gridy:int = tmp.rules[0].claim.gridY +  layoutManager.getGridSpan(tmp.rules[0].claim.width) + 1;
						//horizontal lines to argType box
						drawUtility.graphics.moveTo(gridy * layoutManager.uwidth, tmp.rules[m].argType.y + 30);
						drawUtility.graphics.lineTo(tmp.rules[m].argType.x, tmp.rules[m].argType.y + 30);
						//vertical line from argtype to inference box
						if(tmp.rules[m].visible == true)
						{
							drawUtility.graphics.moveTo(tmp.rules[m].argType.x + tmp.rules[m].argType.width/2, tmp.rules[m].argType.y + tmp.rules[m].argType.height);
							drawUtility.graphics.lineTo(tmp.rules[m].argType.x + tmp.rules[m].argType.width/2, tmp.rules[m].y);
						}
						//an inference always has reasons
						var gridyreasons:int = tmp.rules[m].reasons[0].gridY - 1;
						for(var n:int = 0; n < tmp.rules[m].reasons.length; n++){
							//draw a line from the prev grid to the current reason
							drawUtility.graphics.moveTo(gridyreasons * layoutManager.uwidth, tmp.rules[m].reasons[n].y + 30);
							drawUtility.graphics.lineTo(tmp.rules[m].reasons[n].x, tmp.rules[m].reasons[n].y + 30);
						}
						
						drawUtility.graphics.moveTo(gridyreasons * layoutManager.uwidth, tmp.rules[m].reasons[0].y + 30);
						drawUtility.graphics.lineTo(gridyreasons * layoutManager.uwidth, tmp.rules[m].reasons[n-1].y + 30);
						
						drawUtility.graphics.moveTo(tmp.rules[m].argType.x  + tmp.rules[m].argType.width, tmp.rules[m].argType.y + 30);
						drawUtility.graphics.lineTo(gridyreasons * layoutManager.uwidth, tmp.rules[m].reasons[0].y + 30);
						
					}
					if(tmp.rules.length > 0){
						gridy = tmp.rules[0].claim.gridY +  layoutManager.getGridSpan(tmp.rules[0].claim.width) + 1;
						//vert line
						drawUtility.graphics.moveTo(gridy * layoutManager.uwidth, tmp.rules[0].argType.y+30);
						drawUtility.graphics.lineTo(gridy * layoutManager.uwidth, tmp.rules[m-1].argType.y + 30);
						
						//first horizontal line
						drawUtility.graphics.moveTo(tmp.x + tmp.width, tmp.y + 30);
						drawUtility.graphics.lineTo(gridy * layoutManager.uwidth, tmp.rules[0].argType.y + 30);
						//draw an arrow
						drawUtility.graphics.moveTo(tmp.x + tmp.width, tmp.y + 30);
						drawUtility.graphics.lineTo(tmp.x + tmp.width + 5, tmp.y + 30 - 5);
						drawUtility.graphics.moveTo(tmp.x + tmp.width, tmp.y + 30);
						drawUtility.graphics.lineTo(tmp.x + tmp.width + 5, tmp.y + 30 + 5);
					}	
				}
			}
		}
	}
}
