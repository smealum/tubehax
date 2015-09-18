<?php
	$cookie_name = "value";

	include("version.php");

	$version = array();

	if(isset($_POST["version"]))
	{
		if(strlen($_POST["version"]) > 2)
		{
			$v = explode(" ", $_POST["version"]);
			$version = array("model" => $v[0], "cup_0" => $v[1], "cup_1" => $v[2], "cup_2" => $v[3], "region" => $v[4]);
			$version_name = getVersion($version);
			error_log ( $version_name );
		}
	}else if(isset($_COOKIE[$cookie_name])){
		$version_name = $_COOKIE[$cookie_name];
	}

	// basic validation on version
	if(isset($version_name) && !preg_match('/[^A-Za-z0-9_]/', $version_name))
	{
		$url_filename = "./urls/".$version_name.".html";
	
		// prepare version for web payload
		preg_match('/(.*)_([UEJ])_(.*)_(.*)/', $version_name, $v);
		if($v[1] == "N3DS")$version["firm"] = "NEW";
		else $version["firm"] = "OLD";
		if($v[2] == "E" || $v[2] == "U") $version["ytb"] = "west";
		else $version["ytb"] = "jpn";

		include("hax.php");
	}else{
		// otherwise, display version selector
		include("version.html");

		// debug
		// foreach(array_keys($_COOKIE) as $paramName)
		// 	echo $paramName . "<br>";
	}
?>
