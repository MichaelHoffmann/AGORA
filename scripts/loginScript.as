// ActionScript file
import mx.rpc.events.ResultEvent;


private function login():void{
	loginService.verifyLogin(username.text,password.text);
}

private function verifyLogin(event:ResultEvent):void{
	if(event.result.first_name==null){
		loginPrompt.labelText="Username and password invalid. Please verify and login again."
	}
	else{
		currentState="";
		taskPrompt.labelText="Welcome "+event.result.first_name+" "+event.result.last_name+". Please choose one of the following tasks to continue";
		_userID = event.result.id;
	}
}
