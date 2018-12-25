	.org $8000
	.include "org.inc"
	.include "shared.inc"
	.include "macros.inc"
	.segment "bank2"

	.export LoadChrFromX

.macro copy_chr name
	.local copy_next
copy_next:
	lda name + $0, x
	sta PPU_DATA
	lda name + $100, x
	sta PPU_DATA
	lda name + $200, x
	sta PPU_DATA
	lda name + $300, x
	sta PPU_DATA
	lda name + $400, x
	sta PPU_DATA
	lda name + $500, x
	sta PPU_DATA
	lda name + $600, x
	sta PPU_DATA
	lda name + $700, x
	sta PPU_DATA
	lda name + $800, x
	sta PPU_DATA
	lda name + $900, x
	sta PPU_DATA
	lda name + $a00, x
	sta PPU_DATA
	lda name + $b00, x
	sta PPU_DATA
	lda name + $c00, x
	sta PPU_DATA
	lda name + $d00, x
	sta PPU_DATA
	lda name + $e00, x
	sta PPU_DATA
	lda name + $f00, x
	sta PPU_DATA
	inx
	bne copy_next
.endmacro

intro_tiles:
	.incbin "intro.chr"

org_tiles:
	.incbin "org.chr"

lost_tiles:
	.incbin "lost.chr"

NonMaskableInterrupt:
Start:
LoadChrFromX:
	jsr LoadChrFromXInner
	jmp ReturnBank

LoadChrFromXInner:
	lda PPU_STATUS
	lda #$00
	sta PPU_ADDRESS
	lda #$00
	sta PPU_ADDRESS

	dex
	bpl check_is_org
	ldy #1
copy_intro_background:	
	ldx #0
	copy_chr intro_tiles
	dey
	bpl copy_intro_background
	rts
check_is_org:
	bne check_is_scen
	jsr copy_original
	; todo patch it
	rts
check_is_scen:
	dex
	bne check_is_lost
	jsr copy_original
	; todo patch it
	rts
check_is_lost:
	dex
	bne unknown_chr
	jsr copy_lost
	; todo patch it?
	rts

unknown_chr:
	jmp unknown_chr

copy_lost:
	ldx #0
	copy_chr lost_tiles
	ldx #0
	copy_chr lost_tiles+$1000
	rts

copy_original:
	ldx #0
	copy_chr org_tiles
	ldx #0
	copy_chr org_tiles+$1000
	rts

control_bank


