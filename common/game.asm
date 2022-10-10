ReadJoypads: 
		lda #$01               ;reset and clear strobe of joypad ports
		sta JOYPAD_PORT
		lsr
		sta JOYPAD_PORT
		ldy #$08
PortLoop:
	pha
		lda JOYPAD_PORT
		sta $00                ;check d1 and d0 of port output
		lsr                    ;this is necessary on the old
		ora $00                ;famicom systems in japan
		lsr
	pla
		rol                    ;rotate bit from carry flag
		dey
		bne PortLoop           ;count down bits left
		sta SavedJoypadBits
	pha
		and #%00110000
		and JoypadBitMask
		beq Save8Bits
	pla
		and #%11001111
		sta SavedJoypadBits
		rts
Save8Bits:
	pla
		sta JoypadBitMask
		rts


mario_colors:
		.byte $3F, $11, $03, $16, $27, $18, $00 ; mario
		.byte $3F, $11, $03, $30, $27, $19, $00 ; luigi
		.byte $3F, $11, $03, $37, $27, $16, $00 ; fiery

mario_colors_peach:
		.byte $3F, $11, $03, $16, $27, $30, $00 ; peach
		.byte $3F, $11, $03, $30, $27, $19, $00 ; not-used (but offset is ;) hack fuck.
		.byte $3F, $11, $03, $16, $27, $37, $00 ; fiery

mario_gfx:
		.byte $c0, $32, $00, $A0
		.byte $c0, $33, $00, $A8
		.byte $c8, $4f, $00, $A0
		.byte $c8, $4f, $40, $A8

DrawTitleMario:
		ldx #4*4-1
		ldy #4*4-1
@copy_next:
		lda mario_gfx, x
		sta Sprite_Data+4, y
		dey
		dex
		bpl @copy_next
SetMarioPalette:
		ldy VRAM_Buffer1_Offset
		ldx CurrentPlayer
		beq @mario_pal
		ldx #$07
@mario_pal:
		lda PlayerStatus
		cmp #$02
		bne @draw_pal
		ldx #$0E
@draw_pal:
		lda WRAM_IsContraMode
		beq @normal
		lda mario_colors_peach, x
		jmp @write_it 
@normal:
		lda mario_colors, x
@write_it:
		sta VRAM_Buffer1, y
		beq @copy_done
		inx
		iny
		bne @draw_pal
@copy_done:
		sty VRAM_Buffer1_Offset
		rts

DrawOneSpriteRow:
		sta $01
DrawSpriteObject:
		lda $03                    ;get saved flip control bits
		lsr
		lsr                        ;move d1 into carry
		lda $00
		bcc NoHFlip                ;if d1 not set, branch
		sta Sprite_Tilenumber+4,y  ;store first tile into second sprite
		lda $01                    ;and second into first sprite
		sta Sprite_Tilenumber,y
		lda #$40                   ;activate horizontal flip OAM attribute
		bne SetHFAt                ;and unconditionally branch
NoHFlip:
		sta Sprite_Tilenumber,y    ;store first tile into first sprite
		lda $01                    ;and second into second sprite
		sta Sprite_Tilenumber+4,y
		lda #$00                   ;clear bit for horizontal flip
SetHFAt:
		ora $04                    ;add other OAM attributes if necessary
		sta Sprite_Attributes,y    ;store sprite attributes
		sta Sprite_Attributes+4,y
		lda $02                    ;now the y coordinates
		sta Sprite_Y_Position,y    ;note because they are
		sta Sprite_Y_Position+4,y  ;side by side, they are the same
		lda $05       
		sta Sprite_X_Position,y    ;store x coordinate, then
		clc                        ;add 8 pixels and store another to
		adc #$08                   ;put them side by side
		sta Sprite_X_Position+4,y
		lda $02                    ;add eight pixels to the next y
		clc                        ;coordinate
		adc #$08
		sta $02
		tya                        ;add eight to the offset in Y to
		clc                        ;move to the next two sprites
		adc #$08
		tay
		inx                        ;increment offset to return it to the
		inx                        ;routine that called this subroutine
		rts

RenderPlayerSub:
		sta $07                      ;store number of rows of sprites to draw
		lda Player_Rel_XPos
		sta Player_Pos_ForScroll     ;store player's relative horizontal position
		sta $05                      ;store it here also
		lda Player_Rel_YPos
		sta $02                      ;store player's vertical position
		lda PlayerFacingDir
		sta $03                      ;store player's facing direction
		lda Player_SprAttrib
		sta $04                      ;store player's sprite attributes
		ldx PlayerGfxOffset          ;load graphics table offset
		ldy Player_SprDataOffset     ;get player's sprite data offset
DrawPlayerLoop:
		lda PlayerGraphicsTable,x    ;load player's left side
		sta $00
		lda PlayerGraphicsTable+1,x  ;now load right side
		jsr DrawOneSpriteRow
		dec $07                      ;decrement rows of sprites to draw
		bne DrawPlayerLoop           ;do this until all rows are drawn
		rts

