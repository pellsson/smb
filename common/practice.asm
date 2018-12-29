	.include "text.inc"
	.include "org.inc"
	.include "lost.inc"
	.include "wram.inc"

;
; Practice stuff
;
quick_resume_0:
	.byte $A5, $00, $00, $00, $00, $00, $00, $00 ; Base for 0
	.byte $26, $90, $DD, $FC, $47, $BF, $30, $00 ; Base for 100
	.byte $81, $98, $9B, $AA, $9D, $C8, $F3, $00 ; Base for 200
	.byte $2A, $A2, $F7, $B2, $5D, $39, $83, $00 ; Base for 300
	.byte $9F, $14, $2A, $02, $56, $52, $FE, $00 ; Base for 400
	.byte $9F, $4A, $74, $E0, $09, $C9, $DA, $00 ; Base for 500
	.byte $F2, $E9, $0C, $DE, $C7, $7A, $F4, $00 ; Base for 600
	.byte $18, $00, $30, $30, $50, $30, $90, $00 ; Base for 700
	.byte $02, $AC, $A9, $F0, $A3, $42, $04, $00 ; Base for 800
	.byte $00, $B8, $B9, $C8, $BB, $2A, $5C, $00 ; Base for 900
	.byte $BD, $A0, $DB, $9A, $2D, $19, $43, $00 ; Base for 1000
	.byte $CF, $C8, $57, $C7, $68, $E6, $37, $00 ; Base for 1100
	.byte $12, $B4, $91, $F8, $DB, $2A, $9C, $00 ; Base for 1200
	.byte $55, $DB, $70, $C6, $27, $AB, $E4, $00 ; Base for 1300
	.byte $E1, $2C, $EE, $B7, $6A, $04, $D0, $00 ; Base for 1400
	.byte $36, $9A, $F7, $C2, $2D, $A9, $F2, $00 ; Base for 1500
	.byte $7C, $10, $E8, $C9, $18, $8A, $BB, $00 ; Base for 1600
	.byte $13, $4B, $6D, $FB, $20, $D6, $97, $00 ; Base for 1700
	.byte $6A, $06, $D2, $DF, $7A, $C4, $31, $00 ; Base for 1800
	.byte $1E, $DA, $E7, $52, $9C, $39, $01, $00 ; Base for 1900
	.byte $15, $87, $AC, $A3, $FA, $BD, $48, $00 ; Base for 2000
	.byte $B3, $20, $46, $06, $8A, $87, $92, $00 ; Base for 2100
	.byte $D2, $3D, $99, $E2, $D1, $14, $B6, $00 ; Base for 2200
	.byte $51, $B7, $14, $7A, $52, $A6, $03, $00 ; Base for 2300
	.byte $93, $98, $BF, $8E, $F1, $EC, $0F, $00 ; Base for 2400
	.byte $69, $F3, $20, $C6, $87, $0A, $04, $00 ; Base for 2500
	.byte $9F, $DE, $E1, $5C, $9E, $27, $1B, $00 ; Base for 2600
	.byte $D3, $52, $F4, $51, $B9, $1A, $68, $00 ; Base for 2700
	.byte $29, $37, $65, $0B, $C1, $D6, $55, $00 ; Base for 2800
	.byte $47, $43, $CD, $4A, $D0, $45, $E5, $00 ; Base for 2900
	.byte $28, $EC, $BD, $64, $1E, $D6, $EB, $00 ; Base for 3000
	.byte $29, $49, $1B, $89, $BE, $AD, $D0, $00 ; Base for 3100
