package components
{
	import Controller.UserSessionController;
	
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.ProjectsModel;
	import Model.UserSessionModel;
	
	import classes.Language;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.VGroup;
	
	public class Projects extends Panel
	{
		public var loadingDisplay:Label;
		public var projectsGroup:VGroup;
		public var scroller:Scroller;
		public var model:ProjectsModel;
		public var signIn:Label;
		
		public function Projects()
		{
			super();
			model = AGORAModel.getInstance().myProjectsModel;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			if(!loadingDisplay){
				loadingDisplay = new Label;
				loadingDisplay.text = Language.lookup("Loading");
				loadingDisplay.y = 10;
				loadingDisplay.visible = false;
				addElement(loadingDisplay);
			}
			if(!scroller){
				scroller = new Scroller;
				scroller.x = 10;
				scroller.y = 25;
				addElement(scroller);
			}
			if(!projectsGroup){
				projectsGroup = new VGroup;
				projectsGroup.gap = 5;
				scroller.viewport = projectsGroup;
			}
			if(!signIn){
				signIn = new Label;
				signIn.setStyle("textDecoration","underline");
				signIn.text = Language.lookup("SignInToViewProj");
				signIn.addEventListener(MouseEvent.CLICK, showSignInBox);
				addElement(signIn);
			}	
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
						projectsGroup.addElement(button);
						button.addEventListener(MouseEvent.CLICK, getProjectPanel);
					}
				}	
			}
			else{
				projectsGroup.removeAllElements();
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
		
		private function getProjectPanel(event:MouseEvent):void{
			var button:Button = event.target as Button;
			//call controller
			
		}
		
		private function showSignInBox(event:MouseEvent):void{
			UserSessionController.getInstance().showSignInBox();
		}
	}
}