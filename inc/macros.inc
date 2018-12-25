.macro lsr_by n
	.repeat n, i
		lsr
	.endrep
.endmacro

.macro scenarios_shared
	.res $FE00 - *, $EA
	Enter_ScenLoadArea:
		lda #BANK_SCEN_DATA
		jsr SetBankFromA
		jmp ScenLoadArea

	Enter_ScenReset:
		lda #BANK_SCEN_DATA
		jsr SetBankFromA
		jmp ScenReset

	Enter_ScenUpdateSelected:
		lda #BANK_SCEN_DATA
		jsr SetBankFromA
		jmp ScenUpdateSelected

	Enter_ScenValidate:
		lda #BANK_SCEN_DATA
		jsr SetBankFromA
		jmp ScenValidate

.endmacro

;
; Lower banks
; 
.macro control_bank
	.res $FF00 - *, $EA

	Enter_AdvanceToRule:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp AdvanceToRule

	Enter_SoundEngine:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp SoundEngine

	Enter_LoadChrFromX:
		lda #BANK_CHR
		jsr SetBankFromA
		jmp LoadChrFromX

	ReturnBank:
		lda BANK_SELECTED
		jmp SetBankFromA

	SetBankFromA:
		sta $E000
		lsr
		sta $E000
		lsr
		sta $E000
		lsr
		sta $E000
		lsr
		sta $E000
		rts

	MapperReset:
		;
		; Clear MMC1 state
		;
		sei
		ldx #$FF
		txs
		stx $8000
		;
		; Set 32kb bank switch
		;
		lda #$02
		sta $8000
		lsr
		sta $8000
		lsr
		sta $8000
		lsr
		sta $8000
		lsr
		sta $8000
	StartBank:
		;
		; 0 Bank selected
		;
		sta BANK_SELECTED
		ldx #$00
		stx PPU_CTRL_REG1
		stx PPU_CTRL_REG2
		jsr SetBankFromA
		jmp Start

		.res $FFFA - *, $ea
		;
		; Interrupt table
		;
		.word NonMaskableInterrupt
		.word MapperReset
		.word MapperReset
.endmacro
