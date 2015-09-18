<?php

	include("version.php");

	$v = explode("-", $_GET["version"]);
	$version = array("model" => $v[0], "cup_0" => $v[1], "cup_1" => $v[2], "cup_2" => $v[3], "nup" => $v[4], "region" => $v[5]);
	$version_name = getVersion($version);

	echo($version_name);
?>
