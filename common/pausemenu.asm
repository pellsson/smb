.define UservarIndex0	WRAM_Temp+4
.define UservarIndex1	WRAM_Temp+6

CustomRow = WRAM_Temp+$10

.define MENU_ROW_LENGTH 16
.define MENU_ROW_COUNT 16

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
pm_hero_peach_row:
	.byte $24, " HERO  PEACH", $24, $24, $24

pm_show_rule_row:
	.byte $24, " SHOW  RULE ", $24, $24, $24
pm_show_sock_row:
	.byte $24, " SHOW  SOCK ", $24, $24, $24

pm_info_on_row:
	.byte $24, " INFO  ON   ", $24, $24, $24
pm_info_off_row:
	.byte $24, " INFO  OFF  ", $24, $24, $24

pm_input_on_row:
	.byte $24, " INPUT ON   ", $24, $24, $24
pm_input_off_row:
	.byte $24, " INPUT OFF  ", $24, $24, $24

pm_star_row:
	.byte $24, " GET STAR   ", $24, $24, $24

pm_slowmo_off_row:
	.byte $24, " SLOMO NONE ", $24, $24, $24

pm_slowmo_min_row:
	.byte $24, " SLOMO LOW  ", $24, $24, $24

pm_slowmo_mid_row:
	.byte $24, " SLOMO MID  ", $24, $24, $24

pm_slowmo_max_row:
	.byte $24, " SLOMO MAX  ", $24, $24, $24

pm_slowmo_adv_row:
	.byte $24, " SLOMO ADV  ", $24, $24, $24

pm_restart_row:
	.byte $24, " RESTART LEV", $24, $24, $24

pm_save_row:
	.byte $24, " SAVE STATE", $24, $24, $24
pm_load_row:
	.byte $24, " LOAD STATE", $24, $24, $24

pm_title_row:
	.byte $24, " EXIT TITLE ", $24, $24, $24
pm_intro_row:
	.byte $24, " EXIT INTRO ", $24, $24, $24


.macro row_render_data ppu, data
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
		row_render_data $23C8, pm_attr_data
		inc $07
		jsr draw_prepared_row
		row_render_data $2080, pm_empty_row
		rts

_draw_pm_row_1:
		lda PlayerStatus
		bne @check_is_fire
		row_render_data $20A0, pm_no_pup_row
		rts
	@check_is_fire:
		cmp #2
		beq @is_fire
		row_render_data $20A0, pm_super_pup_row
		rts
	@is_fire:
		row_render_data $20A0, pm_fire_pup_row
		rts

_draw_pm_row_2:
		row_render_data $20C0, pm_big_row
		lda PlayerSize
		beq @is_big
		row_render_data $20C0, pm_small_row
	@is_big:
		rts

_draw_pm_row_3:
		lda WRAM_IsContraMode
		beq @checkplayer
		row_render_data $20E0, pm_hero_peach_row
		rts
@checkplayer:
		row_render_data $20E0, pm_hero_mario_row
		lda CurrentPlayer
		beq @is_mario
		row_render_data $20E0, pm_hero_luigi_row
	@is_mario:
		rts

_draw_pm_row_4:
		row_render_data $23D0, pm_attr_data
		inc $07
		jsr draw_prepared_row
		row_render_data $2100, pm_show_sock_row
		lda WRAM_PracticeFlags
		and #PF_SockMode
		beq @is_sock
		row_render_data $2100, pm_show_rule_row
	@is_sock:
		rts

copy_user_row:
		ldx #(MENU_ROW_LENGTH - 1)
@copy_more:
		lda pm_empty_row, x
		sta CustomRow, x
		dex
		bpl @copy_more
		lda $02
		sta CustomRow+5
		lda $01
		and #$F
		sta CustomRow+$08
		lda $00
		and #$F0
		lsr
		lsr
		lsr
		lsr
		sta CustomRow+$09
		lda $00
		and #$0F
		sta CustomRow+$0A
		rts

_draw_pm_row_5:
		row_render_data $2120, pm_info_on_row
		lda WRAM_PracticeFlags
		and #PF_DisablePracticeInfo
		beq @info_on
		row_render_data $2120, pm_info_off_row
	@info_on:
		rts

