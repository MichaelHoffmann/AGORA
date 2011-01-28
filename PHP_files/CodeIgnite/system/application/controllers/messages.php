<?php

class Messages extends Controller {
	function Messages(){
		parent::Controller();
		$this->load->library('session');
		$this->load->model('MessageModel');
		$this->load->model('ObserverModel');
		$this->load->helper('url');
	}
	
	function index($refresh="on"){
			$username=$this->session->userdata('username');
			if(empty($username)){
				$data['info']="Please log in to access this page";
				header("Location: http://localhost/eDemocracy/index.php/admin");
			}
			$i=1;
			$result=$this->MessageModel->read_messages();
			if($result==false){
				$data['message']="No new messages";
			}
			else{
				$data['message']="New message received!";
			}
			$result=$this->MessageModel->get_messages();
			$i=0;
			foreach($result as $row){
				$data['messages'][$i]=0;
				$data['answer'][$i]=$row->answer;
				$data['question'][$i]=$row->question;
				$data['category'][$i]=$row->category_name;
				$data['latitude'][$i]=$row->latitude;
				$data['longitude'][$i]=$row->longitude;
				$data['responseid'][$i]=$row->response_id;
				$data['approver'][$i]=$row->approver;
				$data['observer'][$i]=$row->observer_user_id;
				$data['timestamp'][$i]=$row->time_received;
				$i++;
			}
			$result=$this->ObserverModel->get_observer_location();
			$i=0;
			foreach($result as $row){
				$data['glatitude'][$i]=$row->latitude;
				$data['glongitude'][$i]=$row->longitude;
				$i++;
			}
			$data['refresh']=$refresh;
			$this->load->view('messageview',$data);
			
			
			
	}
	
	function sortbyobservers(){
		$observer_id=$_POST['observer_id'];
		$result=$this->MessageModel->get_messages_by_observer($observer_id);
		$i=0;
			foreach($result as $row){
				$data['messages'][$i]=0;
				$data['answer'][$i]=$row->answer;
				$data['question'][$i]=$row->question;
				$data['category'][$i]=$row->category_name;
				$data['latitude'][$i]=$row->latitude;
				$data['longitude'][$i]=$row->longitude;
				$data['responseid'][$i]=$row->response_id;
				$data['approver'][$i]=$row->approver;
				$data['observer'][$i]=$row->observer_user_id;
				$data['timestamp'][$i]=$row->time_received;
				$i++;
			}
			$result=$this->ObserverModel->get_observer_location($observer_id);
			$i=0;
			foreach($result as $row){
				$data['glatitude'][$i]=$row->latitude;
				$data['glongitude'][$i]=$row->longitude;
				$i++;
			}
			$data['refresh']="off";
			$data['message']="Selecting messages from Observer ".$observer_id;
			$this->load->view('messageview',$data);

		}
	function set_refresh(){
		$refresh="on";
		if(isset($_POST['refresh'])){
			$refresh=$_POST['refresh'];
			
		}
		$this->index($refresh);
	}
}

?>