.ifndef __INTRO_INC__
.define __INTRO_INC__

.macro write_nt nt
		ldx PPU_STATUS	; Read PPU status to reset the high/low latch
		ldx #$00
		stx PPU_SCROLL_REG ; No scrolling
		stx PPU_SCROLL_REG
		stx PPU_CTRL_REG2 ; No rendering
		;
		; Copycopycopycopy
		;
		lda PPU_STATUS
		lda #$20
		sta PPU_ADDRESS
		lda #$00
		sta PPU_ADDRESS
@write_nt_0:
		lda .ident(.concat(nt, "_", "0")), x
		sta PPU_DATA
		inx
		bne @write_nt_0
@write_nt_1:
		lda .ident(.concat(nt, "_", "1")), x
		sta PPU_DATA
		inx
		bne @write_nt_1
@write_nt_2:
		lda .ident(.concat(nt, "_", "2")), x
		sta PPU_DATA
		inx
		bne @write_nt_2
@write_nt_3:
		lda .ident(.concat(nt, "_", "3")), x
		sta PPU_DATA
		inx
		bne @write_nt_3
.endmacro

.endif