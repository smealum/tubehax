from datetime import datetime
import sys
import ast

def outputConstantsH(d):
	out=""
	out+=("#ifndef CONSTANTS_H")+"\n"
	out+=("#define CONSTANTS_H")+"\n"
	for k in d:
		out+=("	#define "+k+" "+str(d[k]))+"\n"
	out+=("#endif")+"\n"
	return out

def outputConstantsS(d):
	out=""
	for k in d:
		out+=(k+" equ ("+str(d[k])+")")+"\n"
	return out

def outputConstantsPY(d):
	out=""
	for k in d:
		out+=(k+" = ("+str(d[k])+")")+"\n"
	return out

if len(sys.argv)<1:
	print("use : "+sys.argv[0]+" <extensionless_output_name> <input_file1> <const=value> <input_file2> ...")
	exit()

l = {"BUILDTIME" : "\""+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"\""}

for a in sys.argv[2:]:
	if "=" in a:
		a = a.split("=")
		l[a[0]] = a[1]
	else:
		s=open(a, "r").read()
		if len(s) > 0:
			l.update(ast.literal_eval(s))

if "FIRM_VERSION" in l and l["FIRM_VERSION"] == "NEW":
	l["FIRM_SYSTEM_LINEAR_OFFSET"] = "0x07C00000"
else:
	l["FIRM_SYSTEM_LINEAR_OFFSET"] = "0x04000000"

if "YTB_VERSION" in l and l["YTB_VERSION"] == "west":
	l["YTB_VIRTUAL_TRAMPOLINE"] = "0x00bc07f8"
	l["YTB_STACK_PIVOT"] = "0x00100d84" # ldmda r4!, {r2, r3, r6, r9, ip, sp, lr, pc}
	l["YTB_STACK_PIVOT2"] = "0x00119b84" # ldm r10!, {r4, r5, r9, r12, sp, lr, pc}
else:
	# JPN
	l["YTB_VIRTUAL_TRAMPOLINE"] = "0x00bbf7f8"
	l["YTB_STACK_PIVOT"] = "0x00100d84" # ldmda r4, {r2, r3, r6, r9, ip, sp, lr, pc} (not a typo, the ! is the only difference with WEST)
	l["YTB_STACK_PIVOT2"] = "0x0010d8b4" # ldm r8!, {r8, ip, sp, lr, pc}
	
l["IRON_CODE_LINEAR_BASE"] = "(0x30000000 + FIRM_SYSTEM_LINEAR_OFFSET - 0x00200000)"

open(sys.argv[1]+".h","w").write(outputConstantsH(l))
open(sys.argv[1]+".s","w").write(outputConstantsS(l))
open(sys.argv[1]+".py","w").write(outputConstantsPY(l))
