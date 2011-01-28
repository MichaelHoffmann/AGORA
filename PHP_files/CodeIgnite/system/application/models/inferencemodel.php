<?php

class InferenceModel extends Model {

	function InferenceModel(){
		parent::Model();
		$this->load->database();
	}

	function storeInference($inference,$inference_index,$arg_scheme,$language_form,$x,$y,$claim_index,$user_id,$map_id=1){
		$sql = "select arg_scheme_id from argschemes where class_name=\"$arg_scheme\"";
		$query = $this->db->query($sql);
		$row = $query->row();

		$arg_scheme_id = $row->arg_scheme_id;

		$sql = "select lang_id from langtypes where function_id=\"$language_form\" and arg_scheme_id = $arg_scheme_id";
		$query = $this->db->query($sql);
		$row = $query->row();

		$lang_id = $row->lang_id;

		$sql = "insert into inference (inference_text,inference_index,claim_index,arg_scheme_id,lang_id,x,y,id,map_id) values (\"$inference\",$inference_index,$claim_index,$arg_scheme_id,$lang_id,$x,$y,$user_id,$map_id)";
		$query = $this->db->query($sql);

		$sql = "select inference_id from inference where claim_index=$claim_index and map_id=$map_id and id=$user_id";
		$query = $this->db->query($sql);
		$row = $query->row();

		$inference_id = $row->inference_id;

		$sql = "select reason_id from reason where claim_index=$claim_index and reason_map_id = $map_id and id=$user_id";
		$query = $this->db->query($sql);
		$result = $query->result();

		$sql = "select claim_id from claim where claim_index=$claim_index and id=$user_id and claim_map_id=$map_id";
		$query = $this->db->query($sql);
		$row = $query->row();

		$claim_id = $row->claim_id;

		foreach($result as $value){
			$sql = "insert into inferencedescriptor (claim_id,reason_id,inference_id) values ($claim_id,$value->reason_id,$inference_id)";
			$query = $this->db->query($sql);
		}
	}

	function updateInference($inference,$inference_index,$claim_index,$user_id,$map_id=1){
		$sql="update inference set inference_text=\"$inference\" where inference_index=$inference_index and claim_index=$claim_index and id=$user_id and map_id=$map_id";
		$query = $this->db->query($sql);
	}

	function updateCoordinates($x,$y,$claim_index,$user_id,$map_id=1){
		$sql = "update inference set x=$x,y=$y where inference_index=$claim_index and claim_index=$claim_index and user_id=$user_id and map_id=$map_id";
		$query = $this->db->query($sql);
	} 
}
?>
		


