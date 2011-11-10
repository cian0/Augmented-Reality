<?php

if (isset($GLOBALS["HTTP_RAW_POST_DATA"]))
{
// create the target directory if it doesn't exist //	
	
// write the file to the target directory //		
	
	
	$filename = "/home/entrepph/public_html/images/".$_GET['filename'];
	$fp = fopen($filename, "wb" );
	fwrite( $fp, $GLOBALS[ 'HTTP_RAW_POST_DATA' ] );
	fclose( $fp );	
}	else{
	echo('file data not received');
}

?>