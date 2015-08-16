ROPDB_VERSIONS = west jpn
ROPDB_TARGETS = $(addsuffix _ropdb.txt, $(addprefix ytb_ropdb/, $(ROPDB_VERSIONS)))
ROPDB_TARGET = ytb_ropdb/$(YTB_VERSION)_ropdb.txt

PAYLOAD_NAME = $(FIRM_VERSION)_$(YTB_VERSION)_payload.html

WEB_TARGETS = web/index.php web/hax.php web/stats.php web/frame.html web/version.html web/payloads/$(PAYLOAD_NAME) web/urls

SCRIPTS = "scripts"

.PHONY: directories all build/constants clean

all: directories build/constants web/payloads/$(PAYLOAD_NAME) $(WEB_TARGETS)
web/urls:
	@python scripts/urls2html.py urls.txt web/urls/
directories:
	@mkdir -p build
	@mkdir -p web
	@mkdir -p web/payloads
	@mkdir -p web/urls


build/constants: ytb_ropdb/ropdb.txt
	@python $(SCRIPTS)/makeHeaders.py build/constants "YTB_VERSION=$(YTB_VERSION)" "FIRM_VERSION=$(FIRM_VERSION)" $^
	@touch build/constants


web/payloads/$(PAYLOAD_NAME): build/ytb_payload.bin
	@python scripts/bin2html.py ytb_payload/ytb_payload.bin > $@
web/%.php: ytb_page/%.php
	@cp $< $@
web/%.html: ytb_page/%.html
	@cp $< $@


build/ytb_rop.bin: ytb_rop/ytb_rop.bin
	@cp ytb_rop/ytb_rop.bin build/
ytb_rop/ytb_rop.bin: ytb_rop/ytb_rop.s ytb_include/ytb_include.s build/constants
	@cd ytb_rop && armips ytb_rop.s


build/ytb_payload.bin: ytb_payload/ytb_payload.bin
	@cp ytb_payload/ytb_payload.bin build/
ytb_payload/ytb_payload.bin: ytb_payload/ytb_payload.s ytb_include/ytb_include.s build/constants build/ytb_rop.bin
	@cd ytb_payload && armips ytb_payload.s


ytb_ropdb: $(ROPDB_TARGETS)
ytb_ropdb/ropdb.txt: $(ROPDB_TARGET)
	@cp $(ROPDB_TARGET) ytb_ropdb/ropdb.txt
ytb_ropdb/%_ropdb.txt: ytb_ropdb/west_ropdb_proto.txt
	@echo building ropDB for ytb version $*...
	@python scripts/portRopDb.py ytb_code_west.bin ytb_code_$*.bin 0x00100000 ytb_ropdb/west_ropdb_proto.txt ytb_ropdb/$*_ropdb.txt

clean:
	@rm -rf build
	@rm -f ytb_ropdb/ropdb.txt
