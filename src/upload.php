<?php

if (isset($GLOBALS["HTTP_RAW_POST_DATA"]))
{
// create the target directory if it doesn't exist //	
	$dir = ($_GET['destination']) ? $_GET['destination'] : 'images';
	if (!file_exists($dir)){ 
		mkdir($dir, 0777, true);
		echo ("file doesn't exist....");
	}
	echo ($dir);
	
// write the file to the target directory //		
	
	
	$filename = "/home/entrepph/public_html/images/".$_GET['filename'];
	$fp = fopen($filename, "wb" );
	fwrite( $fp, $GLOBALS[ 'HTTP_RAW_POST_DATA' ] );
	fclose( $fp );	
}	else{
	echo('file data not received');
}

?>