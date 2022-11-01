.include "org.inc"
.include "lost.inc"
.include "wram.inc"
.include "rng.asm"
.include "savestates.asm"

StatusAddr_SockV   = MMC5_ExRamOfs+$2061
StatusAddr_SockN   = MMC5_ExRamOfs+$206B
StatusAddr_XVal    = MMC5_ExRamOfs+$2053
StatusAddr_YVal    = MMC5_ExRamOfs+$2073
StatusAddr_Rule    = MMC5_ExRamOfs+$204B
StatusAddr_Frame   = MMC5_ExRamOfs+$206B
StatusAddr_DPad    = MMC5_ExRamOfs+$2079
StatusAddr_Remains = MMC5_ExRamOfs+$205C
StatusAddr_Time    = MMC5_ExRamOfs+$207B

RunPendingWrites:
	lda PendingWrites
	beq @DonePending
	lsr a
	bcc :+
	tax
	jsr WritePracticeTopReal
	jsr WriteSockTimer
	jsr RedrawFrameNumbersReal
	clc
	bcc @ClearPending
	txa
:	lsr a
	bcc :+
	tay
	jsr WriteSockTimer
	tya
:	lsr a
	bcc :+
	tay
	jsr RedrawFrameNumbersReal
	tya
:	lsr a
	bcc :+
	tay
	jsr RedrawGameTimer
	tya
:	lsr a
	bcc @ClearPending
	jsr DrawRemainTimer
@ClearPending:
	lda #0
	sta PendingWrites
@DonePending:
	jsr PerFrameSock
	jsr WriteJoypad
	jmp ReturnBank

WriteJoypad:
	lda JoypadBitMask
	and #%1111
	tay
	lda @DPadGfx,y
	sta StatusAddr_DPad
	lda JoypadBitMask
	asl a
	rol a
	rol a
	and #%11
	tay
	lda @BtnGfx,y
	sta StatusAddr_DPad+1
	rts
@DPadGfx:
.byte $24 ; %0000 None
.byte $30 ; %0001 R
.byte $31 ; %0010 L
.byte $24 ; %0011 L+R
.byte $32 ; %0100 D
.byte $33 ; %0101 D+R
.byte $34 ; %0110 D+L
.byte $32 ; %0111 D+L+R
.byte $35 ; %1000 U
.byte $36 ; %1001 U+R
.byte $37 ; %1010 U+L
@BtnGfx:
.byte $24 ; %00 None
.byte $38 ; %01 A
.byte $39 ; %10 B
.byte $3A ; %11 A+B

DrawRemainTimer:
	lda #'R'
	sta StatusAddr_Remains
	lda IntervalTimerControl
	cmp #10
	jsr DivByTen
	stx StatusAddr_Remains+1
	sta StatusAddr_Remains+2
	rts

WritePracticeTopReal:
	lda #$24
	ldx #$60
:	sta MMC5_ExRamOfs+$2000 - $60,x
	inx
	bne :-
	
	lda #'F'
	sta StatusAddr_Frame
	lda #'R'
	sta StatusAddr_Rule
	lda #'Y'
	sta StatusAddr_YVal
	lda #'S'
	sta StatusAddr_SockV
	lda #'T'
	sta StatusAddr_Time
	lda #'*'
	sta StatusAddr_Frame+1
	;sta StatusAddr_SockN
	lda #'X'
	sta StatusAddr_XVal
	
	lda #%10101010
	sta MMC5_ExRamOfs+$23C0
	sta MMC5_ExRamOfs+$23C1
	sta MMC5_ExRamOfs+$23C3
	sta MMC5_ExRamOfs+$23C4
	sta MMC5_ExRamOfs+$23C5
	sta MMC5_ExRamOfs+$23C6
	sta MMC5_ExRamOfs+$23C7
	lda #%11101010
	sta MMC5_ExRamOfs+$23C2
	rts

RedrawFramesRemaningInner:
        lda WRAM_PracticeFlags
        and #PF_DisablePracticeInfo
        beq @draw
		lda StarFlagTaskControl
		cmp #$04
		beq @draw ; force remainder if flagpole end
		lda OperMode
		cmp #$02
		beq @draw ; force remainder if castle end
		lda WarpZoneControl
		beq nodraw
		lda GameEngineSubroutine
		cmp #$03
		bne nodraw ; force remainder if warp zone
@draw:	StatusbarUpdate SB_Remains
nodraw:	rts

RedrawAllInner:
		jsr RedrawFramesRemaningInner
		jsr RedrawFrameNumbersInner
		rts

RedrawAll:
		jsr RedrawFramesRemaningInner
		jsr RedrawFrameNumbersInner
		jmp ReturnBank

RedrawFrameNumbersReal:
	; frame counter
	lda FrameCounter
	jsr DivByTen
	sta StatusAddr_Frame+4
	txa
	jsr DivByTen
	sta StatusAddr_Frame+3
	stx StatusAddr_Frame+2
	; rule counter
	lda CurrentRule+0
	sta StatusAddr_Rule+1
	lda CurrentRule+1
	sta StatusAddr_Rule+2
	lda CurrentRule+2
	sta StatusAddr_Rule+3
	lda CurrentRule+3
	sta StatusAddr_Rule+4
	rts

