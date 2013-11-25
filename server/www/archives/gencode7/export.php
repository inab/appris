<?php
	header('Content-Type: application/force-download');
	header('Content-disposition: attachment; filename='.$_POST['filename']);
	print $_POST['exportdata'];
?>