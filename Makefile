AS = ca65
LD = ld65
AFLAGS = -W0 -U -I inc -g --create-dep "$@.dep"
OUT = build
OBJECTS = $(OUT)/intro.o \
          $(OUT)/original.o \
          $(OUT)/common.o \
          $(OUT)/scenarios.o \
          $(OUT)/scenario_data.o \
          $(OUT)/lost.o \
          $(OUT)/leveldata.o \
          $(OUT)/dummy.o \
          $(OUT)/ines.o

SCENARIOS = scen/templates/1-2g_hi.json \
			scen/templates/1-2g_lo.json \
			scen/templates/1-1_d70.json

WRAM = inc/wram.inc \
		wram/full.bin \
		lost/wram-init.bin

INCS = inc/wram.inc \
       inc/macros.inc \
       inc/org.inc \
       inc/shared.inc \
       inc/utils.inc

GEN_SCENARIOS = scen/scenario_data.asm

all: smb.nes

run: smb.nes
	wine fceux/fceux.exe smb.nes

patch.zip: patch.ips
	zip patch.zip patch.ips README.md

patch.ips: smb.nes
	python scripts/ips.py create --output patch.ips original.nes smb.nes

inc/wram.inc: wram/ram_layout.asm $(OUT)/ram_layout.map
	python scripts/genram.py $(OUT)/ram_layout.map inc/wram.inc

lost/wram-init.bin: wram/full.bin $(OUT)/ram_layout.map
	python scripts/segram.py $(OUT)/ram_layout.map wram/full.bin WRAM_LostStart WRAM_LostEnd lost/wram-init.bin

wram/full.bin $(OUT)/ram_layout.map: wram/ram_layout.asm
	$(AS) $(AFLAGS) -l $(OUT)/ram_layout.map wram/ram_layout.asm -o build/ram_layout.o
	$(LD) -C scripts/ram-link.cfg build/ram_layout.o -o wram/full.bin

$(GEN_SCENARIOS): scripts/genscenarios.py $(SCENARIOS)
	python scripts/genscenarios.py $(SCENARIOS) > $(GEN_SCENARIOS)

$(OUT)/intro.o: $(INCS) intro/intro.asm intro/faxsound.asm intro/intro.inc intro/records.asm intro/smlsound.asm intro/nt.asm intro/settings.asm
	$(AS) $(AFLAGS) -l $(OUT)/intro.map intro/intro.asm -o $@

chr/full.chr: chr/build_chr.sh
	(cd chr && sh build_chr.sh)

$(OUT)/dummy.o: $(INCS) dummy.asm
	$(AS) $(AFLAGS) -l $(OUT)/dummy.map dummy.asm -o $@

$(OUT)/original.o: $(INCS) org/original.asm
	$(AS) $(AFLAGS) -l $(OUT)/original.map org/original.asm -o $@

$(OUT)/ines.o: $(INCS) common/ines.asm
	$(AS) $(AFLAGS) -l $(OUT)/ines.map common/ines.asm -o $@

$(OUT)/common.o: common/common.asm common/sound.asm common/sound-ll.asm common/practice.asm
	$(AS) $(AFLAGS) -l $(OUT)/common.map common/common.asm -o $@

$(OUT)/scenario_data.o: $(INCS) $(GEN_SCENARIOS) scen/scen_exports.asm
	$(AS) $(AFLAGS) -l $(OUT)/scenario_data.map $(GEN_SCENARIOS) -o $@

$(OUT)/scenarios.o: $(INCS) scen/scenarios.asm
	$(AS) $(AFLAGS) -l $(OUT)/scenarios.map scen/scenarios.asm -o $@

$(OUT)/lost.o: $(INCS) $(WRAM) lost/lost.asm
	$(AS) $(AFLAGS) -l $(OUT)/lost.map lost/lost.asm -o $@

$(OUT)/leveldata.o: lost/leveldata.asm
	$(AS) $(AFLAGS) -l $(OUT)/leveldata.map lost/leveldata.asm -o $@

smb.nes: $(OBJECTS) chr/full.chr
	$(LD) -C scripts/link.cfg \
		$(OUT)/ines.o \
		$(OUT)/intro.o \
		$(OUT)/dummy.o \
		$(OUT)/original.o \
		$(OUT)/common.o \
		$(OUT)/scenarios.o \
		$(OUT)/scenario_data.o \
		$(OUT)/lost.o \
		$(OUT)/leveldata.o \
		--dbgfile "smb.dbg" \
		-o smb.tmp
	cat smb.tmp chr/full.chr > smb.nes


.PHONY: clean

clean:
	rm -f build/*

include $(wildcard build/*.dep)
