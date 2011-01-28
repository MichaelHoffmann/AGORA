<?php
class Ushapaca{
	public function acceptClaim($selectedNode){
		        //create array of data to be posted
        	$post_data['type'] = 'attribution';
        	$post_data['arg1_select'] = 'user';
        	$post_data['arg2_select'] = $selectedNode;
        	//traverse array and prepare data for posting (key1=value1)
        	foreach ( $post_data as $key => $value) {
                	$post_items[] = $key . '=' . $value;
        	}

        	//create the final string to be posted using implode()
        	$post_string = implode ('&', $post_items);

        	//create cURL connection
        	$curl_connection =
          		curl_init('http://idm.gtisc.gatech.edu/alpaca/demo/create/finish');

        	//set options
        	curl_setopt($curl_connection, CURLOPT_CONNECTTIMEOUT, 30);
        	curl_setopt($curl_connection, CURLOPT_USERAGENT,
          		"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)");
        	curl_setopt($curl_connection, CURLOPT_RETURNTRANSFER, true);
        	curl_setopt($curl_connection, CURLOPT_SSL_VERIFYPEER, false);
        	curl_setopt($curl_connection, CURLOPT_FOLLOWLOCATION, 1);

        	//set data to be posted
        	curl_setopt($curl_connection, CURLOPT_POSTFIELDS, $post_string);

       		 //perform our request
        	$result = curl_exec($curl_connection);

        	//show information regarding the request
        	$tmp = curl_getinfo($curl_connection);

        	//close the connection
        	curl_close($curl_connection);

		return $tmp;
	}

	public function acceptCategory($selectedNode,$selectedCategory){
		           //create array of data to be posted
                $post_data['type'] = 'implies';
                $post_data['arg1_select'] = $selectedNode;
                $post_data['arg2_select'] = $selectedCategory;
                //traverse array and prepare data for posting (key1=value1)
                foreach ( $post_data as $key => $value) {
                        $post_items[] = $key . '=' . $value;
                }

                //create the final string to be posted using implode()
                $post_string = implode ('&', $post_items);

                //create cURL connection
                $curl_connection =
                        curl_init('http://idm.gtisc.gatech.edu/alpaca/demo/create/finish');

                //set options
                curl_setopt($curl_connection, CURLOPT_CONNECTTIMEOUT, 30);
                curl_setopt($curl_connection, CURLOPT_USERAGENT,
                        "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)");
                curl_setopt($curl_connection, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($curl_connection, CURLOPT_SSL_VERIFYPEER, false);
                curl_setopt($curl_connection, CURLOPT_FOLLOWLOCATION, 1);

                //set data to be posted
                curl_setopt($curl_connection, CURLOPT_POSTFIELDS, $post_string);

                 //perform our request
                $result = curl_exec($curl_connection);

                //show information regarding the request
                $tmp = curl_getinfo($curl_connection);

                //close the connection
                curl_close($curl_connection);

                return $tmp;
	}

	public function addToGraph($claim){
                $post_data['claim'] = $claim;
                $post_data['graph_select'] = 'ushahidinew';
                //traverse array and prepare data for posting (key1=value1)
                foreach ( $post_data as $key => $value) {
                        $post_items[] = $key . '=' . $value;
                }

                //create the final string to be posted using implode()
                $post_string = implode ('&', $post_items);

                //create cURL connection
                $curl_connection =
                        curl_init('http://idm.gtisc.gatech.edu/alpaca/demo/add');

                //set options
                curl_setopt($curl_connection, CURLOPT_CONNECTTIMEOUT, 30);
                curl_setopt($curl_connection, CURLOPT_USERAGENT,
                        "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)");
                curl_setopt($curl_connection, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($curl_connection, CURLOPT_SSL_VERIFYPEER, false);
                curl_setopt($curl_connection, CURLOPT_FOLLOWLOCATION, 1);

                //set data to be posted
                curl_setopt($curl_connection, CURLOPT_POSTFIELDS, $post_string);

                 //perform our request
                $result = curl_exec($curl_connection);

                //show information regarding the request
                $tmp = curl_getinfo($curl_connection);

                //close the connection
                curl_close($curl_connection);

                return $tmp;
	}
}
?>
