;
; This hack is just inlined into intro.asm
;
SETTINGS_MENU_PPU = $1FF3
MAX_SETTING = 14

.macro draw_simple_at at, txt
		.local @copy
		.local @s
		lda PPU_STATUS
		lda #>(SETTINGS_MENU_PPU + (at * $20))
		sta PPU_ADDRESS
		lda #<(SETTINGS_MENU_PPU + (at * $20))
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
		lda #>(SETTINGS_MENU_PPU + (at * $20))
		sta PPU_ADDRESS
		lda #<(SETTINGS_MENU_PPU + (at * $20))
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
		lda #>(SETTINGS_MENU_PPU + (at * $20))
		sta PPU_ADDRESS
		lda #<(SETTINGS_MENU_PPU + (at * $20))
		sta PPU_ADDRESS
	pla
		jmp draw_buttons
.endmacro

.macro add_button v
		ldy #v
		sty PPU_DATA
		ldy #$24
		sty PPU_DATA
		inx
.endmacro

draw_buttons:
		ldx #0
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
		ror
		bcc @finalize
		add_button 'A'
@finalize:
		cpx #4
		bpl @done
		add_button ' '
		jmp @finalize
@done:
		rts

_music_on: draw_simple_at 6, "ON "
_music_off: draw_simple_at 6, "OFF"

_draw_music_opt:
		lda WRAM_DisableMusic
		beq @on
		jmp _music_off
@on:
		jmp _music_on

_sound_on: draw_simple_at 7, "ON "
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
_char_org: draw_simple_at 14, "ORG   "
_char_lost: draw_simple_at 14, "LOST  "

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

_draw_reset_records_opt:
		draw_simple_at 19, "NO ORG LL EXT"

_draw_reset_wram_opt:
		draw_simple_at 20, "NO YES"


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
		.word _draw_reset_records_opt
		.word _draw_reset_wram_opt

redraw_setting:
		lda SETTINGS_INDEX
		asl
		tay
		lda settings_renderers, y
		sta $00
		lda settings_renderers+1, y
		sta $01
		jmp ($0000)

set_selection_sprites:
		ldy #(8*4)-1
		lda #$fe
@zero_more:
		sta $204, y
		dey
		bpl @zero_more
		
		lda SETTINGS_INDEX
		asl ; *=2
		asl ; *=4
		asl ; *=8
		clc
		adc #$27
		sta $01

		lda SETTINGS_X
		asl ; *=2
		asl ; *=4
		asl ; *=8
		clc
		adc #152
		sta $00
		ldy #4
@set_more:
		lda $01
		sta $204, y
		lda #$0D
		sta $205, y
		lda #$20
		ora SETTINGS_ATTR
		sta $206, y
		lda $00
		sta $207, y
		clc
		adc #8
		sta $00
		iny
		iny
		iny
		iny
		dex
		bne @set_more

		rts

_select_music:
		ldx #2
		lda WRAM_DisableMusic
		beq @on
		inx ; OFF
@on:
		jmp set_selection_sprites

_select_sound:
		ldx #2
		lda WRAM_DisableSound
		beq @on
		inx ; OFF
@on:
		jmp set_selection_sprites

_select_value:
		ldx #1
		jmp set_selection_sprites

_select_charset:
		ldx #6
		lda WRAM_CharSet
		beq @draw
		cmp #1
		beq @draw_org
		ldx #4
		jmp set_selection_sprites
@draw_org:
		ldx #3
@draw:
		jmp set_selection_sprites

select_buttons:
		ldx #7
		cmp #0
		beq @unbound
		ldx #1
@unbound:
		jmp set_selection_sprites

_select_retry_buttons:
		lda WRAM_RestartButtons
		jmp select_buttons

_select_title_buttons:
		lda WRAM_TitleButtons
		jmp select_buttons

_select_save_buttons:
		lda WRAM_SaveButtons
		jmp select_buttons

_select_load_buttons:
		lda WRAM_LoadButtons
		jmp select_buttons

_select_reset_wram:
		ldx #2
		lda SETTINGS_X
		beq @no
		inx
@no:
		jmp set_selection_sprites

_select_reset_records:
		; NO ORG LL EXT
		jsr get_setting_idx
		txa
		ldx #2
		and #1
		beq @is_two
		inx
@is_two:
		jmp set_selection_sprites

select_option:
		.word _select_music
		.word _select_sound
		.word _select_value
		.word _select_value
		.word _select_value
		.word _select_value
		.word _select_value
		.word _select_value
		.word _select_charset
		.word _select_retry_buttons
		.word _select_title_buttons
		.word _select_save_buttons
		.word _select_load_buttons
		.word _select_reset_records
		.word _select_reset_wram

selection_changed:
		lda #0
		sta SETTINGS_X
redraw_selection:
		lda SETTINGS_INDEX
		asl
		tay
		lda select_option, y
		sta $00
		lda select_option+1, y
		sta $01
		jmp ($0000)