quick_resume_32:
	.byte $1D, $D1, $EA, $49, $9D, $0E, $34, $00 ; Base for 3200
	.byte $12, $D4, $F1, $58, $BA, $0B, $7F, $00 ; Base for 3300
	.byte $0C, $88, $91, $80, $A3, $A2, $E5, $00 ; Base for 3400
	.byte $90, $5F, $7F, $C1, $3E, $BC, $C1, $00 ; Base for 3500
	.byte $77, $2D, $C3, $98, $1F, $2F, $11, $00 ; Base for 3600
	.byte $EC, $BF, $66, $18, $D4, $E5, $4C, $00 ; Base for 3700
	.byte $7A, $68, $9C, $4D, $75, $EF, $04, $00 ; Base for 3800
	.byte $DC, $E7, $5E, $90, $2D, $0D, $57, $00 ; Base for 3900
	.byte $47, $07, $89, $86, $95, $98, $B3, $00 ; Base for 4000
	.byte $20, $68, $28, $F8, $A9, $58, $0A, $00 ; Base for 4100
	.byte $92, $F1, $D4, $37, $9F, $F0, $CF, $00 ; Base for 4200
	.byte $44, $E6, $6F, $A3, $7C, $3A, $C2, $00 ; Base for 4300
	.byte $5C, $12, $AA, $8F, $DA, $C5, $70, $00 ; Base for 4400
	.byte $26, $56, $1A, $B6, $83, $EE, $E9, $00 ; Base for 4500
	.byte $66, $AA, $67, $33, $FD, $9A, $61, $00 ; Base for 4600
	.byte $DF, $52, $EC, $49, $91, $02, $20, $00 ; Base for 4700
	.byte $A8, $61, $31, $F3, $90, $77, $57, $00 ; Base for 4800
	.byte $47, $1F, $91, $AE, $8D, $D0, $CB, $00 ; Base for 4900
	.byte $76, $3C, $D0, $A9, $08, $5A, $4A, $00 ; Base for 5000
	.byte $CE, $AD, $30, $6A, $0A, $DE, $CB, $00 ; Base for 5100
	.byte $94, $8B, $A2, $B5, $F0, $9B, $7A, $00 ; Base for 5200
	.byte $B8, $39, $49, $3B, $A9, $DE, $8D, $00 ; Base for 5300
	.byte $7C, $1E, $E6, $DB, $16, $A0, $8D, $00 ; Base for 5400
	.byte $8B, $12, $04, $20, $28, $68, $38, $00 ; Base for 5500
	.byte $49, $25, $B7, $FC, $93, $6A, $4C, $00 ; Base for 5600
	.byte $E5, $1A, $D0, $E5, $44, $8E, $07, $00 ; Base for 5700
	.byte $4F, $6B, $F5, $22, $C8, $8D, $1C, $00 ; Base for 5800
	.byte $D3, $8A, $2D, $39, $63, $11, $D7, $00 ; Base for 5900
	.byte $CD, $C4, $5F, $D7, $68, $C6, $17, $00 ; Base for 6000
	.byte $F9, $F8, $0B, $FB, $EC, $1B, $C3, $00 ; Base for 6100
	.byte $7B, $EF, $18, $C6, $F7, $7A, $94, $00 ; Base for 6200
	.byte $EC, $3D, $E5, $9E, $55, $69, $C3, $00 ; Base for 6300
quick_resume_64:
	.byte $95, $DE, $F5, $48, $A2, $33, $77, $00 ; Base for 6400
	.byte $92, $AF, $8A, $D5, $C0, $6B, $EB, $00 ; Base for 6500
	.byte $29, $45, $17, $9D, $B2, $89, $EC, $00 ; Base for 6600
	.byte $B6, $FB, $96, $61, $4D, $8F, $14, $00 ; Base for 6700
	.byte $3C, $FA, $83, $76, $70, $9C, $7D, $00 ; Base for 6800
	.byte $64, $BE, $77, $0B, $E5, $F2, $39, $00 ; Base for 6900
	.byte $62, $4A, $8E, $1B, $07, $31, $3F, $00 ; Base for 7000
	.byte $DA, $09, $BD, $AE, $D5, $88, $23, $00 ; Base for 7100
	.byte $9A, $63, $57, $91, $3E, $1C, $60, $00 ; Base for 7200
	.byte $31, $53, $31, $97, $F4, $DB, $32, $00 ; Base for 7300
	.byte $7A, $5A, $AE, $1B, $47, $71, $FF, $00 ; Base for 7400
	.byte $43, $3D, $BB, $C0, $B7, $36, $58, $00 ; Base for 7500
	.byte $F2, $B3, $56, $30, $9C, $FD, $C4, $00 ; Base for 7600
	.byte $13, $45, $63, $E9, $2E, $FC, $A1, $00 ; Base for 7700
	.byte $F2, $5F, $BB, $04, $72, $7A, $9E, $00 ; Base for 7800
	.byte $3D, $F9, $82, $71, $75, $97, $7C, $00 ; Base for 7900
	.byte $EE, $47, $9B, $14, $22, $0A, $4E, $00 ; Base for 8000
	.byte $E9, $CC, $1F, $87, $B8, $B7, $C6, $00 ; Base for 8100
	.byte $B2, $97, $F2, $DD, $38, $82, $F3, $00 ; Base for 8200
	.byte $4E, $4E, $D2, $4F, $EB, $74, $A2, $00 ; Base for 8300
	.byte $3B, $D7, $A0, $0F, $4F, $51, $CF, $00 ; Base for 8400
	.byte $81, $84, $87, $8E, $81, $9C, $9F, $00 ; Base for 8500
	.byte $1A, $10, $24, $04, $4C, $44, $DC, $00 ; Base for 8600
	.byte $D9, $52, $E0, $45, $85, $0E, $04, $00 ; Base for 8700
	.byte $68, $CA, $1B, $8F, $B8, $A7, $D6, $00 ; Base for 8800
	.byte $47, $31, $BF, $DC, $A3, $1A, $5C, $00 ; Base for 8900
	.byte $D9, $54, $E6, $4F, $83, $1C, $1A, $00 ; Base for 9000
	.byte $3D, $5F, $25, $9B, $D0, $E7, $46, $00 ; Base for 9100
	.byte $50, $26, $86, $CB, $C6, $51, $DD, $00 ; Base for 9200
	.byte $6D, $4F, $95, $0A, $20, $34, $74, $00 ; Base for 9300
	.byte $C4, $55, $DD, $76, $CC, $21, $B9, $00 ; Base for 9400
	.byte $06, $B4, $B9, $D0, $A3, $02, $44, $00 ; Base for 9500