_draw_pm_row_6:
		row_render_data $2140, pm_input_on_row
		lda WRAM_PracticeFlags
		and #PF_EnableInputDisplay
		bne @input_on
		row_render_data $2140, pm_input_off_row
	@input_on:
		rts

_draw_pm_row_7:
		lda BANK_SELECTED
		cmp #BANK_ORG
		beq @is_org
		lda WRAM_LostUser0
		ldx WRAM_LostUser0+1
		jmp @save
@is_org:
		lda WRAM_OrgUser0
		ldx WRAM_OrgUser0+1
@save:
		sta $00
		stx $01
		lda #$21 ; X
		sta $02
		jsr copy_user_row
		row_render_data $2160, CustomRow
		rts

_draw_pm_row_8:
		row_render_data $23D8, pm_attr_data
		inc $07
		jsr draw_prepared_row
		lda BANK_SELECTED
		cmp #BANK_ORG
		beq @is_org
		lda WRAM_LostUser1
		ldx WRAM_LostUser1+1
		jmp @save
@is_org:
		lda WRAM_OrgUser1
		ldx WRAM_OrgUser1+1
@save:
		sta $00
		stx $01
		lda #$22 ; Y
		sta $02
		jsr copy_user_row
		row_render_data $2180, CustomRow
		rts

_draw_pm_row_9:
		ldx WRAM_SlowMotion
		beq @off
		dex
		beq @min
		dex
		beq @mid
		dex
		beq @max
		row_render_data $21A0, pm_slowmo_adv_row
		rts
@max:
		row_render_data $21A0, pm_slowmo_max_row
		rts
@mid:
		row_render_data $21A0, pm_slowmo_mid_row
		rts
@min:
		row_render_data $21A0, pm_slowmo_min_row
		rts
@off:
		row_render_data $21A0, pm_slowmo_off_row
		rts

_draw_pm_row_10:
		row_render_data $21C0, pm_star_row
		rts

_draw_pm_row_11:
		row_render_data $21E0, pm_restart_row
		rts

_draw_pm_row_12:
		row_render_data $23E0, pm_attr_data
		inc $07
		jsr draw_prepared_row
		row_render_data $2200, pm_save_row
		rts

_draw_pm_row_13:
		row_render_data $2220, pm_load_row
		rts

_draw_pm_row_14:
		row_render_data $2240, pm_title_row
		rts

_draw_pm_row_15:
		row_render_data $2260, pm_intro_row
		rts

_draw_pm_row_16:
		row_render_data $2280, pm_empty_row
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
		.word _draw_pm_row_12
		.word _draw_pm_row_13
		.word _draw_pm_row_14
		.word _draw_pm_row_15
		.word _draw_pm_row_16

prepare_draw_row:
		asl ; *=2
		tay
		lda pm_row_initializers, y
		sta $00
		lda pm_row_initializers+1, y
		sta $01
		jmp ($0000)

draw_prepared_row:
		lda $00
	pha
		lda Mirror_PPU_CTRL_REG1
		ldx BANK_SELECTED
		cpx #BANK_ORG
		beq @okok
        lda UseNtBase2400
@okok:
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
		sta WRAM_LevelPlayerStatus
		lda PlayerSize
		sta WRAM_LevelPlayerSize
		rts

pm_toggle_powerup:
		lda PlayerStatus
		cmp #2
		bne @solve_state
		ldx #1
		stx PlayerSize
		dex
		stx PlayerStatus
		jmp @redraw_and_save
@solve_state:
		ldx #0
		ldy #1
		cmp #1
		bne @fire_or_big
		iny
@fire_or_big:
		stx PlayerSize
		sty PlayerStatus
@redraw_and_save:
		lda #2
		jsr draw_menu_row_from_a
		jsr RedrawMario
		jmp playerstatus_to_savestate

pm_toggle_size:
		lda PlayerSize
		eor #1
		sta PlayerSize
		jsr RedrawMario
		jmp playerstatus_to_savestate

pm_toggle_hero:
		lda WRAM_IsContraMode
		beq @okchange
		rts
@okchange:
		lda CurrentPlayer
		eor #1
		sta CurrentPlayer
		jsr LL_UpdatePlayerChange
		jmp RedrawMario

pm_toggle_show:
		lda WRAM_PracticeFlags
		eor #PF_SockMode
		sta WRAM_PracticeFlags
		and #PF_SockMode
		beq @SockMode
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

