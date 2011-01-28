<?php

require_once("connection.php");
require_once("./org/agora/vo/Scheme.php");

class ArgScheme{
	public function ArgScheme(){
	}
	
	public function getSchemes(){
		$sql = "select name from argschemes";
		$query = mysql_query($sql,get_connection());
		$ret = array();
		while($row = mysql_fetch_object($query)){
			$tmp = new Scheme();
			$tmp->scheme_name = $row->name;
			$ret[]=$tmp;
		}
		mysql_free_result($query);
		return $ret;

	}
	
	public function getSchemeClasses($name){
		$sql = "select name,class_name from argschemes where name = \"$name\"";
		$query = mysql_query($sql,get_connection());
		$ret = array();
		while($row=mysql_fetch_object($query)){
			$tmp = new Scheme();
			$tmp->name = $row->name;
			$tmp->class_name = $row->class_name;
			$ret[] = $tmp;
		}
		mysql_free_result($query);
		return $ret;
	}
	
	public function getLanguageTypes($name){
		$sql = "select arg_scheme_id from argschemes where name=\"$name\"";
		$query = mysql_query($sql,get_connection());
		
		$row = mysql_fetch_object($query);
		
		$id = $row->arg_scheme_id;
		mysql_free_result($query);
		$sql = "select language_forms from langtypes where arg_scheme_id=$id";
		$query = mysql_query($sql,get_connection());
		$ret = array();
		while($row=mysql_fetch_object($query)){
			$tmp = new Scheme();
			$tmp->language_type = $row->language_forms;
			$ret[]=$tmp;
		}
		return $ret;
	}
	
	public function getLanguageFunction($lang_text,$name){
		$sql = "select arg_scheme_id from argschemes where name=\"Modus Ponens\"";
		$query = mysql_query($sql,get_connection());
		$row = mysql_fetch_row($query);
		
		$id = $row[0];
		
		$sql = "select language_forms,function_id from langtypes where language_forms = \"$lang_text\" and arg_scheme_id=$id";
		$query = mysql_query($sql,get_connection());
		while($row=mysql_fetch_object($query)){
			$tmp = new Scheme();
			$tmp->language_type = $row->language_forms;
			$tmp->function_name = $row->function_id;
			$ret[] = $tmp;
		}
		return $ret;
	}
}

?>