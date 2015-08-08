import os
import sys
import struct
import bin2html

def convert_url(url):
	url = bytes(url, "ascii")
	url += bytearray([0] * (2 - (len(url) % 2))) # pads to u16 and adds an extra null byte if necessary
	url = struct.unpack("<%dH" % (len(url) // 2), url)
	return bin2html.do_convert(url, offset = 0x600 + 0x300)

def convert_cookie(cookie):
	cookie = bytes(cookie, "ascii")
	cookie += bytearray([0] * (2 - (len(cookie) % 2))) # pads to u16 and adds an extra null byte if necessary
	cookie = struct.unpack("<%dH" % (len(cookie) // 2), cookie)
	return bin2html.do_convert(cookie, offset = 0x700 + 0x300)

path = sys.argv[2]

for url in open(sys.argv[1], "r").readlines():
	url = url.rstrip()
	out = convert_url("http://m.youtube.com/otherapp/" + url + ".bin") + "\n"
	out += convert_cookie(".m.youtube.com	TRUE	/	FALSE	0	value	" + url)
	open(path + "/" + url + ".html", "w").write(out)