pm_toggle_info:
		lda WRAM_PracticeFlags
		eor #PF_DisablePracticeInfo
		sta WRAM_PracticeFlags
		and #PF_DisablePracticeInfo
		beq @keepinfo
		;
		; Blank out practice info if practice info is disabled
		;
		ldx VRAM_Buffer1_Offset
		lda #$20
		sta VRAM_Buffer1,x
		lda #$62 ; addr
		sta VRAM_Buffer1+1,x
		lda #$0e ; len
		sta VRAM_Buffer1+2,x
		lda #$24 ; blank
		sta VRAM_Buffer1+3, x
		sta VRAM_Buffer1+4, x
		sta VRAM_Buffer1+5, x
		sta VRAM_Buffer1+6, x
		sta VRAM_Buffer1+7, x
		sta VRAM_Buffer1+8, x
		sta VRAM_Buffer1+9, x
		sta VRAM_Buffer1+10, x
		sta VRAM_Buffer1+11, x
		sta VRAM_Buffer1+14, x
		sta VRAM_Buffer1+15, x
		sta VRAM_Buffer1+16, x
		lda #$2e ; coin icon
		sta VRAM_Buffer1+12, x
		lda #$29 ; cross symbol
		sta VRAM_Buffer1+13, x
		lda #$00
		sta VRAM_Buffer1+17, x
		lda VRAM_Buffer1_Offset
		clc
		adc #$11
		sta VRAM_Buffer1_Offset
		rts
@keepinfo:
		ldx VRAM_Buffer1_Offset
		lda #$20
		sta VRAM_Buffer1,x
		lda #$69 ; addr
		sta VRAM_Buffer1+1,x
		lda #$01 ; len
		sta VRAM_Buffer1+2,x
		lda WRAM_EntrySockTimer
		sta VRAM_Buffer1+3, x
		lda #$00
		sta VRAM_Buffer1+4, x
		lda VRAM_Buffer1_Offset
		clc
		adc #$04
		sta VRAM_Buffer1_Offset
        jmp RedrawFrameNumbersInner

pm_toggle_input:
		lda WRAM_PracticeFlags
		eor #PF_EnableInputDisplay
		sta WRAM_PracticeFlags
		and #PF_EnableInputDisplay
		bne @inputon
		;
		; If we disable input display, restore " X   Y " text
		;
		ldx VRAM_Buffer1_Offset
		lda #$20
		sta VRAM_Buffer1,x
		lda #$51 ; addr
		sta VRAM_Buffer1+1,x
		lda #$07 ; len
		sta VRAM_Buffer1+2,x
		lda #$24 ; blank
		sta VRAM_Buffer1+3, x
		sta VRAM_Buffer1+5, x
		sta VRAM_Buffer1+6, x
		sta VRAM_Buffer1+7, x
		sta VRAM_Buffer1+9, x
		lda #$21 ; X
		sta VRAM_Buffer1+4, x
		lda #$22 ; Y
		sta VRAM_Buffer1+8, x
		lda #$00
		sta VRAM_Buffer1+10, x
		lda VRAM_Buffer1_Offset
		clc
		adc #$0a
		sta VRAM_Buffer1_Offset
@inputon:
        rts


pm_slowmo:
		ldx WRAM_SlowMotion
		inx
		cpx #5
		bne @good
		ldx #0
@good:
		stx WRAM_SlowMotion
		rts

pm_give_star:
		lda #$FF
		sta StarInvincibleTimer
		lda #StarPowerMusic
		sta AreaMusicQueue
		rts

pm_low_user:
		jsr get_user_selected
		lda ($00), y
		clc
		adc #1
		and #$0F
		sta $03
		lda ($00), y
		and #$F0
		ora $03
		sta ($00), y
		rts

pm_restart_level:
		jmp RequestRestartLevel

pm_exit_intro:
		lda #BANK_LOADER
		jmp StartBank

pm_exit_title:
		lda BANK_SELECTED
		jmp StartBank

pm_no_activation:
		rts

pm_save_state:
		jmp begin_save

pm_load_state:
		jmp begin_load

