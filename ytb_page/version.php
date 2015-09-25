<?php
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
		if($v["cup_0"] == 9)
		{
			if ($v["cup_1"]==0 or $v["cup_1"]==1)
			{
				return "11272";
			}
			else if ($v["cup_1"]==2)
			{
				return "12288";
			}
			else if ($v["cup_1"]==3)
			{
				return "13330";
			}
			else if ($v["cup_1"]==4)
			{
				return "14336";
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
		}else if($v["cup_0"] == 10){
			if ($v["cup_1"]==0)
			{
				if ($v["region"]=="USA")
				{
					return "20480_usa";
				}
				else
				{
					return "19456";
				}
			}else if ($v["cup_1"]==1)
			{
				if ($v["region"]=="USA")
				{
					return "21504_usa";
				}
				else
				{
					return "20480";
				}
			}
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

	function getVersion($version)
	{
		return getFirmVersion($version)."_".getRegion($version)."_".getMenuVersion($version)."_".getMsetVersion($version);
	}
?>