RedrawFrameNumbersInner:
	lda #%110
	ora PendingWrites
	sta PendingWrites

		lda OperMode
		beq @draw ; slighty dumb
		lda WRAM_PracticeFlags
		and #PF_DisablePracticeInfo
		bne nodraw
@draw:	ldy VRAM_Buffer1_Offset
		lda #$20
		sta VRAM_Buffer1, y
		lda #$6d
		sta VRAM_Buffer1+1, y
		lda #$03
		sta VRAM_Buffer1+2, y
		lda FrameCounter
		jsr DivByTen
		sta VRAM_Buffer1+5, y
		txa
		jsr DivByTen
		sta VRAM_Buffer1+4, y
		txa
		sta VRAM_Buffer1+3, y
		lda #0
		sta VRAM_Buffer1+6, y

		lda OperMode
		beq @rule ; force RULE if on title screen
		lda WRAM_PracticeFlags
		and #PF_SockMode
		beq @dont_draw_rule
@rule:	lda #$20
		sta VRAM_Buffer1+6, y ; Offset for RULE (if any)
		lda #$64
		sta VRAM_Buffer1+7, y
		lda #$04
		sta VRAM_Buffer1+8, y
		ldx #0
@copy_rule:
		lda CurrentRule, x
		sta VRAM_Buffer1+9, y
		iny
		inx
		cpx #4
		bne @copy_rule
		lda #0
		sta VRAM_Buffer1+9, y
		iny
		iny
		iny
@dont_draw_rule:
		tya
		clc
		adc #6
		sta VRAM_Buffer1_Offset
		ldx ObjectOffset
		rts

UpdateFrameRule:
		lda #$14
		cmp IntervalTimerControl
		bne NotEvenFrameRule
		lda #$01
		sta DigitModifier+5
		ldy #RULE_COUNT_OFFSET
		ldx #2
		jsr DigitsMathRoutineN
NotEvenFrameRule:
		jmp ReturnBank

PrintableWorldNumber:
		lda BANK_SELECTED
		cmp #BANK_ORG
		bne @get_ll_world
@org_world:
		lda WorldNumber
		jmp @to_print
@get_ll_world:
		lda IsPlayingExtendedWorlds
		beq @org_world
		lda WorldNumber
		and #3
		clc
		adc #9
@to_print:
		sec
		adc #0
		rts

GetSelectedValue:
		lda $0
		beq @get_world
		cmp #1
		beq @get_level
		cmp #2
		beq @get_pups
		bne @get_player
@get_level:
		lda LevelNumber
		sec
		adc #0
		rts
@get_pups:
		lda PowerUps
		rts
@get_player:
		lda WRAM_IsContraMode ;
		beq @not_peach
		lda #$19
		rts
@not_peach:
		lda #$16 ; M
		sec
		sbc CurrentPlayer ; M / L
		rts 
@get_world:
		jmp PrintableWorldNumber

DrawRuleNumber:
		ldx VRAM_Buffer1_Offset
		lda #$22
		sta VRAM_Buffer1, x
		lda #$Eb
		sta VRAM_Buffer1+1, x
		lda #$04
		sta VRAM_Buffer1+2, x
		ldy #0
@copy_next:
		lda ($04), y
		sta VRAM_Buffer1+3, x
		inx
		iny
		cpy #4
		bne @copy_next
		lda VRAM_Buffer1_Offset
		clc 
		adc #7
		sta VRAM_Buffer1_Offset
		rts


menu_text:
	text_block $222B, "% WORLD"
	text_block $224B, "% LEVEL"
	text_block $226B, "% P-UPS"
	text_block $228B, "% HERO"
	text_block $22f0, "RULE"
	.byte $00

draw_menu:
		jsr DrawTitleMario
		lda FrameCounter
		and #$1
		beq @redraw_extra
		ldx #0
		stx $0
		ldy VRAM_Buffer1_Offset
@more_bytes:
		lda menu_text, x
		cmp #$25 ; %
		bne @draw_menu_byte
		jsr GetSelectedValue
		inc $0
@draw_menu_byte:
		sta VRAM_Buffer1, y
		lda menu_text, x
		inx
		iny
		cmp #0
		bne @more_bytes
		dey
		sty VRAM_Buffer1_Offset
		rts
@redraw_extra:
		jsr DrawRuleNumber
		jsr DrawRuleCursor
		jsr DrawMushroomIcon
		jmp RedrawFrameNumbersInner

;-------------------------------------------------------------------------------------

RuleCursorData:
	.byte $22, $ca, $06, $24, $24, $24, $24, $24, $24, $00

DrawRuleCursor:
		lda RuleIndex
		bne @initialized
		lda #4
		sta RuleIndex
@initialized:
		ldy #9
		lda VRAM_Buffer1_Offset
		clc
		adc #9
		sta VRAM_Buffer1_Offset
		tax
WriteRuleCursor:
		lda RuleCursorData,y
		sta VRAM_Buffer1,x
		dex
		dey
		bpl WriteRuleCursor
		lda VRAM_Buffer1_Offset
		sec
		sbc #6
		adc RuleIndex
		tax
		dex
		lda #$29
		sta VRAM_Buffer1,x
		rts

MushroomIconData:
		.byte $22, $29, $87, $24, $24, $24, $24, $24, $24, $24
