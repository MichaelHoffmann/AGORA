//This class is the canvas on which everything will be drawn
package components
{
	import Controller.ArgumentController;
	import Controller.LayoutController;
	import Controller.LoadController;
	import Controller.logic.ConditionalSyllogism;
	import Controller.logic.DisjunctiveSyllogism;
	import Controller.logic.ModusPonens;
	import Controller.logic.ModusTollens;
	import Controller.logic.NotAllSyllogism;
	import Controller.logic.ParentArg;
	
	import Events.AGORAEvent;
	
	import Model.AGORAMapModel;
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.InferenceModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import classes.Language;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.Menu;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.events.ScrollEvent;
	import mx.managers.DragManager;
	import mx.states.State;
	import mx.utils.DisplayUtil;
	
	import spark.components.Label;
	
	public class AgoraMap extends Canvas
	{
		public static const BY_ARGUMENT:String = "ByArgument";
		public static const BY_CLAIM:String = "ByClaim";
		
		public var beganBy:String;
		public var drawUtility:UIComponent = null;
		public var drawUtility1:UIComponent = null;
		public var drawUtility2:UIComponent = null;
		public var ID:int;
		public var helpText:HelpText;
		public var flag:int;
		public var textLabel:Dictionary;
		public var firstClaimHelpText:FirstClaimHelpText;
		public var rectangle:Shape;
		private static var _tempID:int;
		public var timer:Timer;
		private var _removePreviousElements:Boolean;
		
		public var panelsHash:Dictionary;
		public var menuPanelsHash:Dictionary;
		
		public function AgoraMap()
		{	
			addEventListener(DragEvent.DRAG_ENTER,acceptDrop);
			addEventListener(DragEvent.DRAG_DROP,handleDrop );
			addEventListener(MouseEvent.CLICK,mouseclicked);
			initializeMapStructures();
			timer = new Timer(10000);
			timer.addEventListener(TimerEvent.TIMER, onMapTimer);
			bottom = 100;
			beganBy = BY_CLAIM;
			removePreviousElements = false;
			addEventListener(ResizeEvent.RESIZE,scrollAutomatically);
		}
		
		//--------------------- getters and setters -------------------//
		public function get removePreviousElements():Boolean{
			return _removePreviousElements;
		}
		public function set removePreviousElements(value:Boolean):void{
			_removePreviousElements = value;
			invalidateProperties();
			invalidateDisplayList();
		}
		
		protected function onMapTimer(event:TimerEvent):void{
			LoadController.getInstance().fetchMapData();
		}
		
		public function getGlobalCoordinates(point:Point):Point
		{
			return localToGlobal(point);
		}
		
		public function initializeMapStructures():void{
			panelsHash = new Dictionary;
			menuPanelsHash = new Dictionary;
			removePreviousElements = true;
			textLabel = new Dictionary;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			drawUtility = new UIComponent();
			drawUtility1 = new UIComponent();
			drawUtility2 = new UIComponent();
			helpText = new HelpText;
			addChild(helpText);
			helpText.visible = false;
			firstClaimHelpText = new FirstClaimHelpText;
			addChild(firstClaimHelpText);
			firstClaimHelpText.visible = false;
			this.addChild(drawUtility);
			this.addChild(drawUtility1);
			drawUtility.depth = 100;
			rectangle = new Shape;
			flag = 0;

		}
		public function acceptDrop(d:DragEvent):void
		{
			DragManager.acceptDragDrop(Canvas(d.currentTarget));
		}
		
		public function scrollAutomatically(d:ResizeEvent):void
		{
			

		}
		public function mouseclicked(d:MouseEvent):void
		{
			if(d.target == this)
			{
			for each(var sm in AGORAModel.getInstance().agoraMapModel.globalComments)
			{
				if(sm is StatementModel)
				{
					if(sm.statementFunction == StatementModel.COMMENT || sm.statementFunction == StatementModel.REFERENCE || sm.statementFunction == StatementModel.AMENDMENT || sm.statementFunction == StatementModel.QUESTION || sm.statementFunction == StatementModel.DEFINITION || sm.statementFunction == StatementModel.SUPPORT || sm.statementFunction == StatementModel.LINKTOMAP || sm.statementFunction == StatementModel.LINKTORESOURCES || sm.statementFunction == StatementModel.REFORMULATION)
					{
						AGORAModel.getInstance().agoraMapModel.deletedList.push(sm);
					
						delete AGORAModel.getInstance().agoraMapModel.panelListHash[sm.ID];
						delete AGORAModel.getInstance().agoraMapModel.globalComments[sm.ID];					
						delete AGORAModel.getInstance().agoraMapModel.showChildren[sm.ID];
					}
						
				}
			}
			}
			
		}

		
		public function handleDrop(dragEvent:DragEvent):void
		{	
			var currentStage:Canvas = Canvas(dragEvent.currentTarget);
			var gridPanel:GridPanel = dragEvent.dragInitiator as GridPanel;
			var dragSource:DragSource = dragEvent.dragSource;
			var tmpx:int = int(dragSource.dataForFormat("x"));
			var tmpy:int = int(dragSource.dataForFormat("y"));
			tmpx = currentStage.mouseX - tmpx;
			tmpy = currentStage.mouseY - tmpy;
			var toxgrid:int = Math.floor(tmpy/AGORAParameters.getInstance().gridWidth);
			var toygrid:int = Math.floor(tmpx/AGORAParameters.getInstance().gridWidth);
			var diffx:int = toxgrid - int(dragSource.dataForFormat("gx"));
			var diffy:int = toygrid - int(dragSource.dataForFormat("gy"));
			setChildIndex(gridPanel, numChildren - 1);
			LayoutController.getInstance().movePanel(gridPanel,diffx, diffy);
			
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			if(removePreviousElements){
				removeAllChildren();
				removeAllElements();
				_removePreviousElements = false;
			}
		
			try{
				drawUtility.removeChildAt(0);
				removeChild(drawUtility);
			}catch(e:Error){
			}
			addChildAt(drawUtility, 0);
			try{
				drawUtility1.removeChildAt(0);
				removeChild(drawUtility1);
			}catch(e:Error){
			}
			//if(drawUtility.numChildren > 0)
			//drawUtility.removeChildren(0,drawUtility.numChildren-1);
			
			try{
				removeChild(helpText);
			}catch(e:Error){
			}
			addChild(helpText);
			try{
				removeChild(firstClaimHelpText);
			}catch(e:Error){
			}
			addChild(firstClaimHelpText);
			
			for each(var info:UIComponent in getChildren())
			{
				if(info is InfoBox)
				{
				var info1:InfoBox = info as InfoBox;			
				if(info1.helptext == Language.lookup('ArgComplete'))
					removeChild(info);
				}
			}
			
			var newPanels:ArrayCollection = AGORAModel.getInstance().agoraMapModel.newPanels; 
			
			for(var i:int=0; i< newPanels.length; i++){
				if(StatementModel(newPanels[i]).statementFunction == StatementModel.INFERENCE){
					var inference:ArgumentPanel = new ArgumentPanel;
					inference.model = newPanels[i];
					panelsHash[inference.model.ID] = inference;
					addChild(inference);
					//add the next infobox
					var addArgumentsInfo:InfoBox = new InfoBox;
					addArgumentsInfo.visible = false;
					addArgumentsInfo.text = Language.lookup('ArgComplete');
					addArgumentsInfo.boxWidth = 500;
					addChild(addArgumentsInfo);
				}
					
				else if(newPanels[i] is StatementModel){
					var argumentPanel:ArgumentPanel;
					var model:StatementModel = newPanels[i];
					if(model.statementType != null){
					//if(model.statementType != StatementModel.OBJECTION && model.statementType != StatementModel.COUNTER_EXAMPLE && model.statementType != StatementModel.REFERENCE && model.statementType != StatementModel.AMENDMENT && model.statementType != StatementModel.COMMENT &&  model.statementType != StatementModel.DEFINITION &&  model.statementType != StatementModel.QUESTION && model.statementType != StatementModel.SUPPORT && model.statementType != StatementModel.LINKTOMAP && model.statementType != StatementModel.LINKTORESOURCES && model.statementType != StatementModel.REFORMULATION){
						argumentPanel = new ArgumentPanel;
						argumentPanel.model = model;
						panelsHash[model.ID] = argumentPanel;
						argumentPanel.addEventListener(AGORAEvent.STATEMENT_STATE_TO_EDIT, ArgumentController.getInstance().removeOption);
						if(model.argumentTypeModel){
							if(!model.argumentTypeModel.reasonsCompleted)
							{
								if(model.argumentTypeModel.reasonModels.length == 1){
									argumentPanel.branchControl = new Option;
									argumentPanel.branchControl.x = argumentPanel.x + AGORAParameters.getInstance().gridWidth * 10;
									argumentPanel.branchControl.y = argumentPanel.y;
									argumentPanel.branchControl.argumentTypeModel = model.argumentTypeModel;
									addChild(argumentPanel.branchControl);
								}
							}
						}
						addChild(argumentPanel);
						argumentPanel.changeTypeInfo = new InfoBox;
						argumentPanel.changeTypeInfo.visible = false;
						argumentPanel.changeTypeInfo.text = Language.lookup('PartUnivReq');
						argumentPanel.changeTypeInfo.boxWidth = argumentPanel.getExplicitOrMeasuredWidth();
						addChild(argumentPanel.changeTypeInfo);
					}
					else if(model.statementFunction == StatementModel.OBJECTION || model.statementFunction == StatementModel.COUNTER_EXAMPLE) {
						argumentPanel = new ArgumentPanel;
						argumentPanel.model = model;
						panelsHash[model.ID] = argumentPanel;
						addChild(argumentPanel);
					}
					else if(model.statementFunction == StatementModel.REFERENCE || model.statementFunction == StatementModel.AMENDMENT || model.statementFunction == StatementModel.COMMENT ||  model.statementFunction == StatementModel.DEFINITION ||  model.statementFunction == StatementModel.QUESTION || model.statementFunction == StatementModel.SUPPORT || model.statementFunction == StatementModel.LINKTOMAP || model.statementFunction == StatementModel.LINKTORESOURCES || model.statementFunction == StatementModel.REFORMULATION){
						argumentPanel = new ArgumentPanel;
						argumentPanel.model = model;
						panelsHash[model.ID] = argumentPanel;
						
						if(flag == 0)
						{
							addChild(drawUtility2);
						}
							addChild(argumentPanel);

						flag = 1;
						
					}
				}
			}
			
			
			var newMenuPanels:ArrayCollection = AGORAModel.getInstance().agoraMapModel.newConnections;
			for each(var argumentTypeModel:ArgumentTypeModel in newMenuPanels){
				var menuPanel:MenuPanel = new MenuPanel;
				menuPanel.model = argumentTypeModel;
				menuPanel.schemeSelector = new ArgSelector;
				menuPanel.schemeSelector.visible = false;
				menuPanel.schemeSelector.argumentTypeModel = argumentTypeModel;
				menuPanelsHash[menuPanel.model.ID] =  menuPanel;
				addChild(menuPanel);
				addChild(menuPanel.schemeSelector);
			}
			LoadController.getInstance().mapUpdateCleanUp();
			AGORAModel.getInstance().agoraMapModel.check = false;
			
			var a:Array = getChildren();
			//if(flag == 0)
			if(contains(drawUtility2) == true && contains(drawUtility) == true)
			{
				if(getChildIndex(drawUtility) > getChildIndex(drawUtility2))
				swapChildren(drawUtility,drawUtility2);
			}
			addChild(drawUtility1);
			
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			connectRelatedPanels();
		}
		
		protected function connectRelatedPanels():void
		{
			var panelList:Dictionary = panelsHash;			
			drawUtility.graphics.clear();
			drawUtility1.graphics.clear();
			drawUtility.graphics.lineStyle(2,0,1);
			var gridWidth:int = AGORAParameters.getInstance().gridWidth;
			var layoutController:LayoutController = LayoutController.getInstance();
			var statementModel:StatementModel;
			var argumentTypeModel:ArgumentTypeModel;
			//code for the connecting arrows
			
			for each(var model:StatementModel in AGORAModel.getInstance().agoraMapModel.panelListHash){
				if(model.supportingArguments.length > 0 || model.objections.length > 0 || model.comments.length > 0){
					//First Vertical Line Starting Point
					var argumentPanel:ArgumentPanel = panelsHash[model.ID]; 
					
					var fvlspx:int = ((argumentPanel.x + argumentPanel.width)/gridWidth + 2) * gridWidth;
					var fvlspy:int = argumentPanel.y + 72;
					if(model.supportingArguments.length > 0){
						//draw arrow
						drawUtility.graphics.lineStyle(10, 0x29ABE2, 10);
						drawUtility.graphics.moveTo(argumentPanel.x + argumentPanel.width + 20, argumentPanel.y + 87);
						drawUtility.graphics.lineTo(argumentPanel.x + argumentPanel.width, argumentPanel.y + 72);
						drawUtility.graphics.lineTo(argumentPanel.x + argumentPanel.width + 20, argumentPanel.y + 57);
						//First Vertical Line Finishing Point
						var lastMenuPanel:MenuPanel = menuPanelsHash[layoutController.getBottomArgument(model).ID];
						var fvlfpy:int = (lastMenuPanel.y + 72);
						//draw a line
						drawUtility.graphics.moveTo(fvlspx, fvlspy);
						drawUtility.graphics.lineTo(fvlspx, fvlfpy);
						
						//Line from claim to vertical line starting point
						var firstMenuPanel:MenuPanel = menuPanelsHash[model.supportingArguments[0].ID];
						drawUtility.graphics.moveTo(argumentPanel.x + argumentPanel.width, argumentPanel.y + 72);
						drawUtility.graphics.lineTo(fvlspx, argumentPanel.y + 72);
						//for each argument
						for each(argumentTypeModel in model.supportingArguments){
							//get the point one grid before the first reason horizontally.
							var rspx:int = (argumentTypeModel.reasonModels[0].ygrid - 1) * gridWidth;
							var rspy:int = argumentTypeModel.xgrid * gridWidth + 72;
							//get the point in front of the last reason
							var rfpy:int = layoutController.getBottomReason(argumentTypeModel).xgrid * gridWidth + 72;
							
							//draw a line
							drawUtility.graphics.moveTo(rspx, rspy);
							drawUtility.graphics.lineTo(rspx, rfpy);
							
							var menuPanel:MenuPanel = menuPanelsHash[argumentTypeModel.ID];
							//Line from menu Panel to the starting point of reason vertical line
							drawUtility.graphics.moveTo(menuPanel.x + menuPanel.width -30, menuPanel.y + 72);
							drawUtility.graphics.lineTo(rspx, menuPanel.y + 72);
							
							//Line from first vertical line to menu Panel
							drawUtility.graphics.moveTo(fvlspx, menuPanel.y + 72);
							drawUtility.graphics.lineTo(menuPanel.x+10, menuPanel.y + 72);
							
							//Line from menuPanel to Inference
							var inferencePanel:ArgumentPanel = panelsHash[argumentTypeModel.inferenceModel.ID];
							if(inferencePanel.visible){
								drawUtility.graphics.moveTo(menuPanel.x + menuPanel.width/2, menuPanel.y+menuPanel.height+10);
								drawUtility.graphics.lineTo(menuPanel.x + menuPanel.width/2, inferencePanel.y);
							}
							for each(statementModel in argumentTypeModel.reasonModels){
								//hline
								var poReason:int = statementModel.xgrid * gridWidth + 72;
								drawUtility.graphics.moveTo(rspx, poReason);
								drawUtility.graphics.lineTo(statementModel.ygrid * gridWidth, poReason);
							}
						}
					}
					if(model.objections.length > 0){
						drawUtility.graphics.lineStyle(10, 0xF99653, 10);
						argumentPanel = panelsHash[model.ID];
						var lastObjection:StatementModel = layoutController.getBottomObjection(model);
						if(lastObjection != null){
							
							var bottomObjection:ArgumentPanel = panelsHash[lastObjection.ID];
							fvlspx = argumentPanel.x + argumentPanel.getExplicitOrMeasuredWidth() - 30;
							fvlspy = argumentPanel.y-15 + argumentPanel.getExplicitOrMeasuredHeight();
							fvlfpy = bottomObjection.y + 72;
							//draw a line from the first objection to the last objection
							//and an arrow
							drawUtility.graphics.moveTo(fvlspx, fvlfpy);
							drawUtility.graphics.lineTo(fvlspx, fvlspy);
							drawUtility.graphics.lineTo(fvlspx-15, fvlspy +15);
							drawUtility.graphics.moveTo(fvlspx, fvlspy);
							drawUtility.graphics.lineTo(fvlspx+15, fvlspy+15);
							for each(var obj:StatementModel in model.objections){
								//horizontal line from the vertical line to the objection
								if(panelsHash.hasOwnProperty(obj.ID)){
									var objectionPanel:ArgumentPanel = panelsHash[obj.ID];
									if(!textLabel[obj.ID])
										textLabel[obj.ID] = new spark.components.Label();
									drawUtility.graphics.moveTo(fvlspx, objectionPanel.y +72);
									//drawUtility.graphics.lineTo(fvlspx+(objectionPanel.x-fvlspx)/2-35 , objectionPanel.y + 72);
									//drawUtility.graphics.moveTo(fvlspx+(objectionPanel.x-fvlspx)/2+45, objectionPanel.y +72);
									drawUtility.graphics.lineTo(objectionPanel.x, objectionPanel.y +72);
									if(objectionPanel.statementType == StatementModel.OBJECTION)
										textLabel[obj.ID].text = Language.lookup("objects");
									else if(objectionPanel.statementType == StatementModel.COUNTER_EXAMPLE)
										textLabel[obj.ID].text = Language.lookup("defeats");
									textLabel[obj.ID].x = objectionPanel.x - (objectionPanel.x - fvlspx)/2 - 17;
									textLabel[obj.ID].y = objectionPanel.y + 68;
									textLabel[obj.ID].visible = true;
									textLabel[obj.ID].width=70;
									textLabel[obj.ID].height=25;
									textLabel[obj.ID].opaqueBackground = 0xFFFFFF;
									drawUtility.addChild(textLabel[obj.ID]);
									drawUtility.invalidateDisplayList();
								}
							}
						}	
					}
					if(model.comments.length > 0){
							
						var test:int  = AGORAModel.getInstance().agoraMapModel.hide[model.ID];
						var test1:Boolean = AGORAModel.getInstance().agoraMapModel.addClicked;
						if (AGORAModel.getInstance().agoraMapModel.hide.hasOwnProperty(model.ID) && AGORAModel.getInstance().agoraMapModel.hide[model.ID] != 1)
						{
							
							//this.alpha = 0.2;
							AGORAModel.getInstance().agoraMapModel.addClicked = 0;
							//AGORAModel.getInstance().agoraMapModel.hide[model.ID] = 1;
							
							argumentPanel = panelsHash[model.ID];
							var lastObjection:StatementModel = layoutController.getBottomComment(model);
							//if(layoutController.getBottomObjection(model)!=null)
								//lastObjection = layoutController.getBottomObjection(model);
							if(lastObjection != null){

								var bottomObjection:ArgumentPanel = panelsHash[lastObjection.ID];
								if(bottomObjection !=null)
									{
									fvlspx = argumentPanel.x + argumentPanel.getExplicitOrMeasuredWidth() - 70;
									fvlspy = argumentPanel.y-15 + argumentPanel.getExplicitOrMeasuredHeight();
									
									fvlfpy = bottomObjection.y + 72;
									
									//draw a line from the first objection to the last objection
									//and an arrow						
								}
								/*var rectHeight:int = bottomObjection.y+100 - model.comments.length * 135;
								var firstComment:ArgumentPanel = panelsHash[model.comments[0].ID];
								 // initializing the variable named rectangle
								rectangle.graphics.beginFill(0xFFFF00); // choosing the colour for the fill, here it is red
								rectangle.graphics.drawRect(fvlspx,rectHeight,400,bottomObjection.y-rectHeight+100); // (x spacing, y spacing, width, height)
								rectangle.graphics.endFill(); // not always needed but I like to put it in to end the fill
								drawUtility2.addChild(rectangle);
								//drawUtility.opaqueBackground = 0xFFFFFF;*/
								drawUtility1.graphics.lineStyle(10, 0xFFFF00, 10);
								for each(var obj:StatementModel in model.comments){
									//horizontal line from the vertical line to the objection
									if(AGORAModel.getInstance().agoraMapModel.panelListHash.hasOwnProperty(obj.ID)){
										var objectionPanel:ArgumentPanel = panelsHash[obj.ID];
										if(!textLabel[obj.ID])
											textLabel[obj.ID] = new spark.components.Label();
										
										textLabel[obj.ID].x = objectionPanel.x - (objectionPanel.x - fvlspx)/2 - 30;
										textLabel[obj.ID].y = objectionPanel.y+66;
										
										if(objectionPanel.statementType == StatementModel.COMMENT)
										{
											drawUtility1.graphics.moveTo(fvlspx, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(fvlspx, fvlspy);
											drawUtility1.graphics.lineTo(fvlspx-15, fvlspy +15);
											drawUtility1.graphics.moveTo(fvlspx, fvlspy);
											drawUtility1.graphics.lineTo(fvlspx+15, fvlspy+15);
											drawUtility1.graphics.moveTo(fvlspx, objectionPanel.y +72);
											//drawUtility1.graphics.lineTo(fvlspx+(objectionPanel.x-fvlspx)/2-35 , objectionPanel.y + 72);
											//drawUtility1.graphics.moveTo(fvlspx+(objectionPanel.x-fvlspx)/2+48, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x, objectionPanel.y +72);
											textLabel[obj.ID].text = Language.lookup("Comments");
											textLabel[obj.ID].width=85;
											textLabel[obj.ID].height=25;
										}
										else if(objectionPanel.statementType == StatementModel.REFORMULATION)
										{
											drawUtility1.graphics.moveTo(fvlspx, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(fvlspx, fvlspy);
											drawUtility1.graphics.lineTo(fvlspx-15, fvlspy +15);
											drawUtility1.graphics.moveTo(fvlspx, fvlspy);
											drawUtility1.graphics.lineTo(fvlspx+15, fvlspy+15);
											drawUtility1.graphics.moveTo(fvlspx, objectionPanel.y +72);
											//drawUtility1.graphics.lineTo(fvlspx+(objectionPanel.x-fvlspx)/2-45 , objectionPanel.y + 72);
											//drawUtility1.graphics.moveTo(fvlspx+(objectionPanel.x-fvlspx)/2+45, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x, objectionPanel.y +72);
											textLabel[obj.ID].text = Language.lookup("EquivEquiv");
											textLabel[obj.ID].width=50;
											textLabel[obj.ID].height=20;
										}
										else if(objectionPanel.statementType == StatementModel.AMENDMENT)
										{
											drawUtility1.graphics.moveTo(fvlspx, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(fvlspx, fvlspy);
											drawUtility1.graphics.lineTo(fvlspx-15, fvlspy +15);
											drawUtility1.graphics.moveTo(fvlspx, fvlspy);
											drawUtility1.graphics.lineTo(fvlspx+15, fvlspy+15);
											drawUtility1.graphics.moveTo(fvlspx, objectionPanel.y +72);
											//drawUtility1.graphics.lineTo(fvlspx+(objectionPanel.x-fvlspx)/2-35 , objectionPanel.y + 72);
											//drawUtility1.graphics.moveTo(fvlspx+(objectionPanel.x-fvlspx)/2+45, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x, objectionPanel.y +72);
											textLabel[obj.ID].text = Language.lookup("FriendlyAmendTo");
											textLabel[obj.ID].width=80;
											textLabel[obj.ID].height=38;
										}
										else if(objectionPanel.statementType == StatementModel.SUPPORT)
										{
											drawUtility1.graphics.moveTo(fvlspx, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(fvlspx, fvlspy);
											drawUtility1.graphics.lineTo(fvlspx-15, fvlspy +15);
											drawUtility1.graphics.moveTo(fvlspx, fvlspy);
											drawUtility1.graphics.lineTo(fvlspx+15, fvlspy+15);
											drawUtility1.graphics.moveTo(fvlspx, objectionPanel.y +72);
											//drawUtility1.graphics.lineTo(fvlspx+(objectionPanel.x-fvlspx)/2-35 , objectionPanel.y + 72);
											//drawUtility1.graphics.moveTo(fvlspx+(objectionPanel.x-fvlspx)/2+45, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x, objectionPanel.y +72);
											textLabel[obj.ID].text = Language.lookup("Supports");
											textLabel[obj.ID].width=65;
											textLabel[obj.ID].height=25;
										}
										else if(objectionPanel.statementType == StatementModel.LINKTOMAP)
										{
											drawUtility1.graphics.moveTo(fvlspx-30,fvlspy);
											drawUtility1.graphics.lineTo(fvlspx-30, objectionPanel.y +72);
											drawUtility1.graphics.moveTo(fvlspx-30, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(fvlspx+(objectionPanel.x-fvlspx)/2-35 , objectionPanel.y + 72);
											drawUtility1.graphics.moveTo(fvlspx+(objectionPanel.x-fvlspx)/2+45, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x-15, objectionPanel.y+72-15);
											drawUtility1.graphics.moveTo(objectionPanel.x, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x-15, objectionPanel.y+72+15);
											textLabel[obj.ID].text = Language.lookup("SeeAlsoArgumentMap");
											textLabel[obj.ID].width=50;
											textLabel[obj.ID].height=20;
										}
										else if(objectionPanel.statementType == StatementModel.LINKTORESOURCES)
										{
											drawUtility1.graphics.moveTo(fvlspx-30,fvlspy);
											drawUtility1.graphics.lineTo(fvlspx-30, objectionPanel.y +72);
											drawUtility1.graphics.moveTo(fvlspx-30, objectionPanel.y +72);
											//drawUtility1.graphics.lineTo(fvlspx+(objectionPanel.x-fvlspx)/2-35 , objectionPanel.y + 72);
											//drawUtility1.graphics.moveTo(fvlspx+(objectionPanel.x-fvlspx)/2+5, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x-15, objectionPanel.y+72-15);
											drawUtility1.graphics.moveTo(objectionPanel.x, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x-15, objectionPanel.y+72+15);
											textLabel[obj.ID].text = Language.lookup("seeMap");
											textLabel[obj.ID].width=40;
											textLabel[obj.ID].height=20;
										}
										else if(objectionPanel.statementType == StatementModel.REFERENCE)
										{
											drawUtility1.graphics.moveTo(fvlspx-30,fvlspy);
											drawUtility1.graphics.lineTo(fvlspx-30, objectionPanel.y +72);
											drawUtility1.graphics.moveTo(fvlspx-30, objectionPanel.y +72);
											//drawUtility1.graphics.lineTo(fvlspx+(objectionPanel.x-fvlspx)/2-35 , objectionPanel.y + 72);
											//drawUtility1.graphics.moveTo(fvlspx+(objectionPanel.x-fvlspx)/2+5, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x-15, objectionPanel.y+72-15);
											drawUtility1.graphics.moveTo(objectionPanel.x, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x-15, objectionPanel.y+72+15);
											textLabel[obj.ID].text = Language.lookup("seeMap");
											textLabel[obj.ID].width=40;
											textLabel[obj.ID].height=20;
										}
										else if(objectionPanel.statementType == StatementModel.DEFINITION)
										{
											drawUtility1.graphics.moveTo(fvlspx, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(fvlspx, fvlspy);
											drawUtility1.graphics.lineTo(fvlspx-15, fvlspy +15);
											drawUtility1.graphics.moveTo(fvlspx, fvlspy);
											drawUtility1.graphics.lineTo(fvlspx+15, fvlspy+15);
											drawUtility1.graphics.moveTo(fvlspx, objectionPanel.y +72);
											//drawUtility1.graphics.lineTo(fvlspx+(objectionPanel.x-fvlspx)/2-35 , objectionPanel.y + 72);
											//drawUtility1.graphics.moveTo(fvlspx+(objectionPanel.x-fvlspx)/2+30, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x, objectionPanel.y +72);
											textLabel[obj.ID].text = Language.lookup("Defines");
											textLabel[obj.ID].width=65;
											textLabel[obj.ID].height=25;
											
										}
										else if(objectionPanel.statementType == StatementModel.QUESTION)
										{
											drawUtility1.graphics.moveTo(fvlspx-30,fvlspy);
											drawUtility1.graphics.lineTo(fvlspx-30, objectionPanel.y +72);
											drawUtility1.graphics.moveTo(fvlspx-30, objectionPanel.y +72);
											//drawUtility1.graphics.lineTo(fvlspx+(objectionPanel.x-fvlspx)/2-35 , objectionPanel.y + 72);
											//drawUtility1.graphics.moveTo(fvlspx+(objectionPanel.x-fvlspx)/2+40, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x-15, objectionPanel.y+72-15);
											drawUtility1.graphics.moveTo(objectionPanel.x, objectionPanel.y +72);
											drawUtility1.graphics.lineTo(objectionPanel.x-15, objectionPanel.y+72+15);
											textLabel[obj.ID].text = Language.lookup("LeadsToQ");
											textLabel[obj.ID].width=70;
											textLabel[obj.ID].height=25;
										}
										
										textLabel[obj.ID].visible = true;
										textLabel[obj.ID].opaqueBackground = 0xFFFFFF;
										drawUtility1.addChild(textLabel[obj.ID]);
										drawUtility1.invalidateDisplayList();	
									}
								}
							}
						}	
					}
				}
			}
		}
	}
}