quick_resume_96:
	.byte $D6, $21, $8D, $CE, $D5, $48, $E2, $00 ; Base for 9600
	.byte $E1, $C8, $0B, $9B, $8C, $BB, $A2, $00 ; Base for 9700
	.byte $D5, $EA, $41, $95, $16, $3C, $10, $00 ; Base for 9800
	.byte $54, $3C, $94, $ED, $C4, $1F, $97, $00 ; Base for 9900

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

SMALL_FIRE_FRAMES = $1b3

AdvanceToRule:
		jsr AdvanceToRuleInner
		jmp ReturnBank

AdvanceToRuleInner:
		;
		; Regardless of rule, always honor powerups
		;
		lda #0
		ldy #0
		ldx PowerUps
		beq NoPowerups
		lda #$3B
		iny
		dex
		beq BigMarioPowerup
		lda #$7A
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
		cmp #3
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
		jsr AdvanceRandom
		jsr AdvanceRandom
		jsr AdvanceRandom
		jmp AdvanceFurther
RuleContinue:
		lda #0
		sta TopScoreDisplay+5
		sta TopScoreDisplay+4
		;
		; Advance to correct place within this rule
		;
		lda #18
		sta $02
AdvanceWithin:
		jsr AdvanceRandom
		dec $02
		bne AdvanceWithin
		;
		; Advance powerup frames
		;
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
		ldx #$a2
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

;-------------------------------------------------------------------------------------

RedrawPosition:
		lda VRAM_Buffer1_Offset
		bne DontRedrawPosition
		lda Player_Rel_XPos
		jsr DivByTen
		sta DisplayDigits+POSITION_OFFSET
		txa
		jsr DivByTen
		sta DisplayDigits+POSITION_OFFSET-1
		stx DisplayDigits+POSITION_OFFSET-2
		lda #$a5
		jsr PrintStatusBarNumbers
DontRedrawPosition:
		jmp ReturnBank


StatusBarData:
		.byte $cb, $04 ; top score display on title screen
		.byte $64, $04 ; player score
		.byte $64, $06
		.byte $6d, $03 ; coin tally
		.byte $6d, $03
		.byte $7a, $03 ; game timer
		.byte $75, $03 ; POS
		.byte $7E, $02 ; RM

StatusBarOffset:
		.byte $06, $0c, $12, FRAME_NUMBER_OFFSET+1, $1e, $24
		.byte POSITION_OFFSET+1, FRAMES_REMAIN_OFFSET+1

PrintStatusBarNumbers:
		sta $00            ;store player-specific offset
		jsr OutputNumbers  ;use first nybble to print the coin display
		lda $00            ;move high nybble to low
		lsr                ;and print to score display
		lsr
		lsr
		lsr
OutputNumbers:
		clc                      ;add 1 to low nybble
		adc #$01
		and #%00001111           ;mask out high nybble
		cmp #$08
		bcs ExitOutputN
		pha                      ;save incremented value to stack for now and
		asl                      ;shift to left and use as offset
		tay
		ldx VRAM_Buffer1_Offset  ;get current buffer pointer
		lda #$20                 ;put at top of screen by default
		cpy #$00                 ;are we writing top score on title screen?
		bne SetupNums
		lda #$22                 ;if so, put further down on the screen
