.macro lsr_by n
	.repeat n, i
		lsr
	.endrep
.endmacro

.macro DoUpdateSockHash
		.local @dont_render
		lda WRAM_PracticeFlags
		and #PF_SockMode
		beq @dont_render
		lda IntervalTimerControl
		and #3
		cmp #2
		bne @dont_render
		jsr Enter_ForceUpdateSockHash
	@dont_render:
.endmacro

.macro practice_callgate
	.res $FE00 - *, $EA

	Enter_UpdateGameTimer:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp UpdateGameTimer

	Enter_SetDefaultWRAM:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp SetDefaultWRAM

	Enter_FactoryResetWRAM:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp FactoryResetWRAM

	Enter_RedrawSockTimer:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp RedrawSockTimer

	Enter_PracticeInit:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp PracticeInit

	Enter_ForceUpdateSockHash:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp ForceUpdateSockHash

	Enter_PracticeOnFrame:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp PracticeOnFrame

	Enter_PracticeTitleMenu:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp PracticeTitleMenu

	Enter_UpdateFrameRule:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp UpdateFrameRule

	Enter_WritePracticeTop:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp WritePracticeTop

	Enter_RedrawUserVars:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp RedrawUserVars

	Enter_RedrawAll:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp RedrawAll

	Enter_RedrawFrameNumbers:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp RedrawFrameNumbers

	Enter_ProcessLevelLoad:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp ProcessLevelLoad


.endmacro


.macro scenarios_callgate
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