DrawMushroomIcon:
		ldy #$0a
		lda VRAM_Buffer1_Offset
		clc
		adc #$0a
		sta VRAM_Buffer1_Offset
		tax
IconDataRead:
		lda MushroomIconData,y
		sta VRAM_Buffer1,x
		dex
		dey
		bpl IconDataRead
		lda WRAM_MenuIndex
		cmp #4
		bmi FirstFour
		clc
		adc #2
FirstFour:
		adc VRAM_Buffer1_Offset
		tax
		lda #$ce
		sta VRAM_Buffer1+3-$0a,x
		rts

rule_input:
		ldx RuleIndex
		cmp #Left_Dir
		bne @test_right
		dex
		jmp @rule_hori
@test_right:
		cmp #Right_Dir
		bne @test_down
		inx
@rule_hori:
		cpx #1
		bpl @test_high
		ldx #4
@test_high:
		cpx #5
		bne @save_index
		ldx #1
@save_index:
		stx RuleIndex
		rts
@test_down:
		cmp #Down_Dir
		bne @test_up
		lda #$ff
		jmp @update
@test_up:
		cmp #Up_Dir
		bne rule_done
		lda #$01
@update:
		ldy RuleIndex
		dey
		clc
		adc ($04),y
		bmi @negative
		cmp #10
		bmi @save_digit
		lda #0
		jmp @save_digit
@negative:
		lda #9
@save_digit:
		sta ($04), y
rule_done:
		rts

menu_input:
		cmp #Left_Dir
		bne @check_right
		lda #$ff
		sta $0
		bne @set_mask
@check_right:
		cmp #Right_Dir
		bne rule_done
		lda #$01
		sta $0
@set_mask:
		ldx WRAM_MenuIndex
		dex
		bmi @world_selected
		bne @check_pups
		lda LevelNumber ; level
		clc
		adc $00
		and #$03
		sta LevelNumber
		rts
@world_selected:
		jmp ChangeWorldNumber
@check_pups:
		dex
		bne @hero_selected
		lda PowerUps
		clc
		adc $00
		and #$03
		sta PowerUps
@keep_peach:
		rts
@hero_selected:
		lda WRAM_IsContraMode
		bne @keep_peach
		lda CurrentPlayer
		clc
		adc $01
		and #$01
		sta CurrentPlayer
		jmp LL_UpdatePlayerChange

ChangeWorldNumber:
	ldx BANK_SELECTED          ; get selected game
	ldy WorldNumber            ; and current world number
	lda $0                     ; get input direction
	cmp #1                     ; check for going right
	bne @going_left            ; if not - skip to going left
@going_right:                  ; we are going right
	iny                        ; advance to next world
	cpx #BANK_ANNLL            ; are we playing ANN?
	bne @checked_ann_r         ; no - skip ahead
	cpy #8                     ; yes - have we selected world 9
	bne @checked_ann_r         ; no - skip ahead
	iny                        ; yep - advance past world 9 (it doesnt exist in ANN)
@checked_ann_r:                ;
	cpx #BANK_ORG              ; are we playing smb1?
	bne @check_ll_r            ; nope - we have more worlds to consider
    cpy #8                     ; yes - are we past the end of the game?
	bcc @store                 ; no - we're done, store the world
	ldy #0                     ; yes - wrap around to world 1
	beq @store                 ; and store
@check_ll_r:                   ;
	cpy #$D                    ; we are playing LL / ANN, are we past the end of the game?
	bcc @store                 ; no - we're done, store the world
	ldy #0                     ; yes - wrap around to world 1
	beq @store                 ; and store
@going_left:                   ; we are going left
	dey                        ; drop world number by 1
	cpx #BANK_ANNLL            ; are we playing ANN?
	bne @checked_ann_l         ; no - skip ahead
	cpy #8                     ; yes - have we selected world 9?
	bne @checked_ann_l         ; no - skip ahead
	dey                        ; yep - derement cpast world 9 (it doesnt exist in ANN)
@checked_ann_l:				   ;
	cpy #$FF                   ; have we wrapped around?
	bne @store                 ; no - we're done, store the world
	cpx #BANK_ORG              ; are we playing smb1?
	bne @check_ll_l            ; nope - we have more worlds to consider
	ldy #$07                   ; yes - wrap around to world 8
	bne @store                 ; and store
@check_ll_l:                   ;
    ldy #$0C                   ; we are playing LL / ANN, wrap to world D
@store:                        ;
	sty WorldNumber            ; update selected world
	rts                        ; and exit

next_task:
		ldx #4*4-1
		lda #0
		sta VRAM_Buffer1
		sta VRAM_Buffer1_Offset
@reset_next:
		sta Sprite_Data+4, x
		dex
		bpl @reset_next
		jsr WriteRulePointer
		ldy #3
@copy_rule:
		lda ($04), y
		sta SavedRule, y
		dey
		bpl @copy_rule
		inc OperMode_Task
		jmp ReturnBank

WriteRulePointer:
		lda WorldNumber
		asl ; *=2
		asl ; *=4
		asl ; *=8
		asl ; *=16
		sta $04
		lda LevelNumber
		asl ; *=2
		asl ; *=4
		clc
		adc $04
		ldx BANK_SELECTED
		cpx #BANK_ORG
		beq @is_org
		clc
		adc #<WRAM_LostRules
		sta $04
		lda #0
		adc #>WRAM_LostRules
		sta $05
		rts