settings_pal:
		.byte $0f, $33, $0f, $0f ; Title
		.byte $0f, $3a, $0f, $0f ; Options
		.byte $0f, $0f, $0f, $0f ; Unused
		.byte $0f, $30, $10, $30 ; Values
		;
		;
		;
		.byte $0f, $0f, $17, $0f ; Selection
		.byte $0f, $0f, $28, $0f ; Flash
		.byte $0f, $0f, $0f, $0f ; Unused
		.byte $0f, $0f, $0f, $0f ; Unused

enter_settings:
		lda #0
		sta SND_MASTERCTRL_REG
		write_nt "settings_data"
		ldx #0
		lda #0
@nuke_sprites:
		sta $200, x
		inx
		bne @nuke_sprites
		stx SETTINGS_INDEX
		;
		; Copy palette
		;
		lda PPU_STATUS ; Latch
		lda #$3F
		sta PPU_ADDRESS
		ldx #$00
		stx PPU_ADDRESS
@copypal:
		lda settings_pal, x
		sta PPU_DATA
		inx
		cpx #$20
		bne @copypal

		lda #1
		sta LDR_MODE
		ldx #MAX_SETTING
@next:
		stx SETTINGS_INDEX
		txa
		pha
		jsr redraw_setting
		pla
		tax
		dex
		bpl @next
		jmp selection_changed

_music_input:
		and #(B_Button|A_Button)
		beq @nope
		lda WRAM_DisableMusic
		eor #1
		sta WRAM_DisableMusic
@nope:
		rts

_sound_input:
		and #(B_Button|A_Button)
		beq @nope
		lda WRAM_DisableSound
		eor #1
		sta WRAM_DisableSound
@nope:
		rts

_user_input:
		cmp #Right_Dir
		bne @checkleft
		ldx SETTINGS_X
		inx
		cpx #3
		bne @saveright
		ldx #0
@saveright:
		stx SETTINGS_X
		rts
@checkleft:
		cmp #Left_Dir
		bne @checkab
		ldx SETTINGS_X
		dex
		bpl @saveleft
		ldx #2
@saveleft:
		stx SETTINGS_X
		rts
@checkab:
		and #(B_Button|A_Button)
		beq @nothing
		lda #$11
		sta $03
		lda SavedJoypadBits
		and #B_Button
		bne @incit
		lda #$ff
		sta $03
@incit:
		jsr get_uservar_ptr
		ldy #0
		ldx SETTINGS_X
		beq @hibyte
		dex
		beq @hinibble
		lda ($00), Y
		clc
		adc $03
		and #$0F
		sta $03
		lda ($00), Y
		and #$F0
		ora $03
		sta ($00), Y
@hinibble:
		lda $03
		and #$F0
		clc
		adc ($00), Y
		sta ($00), Y
@nothing:
		rts
@hibyte:
		iny
		lda ($00), Y
		clc
		adc $03
		and #$7
		sta ($00), Y
		rts

byte_input:
		lda SavedJoypadBits
		and #(Left_Dir|Right_Dir)
		beq @checkab
		lda SETTINGS_X
		eor #1
		sta SETTINGS_X
@nothing:
		rts
@checkab:
		ldy #0
		lda SavedJoypadBits
		cmp #B_Button
		bne @checka
		lda #$11
		bne @do
@checka:
		cmp #A_Button
		bne @nothing
		lda #$FF
@do:
		sta $03
		lda SETTINGS_X
		beq @hinibble
		lda $03
		clc
		adc ($00), Y
		and #$0F
		sta $03
		lda ($00), Y
		and #$F0
		ora $03
		sta ($00), Y
		rts
@hinibble:
		lda $03
		and #$F0
		clc
		adc ($00), Y
		sta ($00), Y
		rts


_drawdelay_input:
		lda #<WRAM_DelayUserFrames
		sta $00
		lda #>WRAM_DelayUserFrames
		sta $01
		jmp byte_input

_savedelay_input:
		lda #<WRAM_DelaySaveFrames
		sta $00
		lda #>WRAM_DelaySaveFrames
		sta $01
		jmp byte_input

_charset_input:
		and #(B_Button|A_Button)
		beq @nothing
		ldx WRAM_CharSet
		inx
		cpx #3
		bne @save
		ldx #0
@save:
		stx WRAM_CharSet
@nothing:
		rts

recordbuttons_input:
		ldx RECORD_BUTTONS
		beq @normalinput
		dec RECORD_FRAMES
		beq @savebuttons
		lda RECORD_FRAMES
		and #7
		bne @nothing
		lda SETTINGS_ATTR
		eor #1
		sta SETTINGS_ATTR
		rts
@savebuttons:
		ldy #0
		sty RECORD_BUTTONS
		sty SETTINGS_ATTR
		lda SavedJoypadBits
		and #(Start_Button^$ff)
		sta ($00), Y
		rts
@normalinput:
		lda SavedJoypadBits
		cmp #B_Button
		bne @checka
		lda #0
		ldy #0
		sta ($00), Y
@nothing:
		rts
@checka:
		cmp #A_Button
		bne @nothing
		inc RECORD_BUTTONS
		lda #120
		sta RECORD_FRAMES
		rts
		
