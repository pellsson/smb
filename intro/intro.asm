LEADER_HEAD_SPRITE = 17*4
KAPPA_SPRITE = 52*4
STAR_INDEX = $700
SEL_INDEX = $701
LDR_MODE = $702 ; ?
SETTINGS_INDEX = $703
SEL_START_Y = $7e
LoaderFrameCounter = $30
CurrentHead = $31
CURSOR_SPRITE = $f9

	.include "mario.inc"
	.include "shared.inc"
	.include "macros.inc"
	.include "wram.inc"
	.include "text.inc"

	.include "intro.inc"

	.org $c000
	.segment "bank1"

Start:
		lda #$10	; Use 0x1000 for background (not that it matters, same in both)
		sta PPU_CTRL_REG1
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
		;
		; Install nametable
		;
		write_nt "nametable_data"

		;
		; Copy static sprite-data over
		;
		ldx #$00
copy_more_sprites:
		lda static_sprite_data, x
		sta $200, x
		inx
		bne copy_more_sprites
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
		jsr Enter_SetDefaultWRAM
		;
		; Enable sound
		;
		lda #$01
		sta OperMode			; Anything but zero and it will play...

		lda #0
		ldx #0
		jsr sml_export_init

		ldx #CHR_INTRO
		jsr Enter_LoadChrFromX

		ldx #$00
		stx PPU_SCROLL_REG ; No scrolling
		stx PPU_SCROLL_REG
		
		;
		; Enable NMI
		;
		lda #$80
		sta PPU_CTRL_REG1
hang:
		jmp hang

ReadJoypads: 
		lda #$01
		sta JOYPAD_PORT
		lsr
		tax
		sta JOYPAD_PORT
		jsr ReadPortBits
		inx
ReadPortBits:
		ldy #$08
PortLoop:
		pha
		lda JOYPAD_PORT,x
		sta $00
		lsr
		ora $00
		lsr
		pla
		rol
		dey
		bne PortLoop
		sta SavedJoypadBits,x
		pha
		and #%00110000
		and JoypadBitMask,x
		beq Save8Bits
		pla
		and #%11001111
		sta SavedJoypadBits,x
		rts
Save8Bits:
		pla
		sta JoypadBitMask,x
		rts

run_settings:
		rts

NonMaskableInterrupt:
		inc LoaderFrameCounter
		lda #$00
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

		lda LDR_MODE
		beq @run_menu
		jsr run_settings
		jmp no_start
@run_menu:
		;
		; Rotate star palette
		;
		lda LoaderFrameCounter
		and #$0f
		bne @no_rotate_stars
		jsr rotate_star_palette
@no_rotate_stars:
		;
		; Change head
		;
		lda LoaderFrameCounter
		and #$1f
		bne NoChangeHead
		ldx CurrentHead
		inx
		cpx #4
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
		ldx #LEADER_HEAD_SPRITE	; Offset
		jsr move_head_group

		lda #16
		sta $04
		lda #3
		sta $01
		ldy #4
		ldx #KAPPA_SPRITE
		jsr move_head_group
		;
		;
		;
		lda LoaderFrameCounter
		and #$07
		bne dont_update_cursor
		lda $201
		cmp #CURSOR_SPRITE
		beq hide_cursor
		lda #CURSOR_SPRITE
		sta $201
		jmp dont_update_cursor
hide_cursor:
		lda #$24
		sta $201
dont_update_cursor:
		;
		; Update sound
		;
		; jsr EnterSoundEngine
		jsr sml_export_play
		jsr ReadJoypads
		lda SavedJoypadBits
		cmp #Select_Button
		bne no_select
		ldx SEL_INDEX
		lda $200
		inx 
		cpx #4
		bne no_loop_around
		ldx #0
		lda #SEL_START_Y-16
no_loop_around:
		clc
		adc #16
		sta $200
		stx SEL_INDEX
no_select:
		cmp #Start_Button
		bne no_start
		ldx SEL_INDEX
		cpx #3
		beq @settings
		lda bank_table, x
		jmp StartBank
@settings:
		jsr enter_settings
no_start:
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
		lda #$80
		sta PPU_CTRL_REG1	; Make sure NMI is on...
		rti

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
		bpl shuffle_more_stars
		lda PPU_STATUS
		lda #$00
		sta PPU_ADDRESS
		sta PPU_ADDRESS
		rts


head_sprite_indexes:
		.byte $5f, $82, $a5, $c8

set_leader_head_sprite:
		lda #35
		sta $0
		ldy head_sprite_indexes, x
		ldx #LEADER_HEAD_SPRITE
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

