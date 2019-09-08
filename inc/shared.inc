BANK_SELECTED = $07ff

.define PF_SockMode $01 ; Todo move elsewhere...
.define PF_SaveState $02
.define PF_LoadState $04
.define PF_RestartLevel $08
.define PF_LevelEntrySaved $10

.macro PF_SetToLevelEnd_A
	lda WRAM_PracticeFlags
	and #(PF_LevelEntrySaved^$FF)
	sta WRAM_PracticeFlags
.endmacro

.macro MACRO_ThrowFrameImpl
ThrowFrame:
		lda Mirror_PPU_CTRL_REG2
		sta PPU_CTRL_REG2
		;
		; Wait for sprite 0
		;
		lda Sprite0HitDetectFlag  ;check for flag here
		beq @SkipSprite0
		ldx #0
		stx PPU_SPR_ADDR
		lda Sprite0Data
		sta PPU_SPR_DATA
		lda Sprite0Data+1
		sta PPU_SPR_DATA
		lda Sprite0Data+2
		sta PPU_SPR_DATA
		lda Sprite0Data+3
		sta PPU_SPR_DATA
@Sprite0Clr:
		lda PPU_STATUS            ;wait for sprite 0 flag to clear, which will
		and #%01000000            ;not happen until vblank has ended
		bne @Sprite0Clr
@Sprite0Hit:
		lda PPU_STATUS            ;do sprite #0 hit detection
		and #%01000000
		beq @Sprite0Hit
		ldy #$14                  ;small delay, to wait until we hit horizontal blank time
@HBlankDelay:
		dey
		bne @HBlankDelay
@SkipSprite0:
		lda ScreenLeft_PageLoc
		lsr Mirror_PPU_CTRL_REG1
		and #$01
		ror
		rol Mirror_PPU_CTRL_REG1
		lda Mirror_PPU_CTRL_REG1
		ora #$80 ; NMI
		sta PPU_CTRL_REG1
		lda HorizontalScroll      ;set scroll registers from variables
		sta PPU_SCROLL_REG
		lda VerticalScroll
		sta PPU_SCROLL_REG
		jmp Enter_SoundEngine
.endmacro

.macro MACRO_RunSlowMo gm
		dec WRAM_SlowMotionLeft
		bmi @allow_frame
		lda DisableScreenFlag
		bne @allow_frame
		ldx OperMode
		dex
		bne @allow_frame
		lda OperMode_Task
		cmp #gm
		bne @allow_frame
		jsr ThrowFrame
		rti
@allow_frame:
		lda WRAM_SlowMotion
		sta WRAM_SlowMotionLeft
.endmacro

TITLE_INIT		= $01

BANK_LOADER		= 0
BANK_CHR		= 2
BANK_ORG		= 4
BANK_COMMON		= 6
BANK_SCEN		= 8
BANK_SCEN_DATA	= 10
BANK_SMBLL		= 12
BANK_LLDATA		= 14

CHR_INTRO	= 0
CHR_ORG		= 1
CHR_SCEN	= 2
CHR_LOST	= 3

SavedRule = $07d9
RuleIndex = $0717 ; Previously DemoAction (can be changed to temp?)
PowerUps = $07e3 ; Previously unused?

.ifndef RESTART_LEVEL_BUTTONS
	.define RESTART_LEVEL_BUTTONS Select_Button|Up_Dir
.endif

.ifndef RESTART_GAME_BUTTONS
	.define RESTART_GAME_BUTTONS Select_Button|Down_Dir
.endif

.ifndef SAVE_STATE_BUTTONS
	.define SAVE_STATE_BUTTONS Select_Button|Right_Dir
.endif

.ifndef LOAD_STATE_BUTTONS
	.define LOAD_STATE_BUTTONS Select_Button|Left_Dir
.endif

