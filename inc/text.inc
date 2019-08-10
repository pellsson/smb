.ifndef __TEXT_INC_DEF__
.define __TEXT_INC_DEF__

.charmap '0', 0
.charmap '1', 1
.charmap '2', 2
.charmap '3', 3
.charmap '4', 4
.charmap '5', 5
.charmap '6', 6
.charmap '7', 7
.charmap '8', 8
.charmap '9', 9
.charmap 'A', $0A
.charmap 'B', $0B
.charmap 'C', $0C
.charmap 'D', $0D
.charmap 'E', $0E
.charmap 'F', $0F
.charmap 'G', $10
.charmap 'H', $11
.charmap 'I', $12
.charmap 'J', $13
.charmap 'K', $14
.charmap 'L', $15
.charmap 'M', $16
.charmap 'N', $17
.charmap 'O', $18
.charmap 'P', $19
.charmap 'Q', $1a
.charmap 'R', $1b
.charmap 'S', $1c
.charmap 'T', $1d
.charmap 'U', $1e
.charmap 'V', $1f
.charmap 'W', $20
.charmap 'X', $21
.charmap 'Y', $22
.charmap 'Z', $23
.charmap '-', $28
.charmap '!', $2b
.charmap '*', $29
.charmap ' ', $24
.charmap '.', $2a
.charmap ':', $28

.macro text_block at, txt
	.byte at >> 8
	.byte at & $ff
	.byte .strlen(txt)
	.byte txt
.endmacro

.macro inline_write_block name
	.local @more_bytes
	ldx #0
	ldy VRAM_Buffer1_Offset
@more_bytes:
	lda name, x
	sta VRAM_Buffer1, y
	inx
	iny
	cmp #0
	bne @more_bytes
	dey
	sty VRAM_Buffer1_Offset
.endmacro

.endif



