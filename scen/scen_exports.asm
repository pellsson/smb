	.export ScenLoadArea
	.export ScenReset
	.export ScenUpdateSelected
	.export ScenValidate

;
; Appended to fpg_data.asm
;
fpg_offset_to_y:
		lda FpgSelected
		asl
		asl
		asl
		asl
		tay
		rts

fpg_validate:
		jsr fpg_offset_to_y
fpg_validate_unsafe:
		lda fpg_validate_func, y
		sta $0
		lda fpg_validate_func+1, y
		sta $1
		jmp ($0)

fpg_load_area:
		jsr fpg_offset_to_y
		lda fpg_load_area_func, y
		sta $0
		lda fpg_load_area_func+1, y
		sta $1
		jmp ($0)

fpg_reset:
		jsr fpg_offset_to_y
		lda fpg_reset_func, y
		sta $0
		lda fpg_reset_func+1, y
		sta $1
		jmp ($0)

fpg_update_selected:
		lda FpgSelected
		cmp #0
		bmi fpg_negative_sel
		cmp fpg_num_configs
		bmi fpg_render_it
		lda #$0
		sta FpgSelected
		jmp fpg_render_it ; beq
fpg_negative_sel:
		ldx fpg_num_configs
		dex
		stx FpgSelected
fpg_render_it:
		jsr fpg_offset_to_y
		lda #8
		sta $0
fpg_copy_more:
		lda fpg_configs, y
		sta VRAM_Buffer1+3, x
		inx
		iny
		dec $0
		bne fpg_copy_more
		rts
;
; 
;
fpg_check_true_over:
		lda FpgFlags
		and #$20
		beq fpg_not_locked
		lda #0
		rts
fpg_not_locked:
		lda FpgSelected
		asl
		asl
		asl
		asl
		tay
		lda fpg_num_routes, y
		inc FpgRuleset
		cmp FpgRuleset
		rts
;
; On bad x
;
fpg_failed_pos_x:
		jsr fpg_check_true_over
		beq fpg_game_over_x
		jmp fpg_validate_unsafe
fpg_game_over_x:
		ldx #$01
		jmp fpg_set_death_flag
;
; On bad y
;
fpg_failed_pos_y:
		jsr fpg_check_true_over
		beq fpg_game_over_y
		jmp fpg_validate_unsafe
fpg_game_over_y:
		ldx #$02
		jmp fpg_set_death_flag
;
; On bad input
;
fpg_failed_input:
		sta FpgErrorParam
		jsr fpg_check_true_over
		beq fpg_game_over_input
		jmp fpg_validate_unsafe
fpg_game_over_input:
		ldx #$3
fpg_set_death_flag:
		stx FpgError
		lda FpgFlags
		ora #$80
		sta FpgFlags
		rts
;
; Victory!
;
fpg_win:
		lda #VictoryMusic
		sta EventMusicQueue
		ldx #$04
		jmp fpg_set_death_flag

ScenLoadArea:
	jsr fpg_load_area
	jmp ReturnBank

ScenReset:
	jsr fpg_reset
	jmp ReturnBank

ScenUpdateSelected:
	jsr fpg_update_selected
	jmp ReturnBank

ScenValidate:
	jsr fpg_validate
	jmp ReturnBank

Start:
NonMaskableInterrupt:

scenarios_callgate
control_bank

