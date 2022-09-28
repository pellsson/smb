	.include "org.inc"
	.include "lost.inc"
	.include "wram.inc"
	.include "quickresume.inc"

;
; Practice stuff
;
QUICKRESUME

do_quick_resume:
	asl ; *= 2
	asl ; *= 4
	asl ; *= 8
	tay
	ldx #0
more_quick_resume:
	clc
	lda ($00), y
	sta PseudoRandomBitReg,x
	iny
	inx
	cpx #7
	bne more_quick_resume
	rts

prac_quick_resume:
	;
	; Get the top two digits of target rule (1234 -> 12)
	;
	lda TopScoreDisplay+2
	jsr MulByTen
	clc
	adc TopScoreDisplay+3
	ldy #0
	sty TopScoreDisplay+2 ; clear (1234 - > 34)
	sty TopScoreDisplay+3 ; clear
	cmp #$20
	bmi prac_quick_using_0
	cmp #$40
	bmi prac_quick_using_32
	cmp #$60
	bmi prac_quick_using_64
	sec
	sbc #$60
	ldx #<quick_resume_96
	stx $00
	ldx #>quick_resume_96
	stx $01
	jmp do_quick_resume

prac_quick_using_0:
	ldx #<quick_resume_0
	stx $00
	ldx #>quick_resume_0
	stx $01
	jmp do_quick_resume

prac_quick_using_32:
	sec
	sbc #$20
	ldx #<quick_resume_32
	stx $00
	ldx #>quick_resume_32
	stx $01
	jmp do_quick_resume

prac_quick_using_64:
	sec
	sbc #$40
	ldx #<quick_resume_64
	stx $00
	ldx #>quick_resume_64
	stx $01
	jmp do_quick_resume

.ifdef PAL
SMALL_FIRE_FRAMES = $10c
.else
SMALL_FIRE_FRAMES = $1b3
.endif

AdvanceToRule:
		;
		; Regardless of rule, always honor powerups
		;
		lda #0
		ldy #0
		ldx PowerUps
		beq NoPowerups
.ifdef PAL
		lda #$4D
.else
		lda #$3B
.endif
		iny
		dex
		beq BigMarioPowerup
.ifdef PAL
		lda #$8C
.else
		lda #$7A
.endif
		iny 
		dex
		beq BigMarioPowerup
		ldx #1
		ldy #2
		lda #<SMALL_FIRE_FRAMES
		;
		; Big mario
		;
BigMarioPowerup:
		stx PlayerSize
		sty PlayerStatus

NoPowerups:
    ldx #0
		stx PowerUps
		sta PowerUpFrames
		;
		; If Rule is 0, use title Rule
		; 
		lda TopScoreDisplay+2
		ora TopScoreDisplay+3
		ora TopScoreDisplay+4
		ora TopScoreDisplay+5
		bne StartAdvance
		rts
StartAdvance:
		lda IntervalTimerControl
.ifdef PAL
		cmp #0
.else
		cmp #3
.endif
DeadLock:
		bne DeadLock
		;
		; Copy to current rule
		;
		ldx #4
KeepCopyRule:
		lda TopScoreDisplay+1,x
		sta DisplayDigits+RULE_COUNT_OFFSET-4, x
		dex
		bne KeepCopyRule
		lda #0
		sta DisplayDigits+RULE_COUNT_OFFSET-5
		;
		; Advance to correct frame rule
		;
		jsr prac_quick_resume
AdvanceFurther:
		dec TopScoreDisplay+5
		bpl CheckAdvanceFurther
		dec TopScoreDisplay+4
		bmi RuleContinue
		lda #9
		sta TopScoreDisplay+5
CheckAdvanceFurther:
		lda TopScoreDisplay+4
		ora TopScoreDisplay+5
		beq RuleContinue
RunRandomAdvance:
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
.ifndef PAL
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
.endif
		jmp AdvanceFurther
RuleContinue:
		lda #0
		sta TopScoreDisplay+5
		sta TopScoreDisplay+4
		;
		; Advance to correct place within this rule
		;
.ifdef PAL
		lda #0
.else
		lda #18
.endif
		sta $02
