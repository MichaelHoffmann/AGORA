package components
{
	import Controller.ArgumentController;
	
	import Model.AGORAModel;
	import Model.LoadProjectMapsModel;
	import Model.MapMetaData;
	import Model.ProjectListModel;
	import Model.VerifyProjectPasswordModel;
	
	import classes.Language;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	
	public class ProjectListPanel extends Panel
	{
		private var model:ProjectListModel;
		private var projMapModel:LoadProjectMapsModel;
		public var loadingDisplay:Label;
		public var scroller:Scroller;
		
		public var vContentGroup:Group; 
		
		public function ProjectListPanel()
		{
			super();
			model = AGORAModel.getInstance().projectListModel;
			projMapModel = AGORAModel.getInstance().loadProjMaps;
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
		}
		
	
		
		override protected function commitProperties():void{
			super.commitProperties();
			
			vContentGroup.removeAllElements();
			//add elements
			if(model.projectList){
				for each(var projXML:XML in model.projectList.proj){
					var button:Button = new Button;
					button.name = projXML.@ID;
					button.label = projXML.@title;
					button.toolTip = projXML.@creator;
					button.width = 170;
					vContentGroup.addElement(button);
					button.addEventListener('click',function(e:Event):void
					{
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
		
		/**
		 * Deletes the current window and repopulates with the maps within that project.
		 * This was taken from mapListPanel and refactored
		 */
		public function onCorrectPassword(projectMapList:XML):void{
			super.commitProperties();
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
			
		}
		
		override protected function measure():void{
			super.measure();	
		}
		
		protected function onMapObjectClicked(event:MouseEvent):void{
			ArgumentController.getInstance().loadMap(event.target.name);					
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			loadingDisplay.move(this.getExplicitOrMeasuredWidth()/2 - loadingDisplay.getExplicitOrMeasuredWidth()/2, 5);
		}
	}
}