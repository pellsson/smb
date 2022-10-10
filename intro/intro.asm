HEAP_SPRITE_OFF = 17*4
PRINCESS_SPRITE_OFF = 53*4
HAND_SPRITE_OFF = 52*4
HEART_SPRITE_OFF = 59*4

LoaderFrameCounter = $30
CurrentHead = $31

CursorY = $200

STAR_INDEX = $700
SEL_INDEX = $701
LDR_MODE = $702 ; ?
SETTINGS_INDEX = $703
LAST_INPUT = $704
SETTINGS_X = $705
RECORD_BUTTONS = $706
RECORD_FRAMES = $707
SETTINGS_ATTR = $708
RECORDS_MODE = $709
RECORDS_TMP = $70A
RECORDS_TMP_HI = $70B
bcdNum = $70C
; bcdNum+1 = $70D
ContraCodeX = $710
ContraSoundFrames = $711

CreditsIndex = $712
PrincessThrowingTimer = $714
PrincessNextThrow = $715
ThrowDir = $716

MirrorPPUCTRL = $720
RndSeed = $721

NumHearts = $722

HeartXLow = $723
HeartYLow = $724
HeartVX = $725 ; and 726
HeartVY = $727 ; and 728
; 5x ^

MAX_HEARTS = 4
SEL_START_Y = $7e
CURSOR_SPRITE = $0A
FIRST_HEAD_TILE = $2E
HEART_SPRITE = $18

	.include "mario.inc"
	.include "shared.inc"
	.include "macros.inc"
	.include "wram.inc"
	.include "text.inc"

	.include "intro.inc"

	.org $8000
	.segment "bank1"

Start:
		lda #$00
		sta MirrorPPUCTRL
		sta PPU_CTRL_REG1
		;
		; Init Random
		;
		ldx #0
@more_random:
		lda $000, x
		adc $100, x
		adc $200, x
		adc $300, x
		adc $400, x
		adc $500, x
		adc $600, x
		adc $700, x
		dex
		bne @more_random
		sta RndSeed
		;
		; Wait for stable ppu state
		;
wait_vbl0:
		lda PPU_STATUS
		bpl wait_vbl0
wait_vbl1:
		lda PPU_STATUS
		bpl wait_vbl1
		inx
clear_memory:
		lda #$00
		sta $0000, x
		sta $0100, x
		sta $0300, x
		sta $0400, x
		sta $0500, x
		sta $0600, x
		cpx #<BANK_SELECTED
		beq dont_wipe_bank_selection
		sta $0700, x
dont_wipe_bank_selection:
		lda #$fe
		sta $0200, x
		inx
		bne clear_memory

		lda #CHR_INTRO_SPR0
		ldx #CHR_INTRO_BG
		jsr SetChrBanksFromAX

		jsr enter_loader

		ldx #$00
		stx PPU_SCROLL_REG ; No scrolling
		stx PPU_SCROLL_REG
		stx WRAM_IsContraMode ; Reset contra mode on restart

		lda #30
		sta PrincessNextThrow
		;
		; Enable NMI
		;
		lda #$90
		sta MirrorPPUCTRL
		sta PPU_CTRL_REG1
hang:
		jmp hang

ReadJoypads: 
		lda SavedJoypadBits
		sta LAST_INPUT
		lda #$01
		sta JOYPAD_PORT
		lsr
		sta JOYPAD_PORT
		ldy #$08
PortLoop:
		pha
		lda JOYPAD_PORT
		sta $00
		lsr
		ora $00
		lsr
		pla
		rol
		dey
		bne PortLoop
		sta SavedJoypadBits
		rts

get_random:
        lda RndSeed
        beq @do_eor
        asl
        beq @no_eor
        bcc @no_eor
@do_eor:
		eor #$1d
@no_eor:
		sta RndSeed
		rts