.ifndef PAL
AdvanceWithin:
		jsr AdvanceRandom
		dec $02
		bne AdvanceWithin
		;
		; Advance powerup frames
		;
.endif
		lda PowerUpFrames
		cmp #<SMALL_FIRE_FRAMES
		bne StartFramePrecision
		ldx #0
CorrectForSmallFire:
		jsr AdvanceRandom
		dex
		bne CorrectForSmallFire
StartFramePrecision:
		lda PowerUpFrames
MorePowerUpFrames:
		beq NoPowerUpFrames
		jsr AdvanceRandom
		dec PowerUpFrames
		jmp MorePowerUpFrames
NoPowerUpFrames:
		;
		; Set the correct framecounter
		;
		ldy #$0e
.ifdef PAL
		ldx #$8D
.else
		ldx #$a2
.endif

		lda BANK_SELECTED
		cmp #BANK_ORG
		beq @is_org
		dex
		dex
		dey
		dey
@is_org:
		lda LevelNumber
		bne SaveFrameCounter
		inx
		iny
SaveFrameCounter:
		stx FrameCounter
		sty SavedEnterTimer
		;
		; On the correct framerule, continue with the game.
		;
		rts

TopText:
	text_block $2044, "RULE * FRAME"
	text_block $2051, " X   Y  TIME R "
	.byte $20, $68, $05, $24, $fe, $24, $2e, $29 ; score trailing digit and coin display
	.byte $23, $c0, $7f, $aa ; attribute table data, clears name table 0 to palette 2
	.byte $23, $c2, $01, $ea ; attribute table data, used for coin icon in status bar
	.byte $00

WritePracticeTop:
	inline_write_block TopText
	jmp ReturnBank

RedrawFramesRemaningInner:
		ldy VRAM_Buffer1_Offset
		lda #$20
		sta VRAM_Buffer1, y
		lda #$7E
		sta VRAM_Buffer1+1, y
		lda #$02
		sta VRAM_Buffer1+2, y
		lda IntervalTimerControl
		jsr DivByTen
		sta VRAM_Buffer1+4, y
		txa
		sta VRAM_Buffer1+3, y
		lda #0
		sta VRAM_Buffer1+5, y
		clc
		tya
		adc #5
		sta VRAM_Buffer1_Offset
		rts

RedrawAllInner:
		jsr RedrawFramesRemaningInner
		jsr RedrawFrameNumbersInner
		rts

RedrawAll:
		jsr RedrawFramesRemaningInner
		jsr RedrawFrameNumbersInner
		jmp ReturnBank

RedrawFrameNumbersInner:
		ldy VRAM_Buffer1_Offset
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

		lda WRAM_PracticeFlags
		and #PF_SockMode
		bne @dont_draw_rule
		lda #$20
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

RedrawFrameNumbers:
		jsr RedrawFrameNumbersInner
		jmp ReturnBank

UpdateFrameRule:
.ifdef PAL
		lda #$11
.else
		lda #$14
.endif
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
		lda WorldNumber
		clc
		adc $00
		ldx BANK_SELECTED
		cpx #BANK_ORG
		bne @world_lost
		and #$07
		jmp @save_world
@world_lost:
		cmp #$0D
		bcc @save_world
		lda $0
		cmp #1 ; going right
		beq @going_left
		lda #$0C
		bne @save_world
@going_left:
		lda #$00
@save_world:
		sta WorldNumber
		rts
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
		cmp #BANK_ORG
		bne @not_org
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
		cmp #$03
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