pm_activation_slots:
		.word pm_toggle_powerup
		.word pm_toggle_size
		.word pm_toggle_hero
		.word pm_toggle_show
		.word pm_toggle_info
		.word pm_toggle_input
		.word pm_low_user ; user
		.word pm_low_user ;
		.word pm_slowmo
		.word pm_give_star
		.word pm_restart_level
		.word pm_save_state
		.word pm_load_state
		.word pm_exit_title
		.word pm_exit_intro
		
pause_run_activation:
		lda WRAM_MenuIndex
		asl
		tay
		lda pm_activation_slots, y
		sta $00
		lda pm_activation_slots+1, y
		sta $01
		jmp ($0000)

draw_menu_row_from_a:
		jsr prepare_draw_row
		lda #0
		sta $07
		jmp draw_prepared_row

pause_menu_activate:
		jsr pause_run_activation
		ldx WRAM_MenuIndex
		inx
		txa
		jmp draw_menu_row_from_a

get_user_selected:
		ldx WRAM_MenuIndex
		lda BANK_SELECTED
		cmp #BANK_ORG
		beq @is_org
		cpx #6
		bne @is_0
		lda #<WRAM_LostUser0
		ldx #>WRAM_LostUser0
		jmp @save
@is_0:
		lda #<WRAM_LostUser1
		ldx #>WRAM_LostUser1
		jmp @save
@is_org:
		cpx #6
		beq @is_org_0
		lda #<WRAM_OrgUser1
		ldx #>WRAM_OrgUser1
		jmp @save
@is_org_0:
		lda #<WRAM_OrgUser0
		ldx #>WRAM_OrgUser0
@save:
		sta $00
		stx $01
		ldy #0
		rts

do_uservar_input:
		lda SavedJoypad1Bits
		cmp #Left_Dir
		bne @check_right
		jsr get_user_selected
		iny
		lda ($00), y
		clc
		adc #1
		and #7
		sta ($00), y
		jmp @redraw
@check_right:
		cmp #Right_Dir
		bne @exit
		jsr get_user_selected
		lda ($00), y
		clc
		adc #$10
		and #$F0
		sta $03
		jsr get_user_selected
		lda ($00), y
		and #$0F
		ora $03
		sta ($00), y
@redraw:
		ldx WRAM_MenuIndex
		inx
		txa
		jmp draw_menu_row_from_a
@exit:
		rts


RunPauseMenu:
		and #$1F
		beq @draw_cursor
	pha
		sta $0
		lda #MENU_ROW_COUNT
		sec
		sbc $0
		jsr prepare_draw_row
		lda #0
		sta $07
		jsr draw_prepared_row
	pla
		sec
		sbc #1
		asl
		asl
		sta $00
		lda GamePauseStatus
		and #$81
		ora $00
		sta GamePauseStatus
		rts
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

		lda LastInputBits
		bne @no_input
		lda SavedJoypad1Bits
		ora JoypadBitMask
		cmp LastInputBits
		bne @input_changed
@no_input:
		rts
@input_changed:
		cmp #Select_Button
		bne @check_down
@move_cursor_down:
		ldx WRAM_MenuIndex
		inx
		cpx #MENU_ROW_COUNT-1
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
		cpx #0
		bpl @no_wrap_up
		ldx #MENU_ROW_COUNT-2
@no_wrap_up:
		jmp @save_exit
@check_a:
		and #A_Button
		beq @exit
		jmp pause_menu_activate
@save_exit:
		stx WRAM_MenuIndex
@exit:
		ldx WRAM_MenuIndex
		cpx #6
		bcc @doneso
		cpx #8
		bcs @doneso ;6-7
		jmp do_uservar_input
@doneso:
		rts

PauseMenu:
		lda GamePauseStatus
		lsr
		bcc @not_paused
		lsr
		jsr RunPauseMenu
		jmp @continue
@not_paused:
		lda WRAM_Timer+1
		bmi @continue
		inc WRAM_Timer
		bne @continue
		inc WRAM_Timer+1
@continue:
		ldx GamePauseTimer
		beq @pause_ready
		dex
		stx GamePauseTimer
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
		bcc @exit
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
		lda #0
		sta UservarIndex0
		sta UservarIndex1
		lda GamePauseStatus
		ora #MENU_ROW_COUNT<<2
		sta GamePauseStatus
		lsr
		lsr
		jmp RunPauseMenu
@clear_legacy:
		lda GamePauseStatus
		and #$7f
		sta GamePauseStatus
@exit:
		rts




