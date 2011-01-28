<?php

class Login extends Controller {
	function Login(){
		parent::Controller();
		$this->load->library('session');
		//$this->load->model('ObserverModel');
	}
	
	function index(){
		$data['info']=NULL;
		$this->load->view('login_page',$data);
		
	}
	function authenticate(){
		$this->load->model('LoginModel');		
		$auth = $this->LoginModel->verify_login();
		print "Random things happening here!";			
		if($auth){
			$this->dashboard();
		}
		else{
			$data['info']="Login Failed, Please Try Again";
			$this->load->view('login_page',$data);
		}
	}
	function dashboard(){
		$username=$this->session->userdata('username');
		if(empty($username)){
			$data['info']="Please log in to access this page";
			$this->load->view('login_page',$data);
			return;
		}
		$this->load->model('ObserverModel');
		$this->load->model('MessageModel');
		$list=$this->ObserverModel->get_observers();
		
		$i=0;
		$data['username']=$username;
		foreach($list as $row){
			$data['observerlist'][$i]['name']=$row->first_name;
			$data['observerlist'][$i]['id'] = $row->observer_id;
			$data['observerlist'][$i]['number']= $row->phone_number;
			$i++;
			//$data['observerlist']['timestamp']=$this->MessageModel->get_last_message_time($row->observer_id);
			//$messageid=$this->MessageModel->get_last_message_id($row->observer_id);
			//$data['observerlist']['approver']=$this->MessageModel->get_approver($messageid);
		}
		$result=$this->ObserverModel->get_observer_location();
		$i=0;
		foreach($result as $row){
			$data['glatitude'][$i]=$row->latitude;
			$data['glongitude'][$i]=$row->longitude;
			$i++;
		}
		$this->load->view('welcome',$data);
	}
	function logout(){
		$this->session->unset_userdata('username');
		$this->session->sess_destroy();
		$data['info']="Successful logout";
		$this->load->view('login_page',$data);
	}
	function messages(){
		$this->load->view('messageview.php');
	}
	
}
