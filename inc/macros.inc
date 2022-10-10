.macro lsr_by n
	.repeat n, i
		lsr
	.endrep
.endmacro

.macro DoUpdateSockHash
		.local @dont_render
		lda WRAM_PracticeFlags
		and #PF_SockMode
		bne @dont_render
		lda IntervalTimerControl
		and #3
		cmp #2
		bne @dont_render
		jsr Enter_ForceUpdateSockHash
	@dont_render:
.endmacro

.macro practice_callgate
	.res $FE00 - *, $EA

	Enter_EndOfCastle:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp EndOfCastle

	Enter_RenderIntermediateTime:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp RenderIntermediateTime

	Enter_FrameToTime:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp FrameToTime

	Enter_UpdateGameTimer:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp UpdateGameTimer

	Enter_InitializeWRAM:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp InitializeWRAM

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

	Enter_RunPendingWrites:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp RunPendingWrites

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

	Enter_LoadPhysicsData:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp LoadPhysicsData

	Enter_LoadMarioPhysics:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp LoadMarioPhysics

	Enter_LL_LoadWarpzone:
		lda #BANK_LLDATA
		jsr SetBankFromA
		jmp LoadWarpzone

	Enter_LL_GetAreaDataAddrs:
		lda #BANK_LLDATA
		jsr SetBankFromA
		jmp GetAreaDataAddrs

	Enter_LL_LoadAreaPointer:
		lda #BANK_LLDATA
		jsr SetBankFromA
		jmp LoadAreaPointer

	Enter_LL_WriteHalfwayPages:
		lda #BANK_LLDATA
		jsr SetBankFromA
		jmp WriteHalfwayPages

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

MMC5_PRGMode          = $5100
MMC5_CHRMode          = $5101
MMC5_RAMProtect1      = $5102
MMC5_RAMProtect2      = $5103
MMC5_ExRamMode        = $5104
MMC5_Nametables       = $5105
MMC5_FillTile         = $5106
MMC5_CHRBank          = $5120
MMC5_PRGBank          = $5113
MMC5_VSplitMode       = $5200
MMC5_VSplitScroll     = $5201
MMC5_VSplitBank       = $5202
MMC5_SLCompare        = $5203
MMC5_SLIRQ            = $5204
MMC5_ExRamOfs         = $3C00

; todo - move these :D
BankJSRAddr           = $6990
BankJSRTargetBank     = $6991
BankJSRA              = $6992
ActiveBank            = $6993
IRQNameTableSelect    = $6994
IRQHorizontalScroll   = $6995
PendingWrites         = $6996
IRQAckFlag            = $69A7
NameTableSelect       = $69A8

;
; Lower banks
; 
.macro control_bank bank
.res $FEF0 - *, $EA

Enter_SoundEngine:
	lda #BANK_COMMON
	jsr SetBankFromA
	jmp SoundEngineExternal

ReturnBank:
	lda BANK_SELECTED
	jmp SetBankFromA

SetChrBank0FromA:
	clc
	sta MMC5_CHRBank+0
	adc #1
	sta MMC5_CHRBank+1
	adc #1
	sta MMC5_CHRBank+2
	adc #1
	sta MMC5_CHRBank+3
	rts

SetChrBanksFromAX:
	jsr SetChrBank0FromA
	txa
SetChrBank1FromA:
	clc
	sta MMC5_CHRBank+4
	adc #1
	sta MMC5_CHRBank+5
	adc #1
	sta MMC5_CHRBank+6
	adc #1
	sta MMC5_CHRBank+7
	rts

SetBankFromA:
	clc
	ora #$80			; mark as prg-rom
	sta MMC5_PRGBank+2  ; set low prg bank
	adc #2              ; advance to high bank
	sta MMC5_PRGBank+4  ; and set high prg bank
	rts

MapperReset:
	;
	; clear mapper state
	;
	sei
	ldx #$FF
	txs
	lda #%01000000         ; disable apu irq
	sta $4017
	lda #%10
	sta MMC5_RAMProtect1
	lda #%01
	sta MMC5_RAMProtect2
	lda #3
	sta MMC5_CHRMode       ; use 1kb chr banking
	lda #1
	sta MMC5_PRGMode       ; use 16kb prg banking
	lsr a
	sta MMC5_PRGBank       ; use bank 0 for prg-ram
	lda #%10
	sta MMC5_ExRamMode
	lda #BANK_LOADER
	sta BANK_SELECTED
	jsr SetBankFromA       ; set startup bank
	lda #$44
	sta MMC5_Nametables    ; set vertical mirroring
	jmp $8000

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

IRQ:
	sei
	php
	pha
	lda MMC5_SLIRQ
	lda #$44
	sta MMC5_Nametables           ; set vertical mirroring
	lda Mirror_PPU_CTRL_REG1
	and #%11110110                ;mask out sprite address and nametable
	ora IRQNameTableSelect
	sta Mirror_PPU_CTRL_REG1      ;update the register and its mirror
	sta PPU_CTRL_REG1
	lda IRQHorizontalScroll
	sta PPU_SCROLL_REG            ;set scroll regs for the screen under the status bar
	lda #$00
	sta PPU_SCROLL_REG
	sta IRQAckFlag                ;indicate IRQ was acknowledged
	lda #%10
	sta MMC5_ExRamMode
@Done:
	pla
	plp
	cli
	rti

	.res $FFFA - *, $ea
	;
	; Interrupt table
	;
	.word NonMaskableInterrupt
	.word MapperReset
	.word IRQ
.endmacro