@is_org:
		clc
		adc #<WRAM_OrgRules
		sta $04
		lda #0
		adc #>WRAM_OrgRules
		sta $05
		rts

toggle_second_quest:
		lda BANK_SELECTED
		cmp #BANK_SMBLL
		beq @not_org
		lda PrimaryHardMode
		eor #1
		sta PrimaryHardMode
		ldx VRAM_Buffer1_Offset
		lda #$3F
		sta VRAM_Buffer1,x
		lda #$00
		sta VRAM_Buffer1+1,x
		sta VRAM_Buffer1+4,x
		lda #$01
		sta VRAM_Buffer1+2,x
		lda #$22 ; Original color
		ldy PrimaryHardMode
		beq @set_default
		lda #$05 ; Hardmode color
@set_default:
		sta VRAM_Buffer1+3,x
		inx
		inx
		inx
		inx
		sta VRAM_Buffer1_Offset
@not_org:
		rts

nuke_timer:
		lda #0
		sta SelectTimer
		jmp ReturnBank

next_task_proxy:
		jmp next_task

PracticeTitleMenu:
		jsr WriteRulePointer
		jsr draw_menu
		lda JoypadBitMask
		ora SavedJoypadBits
		beq nuke_timer
		ldx SelectTimer
		bne @dec_timer
		ldx #32
		stx SelectTimer
		cmp #Start_Button
		beq next_task_proxy
		cmp #Select_Button
		bne @check_b
		ldx WRAM_MenuIndex
		inx
		cpx #5
		bne @save_menu_index
		ldx #0
@save_menu_index:
		stx WRAM_MenuIndex
		jmp @dec_timer
@check_b:
		cmp #B_Button
		bne @check_input
		jsr toggle_second_quest
		jmp @dec_timer
@check_input:
		ldx WRAM_MenuIndex
		cpx #4
		bne @check_menu_input
		jsr rule_input
		jmp @dec_timer
@check_menu_input:
		jsr menu_input
@dec_timer:
		ldx SelectTimer
		dex
		stx SelectTimer
		jmp ReturnBank

begin_save:
		lda BANK_SELECTED
		sta WRAM_SaveStateBank
		lda GamePauseStatus
		ora #02
		sta GamePauseStatus
		lda WRAM_PracticeFlags
		ora #PF_SaveState
		sta WRAM_PracticeFlags
		inc DisableScreenFlag
		lda WRAM_DelaySaveFrames
		sta WRAM_SaveFramesLeft
		lda #0
		sta SND_MASTERCTRL_REG
		rts

begin_load:
		lda WRAM_SaveStateBank
		cmp BANK_SELECTED
		bne @invalid_save
		lda GamePauseStatus
		ora #02
		sta GamePauseStatus
		lda WRAM_PracticeFlags
		ora #PF_LoadState
		sta WRAM_PracticeFlags
		inc DisableScreenFlag
		lda WRAM_DelaySaveFrames
		sta WRAM_SaveFramesLeft
		lda #$00
		sta SND_MASTERCTRL_REG
@invalid_save:
		rts

run_save_load:
		and #PF_SaveState
		beq @load_state
		jmp SaveState
@load_state:
		jmp LoadState

RedrawGameTimer:
	lda GameTimerDisplay
	sta StatusAddr_Time+1
	lda GameTimerDisplay+1
	sta StatusAddr_Time+2
	lda GameTimerDisplay+2
	sta StatusAddr_Time+3
	rts

PracticeOnFrame:
		jsr PracticeOnFrameInner
		jmp ReturnBank

PracticeOnFrameInner:
		lda WRAM_PracticeFlags
		and #PF_SaveState|PF_LoadState
		beq @no_queued_commands
		jmp run_save_load
@no_queued_commands:
		lda BANK_SELECTED
		cmp #BANK_ORG
		bne @lost_sound
		jsr SoundEngine
		jmp @read_keypads
@lost_sound:
		jsr LL_SoundEngine
@read_keypads:
		lda SavedJoypad1Bits
		ora JoypadBitMask
		sta LastInputBits
		jsr ReadJoypads
		lda JoypadBitMask
		ora SavedJoypadBits
		beq @pause_things
		cmp LastInputBits
		beq @pause_things
		cmp WRAM_SaveButtons
		bne @no_begin_save
		jmp begin_save
@no_begin_save:
		cmp WRAM_LoadButtons
		bne @no_begin_load
		jmp begin_load
@no_begin_load:
		cmp WRAM_RestartButtons
		bne @no_restart_level
		jmp RequestRestartLevel
@no_restart_level:
		cmp WRAM_TitleButtons
		bne @pause_things
		lda BANK_SELECTED
		jmp StartBank
@pause_things:
		lda OperMode
		cmp #VictoryModeValue
		beq @check_pause
		cmp #GameModeValue
		bne @exit
		lda OperMode_Task
		ldy BANK_SELECTED
:		cpy #BANK_SMBLL
		bne :+
        cmp #$04
		bmi @exit
		bpl @check_pause
:		cpy #BANK_ANNLL
		bne :+
        cmp #$05
		bmi @exit
		bpl @check_pause
:       cmp #$03
		bmi @exit
