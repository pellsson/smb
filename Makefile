AS = ca65
LD = ld65
AFLAGS = -W0 -U -I inc
OUT = build
OBJECTS = $(OUT)/intro.o \
          $(OUT)/smlsound.o \
          $(OUT)/chrloader.o \
          $(OUT)/original.o \
          $(OUT)/common.o \
          $(OUT)/scenarios.o \
          $(OUT)/scenario_data.o \
          $(OUT)/lost.o \
          $(OUT)/dummy.o

SCENARIOS = scen/templates/1-2g_hi.json \
			scen/templates/1-2g_lo.json \
			scen/templates/1-1_d70.json

WRAM = inc/wram.inc \
		wram/full.bin

INCS = inc/macros.inc \
       inc/org.inc \
       inc/shared.inc \
       inc/utils.inc

GEN_SCENARIOS = scen/scenario_data.asm

all: test.bin

inc/wram.inc: wram/ram_layout.asm $(OUT)/ram_layout.map
	python scripts/genram.py $(OUT)/ram_layout.map inc/wram.inc

lost/init.bin: wram/full.bin $(OUT)/ram_layout.map
	python scripgs/segram.py $(OUT)/ram_layout.map wram/full.bin WRAM_LostStart WRAM_LostEnd lost/wram-init.bin

wram/full.bin $(OUT)/ram_layout.map: wram/ram_layout.asm
	$(AS) $(AFLAGS) -l $(OUT)/ram_layout.map wram/ram_layout.asm -o build/ram_layout.o
	$(LD) -C scripts/ram-link.cfg build/ram_layout.o -o wram/full.bin

$(GEN_SCENARIOS): scripts/genscenarios.py $(SCENARIOS)
	python scripts/genscenarios.py $(SCENARIOS) > $(GEN_SCENARIOS)

$(OUT)/intro.o: $(INCS) intro/intro.asm
	$(AS) $(AFLAGS) -l $(OUT)/intro.map intro/intro.asm -o $@

$(OUT)/smlsound.o: $(INCS) intro/smlsound.asm
	$(AS) $(AFLAGS) -l $(OUT)/smlsound.map intro/smlsound.asm -o $@

$(OUT)/chrloader.o: $(INCS) chr/chrloader.asm
	$(AS) $(AFLAGS) -l $(OUT)/chrloader.map chr/chrloader.asm -o $@

$(OUT)/original.o: $(INCS) org/original.asm
	$(AS) $(AFLAGS) -l $(OUT)/original.map org/original.asm -o $@

$(OUT)/common.o: common/common.asm common/sound.asm common/practice.asm
	$(AS) $(AFLAGS) -l $(OUT)/common.map common/common.asm -o $@

$(OUT)/scenario_data.o: $(INCS) $(GEN_SCENARIOS) scen/scen_exports.asm
	$(AS) $(AFLAGS) -l $(OUT)/scenario_data.map $(GEN_SCENARIOS) -o $@

$(OUT)/scenarios.o: $(INCS) scen/scenarios.asm
	$(AS) $(AFLAGS) -l $(OUT)/scenarios.map scen/scenarios.asm -o $@

$(OUT)/lost.o: $(INCS) $(WRAM) lost/lost.asm
	$(AS) $(AFLAGS) -l $(OUT)/lost.map lost/lost.asm -o $@

$(OUT)/dummy.o: dummy.asm
	$(AS) $(AFLAGS) -l $(OUT)/dummy.map dummy.asm -o $@

test.bin: $(OBJECTS)
	$(LD) -C scripts/link.cfg \
		$(OUT)/smlsound.o $(OUT)/intro.o \
		$(OUT)/chrloader.o \
		$(OUT)/original.o \
		$(OUT)/common.o \
		$(OUT)/scenarios.o \
		$(OUT)/scenario_data.o \
		$(OUT)/lost.o \
		$(OUT)/dummy.o \
		-o $@

.PHONY: clean

clean:
	rm -f build/*