;
; Sockfolder works by taking:
; (YPosition / MaxYSpeed) * (MaxXSpeed)
; and adding it to the players current position
;
; that way you can see pixel mario would land on.
; (except it shows the pixel at $FF, which doesn't technically exist)
;
ForceUpdateSockHashInner:
		ldx VRAM_Buffer1_Offset
		bne DontUpdateSockHash
.ifdef PAL
		lda Player_Y_HighPos             ; check if player is vertically on screen
		beq @nosock                      ; no - skip updating sockfolder
		lda SprObject_Y_Position         ; get player y position
		cmp #$B1                         ; are we close to the ground?
		bcc @yessock                     ; no - we're in a good range to show sockfolder
		clc                              ; yes - no need to update sockfolder, we're probably dying. :(
@nosock:
		rts                              ; skip updating sockfolder
@yessock:
		tay
		cmp #$A0                         ; is the player closer to the ground than A0?
		bcc :+                           ; no - farther up, skip ahead
		lda @Lookup-$A0,y                ; yes - load the correct value from the lookup table
		clc                              ;
		bcc @Set                         ; and skip ahead to calculate the value
:		cmp #$50                         ; is the player in the middle range of the screen?
		bcc :+                           ; no - the player is high up, skip ahead
		lda @Lookup-$50,y                ; yes - load the midrange value from the lookup table
		clc                              ;
		adc #$30                         ; add offset the value based on this "groups" height
		bcc @Set                         ; and skip ahead to calculate the value
:		lda @Lookup,y                    ; we are the top of the screen! load the top range value
		adc #$60                         ; add offset the value based on this "groups" height
@Set:
		adc SprObject_X_Position         ; now we can add the players x position
		sta $2                           ; which is what we'll display in sockfolder
		lda SprObject_PageLoc            ; then add any carry value onto the page location
		adc #0                           ;
		sta $1                           ; and store that to be displayed in sockfolder as well
		lda SprObject_X_MoveForce        ; and set our moveforce in sockfolder
		sta $3
.else
		lda SprObject_X_MoveForce ; Player force
		sta $3
		lda SprObject_X_Position ; Player X
		sta $2
		lda SprObject_PageLoc ; Player page
		sta $1
		lda SprObject_Y_Position ; Player Y
		eor #$ff
		lsr
		lsr
		lsr
		bcc something_or_other
		pha
		clc
		lda #$80
		adc $3
		sta $3
		lda $2
		adc #2
		sta $2
		lda $1
		adc #0
		sta $1
		pla
something_or_other:
		sta $04
		asl
		asl
		adc $04
		adc $2
		sta $2
		lda $1
		adc #0
		sta $1
.endif
@Draw:
		lda #$20
		sta VRAM_Buffer1
		lda #$62 ;
		sta VRAM_Buffer1+1
		lda #$06 ; len
		sta VRAM_Buffer1+2
		ldx #0
		lda $1
		jsr PrintHexByte
		lda $2
		jsr PrintHexByte
		lda $3
		jsr PrintHexByte
		lda #0
		sta VRAM_Buffer1+3, x
		lda #$09
		sta VRAM_Buffer1_Offset
		rts
.ifdef PAL
@Lookup:
; this is a lookup used to calculate (Y/5)*48, which is the number of
; X pixels the player will travel based on their current height.
.byte $39,$36,$36,$36,$36,$36,$33,$33,$33,$33,$33,$30,$30,$30,$30,$30
.byte $2d,$2d,$2d,$2d,$2d,$2a,$2a,$2a,$2a,$2a,$27,$27,$27,$27,$27,$24
.byte $24,$24,$24,$24,$21,$21,$21,$21,$21,$1e,$1e,$1e,$1e,$1e,$1b,$1b
.byte $1b,$1b,$1b,$18,$18,$18,$18,$18,$15,$15,$15,$15,$15,$12,$12,$12
.byte $12,$12,$0f,$0f,$0f,$0f,$0f,$0c,$0c,$0c,$0c,$0c,$09,$09,$09,$09
.endif

ForceUpdateSockHash:
		jsr ForceUpdateSockHashInner
		jmp ReturnBank

LoadState:
		dec WRAM_SaveFramesLeft
		beq @do_loadstate
		lda GamePauseStatus
		ora #02
		sta GamePauseStatus
		rts
@do_loadstate:
		lda #$FF
		sta WRAM_Timer+1 ; Invalidate timer
		ldx #$7F
@save_wram:
		lda WRAM_SaveWRAM, x
		sta WRAM_ToSaveFile, x
		dex
		bpl @save_wram
		ldx #0
@save_level:
		lda WRAM_SaveLevel, x
		sta WRAM_LevelData, x
		inx
		bne @save_level

		lda OperMode
		cmp WRAM_SaveRAM+OperMode
		bne @restore_pal
		lda OperMode_Task
		cmp WRAM_SaveRAM+OperMode_Task
		bne @restore_pal
		lda CurrentPlayer
		cmp WRAM_SaveRAM+CurrentPlayer
		bne @restore_pal
		lda AreaType
		cmp WRAM_SaveRAM+AreaType
		beq @copy_ram
@restore_pal:
		lda PPU_STATUS
		lda #$3F
		sta PPU_ADDRESS
		lda #$00
		sta PPU_ADDRESS
		lda PPU_DATA ; Internal buffer; throw

		ldx #$0
		ldy #$20
@copy_pal:
		lda WRAM_SavePAL, x
		sta PPU_DATA
		inx
		dey
		bne @copy_pal
		ldx #0
@copy_ram:
		lda WRAM_SaveRAM, x
		sta $000, x
		lda WRAM_SaveRAM+$100, x
		sta $100, x
		lda WRAM_SaveRAM+$200, x
		sta $200, x
		lda WRAM_SaveRAM+$300, x
		sta $300, x
		lda WRAM_SaveRAM+$400, x
		sta $400, x
		lda WRAM_SaveRAM+$500, x
		sta $500, x
		lda WRAM_SaveRAM+$600, x
		sta $600, x
		lda WRAM_SaveRAM+$700, x
		sta $700, x
		inx
		bne @copy_ram
		lda PPU_STATUS
		lda #$20
		sta PPU_ADDRESS
		lda #$00
		sta PPU_ADDRESS

		ldx #0
@copy_nt:
		lda WRAM_SaveNT, x
		sta PPU_DATA
		lda WRAM_SaveNT+$100, x
		sta PPU_DATA
		lda WRAM_SaveNT+$200, x
		sta PPU_DATA
		lda WRAM_SaveNT+$300, x
		sta PPU_DATA
		lda WRAM_SaveNT+$400, x
		sta PPU_DATA
		lda WRAM_SaveNT+$500, x
		sta PPU_DATA
		lda WRAM_SaveNT+$600, x
		sta PPU_DATA
		lda WRAM_SaveNT+$700, x
		sta PPU_DATA
		inx
		bne @copy_nt

		ldx #(WRAM_LostEnd - WRAM_LostStart)-1
@copy_lost:
		lda WRAM_SaveLost, x
		sta WRAM_LostStart, x
		dex
		bpl @copy_lost
		lda GamePauseStatus
		ora #2
		sta GamePauseStatus
		lda WRAM_PracticeFlags
		and #PF_LoadState^$FF
		sta WRAM_PracticeFlags
		lda #0
		sta DisableScreenFlag
		; Controllers will be read again this frame. Reset them (very buggy otherwise ;)).
		sta SavedJoypad1Bits
		sta JoypadBitMask
		rts