@check_pause:
		; TODO RENABLE
		; jsr HandleRestarts ; Wont return if it did something
		jmp PauseMenu
@exit:
		rts


PrintHexByte:
		sta $0
		lsr
		lsr
		lsr
		lsr
		jsr DoNibble
		lda $0
DoNibble:
		and #$0f
		sta VRAM_Buffer1+3,x
		inx
DontUpdateSockHash:
		rts

ToHexByte:
		pha
		lsr
		lsr
		lsr
		lsr
		tax
		pla
		and #$0f
		rts



.macro RedrawUserVarEx name, at
		lda name
		sta $00
		lda name+1
		sta $01
		lda ($00), y
		;jsr ToHexByte
		;stx MMC5_ExRamOfs+$204E+off
		;sta MMC5_ExRamOfs+$204F+off

		jsr DivByTen
		sta at+2
		txa
		jsr DivByTen
		sta at+1
		stx at
.endmacro

PerFrameSock:
		ldy #0
		lda FrameCounter
		and #1
		bne @terminate
		lda BANK_SELECTED
		cmp #BANK_ORG
		beq @is_org
		RedrawUserVarEx WRAM_LostUser0, StatusAddr_XVal+1
		RedrawUserVarEx WRAM_LostUser1, StatusAddr_YVal+1
		jmp @terminate
@is_org:
		RedrawUserVarEx WRAM_OrgUser0, StatusAddr_XVal+1
		RedrawUserVarEx WRAM_OrgUser1, StatusAddr_YVal+1
@terminate:
PerFrameSockUpdate:
		lda IntervalTimerControl
		and #3
		cmp #2
		beq @Draw
		rts
@Draw:
		@DataTemp = $4                               ; temp value used for some maths
		@DataSubX = $2                               ; sockfolder subpixel x value
		@DataX    = $3                               ; sockfolder pixel x value
		lda SprObject_X_MoveForce                    ; get subpixel x position
		sta @DataSubX                                ; and store it in our temp data
		lda Player_X_Position                        ; get x position
		sta @DataX                                   ; and store it in our temp data
		lda Player_Y_Position                        ; get y position
		eor #$FF                                     ; invert the bits, now $FF is the top of the screen
		lsr a                                        ; divide pixel position by 8
		lsr a                                        ;
		lsr a                                        ;
		bcc @sock1                                   ; if we're on the top half of tile 'tile', we will land 2.5 pixels later.
		pha                                          ; so store the current value
		clc                                          ;
		lda @DataSubX                                ; get subpixel x position
		adc #$80                                     ; and increase it by half
		sta @DataSubX                                ; and store it back
		lda @DataX                                   ; get x position
		adc #$02                                     ; and add 2 + carry value
		sta @DataX                                   ; and store it back
		pla                                          ; then restore our original value
@sock1:                                          ;
		sta @DataTemp                                ; store this in our temp value
		asl a                                        ; multiply by 4
		asl a                                        ;
		adc @DataTemp                                ; and add the temp value
		adc @DataX                                   ; then add our x position
		jsr ToHexByte
		stx StatusAddr_SockV+1
		sta StatusAddr_SockV+2
		lda @DataSubX
		jsr ToHexByte
		stx StatusAddr_SockV+3
		rts

RequestRestartLevel:
		lda #$80 ; REMOVE 0x80?
		sta GamePauseStatus
		ldx #0
		stx PauseModeFlag
		inx
		stx GamePauseTimer
		inx
		stx PauseSoundQueue
		lda WRAM_PracticeFlags
		ora #PF_RestartLevel
		sta WRAM_PracticeFlags
		ldx #$00
		stx NoteLengthTblAdder ; Less hysterical music
		stx OperMode_Task
		stx ScreenRoutineTask
		stx DisableIntermediate
		stx AltEntranceControl
		stx HalfwayPage
		inx
		stx OperMode
		lda WRAM_LevelAreaPointer
		sta AreaPointer
		lda WRAM_LevelAreaType
		sta AreaType ; Probably not needed but whatever
		inc FetchNewGameTimerFlag
		rts

RestartLevel:
		lda #$0
		sta PlayerChangeSizeFlag
		lda WRAM_LevelIntervalTimerControl
		sta IntervalTimerControl
		lda WRAM_LevelFrameCounter
		sta FrameCounter
		lda WRAM_LevelPlayerStatus
		sta PlayerStatus
		lda WRAM_LevelPlayerSize
		sta PlayerSize
		ldx #6
@copy_random:
		lda WRAM_LevelRandomData, x
		sta PseudoRandomBitReg,x
		dex
		bpl @copy_random
		ldx #3
@copy_rule:
		lda WRAM_LevelFrameRuleData, x
		sta FrameRuleData, x
		dex
		bpl @copy_rule

		lda WRAM_PracticeFlags
		and #PF_RestartLevel^$FF
		sta WRAM_PracticeFlags
		jmp ReturnBank

ProcessLevelLoad:
		lda LevelNumber
		sta WRAM_LoadedLevel
		lda WorldNumber
		sta WRAM_LoadedWorld
		jsr AdvanceToRule
		lda OperMode
		beq @done
		lda WRAM_PracticeFlags
		and #PF_RestartLevel
		bne RestartLevel
		lda WRAM_PracticeFlags
		and #PF_LevelEntrySaved
		bne @done
		lda IntervalTimerControl
		sta WRAM_LevelIntervalTimerControl
		lda FrameCounter
		sta WRAM_LevelFrameCounter
		lda PlayerStatus
		sta WRAM_LevelPlayerStatus
		lda PlayerSize
		sta WRAM_LevelPlayerSize
		lda WRAM_PracticeFlags
		ora #PF_LevelEntrySaved
		sta WRAM_PracticeFlags
		ldx #6
