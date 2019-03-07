;
; This hack is just inlined into intro.asm
;
.macro draw_simple_at at, txt
		.local @copy
		.local @s
		lda PPU_STATUS
		lda #>($2017 + (at * $20))
		sta PPU_ADDRESS
		lda #<($2017 + (at * $20))
		sta PPU_ADDRESS
		ldx #0
		ldy #.strlen(txt)
@copy:
		lda @s, x
		sta PPU_DATA
		inx
		dey
		bne @copy
		rts
@s:
		.byte txt
.endmacro

.macro draw_hexopt_at at, user
		lda PPU_STATUS
		lda #>($2017 + (at * $20))
		sta PPU_ADDRESS
		lda #<($2017 + (at * $20))
		sta PPU_ADDRESS
	.if user
		ldy #1
		lda ($00), y
		and #7
		sta PPU_DATA
	.endif
		ldy #0
		lda ($00), y
		and #$F0
		ror
		ror
		ror
		ror
		sta PPU_DATA
		lda ($00), y
		and #$0F
		sta PPU_DATA
		rts
.endmacro

.macro draw_button_opt at
		.local @is_set
		cmp #0
		bne @is_set
		draw_simple_at at, "UNBOUND"
@is_set:
	pha
		lda PPU_STATUS
		lda #>($2017 + (at * $20))
		sta PPU_ADDRESS
		lda #<($2017 + (at * $20))
		sta PPU_ADDRESS
	pla
		jmp draw_buttons
.endmacro

.macro add_button v
		ldy #v
		sty PPU_DATA
		ldy #$24
		sty PPU_DATA
.endmacro

draw_buttons:
		ror
		bcc @no_right
		add_button 'R'
@no_right:
		ror
		bcc @no_left
		add_button 'L'
@no_left:
		ror 
		bcc @no_down
		add_button 'D'
@no_down:
		ror
		bcc @no_up
		add_button 'U'
@no_up:
		ror ; fuck start
		ror
		bcc @no_select
		add_button 'S'
@no_select:
		ror
		bcc @no_b
		add_button 'B'
@no_b:
		beq @no_a
		add_button 'A'
@no_a:
		rts

_music_on: draw_simple_at 6, "ON"
_music_off: draw_simple_at 6, "OFF"

_draw_music_opt:
		lda WRAM_DisableMusic
		beq @on
		jmp _music_off
@on:
		jmp _music_on

_sound_on: draw_simple_at 7, "ON"
_sound_off: draw_simple_at 7, "OFF"

_draw_sound_opt:
		lda WRAM_DisableSound
		beq @on
		jmp _sound_off
@on:
		jmp _sound_on

get_uservar_ptr:
		ldx SETTINGS_INDEX
		dex
		dex
		bne @try_o1
		; org0
		lda #<WRAM_OrgUser0
		sta $00
		lda #>WRAM_OrgUser0
		sta $01
		rts
@try_o1:
		dex
		bne @try_l0
		; org1
		lda #<WRAM_OrgUser1
		sta $00
		lda #>WRAM_OrgUser1
		sta $01
		rts
@try_l0:
		dex
		bne @do_lost1
		lda #<WRAM_LostUser0
		sta $00
		lda #>WRAM_LostUser0
		sta $01
		rts
@do_lost1:
		lda #<WRAM_LostUser1
		sta $00
		lda #>WRAM_LostUser1
		sta $01
		rts

_draw_user0org_opt:
		jsr get_uservar_ptr
		draw_hexopt_at 8, 1

_draw_user1org_opt:
		jsr get_uservar_ptr
		draw_hexopt_at 9, 1

_draw_user0lost_opt:
		jsr get_uservar_ptr
		draw_hexopt_at 10, 1

_draw_user1lost_opt:
		jsr get_uservar_ptr
		draw_hexopt_at 11, 1

_draw_userdelay_opt:
		lda #<WRAM_DelayUserFrames
		sta $00
		lda #>WRAM_DelayUserFrames
		sta $01
		draw_hexopt_at 12, 0

_draw_savedelay_opt:
		lda #<WRAM_DelaySaveFrames
		sta $00
		lda #>WRAM_DelaySaveFrames
		sta $01
		draw_hexopt_at 13, 0

_char_native: draw_simple_at 14, "NATIVE"
_char_org: draw_simple_at 14, "ORG"
_char_lost: draw_simple_at 14, "LOST"

_draw_charset_opt:
		ldx WRAM_CharSet
		beq @native
		dex
		beq @org
		jmp _char_lost
@org:
		jmp _char_org
@native:
		jmp _char_native

_draw_button_restart_opt:
		lda WRAM_RestartButtons
		draw_button_opt 15

_draw_button_title_opt:
		lda WRAM_TitleButtons
		draw_button_opt 16

_draw_button_save_opt:
		lda WRAM_SaveButtons
		draw_button_opt 17

_draw_button_load_opt:
		lda WRAM_LoadButtons
		draw_button_opt 18

settings_renderers:
		.word _draw_music_opt
		.word _draw_sound_opt
		.word _draw_user0org_opt
		.word _draw_user1org_opt
		.word _draw_user0lost_opt
		.word _draw_user1lost_opt
		.word _draw_userdelay_opt
		.word _draw_savedelay_opt
		.word _draw_charset_opt
		.word _draw_button_restart_opt
		.word _draw_button_title_opt
		.word _draw_button_save_opt
		.word _draw_button_load_opt

redraw_setting:
		lda SETTINGS_INDEX
		asl
		tay
		lda settings_renderers, y
		sta $00
		lda settings_renderers+1, y
		sta $01
		jmp ($0000)

enter_settings:
		write_nt "settings_nt_data"
		ldx #0
		lda #0
@nuke_sprites:
		sta $200, x
		inx
		bne @nuke_sprites
		stx SETTINGS_INDEX
		lda #1
		sta LDR_MODE
		ldx #12
@next:
		stx SETTINGS_INDEX
		txa
		pha
		jsr redraw_setting
		pla
		tax
		dex
		bpl @next
		rts



