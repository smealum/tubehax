<?php
	$cookie_name = "value";

	// compute otherapp payload nme
	function getRegion($v)
	{
		if($v["region"]=="JPN")
		{
			return "J";
		}else if($v["region"]=="EUR")
		{
			return "E";
		}else if($v["region"]=="USA")
		{
			return "U";
		}
	}

	function getFirmVersion($v)
	{
		if($v["model"]=="NEW")
		{
			return "N3DS";
		}else{
			return "POST5";
		}
	}

	function getMenuVersion($v)
	{
		if ($v["cup_1"]==0 or $v["cup_1"]==1)
		{
			return "11272";
		}
		else if ($v["cup_1"]==2)
		{
			return "12288";
		}
		else if (($v["cup_1"]==3 or $v["cup_1"]==4))
		{
			return "13330";
		}
		else if ($v["cup_1"]==5)
		{
			return "15360";
		}
		else if ($v["cup_1"]==6)
		{
			return "16404";
		}
		else if ($v["cup_1"]==7)
		{
			return "17415";
		}
		else if ($v["cup_1"]==9 and $v["region"]=="USA")
		{
			return "20480_usa";
		}
		else if ($v["cup_1"]>=8)
		{
			return "19456";
		}
	}

	function getMsetVersion($v)
	{
		if($v["cup_0"] == 9 and $v["cup_1"] < 6)
		{
			return "8203";
		}
		else
		{
			return "9221";
		}
	}

	$version = array();

	if(isset($_POST["version"]))
	{
		if(strlen($_POST["version"]) > 2)
		{
			$v = explode(" ", $_POST["version"]);
			$version = array("model" => $v[0], "cup_0" => $v[1], "cup_1" => $v[2], "cup_2" => $v[3], "region" => $v[4]);
			$version_name = getFirmVersion($version)."_".getRegion($version)."_".getMenuVersion($version)."_".getMsetVersion($version);
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