SaveState:
		dec WRAM_SaveFramesLeft
		beq @do_savestate
		lda GamePauseStatus
		ora #02
		sta GamePauseStatus
		rts
@do_savestate:
		lda PPU_STATUS
		lda #$3F
		sta PPU_ADDRESS
		lda #$00
		sta PPU_ADDRESS
		lda PPU_DATA ; Internal buffer; throw

		ldx #$0
		ldy #$20
@copy_pal:
		lda PPU_DATA
		sta WRAM_SavePAL, x
		inx
		dey
		bne @copy_pal

		ldx #$7F
@save_wram:
		lda WRAM_ToSaveFile, x
		sta WRAM_SaveWRAM, x
		dex
		bpl @save_wram
		ldx #0
@save_level:
		lda WRAM_LevelData, x
		sta WRAM_SaveLevel, x
		inx
		bne @save_level
@copy_ram:
		lda $000, x
		sta WRAM_SaveRAM, x
		lda $100, x
		sta WRAM_SaveRAM+$100, x
		lda $200, x
		sta WRAM_SaveRAM+$200, x
		lda $300, x
		sta WRAM_SaveRAM+$300, x
		lda $400, x
		sta WRAM_SaveRAM+$400, x
		lda $500, x
		sta WRAM_SaveRAM+$500, x
		lda $600, x
		sta WRAM_SaveRAM+$600, x
		lda $700, x
		sta WRAM_SaveRAM+$700, x
		inx
		bne @copy_ram
		lda PPU_STATUS
		lda #$20
		sta PPU_ADDRESS
		lda #$00
		sta PPU_ADDRESS
		lda PPU_DATA ; Internal buffer; throw
		
		ldx #0
