;
; https://wiki.nesdev.com/w/index.php/16-bit_BCD
;
BCD_BITS = 19
; bcdNum = 0
bcdResult = 2
curDigit = 7
b = 2

bcdConvert:
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


draw_digit:
	pha
		lsr
		lsr
		lsr
		lsr
		sta $2007
	pla
		and #$0F
		sta $2007
		rts

redraw_time:
		stx bcdNum
		sty bcdNum+1

		jsr Enter_FrameToTime

		lda WRAM_PrettyTimeMin
		and #$0F
		sta $2007
		lda #$28
		sta $2007

		lda WRAM_PrettyTimeSec
		jsr draw_digit
		lda #$2A
		sta $2007

		lda WRAM_PrettyTimeFrac
		jsr draw_digit
		lda #$29
		sta $2007

		jsr bcdConvert
		ldx #4
@writeframe:
		lda bcdResult,x
		sta $2007
		dex
		bpl @writeframe
		rts

ppu_record_vram:
		.word $20C2, $20E2, $2102, $2122
		.word $2182, $21A2, $21C2, $21E2
		.word $2242, $2262, $2282, $22A2
		.word $2302, $2322, $2342, $2362
		.word $20D1, $20F1, $2111, $2131
		.word $2191, $21B1, $21D1, $21F1
		.word $2251, $2271, $2291, $22B1
		.word $2311, $2331, $2351, $2371


ppu_world_titles:
		.word $20A2, $2162, $2222, $22E2                      
		.word $20B1, $2171, $2231, $22F1

game_names:
		.word org_name
		.word lost_name
		.word ext_name
org_name:
		.byte "SUPER MARIO BROS.         "
		.byte 0
lost_name:
		.byte "SMB 2: THE LOST LEVELS    "
		.byte 0
ext_name:
		.byte "SMB 2: THE LOST LEVELS EXT"
		.byte 0

world_string:
		.byte "WORLD "

print_cstring:
		ldy #0
@next_title:
		lda ($00), y
		beq @done_w_title
		iny
		sta $2007
		jmp @next_title
@done_w_title:
		rts

song_table:
	.byte 4, 0, 2

redraw_all_records:
		;ldx RECORDS_MODE
		;lda song_table, x
		;ldx #0
		;jsr fax_load_song
		lda PPU_STATUS
		ldy #$03
		ldx #$C0
		lda #$20
		sta $2006
		lda #$00
		sta $2006
		lda #$24
@clear_inner:
		sta $2007
		dex
		bne @clear_inner
		dey
		bpl @clear_inner


		lda PPU_STATUS ; Latch
		lda #$20
		sta $2006
		lda #$42
		sta $2006
		lda RECORDS_MODE
		asl
		tax
		lda game_names, x
		sta $00
		lda game_names+1, x
		sta $01
		jsr print_cstring

		ldx #0
		ldy #0
		lda #8
		sta $01

		lda RECORDS_MODE
		cmp #2
		bne @next_world
		ldy #8
		lda #$0D
		sta $01
@next_world:
		lda ppu_world_titles+1, x
		sta $2006
		lda ppu_world_titles, x
		sta $2006
		stx $00
		ldx #0
@copy_world:
		lda world_string, x
		sta $2007
		inx
		cpx #6
		bne @copy_world
		iny
		sty $2007
		ldx $00
		inx
		inx
		cpy $01
		bne @next_world

		ldx #0
		ldy #8*4
		lda RECORDS_MODE
		cmp #2
		bne @more
		ldy #5*4
@more:
		lda PPU_STATUS ; Latch
		lda ppu_record_vram+1, x
		sta $2006
		lda ppu_record_vram, x
		sta $2006
		txa
	pha
		tya
	pha
		lda RECORDS_MODE
		bne @is_lost
		lda WRAM_OrgTimes+1, x
		tay
		lda WRAM_OrgTimes, x
		tax
		jmp @render_it
@is_lost:
		cmp #2
		beq @is_ext
		lda WRAM_LostTimes+1, x
		tay
		lda WRAM_LostTimes, x
		tax
		jmp @render_it
@is_ext:
		lda WRAM_LostTimes+(8*4*2)+1,x
		tay
		lda WRAM_LostTimes+(8*4*2), x
		tax
@render_it:
		jsr redraw_time
	pla
		tay
	pla
		tax
		inx
		inx
		jsr hack_update_music
		dey
		bne @more
		rts

hack_update_music:
	stx $00
	sty $01
	sta $02
		tya
		and #3
		bne @no_update
		jsr fax_update		
@no_update:
	ldx $00
	ldy $01
	lda $02
		rts

records_attr:
		.incbin "nss/records_attr.bin"

records_palette:
		.byte $0F, $30, $0f, $0f
		.byte $0F, $16, $0f, $0f
		.byte $0F, $11, $0f, $0f
		.byte $0F, $27, $0f, $0f
enter_records:
		jsr screen_off
		; Load sound
		lda #4
		ldx #0
		jsr fax_load_song
		;
		; Retarded.
		;
		lda PPU_STATUS
		lda #$3F
		sta $2006
		lda #$00
		sta $2006
		ldy #$10
		ldx #$00
@more_pal:
		lda records_palette, x
		sta $2007
		inx
		dey
		bne @more_pal

		ldx #0
		lda #0
@nuke_sprites:
		sta $200, x
		inx
		bne @nuke_sprites

		lda #$23
		sta $2006
		lda #$C0
		sta $2006

@copy_more:
		lda records_attr, x
		sta $2007
		inx
		cpx #$40
		bne @copy_more

		lda #0
		sta RECORDS_MODE

		jsr redraw_all_records

		lda #2
		sta LDR_MODE
exit_out:
		rts

exit_records:
		jmp enter_loader

run_records:
		lda WRAM_DisableMusic
		bne @nosound
		jsr fax_update
@nosound:
		lda SavedJoypadBits
		cmp LAST_INPUT
		beq exit_out

		ldx RECORDS_MODE
		cmp #Left_Dir
		beq @go_left
		cmp #Right_Dir
		beq @go_right
		cmp #Start_Button
		beq exit_records
		rts
@go_right:
		inx
		inx
@go_left:
		dex
		bmi @wrap_up
		cpx #3
		bne @save_mode
		ldx #0
		beq @save_mode
@wrap_up:
		ldx #2
@save_mode:
		stx RECORDS_MODE
		jsr screen_off
		jmp redraw_all_records