ChkForPlayerAttrib:
		ldy Player_SprDataOffset    ;get sprite data offset
		lda GameEngineSubroutine
		cmp #$0b                    ;if executing specific game engine routine,
		beq KilledAtt               ;branch to change third and fourth row OAM attributes
		lda PlayerGfxOffset         ;get graphics table offset
		cmp #$50
		beq C_S_IGAtt               ;if crouch offset, either standing offset,
		cmp #$b8                    ;or intermediate growing offset,
		beq C_S_IGAtt               ;go ahead and execute code to change 
		cmp #$c0                    ;fourth row OAM attributes only
		beq C_S_IGAtt
		cmp #$c8
		bne ExPlyrAt                ;if none of these, branch to leave
KilledAtt:
		lda Sprite_Attributes+16,y
		and #%00111111              ;mask out horizontal and vertical flip bits
		sta Sprite_Attributes+16,y  ;for third row sprites and save
		lda Sprite_Attributes+20,y
		and #%00111111  
		ora #%01000000              ;set horizontal flip bit for second
		sta Sprite_Attributes+20,y  ;sprite in the third row
C_S_IGAtt:
		lda Sprite_Attributes+24,y
		and #%00111111              ;mask out horizontal and vertical flip bits
		sta Sprite_Attributes+24,y  ;for fourth row sprites and save
		lda Sprite_Attributes+28,y
		and #%00111111
		ora #%01000000              ;set horizontal flip bit for second
		sta Sprite_Attributes+28,y  ;sprite in the fourth row
ExPlyrAt:
		rts                         ;leave


PlayerGfxProcessing:
		sta PlayerGfxOffset           ;store offset to graphics table here
		lda #$04
		jsr RenderPlayerSub           ;draw player based on offset loaded
		jsr ChkForPlayerAttrib        ;set horizontal flip bits as necessary
		lda FireballThrowingTimer
		beq PlayerOffscreenChk        ;if fireball throw timer not set, skip to the end
		ldy #$00                      ;set value to initialize by default
		lda PlayerAnimTimer           ;get animation frame timer
		cmp FireballThrowingTimer     ;compare to fireball throw timer
		sty FireballThrowingTimer     ;initialize fireball throw timer
		bcs PlayerOffscreenChk        ;if animation frame timer => fireball throw timer skip to end
		sta FireballThrowingTimer     ;otherwise store animation timer into fireball throw timer
		ldy #$07                      ;load offset for throwing
		lda PlayerGfxTblOffsets,y     ;get offset to graphics table
		sta PlayerGfxOffset           ;store it for use later
		ldy #$04                      ;set to update four sprite rows by default
		lda Player_X_Speed
		ora Left_Right_Buttons        ;check for horizontal speed or left/right button press
		beq SUpdR                     ;if no speed or button press, branch using set value in Y
		dey                           ;otherwise set to update only three sprite rows
SUpdR:
		tya                           ;save in A for use
		jsr RenderPlayerSub           ;in sub, draw player object again
PlayerOffscreenChk:
		lda Player_OffscreenBits      ;get player's offscreen bits
		lsr
		lsr                           ;move vertical bits to low nybble
		lsr
		lsr
		sta $00                       ;store here
		ldx #$03                      ;check all four rows of player sprites
		lda Player_SprDataOffset      ;get player's sprite data offset
		clc
		adc #$18                      ;add 24 bytes to start at bottom row
		tay                           ;set as offset here
PROfsLoop:
		lda #$f8                      ;load offscreen Y coordinate just in case
		lsr $00                       ;shift bit into carry
		bcc NPROffscr                 ;if bit not set, skip, do not move sprites
		sta Sprite_Data+4,y 	      ;and into first row sprites
		sta Sprite_Data,y
NPROffscr:
		tya
		sec                           ;subtract eight bytes to do
		sbc #$08                      ;next row up
		tay
		dex                           ;decrement row counter
		bpl PROfsLoop                 ;do this until all sprite rows are checked
		rts                           ;then we are done!

PlayerGfxTblOffsets:
		.byte $20, $28, $c8, $18, $00, $40, $50, $58
		.byte $80, $88, $b8, $78, $60, $a0, $b0, $b8

