<?php

class ReasonModel extends Model{
	function ReasonModel(){
		parent::Model();
		$this->load->database();
	}
	
	function acceptReason($reason,$reason_index,$x,$y,$user_id,$claim_index,$map_id=1){
		$sql = "insert into reason(reason_text,reason_index,x,y,id,claim_index,reason_map_id) values (\"$reason\",$reason_index,$x,$y,$user_id,$claim_index,$map_id)";
		$query = $this->db->query($sql);
	}
	
	function returnReason($reason_text,$user_id,$map_id=1){
		$sql = "select reason_text,reason_index,x,y from reason where reason_text = \"$reason_text\" id = $user_id and reason_map_id = $map_id";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	function updateReason($reason_text,$reason_index,$claim_index,$user_id,$map_id=1){
		$sql = "update reason set reason_text = \"$reason_text\" where reason_index=$reason_index and claim_index=$claim_index and id=$user_id and reason_map_id=$map_id";
		$query = $this->db->query($sql);
	}
}
?>
