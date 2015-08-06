import os
import struct
import bin2html

def convert_url(url):
	url = bytes(url, "ascii")
	url += bytearray([0] * (2 - (len(url) % 2))) # pads to u16 and adds an extra null byte if necessary
	url = struct.unpack("<%dH" % (len(url) // 2), url)
	bin2html.do_convert(url, offset = 0x600 + 0x300)

# urls = ["http://m.youtube.com/otherapp/N3DS_U_20480_usa_9221.bin"]
urls = ["http://m.youtube.com/sec_payload.bin"]

for url in urls:
	convert_url(url)
