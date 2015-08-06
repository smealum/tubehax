import itertools

a=[["EUR", "USA", "JPN"], [9], list(range(10)), [0], ["NEW", "OLD"]]

for v in (list(itertools.product(*a))):
	firmware_version = str(v[4]) + " " + str(v[1]) + " " + str(v[2]) + " " + str(v[3]) + " " + str(v[0])
	pretty_firmware_version = str(v[4]) + " " + str(v[1]) + "." + str(v[2]) + "." + str(v[3]) + " " + str(v[0])
	print("<option value='"+firmware_version+"'>"+pretty_firmware_version+"</option>")
