	.org $8000
	.include "mario.inc"
	.include "shared.inc"
	.include "wram.inc"
	.include "macros.inc"
	.segment "bank2"

	.export LoadChrFromX

.macro copy_charset name
	lda PPU_STATUS
	lda #$10
	sta PPU_ADDRESS
	lda #$00
	sta PPU_ADDRESS
	ldx #0
@block0:
	lda name, x
	sta PPU_DATA
	inx
	bne @block0
@block1:
	lda name+$100, x
	sta PPU_DATA
	inx
	bne @block1
@block2:
	lda name+$200, x
	sta PPU_DATA
	inx
	cpx #$C0
	bne @block2
.endmacro

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

peach_tiles:
	.incbin "peach.chr"

org_tiles:
	.incbin "org.chr"

lost_tiles:
	.incbin "lost.chr"

org_charset:
	.incbin "org-charset.chr"

lost_charset:
	.incbin "lost-charset.chr"

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
	jmp set_charset
check_is_scen:
	dex
	bne check_is_lost
	jsr copy_original
	jmp set_charset
check_is_lost:
	dex
	bne unknown_chr
	jsr copy_lost
	jmp set_charset

unknown_chr:
	jmp unknown_chr


set_charset:
	lda WRAM_CharSet
	beq @done
	cmp #1
	beq @use_org
	lda BANK_SELECTED
	cmp #BANK_SMBLL
	beq @done
	; LOST -> ORG
	jsr copy_lost_charset
@use_org:
	lda BANK_SELECTED
	cmp #BANK_ORG
	beq @done
	; ORG -> LOST
	jmp copy_org_charset
@done:
	rts

copy_org_charset:
	copy_charset org_charset
	rts

copy_lost_charset:
	copy_charset lost_charset
	rts

copy_lost:
	ldx #0
	copy_chr lost_tiles
	ldx #0
	copy_chr lost_tiles+$1000
	rts

copy_original:
	lda WRAM_IsContraMode
	beq @no_contra
	jmp copy_peach
@no_contra:
	ldx #0
	copy_chr org_tiles
copy_org_back:
	ldx #0
	copy_chr org_tiles+$1000
	rts

copy_peach:
	ldx #0
	copy_chr peach_tiles
	jmp copy_org_back

control_bank


