<?php

class ClaimModel extends Model{
	function ClaimModel(){
		parent::Model();
		$this->load->database();
	}
	
	function acceptClaim($claim,$claim_index,$x,$y,$user_id,$map_id=1){
		$sql = "insert into claim(claim_text,claim_index,x,y,id,claim_map_id) values (\"$claim\",$claim_index,$x,$y,$user_id,$map_id)";
		$query = $this->db->query($sql);
	}
	
	function returnClaim($claim_text,$user_id,$map_id=1){
		$sql = "select claim_text,claim_index,x,y from claim where claim_text = \"$claim_text\" id = $user_id and claim_map_id = $map_id";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	function updateClaim($claim_text,$claim_index,$user_id,$map_id=1){
		$sql = "update claim set claim_text = \"$claim_text\" where claim_index=$claim_index and id=$user_id and claim_map_id=$map_id";
		$query = $this->db->query($sql);
	}
}
?>