screen_off:
		ldx PPU_STATUS	; Read PPU status to reset the high/low latch
		ldx #$00
		stx PPU_SCROLL_REG ; No scrolling
		stx PPU_SCROLL_REG
		stx PPU_CTRL_REG2 ; No rendering
		lda MirrorPPUCTRL
		and #$7F
		sta PPU_CTRL_REG1 ; No NMI
		rts

enter_loader:
		jsr screen_off
		lda #SEL_START_Y
		sta CursorY
		lda #0 ; for sml_export_init
		sta NumHearts
		sta SEL_INDEX
		sta LDR_MODE
		tax
		jsr sml_export_init
		;
		; Install nametable
		;
		write_nt "intro_data"
		;
		; Copy static sprite-data over
		;
		ldx #$00
copy_more_sprites:
		lda static_sprite_data, x
		sta $200, x
		inx
		bne copy_more_sprites

		jsr set_leader_head_sprite
		;
		; Install palette
		;
		lda PPU_STATUS ; Latch
		lda #$3F
		sta PPU_ADDRESS
		ldx #$00
		stx PPU_ADDRESS
next_palette_entry:
		lda palette_data, x
		sta PPU_DATA
		inx
		cpx #$20
		bne next_palette_entry
		;
		; Init WRAM
		;
		jsr Enter_InitializeWRAM
		
		rts

ContraCode:
	.byte Up_Dir, Up_Dir, Down_Dir, Down_Dir, Left_Dir, Right_Dir, Left_Dir, Right_Dir, B_Button, A_Button, Start_Button
ContraCodeEnd:

ContraFinishSound:
		dex
		stx ContraSoundFrames
		bne @wait_more
		inc WRAM_IsContraMode
		lda #BANK_ORG
		jmp StartBank
@wait_more:
		jsr fax_update
		rti

NonMaskableInterrupt:
		ldx ContraSoundFrames
		bne ContraFinishSound
		inc LoaderFrameCounter
		lda MirrorPPUCTRL
		and #$7F
		sta PPU_CTRL_REG1
		;
		; Turn on rendering (Sprites, background)
		;
		lda #$1E
		sta PPU_CTRL_REG2
		;
		; Copy sprite data
		;
		lda PPU_STATUS
		lda #$00
		sta PPU_SPR_ADDR
		lda #$02
		sta SPR_DMA

		jsr ReadJoypads

		ldx LDR_MODE
		beq @run_menu
		dex
		bne @not_settings
		jsr run_settings
		jmp exit_nmi
@not_settings:
		jsr run_records
		jmp exit_nmi
@run_menu:
		;
		; Rotate star palette
		;
		lda LoaderFrameCounter
		and #$0f
		bne @no_rotate_stars
		jsr rotate_star_palette
@no_rotate_stars:
		lda LoaderFrameCounter
		and #$3f
		bne @no_update_credits
		jsr update_credits
@no_update_credits:
		;
		; Change head
		;
		lda LoaderFrameCounter
		and #$1f
		bne NoChangeHead
		ldx CurrentHead
		inx
		cpx #6
		bne NoLooparoundHead
		ldx #0
NoLooparoundHead:
		stx CurrentHead
		jsr set_leader_head_sprite
NoChangeHead:

		;
		; Move heads
		;
		lda #00
		sta $04 ; offset
		lda #5 ; Width
		sta $01
		ldy #7 ; Height
		ldx #HEAP_SPRITE_OFF	; Offset
		jsr move_head_group

		lda #16 ; Offset from base
		sta $04
		lda #2 ; Width
		sta $01
		ldy #3 ; Height
		ldx #PRINCESS_SPRITE_OFF
		jsr move_head_group
		jsr update_hearts

		lda #MAX_HEARTS
		cmp NumHearts
		beq @no_new_throw
		dec PrincessNextThrow
		bne @no_new_throw
		jsr spawn_heart
