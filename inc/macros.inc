.macro lsr_by n
	.repeat n, i
		lsr
	.endrep
.endmacro

.macro practice_callgate CurrentBankNumber
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

	Enter_PracticeInit:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp PracticeInit

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

	Enter_RedrawAll:
		lda #BANK_COMMON
		jsr SetBankFromA
		jmp RedrawAll

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

	Enter_LL_GetAreaDataAddrs:
		lda #BANK_LLDATA
		jsr SetBankFromA
		jmp LL_GetAreaDataAddrs

	Enter_LL_LoadAreaPointer:
		lda #BANK_LLDATA
		jsr SetBankFromA
		jmp LL_LoadAreaPointer

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


.macro BankJSR bank, addr
      lda #<addr
      sta BankJSRAddr
      lda #>addr
      sta BankJSRAddr+1
      lda #bank|$80
      jsr _BankJSR
.endmacro

;
; Lower banks
; 
.macro control_bank bank
.res $FEF0 - *, $EA

_BankJSR:
	clc
    sta BankJSRTargetBank
    lda #bank|$80
    pha
    lda BankJSRTargetBank
	sta MMC5_PRGBank+2
	adc #2
	sta MMC5_PRGBank+4
    jsr @CallJSR
	clc
    pla
	sta MMC5_PRGBank+2
	adc #2
	sta MMC5_PRGBank+4
    rts
@CallJSR:
    jmp (BankJSRAddr)


Enter_SoundEngine:
	ldx BANK_SELECTED
	lda #BANK_COMMON
	jsr SetBankFromA
	jmp SoundEngineExternal

ReturnBank:
	lda BANK_SELECTED
	jmp SetBankFromA

SetChrBank0FromX:
	stx MMC5_CHRBank+0
	inx
	stx MMC5_CHRBank+1
	inx
	stx MMC5_CHRBank+2
	inx
	stx MMC5_CHRBank+3
	rts

SetChrBanksFromXY:
	jsr SetChrBank0FromX
SetChrBank1FromY:
	sty OriginalCHRBank
	sty MMC5_CHRBank+4
	iny
	sty MMC5_CHRBank+5
	iny
	sty MMC5_CHRBank+6
	iny
	sty MMC5_CHRBank+7
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
	txa
	pha
	tya
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
	ldy OriginalCHRBank           ;switch back to original CHR
	sty MMC5_CHRBank+4
	iny
	sty MMC5_CHRBank+5
@Done:
	pla
	tay
	pla
	tax
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

SB_Init      = %00000001
SB_SockTimer = %00000010
SB_Frame     = %00000100
SB_GameTimer = %00001000
SB_Remains   = %00010000

.macro StatusbarUpdate value
	lda #value
	ora PendingWrites
	sta PendingWrites
.endmacro

