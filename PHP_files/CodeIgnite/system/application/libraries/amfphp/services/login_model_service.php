<?php
//Load CI DB Instance since we are not coming through index.php
require_once('amfci_db.php');

// Use this path if you are using a module (ie, MatchBox)
// require_once(AMFSERVICES.'/../../../modules/test_shop/models/product_model.php');

// Use this path if you are using standard install
require_once(AMFSERVICES.'/../../../models/loginmodel.php');
class login_model_service extends LoginModel
{
  
}

?>