@no_new_throw:
		lda PrincessThrowingTimer
		beq @not_throwing
		dec PrincessThrowingTimer
		lda #$15 ; No hand on cloud sprite
		ldx $200+(PRINCESS_SPRITE_OFF) ; Process top Y
		bne @update_cloud_sprite
@not_throwing:
		lda #$11
		ldx #$ff
@update_cloud_sprite:
	pha
		lda ThrowDir
		asl
		asl
		tay
	pla
		clc
		adc ThrowDir
 		; Cloud top left/right sprite
		sta $200+(PRINCESS_SPRITE_OFF+(2*4)+1),y
		; Move hand
		stx $200+HAND_SPRITE_OFF ; Y
		lda $200+(PRINCESS_SPRITE_OFF+3),y
		ldx ThrowDir
		beq @throw_l
		clc
		adc #6
		jmp @set_hand
@throw_l:
		lda $200+(PRINCESS_SPRITE_OFF+3),y
		sec
		sbc #6
@set_hand:
		sta $200+HAND_SPRITE_OFF+3
		;
		; 
		;
		lda LoaderFrameCounter
		and #$07
		bne dont_update_cursor
		lda #$0B
		cmp $201
		bne hide_cursor
		lda #$0A
hide_cursor:
		sta $201
dont_update_cursor:
		;
		; Update sound
		;
		lda WRAM_DisableMusic
		bne @disabled
		jsr sml_export_play
@disabled:
		lda SavedJoypadBits
		cmp LAST_INPUT
		bne @has_input
		jmp exit_nmi
@has_input:
		cmp #0
		beq @handlein
		;
		; Check contra code
		;
		ldx ContraCodeX
		cmp ContraCode, X
		bne @resetcode
		inx
		stx ContraCodeX
		cpx #(ContraCodeEnd-ContraCode)
		bne @handlein
		ldx SEL_INDEX
		bne @resetcode
		ldx #$4F
		stx ContraSoundFrames
		ldx #0
		lda #41
		jsr fax_load_song
		jmp exit_nmi
@resetcode:
		ldx #0
		stx ContraCodeX
@handlein:
		cmp #Select_Button
		beq @go_down
		cmp #Down_Dir
		bne @check_up
@go_down:
		lda CursorY
		ldx SEL_INDEX
		inx 
		cpx #5
		bne @no_loop_around
		ldx #0
		lda #SEL_START_Y-16
@no_loop_around:
		clc
		adc #16
@move_cursor:
		sta CursorY
		stx SEL_INDEX
		jmp exit_nmi
@check_up:
		cmp #Up_Dir
		bne @check_start
		lda CursorY
		ldx SEL_INDEX
		dex
		bpl @no_underflow
		ldx #4
		lda #SEL_START_Y+(5*16)
@no_underflow:
		sec
		sbc #16
		jmp @move_cursor
@check_start:
		cmp #Start_Button
		bne exit_nmi
		ldx SEL_INDEX
		cpx #3
		beq @settings
		cpx #4
		beq @showrecords
		lda bank_table, x
		jmp StartBank
@showrecords:
		jsr enter_records
		jmp exit_nmi
@settings:
		jsr enter_settings
exit_nmi:
		;
		; Reset
		;
		lda PPU_STATUS
		;
		; Undo scrolling
		;
		lda #$00
		sta PPU_SCROLL_REG ; No scrolling
		sta PPU_SCROLL_REG
		lda MirrorPPUCTRL
		sta PPU_CTRL_REG1	; Make sure NMI is on...
		rti

spawn_heart:
		inc NumHearts 
		jsr get_random
		and #1
		sta ThrowDir
		ldx #$FC
		ldy #$FF
