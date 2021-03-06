//This class is the canvas on which everything will be drawn
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
	import Controller.ArgumentController;
	import Controller.LoadController;
	
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.InferenceModel;
	import Model.StatementModel;
	import classes.Configure;
	import components.ArgSelector;
	import components.HelpText;
	import components.Option;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import logic.ConditionalSyllogism;
	import logic.DisjunctiveSyllogism;
	import logic.ModusPonens;
	import logic.ModusTollens;
	import logic.NotAllSyllogism;
	import logic.ParentArg;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	import mx.managers.LayoutManager;
	
	public class AgoraMap extends Canvas
	{
		public var layoutManager:ALayoutManager = null;
		public var drawUtility:UIComponent = null;
		public var ID:int;
		public var option:Option;
		public var helpText:HelpText;
		private static var _tempID:int;
		public var initXML:XML;
		public static var dbTypes:Array = ["MP","MT","DisjSyl","NotAllSyl","CS", "CD"];
		public var timer:Timer;
		
		public var panelsHash:Dictionary;
		
		
		public function AgoraMap()
		{
			layoutManager = new LayoutManager;
			addEventListener(DragEvent.DRAG_ENTER,acceptDrop);
			addEventListener(DragEvent.DRAG_DROP,handleDrop );
			addEventListener(FlexEvent.CREATION_COMPLETE, mapCreated);
			timer = new Timer(30000);
			timer.addEventListener(TimerEvent.TIMER, onMapTimer);
			panelsHash = new Dictionary;
		}
		

		protected function onMapTimer(event:TimerEvent):void{
			LoadController.getInstance().fetchMapData();
		}
		
		private function mapCreated(event:FlexEvent):void
		{
		}
		
		public function getAP():XML
		{
			var xml:XML=<map><textbox text=""/><textbox text=""/><textbox text=""/><node TID="1" Type="Standard" typed="0" is_positive="1"  x="2" y="3"  ><nodetext/><nodetext /><nodetext /></node></map>;
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
		
		/*
		public function getConnection( claim:ArgumentPanel):XML
		{
			
			var coordinate:Coordinate = new Coordinate;
			var argTypeCoordinate:Coordinate = new Coordinate;
			var reasonCoordinate:Coordinate = new Coordinate;
			
			coordinate.gridX = claim.gridX;
			coordinate.gridY = claim.gridY;
			
			//First rule
			//if(claim.rules.length == 0)
			{
				coordinate.gridX += Math.ceil(claim.height / layoutManager.uwidth ) + 2;
				coordinate.gridY +=  Math.ceil(claim.width / layoutManager.uwidth ) + 2;
			}
				//Not First Rule
			//else
			{
			//	var lastInference:Inference = claim.rules[claim.rules.length - 1];
			//	var lastInferenceGridX:int  = lastInference.gridX + layoutManager.getGridSpan(lastInference.height);
			//	var lastReason:ArgumentPanel = lastInference.reasons[lastInference.reasons.length - 1];
				var lastReasonGridX:int = lastReason.gridX + layoutManager.getGridSpan(lastReason.height);
				var max:int;
				
				if(lastInferenceGridX <= lastReasonGridX){
					max = lastReasonGridX;
				}
				else{
					max = lastInferenceGridX;
				}
				max = max + layoutManager.yArgDistances;
				coordinate.gridY = coordinate.gridY + layoutManager.getGridSpan(claim.width) + 2;
				coordinate.gridX = max;
			}
			
			if(claim.rules.length == 0){
				argTypeCoordinate.gridX = claim.gridX;
				argTypeCoordinate.gridY = coordinate.gridY;
			}
			else{
				argTypeCoordinate.gridX = coordinate.gridX - layoutManager.yArgDisplay;
				argTypeCoordinate.gridY = coordinate.gridY;
			}
			
			reasonCoordinate.gridX = argTypeCoordinate.gridX;
			reasonCoordinate.gridY = coordinate.gridY + Math.ceil(claim.width/layoutManager.uwidth) + 1;
			
			var xml:XML = <map>
							<textbox text=""/>
							<textbox text=""/>
							<textbox text=""/>
							<node Type="Standard" typed="0" is_positive="1" x={reasonCoordinate.gridX} y={reasonCoordinate.gridY}>
								<nodetext/><nodetext/><nodetext/>
							</node>
							<node Type="Inference" typed="0" is_positive="1" x={coordinate.gridX} y={coordinate.gridY}>
							</node>
							<connection type="Unset" x={argTypeCoordinate.gridX} y={argTypeCoordinate.gridY} />
						 </map>
			
			//setting the ID of the map
			xml.@ID = ID;
			
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
			//newConnXML.@targetnodeID = claim.ID;
			for(i=0; i<nodeList.length(); i++)
			{
				var sourcenodeXML:XML = <sourcenode />;
				sourcenodeXML.@TID = tempID;
				sourcenodeXML.@nodeTID = nodeList[i].@TID;
				newConnXML.appendChild(sourcenodeXML);
			}
			return xml;
		}
		*/
		
		public function getAddReason(inference:Inference):XML
		{
			/*
			//cannot be the first reason
			//get the recently added reason
			var reason:ArgumentPanel = inference.reasons[inference.reasons.length - 1];
			var coordinate:Coordinate = new Coordinate;
			coordinate.gridX = reason.gridX + layoutManager.getGridSpan(reason.height) + 1;
			coordinate.gridY = reason.gridY;
			
			var xml:XML=<map>
						<textbox text=""/>
						<textbox text=""/>
						<textbox text=""/>
						<node Type="Standard" typed="0" is_positive="1" x={coordinate.gridX} y={coordinate.gridY}>
							<nodetext/>
							<nodetext/>
							<nodetext/>
						</node>
						<connection></connection>
						</map>;
		
			xml.@ID = ID;
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
			var reasonNode:XML = nodeList[0];
			var nodetextList:XMLList = reasonNode.nodetext;
			for(var i:int = 0; i < nodetextList.length(); i++)
			{
				nodetextList[i].@textboxTID = textboxesList[i].@TID;
			}
			//add connection
			var connection:XML = xml.connection[0];
			connection.@ID = inference.connID;
			connection.@type = inference.myArg.dbType;
			connection.@x = inference.argType.gridX;
			connection.@y = inference.argType.gridY;
			//connection.@targetnode = inference.claim.ID;
			//add a sourcenode to the connection
			var sourcenode:XML = <sourcenode />;
			sourcenode.@TID = tempID;
			sourcenode.@nodeTID = reasonNode.@TID;
			connection.appendChild(sourcenode);
			*/
			return new XML;
			
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
			request.url = Configure.lookup("baseURL") + "insert.php";
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
			try{
			var xml:XML = new XML("<map id=\""+ID+"\"></map>");
			var argumentPanel:ArgumentPanel;
			var inferencePanel:Inference;
			//form textboxes
			for( var i:int=0; i<layoutManager.panelList.length; i++)
			{
				var panel:GridPanel = layoutManager.panelList[i] as GridPanel;
				//The panel may be an inference a reason/claim  or displayArgType
				if(panel is Inference)
				{	
				}
					//note an Inference is also an Argument Panel, because Inference is a more specific type. So
					//it should come before in the else-if structure.
				else if(panel is ArgumentPanel)
				{
					argumentPanel = ArgumentPanel(panel);
					//add input1
					var currTextBox:DynamicTextArea = argumentPanel.input1;
					var currXML:XML = <textbox></textbox>;
					currXML.@ID = currTextBox.ID;
					if(argumentPanel.statementNegated)
					{
						currXML.@text = "#$#$#$"+currTextBox.text;
					}
					else{
						currXML.@text = currTextBox.text;
					}
					xml = xml.appendChild(currXML);
					//add inputs
					for(var j:int=0; j<argumentPanel.inputs.length; j++)
					{
						currXML = <textbox></textbox>;
						currXML.@ID = argumentPanel.inputs[j].ID;
						currXML.@text = argumentPanel.inputs[j].text;
						xml = xml.appendChild(currXML);
					}
				}	
			}
			//nodes
			for(i=0; i  < layoutManager.panelList.length; i++)
			{
				panel = layoutManager.panelList[i] as GridPanel;
				if(!(panel is MenuPanel)){
					currXML= <node></node>;
					if(panel is Inference)
					{
						inferencePanel = Inference(panel);
						currXML.@ID = inferencePanel.ID;
						currXML.@Type = Language.lookup("Inference");
						currXML.@is_positive = 1;
					}
					else if(panel is ArgumentPanel)
					{
						argumentPanel = ArgumentPanel(panel);
						currXML.@ID = argumentPanel.ID;
						if(argumentPanel.state == 0){
							currXML.@Type=Language.lookup("Universal");
						}
						else{
							currXML.@Type = Language.lookup("Particular");
						}
						
						var nodeText:XML = <nodetext></nodetext>;
						nodeText.@ID = argumentPanel.input1NTID;
						nodeText.@textboxID = argumentPanel.input1.ID;
						currXML = currXML.appendChild(nodeText);
						for(j=0; j<argumentPanel.inputsNTID.length; j++)
						{
							nodeText = <nodetext></nodetext>;
							nodeText.@ID = argumentPanel.inputsNTID[j];
							nodeText.@textboxID = argumentPanel.inputs[j].ID;
							currXML = currXML.appendChild(nodeText);
						}
						if(argumentPanel.statementNegated){
							currXML.@is_positive = 0;
						}
						else{
							currXML.@is_positive = 1;
						}
						
					}
					currXML.@typed = 0;
					currXML.@x = panel.gridX;
					currXML.@y = panel.gridY;
					xml = xml.appendChild(currXML);
				}
			}
			
			//print connections
			for(i=0; i<layoutManager.panelList.length; i++)
			{
				panel = layoutManager.panelList[i] as GridPanel;
				if(panel is Inference)
				{
					inferencePanel = Inference(panel);
					currXML = <connection></connection>;
					currXML.@ID = inferencePanel.connID;
					currXML.@type = inferencePanel.connectionType;
					currXML.@x = inferencePanel.argType.gridX;
					currXML.@y = inferencePanel.argType.gridY;
					xml = xml.appendChild(currXML);
				}	
			}
			}catch(error:Error){
				return (<map><error text="Map was not saved ..." /></map>);
			}
			trace(xml.toXMLString());
			return xml;
		}
		
		public function load(xmlData:XML):void{
			
			//try{
			//var xmlData:XML = new XML(event.target.data);
			
			ID = xmlData.@ID;
			trace('This is the id of the map ' + id);
			trace(ID);
			var textboxes:XMLList = xmlData.textbox;
			var textbox_map:Object = new Object;
			
			//read all text boxes
			for each (var xml:XML in textboxes)
			{
				textbox_map[xml.attribute("ID")] = xml.attribute("text");
			}
			
			var nodes:XMLList = xmlData.node;
			var nodes_map:Object = new Object;
			//read all nodes. This includes setting the text of the node
			//by reading the text in the corresponding textbox node
			for each (xml in nodes)
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
					argumentPanel.userEntered = true;
				}
				nodes_map[xml.attribute("ID")] = argumentPanel;
				argumentPanel.ID = xml.@ID;
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
						connections_map[xml.@ID] = inference;
					}
				}
				claim.rules.push(inference);
				inference.claim = claim;
				var dta:DynamicTextArea = new DynamicTextArea;
				addElement(dta);
				dta.visible = false;
				dta.panelReference = inference;
				inference.input.push(dta);
				
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
					}
				}
			}
			//set states
			//select myArg
			for each(xml in connections)
			{
				sources = xml.sourcenode;
				inference = null;
				for each(var source:XML in sources)
				{
					panel = nodes_map[source.@nodeID];
					if(panel is Inference)
					{
						inference = Inference(panel);
						inference.connID = xml.@connID;
					}
				}
				if(inference.reasons.length > 1)
				{
					inference.hasMultipleReasons = true;
				}
				var type:String = xml.@type;
				if(type != "Unset"){
					inference.myArg =  getMyArg(type);
					inference.myArg.inference = inference;
					inference.myschemeSel = new ArgSelector;	
					inference.myschemeSel.visible = false;
					inference.myschemeSel.addEventListener(FlexEvent.CREATION_COMPLETE,inference.menuCreated);	
					addChild(inference.myschemeSel);
					inference.myschemeSel.selectedScheme = inference.myArg.myname;
					inference.myschemeSel.selectedType = inference.myArg.getLanguageType(type);
					inference.myschemeSel.selectedOption = inference.myArg.getOption(type);
					inference.myArg.setIsExp();
					if(inference.hasMultipleReasons)
					{
						inference.myschemeSel.typeSelector.dataProvider = inference.myArg._expLangTypes;
					}
					else
					{
						inference.myschemeSel.typeSelector.dataProvider = inference.myArg._langTypes;
					}
					inference.myschemeSel.typeSelector.visible = true;
					inference.myschemeSel.typeSelectorText.visible = true;
					inference.myArg.createLinks();
					inference.argType.changeSchemeBtn.label = inference.myschemeSel.selectedScheme;
					inference.selectedBool = true;
					inference.schemeSelected = true;
				}
				else
				{
					inference.selectedBool = false;
					inference.schemeSelected = false;
				}
				
				if(inference.myArg is ConditionalSyllogism)
				{
					claim.multiStatement = true;
					claim.implies = true;
					
					for each(var reason:ArgumentPanel in inference.reasons)
					{
						reason.multiStatement = true;
						reason.implies = true;
					}
				}
			}
			//fill out text
			for each(var node:XML in nodes)
			{
				var aPanel:ArgumentPanel = nodes_map[node.@ID];
				aPanel.ID = node.@ID;
				aPanel.userIdLbl.text = "AU: " +  node.@Author;
				if(node.@Type == "Universal" || aPanel is Inference){
					aPanel.state = 1;
					aPanel.toggleType();
				}
				else
				{
					aPanel.state = 0;
					aPanel.toggleType();
				}
				var nodetextList:XMLList = node.nodetext;
				var i:int = 0;
				for each(var nodetext:XML in nodetextList)
				{
					var string:String = textbox_map[nodetext.@textboxID];
					var ind:int = string.indexOf("#$#$#$",0);
					if(ind != -1)
					{
						string = string.substr(6,string.length -1);
					}
					if(i == 0){
						aPanel.input1.text = string;
						aPanel.input1NTID = nodetext.@ID;
						aPanel.input1.ID = nodetext.@textboxID;
						aPanel.input1.invalidateProperties();
						aPanel.input1.invalidateSize();
						aPanel.input1.invalidateDisplayList();
					}
					else{
						aPanel.inputs[i-1].text = string;
						aPanel.inputsNTID.push(nodetext.@ID);
						aPanel.inputs[i-1].ID = nodetext.@textboxID;
						aPanel.inputs[i-1].invalidateProperties();
						aPanel.inputs[i-1].invalidateSize();
						aPanel.inputs[i-1].invalidateDisplayList();
					}
					
					i++;
				}
				if(aPanel.inference != null)
				{
					if(aPanel.inference.myArg != null)
						aPanel.inference.displayStr = aPanel.inference.myArg.correctUsage();
				}
				//trace('Look here');
				for each(var argPanel:ArgumentPanel in nodes_map)
				{
					argPanel.makeUnEditable();	
				}
				//aPanel.makeUnEditable();
				//make all of the boxes uneditable
				
			}
			//}catch(error:Error){
			//	Alert.show("There was an error in loading the map. The map is corrupted, and may not be correct ...");
			//}
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
			/*
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
			*/
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			var newPanels:ArrayCollection = AGORAModel.getInstance().agoraMapModel.newPanels; 
			for(var i:int=0; i< newPanels.length; i++){
				if(newPanels[i] is InferenceModel){
					var inference:Inference = new Inference;
					inference.model = newPanels[i];
					panelsHash[inference.model.ID] = inference;
					var xWatcherSetter:ChangeWatcher = BindingUtils.bindSetter(inference.setX, inference.model, "xgrid", true);
					var yWatcherSetter:ChangeWatcher = BindingUtils.bindSetter(inference.setY, inference.model, "ygrid", true);
					addChild(inference);
				}
				else if(newPanels[i] is StatementModel){
					var argumentPanel:ArgumentPanel = new ArgumentPanel;
					argumentPanel.model = newPanels[i];
					var xWatcherSetterArgumentPanel:ChangeWatcher = BindingUtils.bindSetter(argumentPanel.setX, argumentPanel.model, "xgrid", true);
					var yWatcherSetterArgumentPanel:ChangeWatcher = BindingUtils.bindSetter(argumentPanel.setY, argumentPanel.model, "ygrid", true);
					addChild(argumentPanel);
				}
			}
			var newMenuPanels:ArrayCollection = AGORAModel.getInstance().agoraMapModel.newConnections;
			for each(var argumentTypeModel:ArgumentTypeModel in newMenuPanels){
				var menuPanel:MenuPanel = new MenuPanel;
				menuPanel.model = argumentTypeModel;
				var xWatcherSetterMenuPanel:ChangeWatcher = BindingUtils.bindSetter(menuPanel.setX, menuPanel.model, "xgrid", true);
				var yWatcherSetterMenuPanel:ChangeWatcher = BindingUtils.bindSetter(menuPanel.setY, menuPanel.model, "ygrid", true);
				addChild(menuPanel);
			}
			
			LoadController.getInstance().mapUpdateCleanUp();
			
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
			
			/*
			
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
			*/
		}		
	}
}
