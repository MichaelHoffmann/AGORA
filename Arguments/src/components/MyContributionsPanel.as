package components
{
	import Controller.AGORAController;
	import Controller.ArgumentController;
	
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.MapMetaData;
	import Model.MyContributionsModel;
	
	import Skins.LeftAlignTextButtonSkin;
	
	import ValueObjects.CategoryDataV0;
	
	import classes.Language;
	
	import components.AGORAMenu;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.skins.Border;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.TileGroup;
	import spark.components.VGroup;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	
	public class MyContributionsPanel extends Panel
	{
		private var model:MyContributionsModel;
		public var loadingDisplay:Label;
		public var scroller:Scroller;
		public var categoryTiles:Group;
		private var mapPanel:VGroup;
		private var subprojectPanel:VGroup;
		private var createProjectPanel : HGroup;
		private var projectMemberPanel : VGroup;
		private var projectTypePanel : VGroup;
		private var mapPanelLbl:Label;
		private var is_project_level:Boolean;
		private var tl:TileLayout;
		private var mapMetaDataVector:Vector.<MapMetaData>;
		private var subprojectPanelLbl:Label;
		private var projectTitlePanel: HGroup;
		private var projectPanel :VGroup;
		
		private var rsp:RightSidePanel;
		public function MyContributionsPanel()
		{
			super();
			/*Instantiations in order of depth in UI field*/
			scroller = new Scroller;
			categoryTiles = new Group;
			tl = new TileLayout();
			mapPanel = new VGroup;
			subprojectPanel = new VGroup;
			subprojectPanelLbl = new Label();
			projectPanel = new VGroup();
			projectTitlePanel = new HGroup();
			projectMemberPanel = new VGroup;
			createProjectPanel = new HGroup;
			projectTypePanel = new VGroup;
			loadingDisplay = new Label;
			mapPanelLbl = new Label();
			model = AGORAModel.getInstance().mycontributionsModel
			/*Setting the UI components to the proper places and sizes*/
			this.percentHeight = this.percentWidth = 100;
			scroller.percentHeight = scroller.percentWidth = 100;
			scroller.x = scroller.y = 25;
			categoryTiles.percentHeight = 100;
			categoryTiles.percentWidth = 100;
			mapPanel.percentWidth = 50;
			projectPanel.percentWidth= 50;
			subprojectPanel.percentWidth = 33;
			createProjectPanel.percentWidth = 50;
			projectMemberPanel.percentWidth = 33;
			//projectTypePanel.percentWidth = 25;
			/*Editing how the layout will be for the buttons*/		
			tl.requestedColumnCount = 3;
			tl.requestedRowCount = 3;
			tl.horizontalAlign="center";
			tl.verticalAlign = "middle";
			tl.columnAlign="justifyUsingWidth";
			tl.rowAlign="justifyUsingHeight";
			categoryTiles.layout = tl;
			/*Adding the category tiles elemet as viewport of scroller*/
			scroller.viewport = categoryTiles;
			/*Making scroller part of this UI component*/
			this.addElement(scroller);
			/*Setting up loading display*/
			loadingDisplay.text = Language.lookup("Loading");
			addElement(loadingDisplay);
			
			rsp = FlexGlobals.topLevelApplication.rightSidePanel;
		}
		
		
		override protected function commitProperties():void{
			super.commitProperties();
			categoryTiles.removeAllElements();
			subprojectPanel.removeAllElements();
			projectTitlePanel.removeAllElements();
			projectPanel.removeAllElements();
			projectMemberPanel.removeAllElements();
			projectTypePanel.removeAllElements();			
			mapPanel.removeAllElements();
			if(model.contributions){
				if(model.map && model.map.list.@map_count!=0 && model.project)
				{
					this.categoryTiles.layout = new HorizontalLayout;
					mapPanel.percentWidth=33;
					projectPanel.percentWidth=33;
					FlexGlobals.topLevelApplication.agoraMenu.createMapBtnContributions.visible = true;
					FlexGlobals.topLevelApplication.agoraMenu.createMapBtnContributions.label = Language.lookup('NewMaphere');
					FlexGlobals.topLevelApplication.agoraMenu.createProjBtnContributions.enabled = true;
					FlexGlobals.topLevelApplication.agoraMenu.createProjBtnContributions.visible = true;
					FlexGlobals.topLevelApplication.agoraMenu.clickthruCategories.visible = true;
						mapPanel.paddingTop = 65;
						projectMemberPanel.paddingTop = 65;
						projectPanel.addElement(projectTitlePanel);
						projectPanel.addElement(subprojectPanel);
						categoryTiles.addElement(projectPanel);
						categoryTiles.addElement(mapPanel);
						categoryTiles.addElement(projectMemberPanel);
						mapPanelLbl.text = Language.lookup('MapsinProject');
						subprojectPanelLbl.text = Language.lookup('SubProj');
						var currProjLbl:mx.controls.Label = new mx.controls.Label();
						currProjLbl.text= AGORAController.getInstance().contributionsCategoryChain.getItemAt(AGORAController.getInstance().contributionsCategoryChain.length-1).current;
						currProjLbl.setStyle("fontSize",14);
						currProjLbl.width = 360;
					//	var currProjButton:Button = new Button();
					//	currProjButton.label = AGORAController.getInstance().contributionsCategoryChain.getItemAt(AGORAController.getInstance().contributionsCategoryChain.length-1).current;
						projectTitlePanel.paddingBottom = 10;
						projectTitlePanel.addElement(currProjLbl);
						subprojectPanel.addElement(subprojectPanelLbl);
						subprojectPanel.paddingTop = 20;
						var lblType: Label = new Label();
						lblType.text = Language.lookup('ProjType');
						
						var btnProjLbl: Label = new Label();
						btnProjLbl.height = undefined;
						btnProjLbl.width = undefined;
						if(model.project.proj.@isHostile == 1)
							btnProjLbl.text = "adversarial" ;
						else if(model.project.proj.@isHostile == 0)
							btnProjLbl.text = "collaborative";
						if(model.project.proj.@isHostile[0])
						{
							projectTypePanel.addElement(btnProjLbl);
							projectTypePanel.paddingLeft = 100;
							projectTypePanel.paddingTop = 10;
							projectTitlePanel.addElement(projectTypePanel);
						}
						
						if(model.project.proj.admin[0])
						{
							var lblAdmin: Label = new Label();
							lblAdmin.text = Language.lookup('ProjectAdmin');
							projectMemberPanel.addElement (lblAdmin);
							for each (var projectXML:XML in model.project.proj.admin)
							{
								var btnProjAdmin:Button = new Button();
								btnProjAdmin.height = undefined;
								btnProjAdmin.width = undefined;
								btnProjAdmin.label = projectXML.@name ;
								btnProjAdmin.setStyle("chromeColor", 0xF99653);
								
								projectMemberPanel.addElement (btnProjAdmin);
								btnProjAdmin.addEventListener('click',function(e:Event):void{
									var url:String;
									for each (var adminXML:XML in model.project.proj.admin)
									{
										if(adminXML.@name == e.target.label)
										  url = adminXML.@url;
									}
									var myURL:URLRequest = new URLRequest(url);
									navigateToURL(myURL, "_blank");
								}, false, 1,false);		
							}
						}
						if(model.project.proj.users.userDetail[0])
						{
							var lblUsers: Label = new Label();
							lblUsers.text = "\n "+Language.lookup('ProjectMembers');
							projectMemberPanel.addElement (lblUsers);
						}
						if(model.map != null){
							mapPanel.addElement(mapPanelLbl);
							populateMaps();
						}
						for each (var projectXML:XML in model.project.proj.users.userDetail)
						{
							var btnProjMembers:Button = new Button();
							btnProjMembers.height = undefined;
							btnProjMembers.width = undefined;
							btnProjMembers.label = projectXML.@name ;
							btnProjMembers.setStyle("chromeColor", 0xF99653);
							
							projectMemberPanel.addElement (btnProjMembers);
							btnProjMembers.addEventListener('click',function(e:Event):void{
								var url:String;
								for each (var adminXML:XML in model.project.proj.users.userDetail)
								{
									if(adminXML.@name == e.target.label)
										url = adminXML.@url;
								}
								var myURL:URLRequest = new URLRequest(url);
								navigateToURL(myURL, "_blank");
							}, false, 1,false);
						}
						for each(var categoryXML:XML in model.category.category){
							trace("Adding buttons");
							/*Create and setup buttons corresponding to categories*/
							var button:Button = new Button;
							
							button.height = 24;
							button.width = 300;
							button.toolTip = categoryXML.@Name;
							button.name = categoryXML.@ID; //The ID (unique DB identifier) of the category
							button.label = categoryXML.@Name; //The title of the category (e.g. Philosophy, Biology, or Projects)
							
							button.setStyle("chromeColor", 0xA0CADB);	
							button.setStyle("skinClass",LeftAlignTextButtonSkin);
							//subprojectPanel.paddingLeft = 25;
							subprojectPanel.addElement(button);
							button.addEventListener('click',function(e:Event):void{
								//Begin private inner click event function for button
								trace("button \"" + e.target.label + "\" clicked");
								e.stopImmediatePropagation();	
								//Checks to see if the current category is a project
								AGORAModel.getInstance().agoraMapModel.tempprojectID = AGORAModel.getInstance().agoraMapModel.projectID;
								AGORAModel.getInstance().agoraMapModel.tempprojID = AGORAModel.getInstance().agoraMapModel.projID;								
								AGORAModel.getInstance().agoraMapModel.projectID = e.target.name;
								AGORAModel.getInstance().agoraMapModel.projID = e.target.name;
								AGORAController.getInstance().verifyProjectMember(e.target.label,e.target.name);
								AGORAController.getInstance().fetchChildCategorycontributions(e.target.label,e.target.name, true);
							}, false, 1,false);
						}
			}
					else
					{
						FlexGlobals.topLevelApplication.agoraMenu.createProjBtnContributions.enabled = false;
						FlexGlobals.topLevelApplication.agoraMenu.createProjBtnContributions.visible = false;
						FlexGlobals.topLevelApplication.agoraMenu.createMapBtnContributions.visible = false;
						FlexGlobals.topLevelApplication.agoraMenu.clickthruCategories.visible = true;
						mapPanel.percentWidth=50;
						projectPanel.percentWidth=50;
						mapPanel.paddingTop = 0;
				mapPanelLbl.text = Language.lookup('ContributionMaps');
				mapPanelLbl
				mapPanel.addElementAt(mapPanelLbl,0);
				subprojectPanelLbl.text = Language.lookup('MemberProjects');
				projectPanel.addElementAt(subprojectPanelLbl,0);
				if(model.contributions.MapsList != null){
					populateMaps();
				}
				for each(var projectXML:XML in model.contributions.ProjectList.proj){
					trace("Adding buttons");
					/*Create and setup buttons corresponding to categories*/
					var button:Button = new Button;

					button.height = 24;
					button.width = 300;
					button.toolTip = projectXML.@title;
					button.name = projectXML.@ID; //The ID (unique DB identifier) of the category
					button.label = projectXML.@title; //The title of the category (e.g. Philosophy, Biology, or Projects)
					
					button.setStyle("chromeColor", 0xA0CADB);
					button.setStyle("skinClass",LeftAlignTextButtonSkin);
	
					projectPanel.addElement(button);
					button.addEventListener('click',function(e:Event):void{
						//Begin private inner click event function for button
						trace("button \"" + e.target.label + "\" clicked");
						e.stopImmediatePropagation();	
						//Checks to see if the current category is a project
						AGORAModel.getInstance().agoraMapModel.projectID = e.target.name;
						AGORAModel.getInstance().agoraMapModel.projID = e.target.name;
						AGORAController.getInstance().fetchChildCategorycontributions(e.target.label,e.target.name, true);
					}, false, 1,false);
				}
				this.categoryTiles.layout = new HorizontalLayout;
				categoryTiles.addElement(mapPanel);
				categoryTiles.addElement(projectPanel);
					}
			}
		
			
		}		
		
		/**
		 * 
		 */
		private function populateMaps():void{
			mapMetaDataVector = new Vector.<MapMetaData>(0,false);
			var mapList:XML;
			if(model.map==null)
			mapList = model.contributions.MapsList[0];
			else
				mapList= model.map;
			trace("loading maps for the project");

			for each (var map:XML in mapList.map)
			{
				//var mapObject:Object = new Object;
				mapMetaData = new MapMetaData;
				trace("map " +  map.@Name + " being loaded");
				mapMetaData.mapID = map.@ID;
				if(map.@title){
					mapMetaData.mapName = map.@title;

				}
				else if(map.@Name){
						mapMetaData.mapName = map.@Name;
						mx.controls.Alert.show(map.@Name);

				}
				mapMetaData.mapCreator = map.@creator;
			//	mapMetaData.firstname = map.@firstname;
				//mapMetaData.lastname = map.@lastname;
			//	mapMetaData.url = map.@url;
				mapMetaDataVector.push(mapMetaData);						
			}
			
			mapMetaDataVector.sort(MapMetaData.isGreater);
			var i:int = 0;
			for each(var mapMetaData:MapMetaData in mapMetaDataVector){
				var mapButton:Button = new Button;
				mapButton.setStyle("chromeColor", 0xF99653);
				mapButton.percentWidth = 100;
				mapButton.name = mapMetaData.mapID.toString();
				mapButton.label = mapMetaData.mapName;
				mapButton.id = i.toString();
				mapButton.addEventListener(MouseEvent.CLICK, onMapObjectClicked);
				trace("map " + mapMetaData.mapName + " officially added as a button");
				mapButton.toolTip = mapMetaData.mapName;
				mapPanel.addElement(mapButton);
				i++;
			}			
		}
		
		
		protected function onMapObjectClicked(event:MouseEvent):void{
			var thisMapInfo:MapMetaData = mapMetaDataVector[parseInt((Button) (event.target).id)];
			rsp.clickableMapOwnerInformation.label = thisMapInfo.mapCreator;
			rsp.mapTitle.text=thisMapInfo.mapName;
			rsp.clickableMapOwnerInformation.toolTip = 
				thisMapInfo.firstname + " " + thisMapInfo.lastname + "\n" + thisMapInfo.url + '\n' + Language.lookup('MapOwnerURLWarning');
			rsp.clickableMapOwnerInformation.addEventListener(MouseEvent.CLICK, function event(e:Event):void{
				navigateToURL(new URLRequest(thisMapInfo.url), 'quote');
			},false, 0, false);
			rsp.invalidateDisplayList();
			//mapMetaDataVector = null;
			ArgumentController.getInstance().loadMap(event.target.name);
		}
		
		
		
		override protected function measure():void{
			super.measure();	
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			loadingDisplay.move(this.getExplicitOrMeasuredWidth()/2 - loadingDisplay.getExplicitOrMeasuredWidth()/2, 5);
		}
	}
}// ActionScript file