@save_random:
		lda PseudoRandomBitReg,x
		sta WRAM_LevelRandomData, x
		dex
		bpl @save_random

		ldx #$3
@save_rule:
		lda FrameRuleData, x
		sta WRAM_LevelFrameRuleData, x
		dex
		bpl @save_rule
@done:
		jmp ReturnBank

PracticeInit:
		lda #0
		sta WRAM_Timer
		sta WRAM_Timer+1
		sta WRAM_SlowMotion
		sta WRAM_SlowMotionLeft
		sta WRAM_MenuIndex
		;
		; Dont reset the SaveStateBank right?
		;
		; sta WRAM_SaveStateBank
		lda WRAM_PracticeFlags
		and #((PF_SaveState|PF_LoadState|PF_RestartLevel|PF_LevelEntrySaved)^$ff)
		sta WRAM_PracticeFlags
nosock:	jmp ReturnBank

WriteSockTimer:
    lda IntervalTimerControl
	sta StatusAddr_SockN
	rts

MagicByte0 = $70 ; P
MagicByte1 = $56 ; V
MagicByte2 = $35 ; 5
MagicByte3 = $35 ; 5

ValidWRAMMagic:
		lda WRAM_Magic+0
		cmp #MagicByte0
		bne @exit
		lda WRAM_Magic+1
		cmp #MagicByte1
		bne @exit
		lda WRAM_Magic+2
		cmp #MagicByte2
		bne @exit
		lda WRAM_Magic+3
		cmp #MagicByte3
@exit:
		rts

InitializeWRAM:
		jsr ValidWRAMMagic
		beq RamGoodExit
		jmp FactoryResetWRAM	
RamGoodExit:
		jmp ReturnBank

SetDefaultWRAM:
		jsr ValidWRAMMagic
		beq RamGoodExit

		lda #MagicByte0
		sta WRAM_Magic+0
		lda #MagicByte1
		sta WRAM_Magic+1
		lda #MagicByte2
		sta WRAM_Magic+2
		lda #MagicByte3
		sta WRAM_Magic+3

		lda #<Player_Rel_XPos
		sta WRAM_OrgUser0
		sta WRAM_LostUser0
		lda #>Player_Rel_XPos
		sta WRAM_OrgUser0+1
		sta WRAM_LostUser0+1
		lda #<SprObject_X_MoveForce
		sta WRAM_OrgUser1
		sta WRAM_LostUser1
		lda #>SprObject_X_MoveForce
		sta WRAM_OrgUser1+1
		sta WRAM_LostUser1+1

		lda #30
		sta WRAM_DelaySaveFrames
		lda #8
		sta WRAM_DelayUserFrames

		lda #RESTART_LEVEL_BUTTONS
		sta WRAM_RestartButtons
		lda #RESTART_GAME_BUTTONS
		sta WRAM_TitleButtons
		lda #SAVE_STATE_BUTTONS
		sta WRAM_SaveButtons
		lda #LOAD_STATE_BUTTONS
		sta WRAM_LoadButtons
		;
		; TODO : Sane init values
		;
		jmp ReturnBank

FactoryResetWRAM:
		ldx #$60
@copy_page:
		stx $01
		lda #$00
		sta $00
		ldy #$00
@copy_byte:
		sta ($00), Y
		iny
		bne @copy_byte
		inx
		bpl @copy_page
		jmp SetDefaultWRAM

EndLevel:
		jsr EndLevelInner
		jmp ReturnBank

EndLevelInner:
		lda WorldNumber
		asl ; *= 2
		asl ; *= 4
		asl ; *= 8
		asl ; *= 16
		sta $00
		lda LevelNumber
		asl ; *= 2
		adc $00
		tax
		lda BANK_SELECTED
		cmp #BANK_ORG
		beq @is_org
		lda WRAM_LostTimes, x
		sta $01
		lda WRAM_LostTimes+1, x
		sta $02
		jmp @checktime
@is_org:
		lda WRAM_OrgTimes, x
		sta $01
		lda WRAM_OrgTimes+1, x
		sta $02
@checktime:
		lda WRAM_Timer
		cmp $01
		bcc @new_record
		beq @checklower
		rts
@checklower:
		lda WRAM_Timer+1
		cmp $02
		bcc @new_record
		beq @new_record
		rts
@new_record:
		ldy #0
		lda WRAM_Timer
		sta ($01), y
		lda WRAM_Timer+1
		iny
		sta ($01), y
		dey
		sty WRAM_Timer
		sty WRAM_Timer+1
		rts


N = WRAM_Temp
CARRY = WRAM_Temp+7
;
; Source div32_16_16:
; http://www.6502.org/source/integers/ummodfix/ummodfix.htm
;
div32_16_16:
		sec
        lda N+2
        sbc N
        lda N+3
        sbc N+1
        bcs @oflo
        ldx #$11