@copy_nt:
		lda PPU_DATA
		sta WRAM_SaveNT, x
		lda PPU_DATA
		sta WRAM_SaveNT+$100, x
		lda PPU_DATA
		sta WRAM_SaveNT+$200, x
		lda PPU_DATA
		sta WRAM_SaveNT+$300, x
		lda PPU_DATA
		sta WRAM_SaveNT+$400, x
		lda PPU_DATA
		sta WRAM_SaveNT+$500, x
		lda PPU_DATA
		sta WRAM_SaveNT+$600, x
		lda PPU_DATA
		sta WRAM_SaveNT+$700, x
		inx
		bne @copy_nt

		ldx #(WRAM_LostEnd - WRAM_LostStart)-1
@copy_lost:
		lda WRAM_LostStart, x
		sta WRAM_SaveLost, x
		dex
		bpl @copy_lost


		lda GamePauseStatus
		ora #2
		sta GamePauseStatus
		lda WRAM_PracticeFlags
		and #PF_SaveState^$FF
		sta WRAM_PracticeFlags
		lda #0
		sta DisableScreenFlag
		rts


.macro RedrawUserVar name, off
		lda name
		sta $00
		lda name+1
		sta $01
		lda ($00), y
		jsr DivByTen
		sta VRAM_Buffer1+off+2
		txa
		jsr DivByTen
		sta VRAM_Buffer1+off+1
		stx VRAM_Buffer1+off+0
.endmacro

noredraw_dec:
		dec WRAM_UserFramesLeft
noredraw:
		jmp ReturnBank

RedrawUserVars:
		lda WRAM_UserFramesLeft
		bne noredraw_dec
		ldy VRAM_Buffer1_Offset
		bne noredraw
		lda #$20
		sta VRAM_Buffer1
		lda #$71
		sta VRAM_Buffer1+1
		lda #$07
		sta VRAM_Buffer1+2
		lda #$24
		sta VRAM_Buffer1+6

		lda BANK_SELECTED
		cmp #BANK_ORG
		beq @is_org
		RedrawUserVar WRAM_LostUser0, 3
		RedrawUserVar WRAM_LostUser1, 7
		jmp @terminate
@is_org:
		RedrawUserVar WRAM_OrgUser0, 3
		RedrawUserVar WRAM_OrgUser1, 7
@terminate:
		sty VRAM_Buffer1+$0A
		lda WRAM_DelayUserFrames
		sta WRAM_UserFramesLeft
		jmp ReturnBank

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
		jmp ReturnBank

RedrawSockTimer:
		ldx VRAM_Buffer1_Offset
		lda #$20
		sta VRAM_Buffer1,x
		lda #$69
      	sta VRAM_Buffer1+1,x
      	lda #$01
      	sta VRAM_Buffer1+2,x
      	lda WRAM_PracticeFlags
      	and #PF_LevelEntrySaved
      	bne @already_saved
      	lda IntervalTimerControl
      	sta WRAM_EntrySockTimer
      	jmp @write_it
@already_saved:
		lda WRAM_PracticeFlags
      	and #PF_RestartLevel
      	beq @use_as_is
      	lda WRAM_EntrySockTimer
      	jmp @write_it
@use_as_is:
		lda IntervalTimerControl
@write_it:
		sta VRAM_Buffer1+3,x
		lda #0
		sta VRAM_Buffer1+4,x
		inx
		inx
		inx
		inx
		stx VRAM_Buffer1_Offset
		jmp RedrawFrameNumbers

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
.ifdef PAL
		lda #<50007
.else
		lda #<60098
.endif
		sta N+0
.ifdef PAL
		lda #>50007
.else
		lda #<60098
.endif
		sta N+1
		jsr div32_16_16 ; x / framerate

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
		jsr RedrawAllInner
		ldx #1
		jmp ReturnBank
@check_ext:
		lda BANK_SELECTED
		cmp #BANK_ORG
		beq @exit
		lda IsPlayingExtendedWorlds
		beq @exit
		cpx #3 ; World D
		beq @is_end
@exit:
		jsr RedrawAllInner
		ldx #0
		jmp ReturnBank

