import sys
import os
import itertools

firmVersions=["OLD", "NEW"]
ytbVersions=["west", "jpn"]

a=[firmVersions, ytbVersions]

cnt=0
for v in (list(itertools.product(*a))):
	os.system("make clean")	
	os.system("make FIRM_VERSION="+str(v[0])+" YTB_VERSION="+str(v[1]))
print(cnt)