@loop:
 		rol N+4
        rol N+5
                        
        dex
        beq @end

        rol N+2
        rol N+3
        lda #0
        sta CARRY
        rol CARRY

        sec
        lda N+2
        sbc N
        sta N+6
        lda N+3
        sbc N+1
        tay
        lda CARRY
        sbc #0
        bcc @loop

        lda N+6
        sta N+2
        sty N+3
        bcs @loop ; always
 @oflo:
 		lda #$FF
        sta N+2
        sta N+3
        sta N+4
        sta N+5
@end:
		rts

PROD = WRAM_Temp+$10
MULR = WRAM_Temp+$10+8
MULND = WRAM_Temp+$10+8+4

mult64_32_32:
		lda     #$00
		sta     PROD+4   ;Clear upper half of
		sta     PROD+5   ;product
		sta     PROD+6
		sta     PROD+7
		ldx     #$20     ;Set binary count to 32
SHIFT_R:
		lsr     MULR+3   ;Shift multiplyer right
		ror     MULR+2
		ror     MULR+1
		ror     MULR
		bcc     ROTATE_R ;Go rotate right if c = 0
		lda     PROD+4   ;Get upper half of product
		clc              ; and add multiplicand to
		adc     MULND    ; it
		sta     PROD+4
		lda     PROD+5
		adc     MULND+1
		sta     PROD+5
		lda     PROD+6
		adc     MULND+2
		sta     PROD+6
		lda     PROD+7
		adc     MULND+3
ROTATE_R:
		ror
		sta     PROD+7   ; right
		ror     PROD+6
		ror     PROD+5
		ror     PROD+4
		ror     PROD+3
		ror     PROD+2
		ror     PROD+1
		ror     PROD
		dex              ;Decrement bit count and
		bne     SHIFT_R  ; loop until 32 bits are
		rts

; https://forums.nesdev.com/viewtopic.php?f=2&t=11341
HexToBCD:
		sta  $01
		lsr
		adc  $01
		ror
		lsr
		lsr
		adc  $01
		ror
		adc  $01
		ror
		lsr
		and  #$3C
		sta  $02
		lsr
		adc  $02
		adc  $01
		rts

FrameToTime:
		jsr FrameToTimeInner
		jmp ReturnBank

FrameToTimeInner:
		lda #0
		sta PROD+3
		sta CARRY
		sta MULR+2
		sta MULR+3
		sta MULND+3
		stx MULR
		sty MULR+1
		lda #$a0
		sta MULND
		lda #$86
		sta MULND+1
		lda #$01
		sta MULND+2
		jsr mult64_32_32 ; x = frames * 100000

		lda PROD+0
		sta N+4
		lda PROD+1
		sta N+5
		lda PROD+2
		sta N+2
		lda PROD+3
		sta N+3
		lda #<60098
		sta N+0
		lda #>60098
		sta N+1
		jsr div32_16_16 ; x / 60098

		lda #0
		sta N+2
		sta N+3

		sta N+1
		lda #100
		sta N+0
		jsr div32_16_16 ; r = x % 100; s = x / 100

		lda N+2
		jsr HexToBCD
		sta WRAM_PrettyTimeFrac

		lda #0
		sta N+2
		sta N+3

		sta N+1
		lda #60
		sta N+0
		jsr div32_16_16 ; m = s/60 s = s%60

		lda N+2
		jsr HexToBCD
		sta WRAM_PrettyTimeSec
		lda N+4
		jsr HexToBCD
		sta WRAM_PrettyTimeMin

		rts



BCD_BITS = 19
bcdNum = WRAM_Timer
bcdResult = 2
curDigit = 7
b = 2

TimerToDecimal:
		lda #$80 >> ((BCD_BITS - 1) & 3)
		sta curDigit
		ldx #(BCD_BITS - 1) >> 2
		ldy #BCD_BITS - 5
@loop:
		; Trial subtract this bit to A:b
		sec
		lda bcdNum
		sbc bcdTableLo,y
		sta b
		lda bcdNum+1
		sbc bcdTableHi,y

		; If A:b > bcdNum then bcdNum = A:b
		bcc @trial_lower
		sta bcdNum+1
		lda b
		sta bcdNum
@trial_lower:
		; Copy bit from carry into digit and pick up 
		; end-of-digit sentinel into carry
		rol curDigit
		dey
		bcc @loop

		; Copy digit into result
		lda curDigit
		sta bcdResult,x
		lda #$10  ; Empty digit; sentinel at 4 bits
		sta curDigit
		; If there are digits left, do those
		dex
		bne @loop
		lda bcdNum
		sta bcdResult
		rts

bcdTableLo:
		.byte <10, <20, <40, <80
		.byte <100, <200, <400, <800
		.byte <1000, <2000, <4000, <8000
		.byte <10000, <20000, <40000

bcdTableHi:
		.byte >10, >20, >40, >80
		.byte >100, >200, >400, >800
		.byte >1000, >2000, >4000, >8000
		.byte >10000, >20000, >40000

DrawTimeDigit:
	pha
		lsr
		lsr
		lsr
		lsr
		sta VRAM_Buffer1, y
		iny
	pla
		and #$0F
		sta VRAM_Buffer1, y
		iny
		rts