SetupNums:
		sta VRAM_Buffer1,x
		lda StatusBarData,y      ;write low vram address and length of thing
		sta VRAM_Buffer1+1,x     ;we're printing to the buffer
		lda StatusBarData+1,y
		sta VRAM_Buffer1+2,x
		sta $03                  ;save length byte in counter
		stx $02                  ;and buffer pointer elsewhere for now
		pla                      ;pull original incremented value from stack
		tax
		lda StatusBarOffset,x    ;load offset to value we want to write
		sec
		sbc StatusBarData+1,y    ;subtract from length byte we read before
		tay                      ;use value as offset to display digits
		ldx $02
DigitPLoop:
		lda DisplayDigits,y      ;write digits to the buffer
		sta VRAM_Buffer1+3,x    
		inx
		iny
		dec $03                  ;do this until all the digits are written
		bne DigitPLoop
		lda #$00                 ;put null terminator at end
		sta VRAM_Buffer1+3,x
		inx                      ;increment buffer pointer by 3
		inx
		inx
		stx VRAM_Buffer1_Offset  ;store it in case we want to use it again
ExitOutputN:
		rts

;-------------------------------------------------------------------------------------


TopText:
	text_block $2044, "RULE * FRAME"
	text_block $2051, "USR POS TIME RM"
	.byte $20, $68, $05, $24, $fe, $24, $2e, $29 ; score trailing digit and coin display
	.byte $23, $c0, $7f, $aa ; attribute table data, clears name table 0 to palette 2
	.byte $23, $c2, $01, $ea ; attribute table data, used for coin icon in status bar
	.byte $00

WritePracticeTop:
	inline_write_block TopText
	jmp ReturnBank

RedrawAll:
		lda IntervalTimerControl
		jsr DivByTen
		sta DisplayDigits+FRAMES_REMAIN_OFFSET
		stx DisplayDigits+FRAMES_REMAIN_OFFSET-1
		lda #$a6
		jsr PrintStatusBarNumbers
		jsr RedrawFrameNumbersInner
		jmp ReturnBank

RedrawFrameNumbersInner:
		;
		; Update frame
		; 
		lda FrameCounter
		jsr DivByTen
		sta DisplayDigits+FRAME_NUMBER_OFFSET
		txa
		jsr DivByTen
		sta DisplayDigits+FRAME_NUMBER_OFFSET-1
		stx DisplayDigits+FRAME_NUMBER_OFFSET-2
		;
		; Print it i think...
		;
		lda WRAM_PracticeFlags
		and #PF_SockMode
		beq @no_sockmode
		lda #$80
@no_sockmode:
		ora #$02
		jsr PrintStatusBarNumbers ;print status bar numbers based on nybbles, whatever they be
		ldx ObjectOffset          ;get enemy object buffer offset
		rts

RedrawFrameNumbers:
		jsr RedrawFrameNumbersInner
		jmp ReturnBank

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

DigitsMathRoutine3:
			ldx #3
DigitsMathRoutineN:
			stx $00
            ldx #$05
AddModLoop3:
            lda DigitModifier,x       ;load digit amount to increment
            clc
            adc DisplayDigits,y       ;add to current digit
            bmi BorrowOne3             ;if result is a negative number, branch to subtract
            cmp #10
            bcs CarryOne3              ;if digit greater than $09, branch to add
StoreNewD3:
            sta DisplayDigits,y       ;store as new score or game timer digit
            dey                       ;move onto next digits in score or game timer
            dex                       ;and digit amounts to increment
            cpx $00
            bpl AddModLoop3            ;loop back if we're not done yet
            lda #$00                  ;store zero here
            ldx #$06                  ;start with the last digit
EraseMLoop3:
            sta DigitModifier-1,x     ;initialize the digit amounts to increment
            dex
            bpl EraseMLoop3            ;do this until they're all reset, then leave
            rts
BorrowOne3:
            dec DigitModifier-1,x     ;decrement the previous digit, then put $09 in
            lda #$09                  ;the game timer digit we're currently on to "borrow
            bne StoreNewD3             ;the one", then do an unconditional branch back
CarryOne3:
            sec                       ;subtract ten from our digit to make it a
            sbc #10                   ;proper BCD number, then increment the digit
            inc DigitModifier-1,x     ;preceding current digit to "carry the one" properly
            jmp StoreNewD3             ;go back to just after we branched here

DigitsMathRoutine:
            ldx #$05