@taken:
		iny
		inx
		inx
		inx
		inx
		lda $200+HEART_SPRITE_OFF+1,x ; Sprite
		bpl @taken
		sty $00 ; Index
		jsr get_random
		and #$1F
		clc
		adc #20
		sta PrincessNextThrow
		lda #$15
		sta PrincessThrowingTimer
		lda $200+(PRINCESS_SPRITE_OFF) ; Princess Y
		sec
		sbc #8
		sta $200+HEART_SPRITE_OFF,x ; Y
		lda #HEART_SPRITE
		sta $200+HEART_SPRITE_OFF+1,x ; Sprite
		lda #0
		sta $200+HEART_SPRITE_OFF+2,x ; Palette
		lda ThrowDir
		bne @throw_right
		lda $200+(PRINCESS_SPRITE_OFF + 0*4)+3 ;Princess X
		sec
		sbc #6
		jmp @next
@throw_right:
		lda $200+(PRINCESS_SPRITE_OFF + 1*4)+3 ;Princess X
		clc
		adc #6
@next:
		sta $200+HEART_SPRITE_OFF+3,x ; X
		lda $00
		asl ; *= 2
		clc
		adc $00 ; *= 3
		asl ; *= 6
		tax
		lda #0
		sta HeartYLow,x
		sta HeartXLow,x
		jsr get_random
		sta HeartVY,x
		ldy #0
		cmp #$9F
		bcs @big_enough
		ldy #1
@big_enough:
		tya
		sta HeartVY+1,x
		jsr get_random
		sta HeartVX,x
		jsr get_random
		and #$1
		ldy ThrowDir
		bne @pos
		clc
		adc #1
		eor #$FF
@pos:
		sta HeartVX+1,x
		rts

update_hearts:
		ldx #0
		ldy #0
		lda #MAX_HEARTS
		sta $00
@gogo:
		dec $00
		bpl @check_heart
		rts
@check_heart:
		lda $200+HEART_SPRITE_OFF+1,y
		cmp #$ff
		beq @advance_next
		; Move X
		lda HeartXLow,x
		clc
		adc HeartVX,x
		sta HeartXLow,x
		lda $200+HEART_SPRITE_OFF+3,y
		adc HeartVX+1,x
		sta $200+HEART_SPRITE_OFF+3,y
		; Move Y
		lda HeartYLow,x
		sec
		sbc HeartVY,x
		sta HeartYLow,x
		lda $200+HEART_SPRITE_OFF,y
		sbc HeartVY+1,x
		sta $200+HEART_SPRITE_OFF,y
		cmp #240
		bcc @advance_next
		dec NumHearts
		lda #$ff
		sta $200+HEART_SPRITE_OFF+1,y
@advance_next:
		lda HeartVY,x
		sec
		sbc #20
		sta HeartVY,x
		lda HeartVY+1,x
		sbc #0
		sta HeartVY+1,x
		txa
		clc
		adc #6
		tax
		iny
		iny
		iny
		iny
		jmp @gogo

rotate_star_palette:
		;
		; Init PPU
		;
		lda PPU_STATUS ; Latch
		lda #$3F
		sta PPU_ADDRESS
		lda #$05
		sta PPU_ADDRESS
		;
		; Rotate star palette
		;
		ldx STAR_INDEX
		inx
		cpx #3
		bne no_star_reset
		ldx #0
no_star_reset:
		stx STAR_INDEX
		ldy #3
shuffle_more_stars:
		lda palette_star_shuffle, x
		sta PPU_DATA
		inx
		cpx #3
		bne no_loop
		ldx #0
no_loop:
		dey
		bne shuffle_more_stars
		lda PPU_STATUS
		lda #$00
		sta PPU_ADDRESS
		sta PPU_ADDRESS
		rts

head_sprite_indexes:
		.byte FIRST_HEAD_TILE+35*0, FIRST_HEAD_TILE+35*1
		.byte FIRST_HEAD_TILE+35*2, FIRST_HEAD_TILE+35*3
		.byte FIRST_HEAD_TILE+35*4, FIRST_HEAD_TILE+35*5

set_leader_head_sprite:
		lda #35
		sta $0
		ldy head_sprite_indexes, x
		ldx #HEAP_SPRITE_OFF
		inx
