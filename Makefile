AS = ca65
LD = ld65
AFLAGS = -W0 -U -I inc
OUT = build
OBJECTS = $(OUT)/intro.o \
          $(OUT)/smlsound.o \
          $(OUT)/chrloader.o \
          $(OUT)/original.o \
          $(OUT)/common.o

SCENARIOS = scen/templates/1-2g_hi.json \
			scen/templates/1-2g_lo.json \
			scen/templates/1-1_d70.json

INCS = inc/macros.inc \
       inc/org.inc \
       inc/shared.inc \
       inc/utils.inc

GEN_SCENARIOS = scen/scenario_data.asm

all: test.bin

$(GEN_SCENARIOS): scripts/genscenarios.py $(SCENARIOS)
	python scripts/genscenarios.py $(SCENARIOS) > $(GEN_SCENARIOS)

$(OUT)/intro.o: $(INCS) intro/intro.asm
	$(AS) $(AFLAGS) -l $(OUT)/intro.map intro/intro.asm -o $@

$(OUT)/smlsound.o: $(INCS) intro/smlsound.asm
	$(AS) $(AFLAGS) -l $(OUT)/smlsound.map intro/smlsound.asm -o $@

$(OUT)/scenarios.o: $(GEN_SCENARIOS)
	$(AS) $(AFLAGS) $< -o $@

$(OUT)/chrloader.o: $(INCS) chr/chrloader.asm
	$(AS) $(AFLAGS) -l $(OUT)/chrloader.map chr/chrloader.asm -o $@

$(OUT)/original.o: $(INCS) org/original.asm
	$(AS) $(AFLAGS) -l $(OUT)/original.map org/original.asm -o $@

$(OUT)/common.o: common/common.asm common/sound.asm common/practice.asm
	$(AS) $(AFLAGS) -l $(OUT)/common.map common/common.asm -o $@	

test.bin: $(OBJECTS)
	$(LD) -C scripts/link.cfg \
		$(OUT)/smlsound.o $(OUT)/intro.o \
		$(OUT)/chrloader.o \
		$(OUT)/original.o \
		$(OUT)/common.o \
		-o $@

.PHONY: clean

clean:
	rm -f build/*