AddModLoop: lda DigitModifier,x       ;load digit amount to increment
            clc
            adc DisplayDigits,y       ;add to current digit
            bmi BorrowOne             ;if result is a negative number, branch to subtract
            cmp #10
            bcs CarryOne              ;if digit greater than $09, branch to add
StoreNewD:  sta DisplayDigits,y       ;store as new score or game timer digit
            dey                       ;move onto next digits in score or game timer
            dex                       ;and digit amounts to increment
            bpl AddModLoop            ;loop back if we're not done yet
            lda #$00                  ;store zero here
            ldx #$06                  ;start with the last digit
EraseMLoop: sta DigitModifier-1,x     ;initialize the digit amounts to increment
            dex
            bpl EraseMLoop            ;do this until they're all reset, then leave
            rts
BorrowOne:  dec DigitModifier-1,x     ;decrement the previous digit, then put $09 in
            lda #$09                  ;the game timer digit we're currently on to "borrow
            bne StoreNewD             ;the one", then do an unconditional branch back
CarryOne:   sec                       ;subtract ten from our digit to make it a
            sbc #10                   ;proper BCD number, then increment the digit
            inc DigitModifier-1,x     ;preceding current digit to "carry the one" properly
            jmp StoreNewD             ;go back to just after we branched here


PrintableWorldNumber:
		lda BANK_SELECTED
		cmp BANK_ORG
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
		lda #$16 ; M
		sec
		sbc CurrentPlayer ; M / L
		rts 
@get_world:
		jsr PrintableWorldNumber
		rts

DrawRuleNumber:
		ldy VRAM_Buffer1_Offset
		lda #$22
		sta VRAM_Buffer1, y
		lda #$Eb
		sta VRAM_Buffer1+1, y
		lda #$04
		sta VRAM_Buffer1+2, y
		ldx #0
@copy_next:
		lda SavedRule, x
		sta VRAM_Buffer1+3, y
		iny
		inx
		cpx #4
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
		jsr DrawTitleMario
		jsr DrawRuleCursor
		jsr DrawMushroomIcon
		jsr DrawRuleNumber
		jmp RedrawFrameNumbersInner

;-------------------------------------------------------------------------------------

RuleCursorData:
	.byte $22, $ca, $06, $24, $24, $24, $24, $24, $24, $00

DrawRuleCursor:
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
		ldx RuleIndex
		clc
		adc SavedRule-1,x
		bmi @negative
		cmp #10
		bmi @save_digit
		lda #0
		jmp @save_digit
@negative:
		lda #9
@save_digit:
		sta SavedRule-1,x
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
		and #$07
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
		rts
@hero_selected:
		lda CurrentPlayer
		clc
		adc $01
		and #$01
		sta CurrentPlayer
		rts

nuke_timer:
		lda #0
		sta SelectTimer
		jmp ReturnBank

next_task:
		ldx #4*4-1
		lda #0
		sta VRAM_Buffer1
		sta VRAM_Buffer1_Offset
@reset_next:
		sta Sprite_Data+4, x
		dex
		bpl @reset_next
		inc OperMode_Task
		jmp ReturnBank

PracticeTitleMenu:
		jsr draw_menu
		lda JoypadBitMask
		ora SavedJoypadBits
		beq nuke_timer
		ldx SelectTimer
		bne @dec_timer
		ldx #32
		stx SelectTimer
		cmp #Start_Button
		beq next_task
		cmp #Select_Button
		bne @check_input
		ldx WRAM_MenuIndex
		inx
		cpx #5
		bne @save_menu_index
		ldx #0
@save_menu_index:
		stx WRAM_MenuIndex
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

ReadJoypads: 
		lda #$01               ;reset and clear strobe of joypad ports
		sta JOYPAD_PORT
		lsr
		tax                    ;start with joypad 1's port
		sta JOYPAD_PORT
		jsr ReadPortBits
		inx                    ;increment for joypad 2's port
ReadPortBits:
		ldy #$08
PortLoop:
		pha                    ;push previous bit onto stack
		lda JOYPAD_PORT,x      ;read current bit on joypad port
		sta $00                ;check d1 and d0 of port output
		lsr                    ;this is necessary on the old
		ora $00                ;famicom systems in japan
		lsr
		pla                    ;read bits from stack
		rol                    ;rotate bit from carry flag
		dey
		bne PortLoop           ;count down bits left
		sta SavedJoypadBits,x  ;save controller status here always
		pha
		and #%00110000         ;check for select or start
		and JoypadBitMask,x    ;if neither saved state nor current state
		beq Save8Bits          ;have any of these two set, branch
		pla
		and #%11001111         ;otherwise store without select
		sta SavedJoypadBits,x  ;or start bits and leave
		rts
