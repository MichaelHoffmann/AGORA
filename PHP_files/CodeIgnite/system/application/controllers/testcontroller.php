<?php

class TestController extends Controller{
	function TestController(){
		parent::Controller();
		$this->load->model('ReasonModel');
		$this->load->model('ClaimModel');
		$this->load->model('ArgumentSchemeModel');
	}
	
	function index(){
		$this->ClaimModel->acceptClaim("This is a claim",1,1,1,1,1);
		echo "Testing";
	}
}