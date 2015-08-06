import os
import sys
import struct

def val2pixel(val):
	b = (val & 0x1f) * 8;
	g = ((val >> 5) & 0x3f) * 4;
	r = ((val >> 11) & 0x1f) * 8;
	return "#%06X" % ((r << 16) + (g << 8) + b)


def putPixel(x, y, val):
	if val != 0xFFFF:
		print('<div class="pxl" style="left: '+str(y)+'px; top: '+str(239-x)+'px; background-color: '+val2pixel(val)+';"></div>')


tileOrder = [0,1,8,9,2,3,10,11,16,17,24,25,18,19,26,27,4,5,12,13,6,7,14,15,20,21,28,29,22,23,30,31,32,33,40,41,34,35,42,43,48,49,56,57,50,51,58,59,36,37,44,45,38,39,46,47,52,53,60,61,54,55,62,63]

w = 320
h = 240

def do_convert(payload, offset = 0, tiled = True):
	offset //= 2 # input in bytes, but should be in shorts
	if tiled:
		o = 0
		for y in range(0,h,8):
			for x in range(0,w,8):
				for k in range(8*8):
					if (o - offset) >= len(payload):
						sys.exit()
					elif o >= offset:
						i = tileOrder[k] % 8
						j = int((tileOrder[k]-i) / 8)
						# i = k % 8
						# j = int((k-i) / 8)
						putPixel(x+i, y+j, payload[o - offset])
					o += 1
	else:
		for i in range(len(payload)):
			x = i % 240;
			y = int((i - x) / 240);
			putPixel(x, y, payload[i])

if __name__ == '__main__':
	file = open(sys.argv[1], "rb")
	data = bytearray(file.read())
	file.seek(0, os.SEEK_END)
	len_data = file.tell()
	payload = list(struct.unpack("<%dH" % (len_data // 2), data))
	do_convert(payload)