copy_next_sprite:
		tya
		sta $200, x
		iny
		inx
		inx
		inx
		inx
		dec $0
		bne copy_next_sprite
		rts

move_head_group:
		;
		; Copy W
		;
		lda $01
		sta $03
		;
		; Base Y
		;
		lda $203, x ; X
		and #$7f
		stx $00
		tax
		lda sine_curve, x
		ldx $00
		clc
		adc $04
		sta $02 ; New Y
		;
		; Move group
		;
next_col:
		lda $03
		sta $01
move_more:
		dec $203, x
		lda $02
		sta $200, x
		inx
		inx
		inx
		inx
		dec $01
		bne move_more
		lda $02
		clc
		adc #$08
		sta $02
		dey
		bne next_col
		rts

credits_start:
credits_pellsson:
	.byte "BY: PELLSSON            "
credits_threecreepio:
	.byte "BY: THREECREEPIO        "
credits_simplistic_memes:
	.byte "BY: SIMPLISTIC MEMES    "
credits_reset:
	.byte "CATCH THEM WITH PRACTICE"
credits_end:

credits_length:
	.byte credits_threecreepio-credits_pellsson
	.byte credits_simplistic_memes-credits_threecreepio
	.byte credits_reset-credits_simplistic_memes
	.byte credits_end-credits_reset
credits_offset:
	.byte credits_pellsson-credits_start
	.byte credits_threecreepio-credits_start
	.byte credits_simplistic_memes-credits_start
	.byte credits_reset-credits_start

update_credits:
		lda $2002
		;
		; Copycopycopycopy
		;
		lda PPU_STATUS
		lda #$21
		sta PPU_ADDRESS
		lda #$A4
		sta PPU_ADDRESS

		ldx CreditsIndex
		ldy credits_length, x
		lda credits_offset, x
		tax
@more:
		lda credits_start, x
		sta PPU_DATA
		inx
		dey
		bne @more
		sty PPU_SCROLL_REG ; No scrolling
		sty PPU_SCROLL_REG
		ldx CreditsIndex
		inx
		cpx #4
		bne @done
		ldx #0
@done:
		stx CreditsIndex
		rts

sine_curve:
	.byte $24, $24, $25, $26, $27, $27, $28, $29, $2A, $2A, $2B, $2C, $2C, $2D, $2E, $2E, $2F, $2F, $30, $30, $31, $31, $32, $32, $32, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $32, $32, $32, $31, $31, $31, $30, $30, $2F, $2F, $2E, $2D, $2D, $2C, $2B, $2B, $2A, $29, $29, $28, $27, $26, $25, $25, $24, $23, $22, $22, $21, $20, $1F, $1E, $1E, $1D, $1C, $1C, $1B, $1A, $1A, $19, $18, $18, $17, $17, $16, $16, $16, $15, $15, $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $15, $15, $16, $16, $17, $17, $18, $18, $19, $19, $1A, $1B, $1B, $1C, $1D, $1D, $1E, $1F, $20, $20, $21, $22, $23, $23

	.include "nt.asm"