PlayerGraphicsTable:
		;big player table
		.byte $00, $01, $02, $03, $04, $05, $06, $07 ;walking frame 1
		.byte $08, $09, $0a, $0b, $0c, $0d, $0e, $0f ;        frame 2
		.byte $10, $11, $12, $13, $14, $15, $16, $17 ;        frame 3
		.byte $18, $19, $1a, $1b, $1c, $1d, $1e, $1f ;skidding
		.byte $20, $21, $22, $23, $24, $25, $26, $27 ;jumping
		.byte $08, $09, $28, $29, $2a, $2b, $2c, $2d ;swimming frame 1
		.byte $08, $09, $0a, $0b, $0c, $30, $2c, $2d ;         frame 2
		.byte $08, $09, $0a, $0b, $2e, $2f, $2c, $2d ;         frame 3
		.byte $08, $09, $28, $29, $2a, $2b, $5c, $5d ;climbing frame 1
		.byte $08, $09, $0a, $0b, $0c, $0d, $5e, $5f ;         frame 2
		.byte $fc, $fc, $08, $09, $58, $59, $5a, $5a ;crouching
		.byte $08, $09, $28, $29, $2a, $2b, $0e, $0f ;fireball throwing

		;small player table
		.byte $fc, $fc, $fc, $fc, $32, $33, $34, $35 ;walking frame 1
		.byte $fc, $fc, $fc, $fc, $36, $37, $38, $39 ;        frame 2
		.byte $fc, $fc, $fc, $fc, $3a, $37, $3b, $3c ;        frame 3
		.byte $fc, $fc, $fc, $fc, $3d, $3e, $3f, $40 ;skidding
		.byte $fc, $fc, $fc, $fc, $32, $41, $42, $43 ;jumping
		.byte $fc, $fc, $fc, $fc, $32, $33, $44, $45 ;swimming frame 1
		.byte $fc, $fc, $fc, $fc, $32, $33, $44, $47 ;         frame 2
		.byte $fc, $fc, $fc, $fc, $32, $33, $48, $49 ;         frame 3
		.byte $fc, $fc, $fc, $fc, $32, $33, $90, $91 ;climbing frame 1
		.byte $fc, $fc, $fc, $fc, $3a, $37, $92, $93 ;         frame 2
		.byte $fc, $fc, $fc, $fc, $9e, $9e, $9f, $9f ;killed

		;used by both player sizes
		.byte $fc, $fc, $fc, $fc, $3a, $37, $4f, $4f ;small player standing
		.byte $fc, $fc, $00, $01, $4c, $4d, $4e, $4e ;intermediate grow frame
		.byte $00, $01, $4c, $4d, $4a, $4a, $4b, $4b ;big player standing

SwimKickTileNum:
		.byte $31, $46

RedrawMario:
		lda #$B8
		ldy PlayerSize
		bne @small_mario
		lda #$C8
@small_mario:
		jsr PlayerGfxProcessing
		jmp SetMarioPalette

LoadPhysicsData:
		jsr LL_UpdatePlayerChange
		jmp ReturnBank

LoadMarioPhysics:
		jsr PlayerIsMarioPatch
		jmp ReturnBank

MarioOrLuigiPhysics:
		;
		; Mario Physics
		;
		.byte $20, $20, $1E, $28
		.byte $28, $0D, $04, $70
		.byte $70, $60, $90, $90
		.byte $0A, $09, $E4, $98
		.byte $D0
		;
		; Luigi Physics
		;
		.byte $18, $18, $18, $22
		.byte $22, $0D, $04, $42
		.byte $42, $3E, $5D, $5D
		.byte $0A, $09, $B4, $68
		.byte $A0

MarioOrLuigiColors:
		.byte $22, $16, $27, $18 ; Mario
		.byte $22, $30, $27, $19 ; Luigi

LL_UpdatePlayerChange:
		; ldx #$60
		ldy #$21
		lda IsPlayingLuigi
		bne PlayerIsLuigiPath
PlayerIsMarioPatch:
		; ldx #$E
		ldy #$10
PlayerIsLuigiPath:
		; stx VOLDST_PatchMovementFriction
		ldx #$10
@copy_more:
		lda MarioOrLuigiPhysics,y
		sta WRAM_JumpMForceData,x
		dey
		dex
		bpl @copy_more
		ldy #7
		lda IsPlayingLuigi
		bne @is_luigi
		ldy #3
@is_luigi:
		ldx #3
@copy_pal:
		lda MarioOrLuigiColors, y
		sta WRAM_PlayerColors, x
		dey
		dex
		bpl @copy_pal
		rts

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


UpdateGameTimer:
		ldy #$23
		lda #$ff
		sta DigitModifier+5
		jsr DigitsMathRoutine3
		ldx VRAM_Buffer1_Offset
		lda #$20
		sta VRAM_Buffer1,x
		lda #$7A
		sta VRAM_Buffer1+1,x
		lda #$03
		sta VRAM_Buffer1+2,x
		lda GameTimerDisplay
		sta VRAM_Buffer1+3,x
		lda GameTimerDisplay+1
		sta VRAM_Buffer1+4,x
		lda GameTimerDisplay+2
		sta VRAM_Buffer1+5,x
		lda #0
		sta VRAM_Buffer1+6,x
		lda VRAM_Buffer1_Offset
		clc
		adc #6
		sta VRAM_Buffer1_Offset
		ldx ObjectOffset
		jmp ReturnBank