Save8Bits:
		pla
		sta JoypadBitMask,x
		rts

.define MENU_ROW_LENGTH 16
.define MENU_ROW_COUNT 12

pm_empty_row:
	.byte "                "
pm_no_pup_row:
	.byte $24, " P-UP  NONE ", $24, $24, $24
pm_super_pup_row:
	.byte $24, " P-UP  SUPER", $24, $24, $24
pm_fire_pup_row:
	.byte $24, " P-UP  FIRE ", $24, $24, $24
pm_small_row:
	.byte $24, " SIZE  SMALL", $24, $24, $24
pm_big_row:
	.byte $24, " SIZE  BIG  ", $24, $24, $24

pm_hero_mario_row:
	.byte $24, " HERO  MARIO", $24, $24, $24
pm_hero_luigi_row:
	.byte $24, " HERO  LUIGI", $24, $24, $24

pm_show_rule_row:
	.byte $24, " SHOW  RULE ", $24, $24, $24
pm_show_sock_row:
	.byte $24, " SHOW  SOCK ", $24, $24, $24

pm_user_row:
	.byte $24, " USR   7 F F", $24, $24, $24
pm_star_row:
	.byte $24, " GET STAR   ", $24, $24, $24
pm_save_row:
	.byte $24, " SAVE STATE ", $24, $24, $24
pm_load_row:
	.byte $24, " LOAD STATE ", $24, $24, $24
pm_restart_row:
	.byte $24, " RESTART LEV", $24, $24, $24
pm_reset_row:
	.byte $24, " EXIT TITLE ", $24, $24, $24

.macro row_dispatch ppu, data
		lda #<ppu
		sta $00
		lda #>ppu
		sta $01
		lda #<data
		sta $02
		lda #>data
		sta $03
.endmacro

pm_attr_data:
		.byte $AA, $AA, $AA, $AA

_draw_pm_row_0:
		row_dispatch $23C8, pm_attr_data
		inc $07
		jsr draw_menu_row
		row_dispatch $2080, pm_empty_row
		rts

_draw_pm_row_1:
		lda PlayerStatus
		bne @check_is_fire
		row_dispatch $20A0, pm_no_pup_row
		rts
	@check_is_fire:
		cmp #2
		beq @is_fire
		row_dispatch $20A0, pm_super_pup_row
		rts
	@is_fire:
		row_dispatch $20A0, pm_fire_pup_row
		rts

_draw_pm_row_2:
		row_dispatch $20C0, pm_big_row
		lda PlayerSize
		beq @is_big
		row_dispatch $20C0, pm_small_row
	@is_big:
		rts

_draw_pm_row_3:
		row_dispatch $20E0, pm_hero_mario_row
		lda CurrentPlayer
		beq @is_mario
		row_dispatch $20E0, pm_hero_luigi_row
	@is_mario:
		rts

_draw_pm_row_4:
		row_dispatch $23D0, pm_attr_data
		inc $07
		jsr draw_menu_row

		row_dispatch $2100, pm_show_sock_row
		lda WRAM_PracticeFlags
		and #PF_SockMode
		bne @is_sock
		row_dispatch $2100, pm_show_rule_row
	@is_sock:
		rts

_draw_pm_row_5:
		row_dispatch $2120, pm_user_row
		rts
_draw_pm_row_6:
		row_dispatch $2140, pm_empty_row
		rts
_draw_pm_row_7:
		row_dispatch $2160, pm_star_row
		rts
_draw_pm_row_8:
		row_dispatch $23D8, pm_attr_data
		inc $07
		jsr draw_menu_row
		row_dispatch $2180, pm_save_row
		rts
_draw_pm_row_9:
		row_dispatch $21A0, pm_load_row
		rts
_draw_pm_row_10:
		row_dispatch $21C0, pm_restart_row
		rts
_draw_pm_row_11:
		row_dispatch $21E0, pm_reset_row
		rts

pm_row_initializers:
		.word _draw_pm_row_0
		.word _draw_pm_row_1
		.word _draw_pm_row_2
		.word _draw_pm_row_3
		.word _draw_pm_row_4
		.word _draw_pm_row_5
		.word _draw_pm_row_6
		.word _draw_pm_row_7
		.word _draw_pm_row_8
		.word _draw_pm_row_9
		.word _draw_pm_row_10
		.word _draw_pm_row_11