_retrybuttons_input:
		lda #<WRAM_RestartButtons
		sta $00
		lda #>WRAM_RestartButtons
		sta $01
		jmp recordbuttons_input

_titlebuttons_input:
		lda #<WRAM_TitleButtons
		sta $00
		lda #>WRAM_TitleButtons
		sta $01
		jmp recordbuttons_input

_savebuttons_input:
		lda #<WRAM_SaveButtons
		sta $00
		lda #>WRAM_SaveButtons
		sta $01
		jmp recordbuttons_input

_loadbuttons_input:
		lda #<WRAM_LoadButtons
		sta $00
		lda #>WRAM_LoadButtons
		sta $01
		jmp recordbuttons_input

records_offsets:
		.byte $00, $03, $07, $0A

get_setting_idx:
		ldx SETTINGS_X
		beq @done
		cpx #3
		bne @not_one
		ldx #1
		rts
@not_one:
		cpx #7
		bne @not_two
		ldx #2
		rts
@not_two:
		ldx #3
@done:
		rts

ResetRecords:
		jsr get_setting_idx
		beq @nope
		dex
		bne @not_org
		lda #<WRAM_OrgTimes
		sta $00
		lda #>WRAM_OrgTimes
		sta $01
		ldx #(WRAM_OrgTimesEnd-WRAM_OrgTimes)
		bne @memset
@not_org:
		dex
		bne @not_ll
		lda #<WRAM_LostTimes
		sta $00
		lda #>WRAM_LostTimes
		sta $01
		ldx #(WRAM_LostTimesEnd-WRAM_LostTimes)
		bne @memset
@not_ll:
		dex
		bne @nope ; this is fucked
		lda #<WRAM_ExtTimes
		sta $00
		lda #>WRAM_ExtTimes
		sta $01
		ldx #(WRAM_ExtTimesEnd-WRAM_ExtTimes)
@memset:
		ldy #0
		lda #0
@memset_next:
		sta ($00),y
		iny
		dex
		bne @memset_next
		pla
		pla ; Ghetto. We should have the intro properly copy data to the screen :()
@nope:
		rts

_reset_records_input:
		lda SavedJoypadBits
		and #(Left_Dir|Right_Dir)
		beq @checkab
		jsr get_setting_idx
		cmp #Left_Dir
		bne @not_left
		dex
		bpl @set_selection
		ldx #3
		bne @set_selection ; jmp
@not_left:
		inx
		cpx #4
		bne @set_selection
		ldx #0
@set_selection:
		lda records_offsets, x
		sta SETTINGS_X
@done:
		rts
@checkab:
		lda SavedJoypadBits
		and #(B_Button|A_Button)
		beq @done
		jmp ResetRecords

_reset_wram_input:
		lda SavedJoypadBits
		and #(Left_Dir|Right_Dir)
		beq @checkab
		lda SETTINGS_X
		eor #3
		sta SETTINGS_X
@checkab:
		lda SETTINGS_X
		beq @nothing
		lda SavedJoypadBits
		and #(B_Button|A_Button)
		beq @nothing
		jsr Enter_FactoryResetWRAM
		pla
		pla ; Ghetto-attack
		jmp enter_loader
@nothing:
		rts

option_inputs:
		.word _music_input
		.word _sound_input
		.word _user_input
		.word _user_input
		.word _user_input
		.word _user_input
		.word _drawdelay_input
		.word _savedelay_input
		.word _charset_input
		.word _retrybuttons_input
		.word _titlebuttons_input
		.word _savebuttons_input
		.word _loadbuttons_input
		.word _reset_records_input
		.word _reset_wram_input

dispatch_input:
		lda SETTINGS_INDEX
		asl
		tay
		lda option_inputs, y
		sta $00
		lda option_inputs+1, y
		sta $01
		lda SavedJoypadBits
		jmp ($0000)

run_option_inputs:
		jsr dispatch_input
		jsr redraw_setting
		jmp redraw_selection
noinput:
		rts

exit_settings:
		ldx #1
		lda WRAM_DelayUserFrames
		bne @user_frames_ok
		stx WRAM_DelayUserFrames
@user_frames_ok:
		lda WRAM_DelaySaveFrames
		bne @save_frames_ok
		stx WRAM_DelaySaveFrames
@save_frames_ok:
		jmp enter_loader

run_settings:
		lda RECORD_BUTTONS
		bne @recordonly
		lda SavedJoypadBits
		cmp LAST_INPUT
		beq noinput
		cmp #Start_Button
		beq exit_settings
		cmp #Up_Dir
		bne @check_down
		dec SETTINGS_INDEX
		bpl @newsel
		lda #MAX_SETTING
		sta SETTINGS_INDEX
		jmp @newsel
@check_down:
		cmp #Select_Button
		beq @go_down
		cmp #Down_Dir
		beq @go_down
@recordonly:
		jmp run_option_inputs
@go_down:
		inc SETTINGS_INDEX
		lda SETTINGS_INDEX
		cmp #(MAX_SETTING+1)
		bmi @newsel
		lda #0
		sta SETTINGS_INDEX
@newsel:
		jmp selection_changed