sine_curve:
	.byte $24, $24, $25, $26, $27, $27, $28, $29, $2A, $2A, $2B, $2C, $2C, $2D, $2E, $2E, $2F, $2F, $30, $30, $31, $31, $32, $32, $32, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $32, $32, $32, $31, $31, $31, $30, $30, $2F, $2F, $2E, $2D, $2D, $2C, $2B, $2B, $2A, $29, $29, $28, $27, $26, $25, $25, $24, $23, $22, $22, $21, $20, $1F, $1E, $1E, $1D, $1C, $1C, $1B, $1A, $1A, $19, $18, $18, $17, $17, $16, $16, $16, $15, $15, $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $15, $15, $16, $16, $17, $17, $18, $18, $19, $19, $1A, $1B, $1B, $1C, $1D, $1D, $1E, $1F, $20, $20, $21, $22, $23, $23

	.include "nt.asm"
	.include "nt_settings.asm"

static_sprite_data:
	.byte SEL_START_Y, CURSOR_SPRITE, $02, $30
	;
	; Mario
	;
	.byte $7f,	$32, $00, $D0
	.byte $7f,	$33, $00, $D0+8
	.byte $7f+8,	$34, $00, $D0
	.byte $7f+8,	$35, $00, $D0+8
	;
	; Left Window
	;
	.byte $c8,	$36, $02, $c0
	.byte $c8,	$37, $02, $c0+8
	.byte $c8+8,	$38, $02, $c0
	.byte $c8+8,	$39, $02, $c0+8
	.byte $c8+16,	$3a, $02, $c0
	.byte $c8+16,	$3b, $02, $c0+8
	;
	; Right Window
	;
	.byte $c8,	$36, $02, $e0
	.byte $c8,	$37, $02, $e0+8
	.byte $c8+8,	$38, $02, $e0
	.byte $c8+8,	$39, $02, $e0+8
	.byte $c8+16,	$3a, $02, $e0
	.byte $c8+16,	$3b, $02, $e0+8
	;
	; Leader face
	;
	.byte $40,	$5f, $01, $40
	.byte $40,	$60, $01, $40+8
	.byte $40,	$61, $01, $40+16
	.byte $40,	$62, $01, $40+24
	.byte $40,	$63, $01, $40+32
	;
	.byte $FF,	$64, $01, $40
	.byte $FF,	$65, $01, $40+8
	.byte $FF,	$66, $01, $40+16
	.byte $FF,	$67, $01, $40+24
	.byte $FF,	$68, $01, $40+32
	;
	.byte $ff,	$69, $01, $40
	.byte $ff,	$6a, $01, $40+8
	.byte $ff,	$6b, $01, $40+16
	.byte $ff,	$6c, $01, $40+24
	.byte $ff,	$6d, $01, $40+32
	;
	.byte $ff,	$6e, $01, $40
	.byte $ff,	$6f, $01, $40+8
	.byte $ff,	$70, $01, $40+16
	.byte $ff,	$71, $01, $40+24
	.byte $ff,	$72, $01, $40+32
	;
	.byte $ff,	$73, $01, $40
	.byte $ff,	$74, $01, $40+8
	.byte $ff,	$75, $01, $40+16
	.byte $ff,	$76, $01, $40+24
	.byte $ff,	$77, $01, $40+32
	;
	.byte $ff,	$78, $01, $40
	.byte $ff,	$79, $01, $40+8
	.byte $ff,	$7a, $01, $40+16
	.byte $ff,	$7b, $01, $40+24
	.byte $ff,	$7c, $01, $40+32
	;
	.byte $ff,	$7d, $01, $40
	.byte $ff,	$7e, $01, $40+8
	.byte $ff,	$7f, $01, $40+16
	.byte $ff,	$80, $01, $40+24
	.byte $ff,	$81, $01, $40+32
	;
	; Kappa
	;
	.byte $FF,	$eb, $03, $90
	.byte $FF,	$ec, $03, $90+8
	.byte $FF,	$ed, $03, $90+16
	;
	.byte $ff,	$ee, $03, $90
	.byte $ff,	$ef, $03, $90+8
	.byte $ff,	$f0, $03, $90+16
	;
	.byte $ff,	$f1, $03, $90
	.byte $ff,	$f2, $03, $90+8
	.byte $ff,	$f3, $03, $90+16
	;
	.byte $ff,	$f4, $03, $90
	.byte $ff,	$f5, $03, $90+8
	.byte $ff,	 $f6, $03, $90+16
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
		.byte $0f, $10, $00, $0d ; Kappa head

bank_table:
		.byte BANK_ORG, BANK_SMBLL, BANK_SCEN

	.include "settings.asm"

practice_callgate
control_bank
