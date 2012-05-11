package components
{
	import Controller.ArgumentController;
	import Controller.UserSessionController;
	
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.MapMetaData;
	import Model.ProjectsModel;
	import Model.UserSessionModel;
	
	import classes.Language;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	
	public class Projects extends Panel
	{
		public var loadingDisplay:Label;
		public var vContentGroup:Group;
		public var scroller:Scroller;
		public var model:ProjectsModel;
		public var signIn:Label;
		
		public function Projects()
		{
			super();
			model = AGORAModel.getInstance().myProjectsModel;
			scroller = new Scroller;
			scroller.x = scroller.y = 5;
			scroller.percentHeight = scroller.percentWidth = 100;
			vContentGroup = new Group;
			vContentGroup.layout = new VerticalLayout();
			//vContentGroup.layout.gap = 10;
			scroller.viewport = vContentGroup;
			this.addElement(scroller);
			loadingDisplay = new Label;
			loadingDisplay.text = Language.lookup("Loading");
			addElement(loadingDisplay);
			signIn = new Label;
			signIn.horizontalCenter = 0;
			signIn.setStyle("textDecoration","underline");
			signIn.text = Language.lookup("SignInToViewProj");
			signIn.addEventListener(MouseEvent.CLICK, showSignInBox);
			this.addElement(signIn);
		}
		
		
		override protected function measure():void{
			super.measure();
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(usm.loggedIn()){
				removeElement(signIn);
				if(model.projectList){
					for each(var xml:XML in model.projectList.proj){
						var button:Button = new Button;
						button.name = xml.@ID;
						button.label = xml.@title;
						button.toolTip = xml.@creator;
						vContentGroup.addElement(button);
						button.addEventListener('click',function(e:Event):void{
							e.stopImmediatePropagation();
							AGORAModel.getInstance().agoraMapModel.projectID = e.target.name;
							AGORAModel.getInstance().agoraMapModel.projectName = e.target.label;
							FlexGlobals.topLevelApplication.join_project = new Join_Project;
							PopUpManager.addPopUp(FlexGlobals.topLevelApplication.join_project, DisplayObject(FlexGlobals.topLevelApplication),true);
							PopUpManager.centerPopUp(FlexGlobals.topLevelApplication.join_project);
						}, false, 1,false);
						
					}
				}	
			}
			else{
				vContentGroup.removeAllElements();
				addElement(signIn);
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			loadingDisplay.move(getExplicitOrMeasuredWidth()/2 - loadingDisplay.getExplicitOrMeasuredWidth()/2, 10);
			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(!usm.loggedIn()){
				signIn.move(getExplicitOrMeasuredWidth()/2 - signIn.getExplicitOrMeasuredWidth()/2, 140);
			}
		}
		
		
		/**
		 * Deletes the current window and repopulates with the maps within that project.
		 * This was taken from mapListPanel and refactored
		 */
		public function onCorrectPassword(projectMapList:XML):void{
			super.commitProperties();
			FlexGlobals.topLevelApplication.agoraMenu.createProjectBtn.label = "Create a map within this project";
			vContentGroup.removeAllElements();
			var mapMetaDataVector:Vector.<MapMetaData> = new Vector.<MapMetaData>(0,false);
			for each (var projectMapList:XML in projectMapList.map){
				try{
					if(projectMapList.@is_deleted == "1"){
						
						continue;
					} else if(projectMapList.@proj_id != null){
						//This needs to be set to continue
					}
				}catch(error:Error){
					trace("is_deleted not available yet");
				}
				
				//var mapObject:Object = new Object;
				mapMetaData = new MapMetaData;
				mapMetaData.mapID = int(projectMapList.attribute("ID")); 
				mapMetaData.mapName = projectMapList.attribute("title");
				//mapMetaData.mapCreator = map.attribute("creator");
				mapMetaDataVector.push(mapMetaData);						
				
				
				mapMetaDataVector.sort(MapMetaData.isGreater);
				
			}
			for each(var mapMetaData:MapMetaData in mapMetaDataVector){
				var mapButton:Button = new Button;
				mapButton.width = 170;
				mapButton.name = mapMetaData.mapID.toString();
				mapButton.addEventListener('click', onMapObjectClicked);
				mapButton.label = mapMetaData.mapName;
				//mapButton.toolTip = mapMetaData.mapCreator;
				vContentGroup.addElement(mapButton);
			}
			
		}
		
		private function getProjectPanel(event:MouseEvent):void{
			var button:Button = event.target as Button;
			//call controller
			
		}
		
		protected function onMapObjectClicked(event:MouseEvent):void{
			ArgumentController.getInstance().loadMap(event.target.name);					
		}
		
		private function showSignInBox(event:MouseEvent):void{
			UserSessionController.getInstance().showSignInBox();
		}
	}
}