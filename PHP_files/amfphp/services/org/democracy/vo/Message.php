<?php
class Message {
	
	public $message_id;
	public $category_id;
	public $category_name;
	public $question;
	public $answer;
	public $answer_signature;
	public $observer_user_id;
	public $question_id;
	public $observer_id;
	public $tid;
	public $time_received;
	public $time_display;	
	// explicit actionscript class
	var $_explicitType = "org.democracy.vo.Message";
	
}


?>