static_sprite_data:
	.byte SEL_START_Y, CURSOR_SPRITE, $02, $30
	;
	; Mario
	;
	.byte $7f,		$06, $00, $D0
	.byte $7f,		$07, $00, $D0+8
	.byte $7f+8,	$08, $00, $D0
	.byte $7f+8,	$09, $00, $D0+8
	;
	; Left Window
	;
	.byte $c8,		$00, $02, $c0
	.byte $c8,		$01, $02, $c0+8
	.byte $c8+8,	$02, $02, $c0
	.byte $c8+8,	$03, $02, $c0+8
	.byte $c8+16,	$04, $02, $c0
	.byte $c8+16,	$05, $02, $c0+8
	;
	; Right Window
	;
	.byte $c8,		$00, $02, $e0
	.byte $c8,		$01, $02, $e0+8
	.byte $c8+8,	$02, $02, $e0
	.byte $c8+8,	$03, $02, $e0+8
	.byte $c8+16,	$04, $02, $e0
	.byte $c8+16,	$05, $02, $e0+8
	;
	; Leader face
	;
	.byte $a0,	FIRST_HEAD_TILE+1, $01, $40
	.byte $a0,	FIRST_HEAD_TILE+2, $01, $40+8
	.byte $a0,	FIRST_HEAD_TILE+3, $01, $40+16
	.byte $a0,	FIRST_HEAD_TILE+4, $01, $40+24
	.byte $a0,	FIRST_HEAD_TILE+5, $01, $40+32
	;
	.byte $FF,	$15, $01, $40
	.byte $FF,	$16, $01, $40+8
	.byte $FF,	$17, $01, $40+16
	.byte $FF,	$18, $01, $40+24
	.byte $FF,	$19, $01, $40+32
	;
	.byte $ff,	$1a, $01, $40
	.byte $ff,	$1b, $01, $40+8
	.byte $ff,	$1c, $01, $40+16
	.byte $ff,	$1d, $01, $40+24
	.byte $ff,	$1e, $01, $40+32
	;
	.byte $ff,	$1f, $01, $40
	.byte $ff,	$20, $01, $40+8
	.byte $ff,	$21, $01, $40+16
	.byte $ff,	$22, $01, $40+24
	.byte $ff,	$23, $01, $40+32
	;
	.byte $ff,	$24, $01, $40
	.byte $ff,	$25, $01, $40+8
	.byte $ff,	$26, $01, $40+16
	.byte $ff,	$27, $01, $40+24
	.byte $ff,	$28, $01, $40+32
	;
	.byte $ff,	$29, $01, $40
	.byte $ff,	$2a, $01, $40+8
	.byte $ff,	$2b, $01, $40+16
	.byte $ff,	$2c, $01, $40+24
	.byte $ff,	$2d, $01, $40+32
	;
	.byte $ff,	$2e, $01, $40
	.byte $ff,	$2f, $01, $40+8
	.byte $ff,	$30, $01, $40+16
	.byte $ff,	$31, $01, $40+24
	.byte $ff,	$32, $01, $40+32
	;
	; Throwing hand
	;
	.byte $ff,	$17, $03, $ff
	;
	; Princess
	;
	.byte $FF,	$0f, $00, $90
	.byte $FF,	$10, $00, $90+8
	;
	.byte $ff,	$11, $03, $90
	.byte $ff,	$12, $03, $90+8
	;
	.byte $ff,	$13, $03, $90
	.byte $ff,	$14, $03, $90+8
	;
	; Hearts
	;
	.byte $ff,	$ff, $03, $90+16
	.byte $ff,	$ff, $00, $90+16
	.byte $ff,	$ff, $03, $90
	.byte $ff,	$ff, $03, $90+8
	.byte $ff,	$ff, $03, $90+16
	;
	; 0x100 bytes here...
	;

palette_data:
		.byte $0f, $2c, $1c, $20 ; White box, hightlight text
		.byte $0f                ; Star unused
palette_star_shuffle:
		.byte $30, $2c, $00      ; Stars
		.byte $0f, $20, $20, $20 ; Main font
		.byte $0f, $00, $10, $30 ; Megaman
		;
		;
		;
		.byte $0f, $16, $27, $18 ; Mario
		.byte $0f, $27, $17, $0d ; Leader head
		.byte $0f, $30, $2c, $11 ; Window
		.byte $0f, $0D, $16, $27 ; Princess cloud

bank_table:
		.byte BANK_ORG, BANK_SMBLL, BANK_SCEN

	.include "settings.asm"
	.include "records.asm"
	.include "smlsound.asm"
	.include "faxsound.asm"

practice_callgate
control_bank
