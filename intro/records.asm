;
; https://wiki.nesdev.com/w/index.php/16-bit_BCD
;
BCD_BITS = 19
bcdNum = 0
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
  .byt <10, <20, <40, <80
  .byt <100, <200, <400, <800
  .byt <1000, <2000, <4000, <8000
  .byt <10000, <20000, <40000

bcdTableHi:
  .byt >10, >20, >40, >80
  .byt >100, >200, >400, >800
  .byt >1000, >2000, >4000, >8000
  .byt >10000, >20000, >40000


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
		.byte "SUPER MARIO BROS.        "
		.byte 0
lost_name:
		.byte "SMB 2 THE LOST LEVELS    "
		.byte 0
ext_name:
		.byte "SMB 2 THE LOST LEVELS EXT"
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

redraw_all_records:
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
		cpy #8
		bne @next_world

		ldx #0
		ldy #4*4*2
		lda RECORDS_MODE
		cmp #2
		bne @not_ext
@not_ext:
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
		bne @use_lost
		lda WRAM_OrgTimes+1, x
		tay
		lda WRAM_OrgTimes, x
		tax
		jmp @render_it
@use_lost:
		lda WRAM_LostTimes+1, x
		tay
		lda WRAM_LostTimes, x
		tax
@render_it:
		jsr redraw_time

	pla
		tay
	pla
		tax
		inx
		inx
		dey
		bne @more

		rts

records_attr:
		.incbin "nss/records_attr.bin"

clear_screen:
		lda #$24
@clear_more:
		sta $2007
		dex
		bne @clear_more
		rts

screen_off:
		ldx PPU_STATUS	; Read PPU status to reset the high/low latch
		ldx #$00
		stx PPU_SCROLL_REG ; No scrolling
		stx PPU_SCROLL_REG
		stx PPU_CTRL_REG2 ; No rendering
		stx PPU_CTRL_REG1 ; No NMI
		rts

enter_records:
		jsr screen_off

		ldx #0
		lda #0
@nuke_sprites:
		sta $200, x
		inx
		bne @nuke_sprites

		lda #$20
		sta $2006
		lda #$00
		sta $2006

		ldx #0
		jsr clear_screen
		jsr clear_screen
		jsr clear_screen
		ldx #$C0
		jsr clear_screen
		;
		; Now points to attr, just copy
		;
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

run_records:
		lda SavedJoypadBits
		cmp LAST_INPUT
		beq exit_out

		ldx RECORDS_MODE
		cmp #Left_Dir
		beq @go_left
		cmp #Right_Dir
		beq @go_right
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
		jsr redraw_all_records
		rts




