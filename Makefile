YTB_VERSION := west
FIRM_VERSION := NEW

ROPDB_VERSIONS = west jpn
ROPDB_TARGETS = $(addsuffix _ropdb.txt, $(addprefix ytb_ropdb/, $(ROPDB_VERSIONS)))
ROPDB_TARGET = ytb_ropdb/$(YTB_VERSION)_ropdb.txt

SCRIPTS = "scripts"

.PHONY: directories all build/constants clean

all: directories build/constants
directories:
	@mkdir -p build 
	@mkdir -p p
	@mkdir -p q


build/constants: ytb_ropdb/ropdb.txt
	@python $(SCRIPTS)/makeHeaders.py build/constants "YTB_VERSION=$(YTB_VERSION)" "FIRM_VERSION=$(FIRM_VERSION)" $^


build/Data0: $(wildcard ytb_save/*.s) build/ytb_code.bin
	@cd ytb_save && make
	@cp ytb_save/Data0 $@


build/ytb_code.bin: ytb_code/ytb_code.bin
	@cp ytb_code/ytb_code.bin build/
ytb_code/ytb_code.bin: $(wildcard ytb_code/source/*)
	@cd ytb_code && make


ytb_ropdb: $(ROPDB_TARGETS)
ytb_ropdb/ropdb.txt: $(ROPDB_TARGET)
	@cp $(ROPDB_TARGET) ytb_ropdb/ropdb.txt
ytb_ropdb/%_ropdb.txt: ytb_ropdb/west_ropdb_proto.txt
	@echo building ropDB for ytb version $*...
	@python scripts/portRopDb.py ytb_code_west.bin ytb_code_$*.bin 0x00100000 ytb_ropdb/west_ropdb_proto.txt ytb_ropdb/$*_ropdb.txt

clean:
	@rm -rf build
	@cd ytb_save && make clean
	@cd ytb_code && make clean
