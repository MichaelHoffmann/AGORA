<?php
class Amf_gateway extends Controller
{
  public function __construct()
  {
    parent::Controller();
    $this->load->library('amfci');
    ini_set('include_path',
		ini_get('include_path') . PATH_SEPARATOR . AMFSERVICES);
  }
  
  public function index()
  {
    $this->amfci->service();
  }
  
}
