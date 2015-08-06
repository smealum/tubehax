<?php
	$cookie_name = "value";

	if(isset($_POST["version"]))
	{
		setcookie($cookie_name, $_POST["version"], time() + (86400 * 30), "/"); // 30 days
		echo("<script>window.location.assign(document.URL);</script>");
	}else{
		if(isset($_COOKIE[$cookie_name]))
		{
			// define $version array and do hax
			$v = explode(" ", $_COOKIE[$cookie_name]);
			$version = array("model" => $v[0], "cup_0" => $v[1], "cup_1" => $v[2], "cup_2" => $v[3], "region" => $v[4]);
			include("hax.php");
		}else{
			// otherwise, display version selector
			include("version.html");
		}

		// debug
		// foreach(array_keys($_COOKIE) as $paramName)
		// 	echo $paramName . "<br>";
	}
?>
