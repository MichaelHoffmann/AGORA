<?php

class ArgumentSchemeModel extends Model{
	function ArgumentSchemeModel(){
		parent::Model();
		$this->load->database();
	}
	
	function getSchemes($claimStart){
		if($claimStart){
			$sql = "select name from argschemes where claimStart = true";
			$query = $this->db->query($sql);
			return $query->result_array();
		}
		else{
			$sql = "select name from argschemes";
			$query = $this->db->query($sql);
			return $query->result_array();
		}
	}
	
	function getSchemeClasses($name){
		$sql = "select class_name from argschemes where name = \"$name\"";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	function getLanguageTypes($name){
		$sql = "select arg_scheme_id from argschemes where name=\"$name\"";
		$query = $this->db->query($sql);
		$row = $query->row();
		
		$id = $row->arg_scheme_id;
		
		$sql = "select language_forms from langtypes where arg_scheme_id=$id";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	function getLanguageFunction($lang_text,$name){
		$sql = "select arg_scheme_id from argschemes where class_name=\"$name\"";
		$query = $this->db->query($sql);
		$row = $query->row();
		
		$id = $row->arg_scheme_id;
		$sql = "select function_id from langtypes where language_forms = \"$lang_text\" and arg_scheme_id=$id";
		$query = $this->db->query($sql);
		return $query->result_array();
	}

	function rollOverLanguageFunction($lang_text,$name){
		$sql = "select arg_scheme_id from argschemes where class_name=\"$name\"";
                $query = $this->db->query($sql);
                $row = $query->row();

                $id = $row->arg_scheme_id;
                $sql = "select function_id from langtypes where language_forms = \"$lang_text\" and arg_scheme_id=$id";
                $query = $this->db->query($sql);
                return $query->result_array();
	}
}

?>