WriteTime:
	tya
	pha
    ldx $00
    ldy $01
		jsr FrameToTimeInner
	pla
	tay
		lda WRAM_PrettyTimeMin
		and #$0F
		sta VRAM_Buffer1, y
		iny
		lda #$AF ; .
		sta VRAM_Buffer1, y
		iny

		lda WRAM_PrettyTimeSec
		jsr DrawTimeDigit
		lda #$AF ; .
		sta VRAM_Buffer1, y
		iny

		lda WRAM_PrettyTimeFrac
		jsr DrawTimeDigit
  .if 0
		lda #$29 ; x
		sta VRAM_Buffer1, y
		iny
	tya
	pha
		jsr TimerToDecimal
	pla
	tay
		ldx #4
@writeframe:
		lda bcdResult,x
		sta VRAM_Buffer1,y
		iny
		dex
		bpl @writeframe
  .endif
		rts

PersonalBestText:
YourTime:
	.byte $22, $2a, $0c
	.byte "TIME ", $fe, $ff
YourPB:
	.byte $22, $4a, $0c
	.byte "PB   ", $fe, $ff
NewRecord:
	.byte $22, $4a, $0c
	.byte "NEW RECORD! ", $ff
LoadedGame:
	.byte $22, $2a, $0c
	.byte "SAVES USED! ", $ff

PbTextOffsets:
	.byte YourTime - PersonalBestText
	.byte YourPB - PersonalBestText
    .byte NewRecord - PersonalBestText
    .byte LoadedGame - PersonalBestText

WriteTimeText:
		ldy VRAM_Buffer1_Offset
		lda PbTextOffsets, x
		tax
@copy_more:
		lda PersonalBestText, x
		sta VRAM_Buffer1, y
		cmp #$ff
		beq @done
		cmp #$fe
		bne @no_time
		txa
	pha
		jsr WriteTime
	pla
		tax
		inx
		bne @copy_more ; Always...
@no_time:
		iny
		inx
		bne @copy_more
@done:
		lda #0
		sta VRAM_Buffer1, y
		sty VRAM_Buffer1_Offset
		rts

GetPbTimeX:
		lda WRAM_LoadedWorld
		ldx BANK_SELECTED
		cpx #BANK_ORG
		beq @not_ext
		ldx IsPlayingExtendedWorlds
		beq @not_ext
		and #$03
		clc
		adc #$09
@not_ext:
	    asl
	    asl
	    asl
	    sta $00
	    lda WRAM_LoadedLevel
	    asl
	    adc $00
	    tax
	    lda BANK_SELECTED
	    cmp #BANK_ORG
	    beq @org
	    lda WRAM_LostTimes, x
	    sta $00
	    lda WRAM_LostTimes+1,x
	    sta $01
	    rts
@org:
	    lda WRAM_OrgTimes, x
	    sta $00
	    lda WRAM_OrgTimes+1, x
	    sta $01
	    rts


RenderIntermediateTime:
		jsr RenderIntermediateTimeInner
		jmp ReturnBank

RenderIntermediateTimeInner:
	    lda WRAM_PracticeFlags
	    and #PF_LevelEntrySaved
	    bne @dontshow
	    lda WRAM_Timer+1
	    beq @dontshow
	    cmp #$FF
	    bne @no_load
	    ldx #3
	    jsr WriteTimeText
	    jmp @resettimer
@no_load:
	    lda WRAM_Timer
	    sta $00
	    lda WRAM_Timer+1
	    sta $01
		ldx #0
		jsr WriteTimeText
	    jsr GetPbTimeX
	    lda $00
	    ora $01
	    bne @checkisrecord
@newrecord:
		lda #Sfx_ExtraLife
		sta Square2SoundQueue
	    lda BANK_SELECTED
	    cmp #BANK_ORG
	    beq @save_org
	    lda WRAM_Timer
	    sta WRAM_LostTimes, x
	    lda WRAM_Timer+1
	    sta WRAM_LostTimes+1, x
	    jmp @printrecord
@save_org:
	    lda WRAM_Timer
	    sta WRAM_OrgTimes, x
	    lda WRAM_Timer+1
	    sta WRAM_OrgTimes+1, x
@printrecord:
	    ldx #2
	    jsr WriteTimeText
	    jmp @resettimer
@checkisrecord:
	    lda WRAM_Timer+1
	    cmp $01
	    bmi @newrecord
	    bne @notarecord
	    lda WRAM_Timer
	    cmp $00
	    bmi @newrecord
@notarecord:
		ldx #1
		jsr WriteTimeText
@resettimer:
	    lda #0
	    sta WRAM_Timer
	    sta WRAM_Timer+1
@dontshow:
    	rts

EndOfCastle:
		lda WRAM_Timer+1
		cmp #$EE ; FUCK HACK
		beq @exit
		ldx WorldNumber
		cpx #World8
		bne @check_ext
@is_end:
		PF_SetToLevelEnd_A
		jsr RenderIntermediateTimeInner
		lda WRAM_PracticeFlags
		ora #PF_LevelEntrySaved
		sta WRAM_PracticeFlags
		lda #$EE
		sta WRAM_Timer+1
		bne @exit
@check_ext:
		lda BANK_SELECTED
		cmp #BANK_ORG
		beq @exit
		lda IsPlayingExtendedWorlds
		beq @exit
		cpx #3 ; World D
		beq @is_end
@exit:
		jmp ReturnBank

