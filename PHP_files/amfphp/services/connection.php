<?php
    
   	//conection info
	define( "DATABASE_SERVER", "localhost");
	define( "DATABASE_USERNAME", "karthik");
	define( "DATABASE_PASSWORD", "Th1sIsthepassword!!");
	define( "DATABASE_NAME", "agora");

	$g_link = false;

    function get_connection()
    {
        global $g_link;
        if( $g_link )
            return $g_link;
        $g_link = mysql_pconnect(DATABASE_SERVER, DATABASE_USERNAME, DATABASE_PASSWORD) or die("Failure to connect to Database");
        mysql_select_db(DATABASE_NAME, $g_link);
        return $g_link;
    }
   
    function close_connection()
    {
        global $g_link;
        if( $g_link != false )
            mysql_close($g_link);
        $g_link = false;
    }
   
?>