prepare_draw_row:
		asl ; *=2
		tay
		lda pm_row_initializers, y
		sta $00
		lda pm_row_initializers+1, y
		sta $01
		jmp ($0000)

draw_menu_row:
		lda $00
	pha
		lda $01
		lda Mirror_PPU_CTRL_REG1
		and #3
		beq @ntbase_selected
		lda $01
		eor #$04
		sta $01
@ntbase_selected:
		lda $01
	pha
		lda HorizontalScroll
		lsr
		lsr
		lsr
		ldx $07
		beq @copy_names
		lsr
		lsr
@copy_names:
		sta $04
		clc
		lda #$20
		ldx $07
		beq @not_attr
		lda #$20/4
@not_attr:
		sec
		sbc $04
		beq @all_on_next
		ldx $07
		beq @minmax_names
		cmp #MENU_ROW_LENGTH/4
		bmi @partial
		lda #MENU_ROW_LENGTH/4
		bne @partial
@minmax_names:
		cmp #MENU_ROW_LENGTH
		bmi @partial
		lda #MENU_ROW_LENGTH
@partial:
		ldy VRAM_Buffer1_Offset
		sta $05
		sta $06
		sta VRAM_Buffer1+2, y ; Count
		lda $01
		sta VRAM_Buffer1+0, y ; High dest
		lda $04
		clc
		adc $00
		sta VRAM_Buffer1+1, y ; Low dest
		;
		; COPY 
		;
		ldx #0
		iny
		iny
		iny
@copy_more_firstpass:
		lda ($02, x)
		sta VRAM_Buffer1, y
		inc $02
		bne @no_high_inc
		inc $03
@no_high_inc:
		iny
		dec $06
		bne @copy_more_firstpass
		lda #MENU_ROW_LENGTH
		ldx $07
		beq @nametable_mode
		lsr
		lsr
@nametable_mode:
		sec
		sbc $05
		sta $06
@all_on_next:
	pla
		eor #$04
		sta $01
	pla
		sta $00
		lda $06
		beq @done
		lda $06 ; remaining to copy
		sta VRAM_Buffer1+2, y ; Count
		lda $01
		sta VRAM_Buffer1+0, y ; High dest
		lda $00
		sta VRAM_Buffer1+1, y ; Low dest
		iny
		iny
		iny
		ldx #0
@copy_more_secondpass:
		lda ($02, x)
		sta VRAM_Buffer1, y
		inc $02
		bne @no_high_inc2
		inc $03
@no_high_inc2:
		iny
		dec $06
		bne @copy_more_secondpass
@done:
		lda #0
		sta VRAM_Buffer1, y
		sty VRAM_Buffer1_Offset
		rts

playerstatus_to_savestate:
		lda PlayerStatus
		asl
		sta $0
		lda SaveStateFlags
		and #$F8
		ora PlayerSize
		ora $0
		sta SaveStateFlags
		rts

pm_toggle_powerup:
		lda PlayerStatus
		cmp #2
		bne @solve_state
		ldx #1
		stx PlayerSize
		dex
		stx PlayerStatus
		jmp RedrawMario
@solve_state:
		ldx #0
		ldy #1
		cmp #1
		bne @fire_or_big
		iny
@fire_or_big:
		stx PlayerSize
		sty PlayerStatus
		jsr RedrawMario
		jmp playerstatus_to_savestate

pm_toggle_size:
		lda PlayerSize
		eor #1
		sta PlayerSize
		jsr RedrawMario
		jmp playerstatus_to_savestate

pm_toggle_hero:
		lda CurrentPlayer
		eor #1
		sta CurrentPlayer
		; TODO - More to be done for SMBLL
		jmp RedrawMario

pm_toggle_show:
		lda WRAM_PracticeFlags
		eor #PF_SockMode
		sta WRAM_PracticeFlags
		and #PF_SockMode
		bne @SockMode
		;
		; If we change back to rule mode we must remove top sock bytes
		;
		ldx VRAM_Buffer1_Offset
		lda #$20
		sta VRAM_Buffer1,x
		lda #$62 ;
		sta VRAM_Buffer1+1,x
		lda #$02 ; len
		sta VRAM_Buffer1+2,x
		lda #$24
		sta VRAM_Buffer1+3, x
		sta VRAM_Buffer1+4, x
		lda #$00
		sta VRAM_Buffer1+5, x
		lda VRAM_Buffer1_Offset
		clc
		adc #$05
		sta VRAM_Buffer1_Offset
		jmp RedrawFrameNumbersInner
@SockMode:
		jmp ForceUpdateSockHashInner


pm_activation_slots:
		.word pm_toggle_powerup
		.word pm_toggle_size
		.word pm_toggle_hero
		.word pm_toggle_show

pause_run_activation:
		lda WRAM_MenuIndex
		asl
		tay
		lda pm_activation_slots, y
		sta $00
		lda pm_activation_slots+1, y
		sta $01
		jmp ($0000)

pause_menu_activate:
		jsr pause_run_activation
		ldx WRAM_MenuIndex
		inx
		txa
		jsr prepare_draw_row
		jmp draw_menu_row

RunPauseMenu:
		and #$F
		beq @draw_cursor
	pha
		sta $0
		lda #MENU_ROW_COUNT
		sec
		sbc $0
		jsr prepare_draw_row
		lda #0
		sta $07
		jsr draw_menu_row
	pla
		sec
		sbc #1
		asl
		sta $00
		lda GamePauseStatus
		and #$81
		ora $00
		sta GamePauseStatus
@draw_cursor:
		lda WRAM_MenuIndex
		asl
		asl
		asl
		clc
		adc #$26
		sta $2FC
		lda #$75
		sta $2FD
		lda #$00
		sta $2FE
		lda #$04
		sta $2FF

		lda SavedJoypad1Bits
		cmp LastInputBits
		bne @input_changed
		rts
@input_changed:
		cmp #Select_Button
		bne @check_down
@move_cursor_down:
		ldx WRAM_MenuIndex
		inx
		cpx #5
		bne @not_gap
		inx
@not_gap:
		cpx #$0B
		bmi @no_wrap_down
		ldx #0
@no_wrap_down:
		jmp @save_exit
@check_down:
		cmp #Down_Dir
		beq @move_cursor_down
		cmp #Up_Dir
		bne @check_a
		ldx WRAM_MenuIndex
		dex
		cpx #5
		bne @not_gap_up
		dex
@not_gap_up:
		cpx #0
		bpl @no_wrap_up
		ldx #$0A
@no_wrap_up:
		jmp @save_exit
@check_a:
		cmp #A_Button
		bne @exit
		jmp pause_menu_activate
@save_exit:
		stx WRAM_MenuIndex
@exit:
		rts

PauseMenu:
		lda GamePauseStatus
		lsr
		bcc @not_paused
		jsr RunPauseMenu
@not_paused:
		lda GamePauseTimer
		beq @pause_ready
		dec GamePauseTimer
		rts
@pause_ready:
		lda SavedJoypad1Bits
		and #Start_Button
		beq @clear_legacy
		lda GamePauseStatus
		and #$80
		bne @exit
		lda #$2b
		sta GamePauseTimer
		lda GamePauseStatus
		tay
		iny
		sty PauseSoundQueue
		eor #$01
		ora #$80
		sta GamePauseStatus
		lsr
		bcc @clear_menu
		lda #0
		sta WRAM_MenuIndex
		ldx #3
		ldy #$ff
@save_more_sprite:
		lda $200, y
		sta WRAM_Temp, x
		dey
		dex
		bpl @save_more_sprite


		lda GamePauseStatus
		ora #MENU_ROW_COUNT<<1 ; 0xB<<1
		sta GamePauseStatus
		lsr
		jmp RunPauseMenu
@clear_menu:
		rts
@clear_legacy:
		lda GamePauseStatus
		and #$7f
		sta GamePauseStatus
@exit:
		rts

PracticeOnFrame:
		jsr SoundEngineInner
		lda SavedJoypad1Bits
		sta LastInputBits
		jsr ReadJoypads

		lda OperMode
		cmp #VictoryModeValue
		beq @check_pause
		cmp #GameModeValue
		bne @exit
		lda OperMode_Task
		cmp #$03
		bne @exit
@check_pause:
		; TODO RENABLE
		; jsr HandleRestarts ; Wont return if it did something
		jsr PauseMenu
@exit:
		jmp ReturnBank

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

ForceUpdateSockHashInner:
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
		ldx VRAM_Buffer1_Offset 
		bne skip_sock_hash
draw_sock_hash:
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
skip_sock_hash:
		rts

ForceUpdateSockHash:
		jsr ForceUpdateSockHashInner
		jmp ReturnBank



