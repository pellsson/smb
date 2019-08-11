
; ???
		.byte $16
		.byte $A
		.byte $1B
		.byte $12
		.byte $18
		.byte $15
		.byte $1E
		.byte $12
		.byte $10
		.byte $12
		.byte $A9
		.byte 0
		.byte $8D
		.byte $3C
		.byte 7
		.byte $A2
		.byte 4
		.byte $AD
		.byte $53
		.byte 7
		.byte $F0
		.byte 2
		.byte $A2
		.byte 9
		.byte $A0
		.byte 4
		.byte $BD
		.byte $4E
		.byte $C8
		.byte $99
		.byte $A0
		.byte $C8
		.byte $99
		.byte $E5
		.byte $C8
		.byte $CA
		.byte $88
		.byte $10
		.byte $F3
		.byte $60




AlternateSoundEngine:
		lda GamePauseStatus
		beq loc_CC6E
		lda #$80
		sta SND_VOLENV_REG
		lsr
		sta unk_4015
		rts
loc_CC6E:
		lda #$FF
		sta unk_4017
		lda #$F
		sta unk_4015
		jsr unk_D54C ; sub_D54C << INSIDE LL-SOUND
		jsr sub_CC88
		lda #0
		sta AreaMusicQueue
		sta Square2SoundQueue
		rts
loc_CC85:
		jmp loc_CD01
sub_CC88:
		lda AreaMusicQueue
		bne loc_CC92
		lda byte_608
		bne loc_CC85
		rts
loc_CC92:
		ldy #0
		sty byte_61D
		sta byte_608
loc_CC9A:
		inc byte_61D
		ldy byte_61D
		cpy #$C
		bne loc_CCA7
		jmp loc_CD19
loc_CCA7:
		lda locret_CFF9,y
		tay
		lda unk_CFFA,y
		sta byte_609
		lda unk_CFFB,y
		sta byte_66
		lda unk_CFFC,y
		sta byte_67
		lda unk_CFFD,y
		sta byte_60C
		lda unk_CFFE,y
		sta byte_60B
		lda unk_CFFF,y
		sta byte_60D
		sta byte_61B
		lda unk_D000,y
		sta byte_61F
		lda unk_D001,y
		sta byte_60E
		sta byte_1
		jsr sub_CEED
		lda #1
		sta byte_611
		sta byte_613
		sta byte_616
		sta byte_617
		sta byte_5F1
		lda #0
		sta byte_60A
		lda #$B
		sta unk_4015
		lda #$F
		sta unk_4015
loc_CD01:
		dec byte_611
		bne loc_CD6B
		ldy byte_60A
		inc byte_60A
		lda ($66),y
		beq loc_CD14
		bpl loc_CD50
		bne loc_CD42
loc_CD14:
		lda byte_608
		bne loc_CD3F
loc_CD19:
		lda #0
		sta byte_608
		sta unk_4008
		sta byte_67
		sta byte_66
		sta byte_60A
		sta byte_60B
		sta byte_60C
		sta byte_60D
		lda #$90
		sta unk_4000
		sta SND_PULSE_4004_REG
		lda #$80
		sta SND_VOLENV_REG
		rts
loc_CD3F:
		jmp loc_CC9A
loc_CD42:
		jsr sub_CFAC
		sta byte_610
		ldy byte_60A
		inc byte_60A
		lda ($66),y
loc_CD50:
		ldx Square2SoundBuffer
		bne loc_CD65
		jsr sub_CFDF
		beq loc_CD5F
		lda #$10
		ldx #$82
		ldy #$7F
loc_CD5F:
		sta byte_612
		jsr sub_CFD5
loc_CD65:
		lda byte_610
		sta byte_611
loc_CD6B:
		lda Square2SoundBuffer
		bne loc_CD7D
		ldy byte_612
		beq loc_CD77
		dec byte_612
loc_CD77:
		lda unk_D23C,y
		sta SND_PULSE_4004_REG
loc_CD7D:
		ldy byte_60B
		beq loc_CDBC
		dec byte_613
		bne loc_CDA9
		ldy byte_60B
		inc byte_60B
		lda ($66),y
		jsr sub_CFA6
		sta byte_613
		txa
		and #$3E
		jsr sub_CFC1
		beq loc_CDA3
		lda #$10
		ldx #$82
		ldy #$7F
loc_CDA3:
		sta byte_614
		jsr sub_CFB7
loc_CDA9:
		ldy byte_614
		beq loc_CDB1
		dec byte_614
loc_CDB1:
		lda unk_D23C,y
		sta unk_4000
		lda #$7F
		sta unk_4001
loc_CDBC:
		lda byte_60C
		beq loc_CDF9
		dec byte_616
		bne loc_CDF9
		ldy byte_60C
		inc byte_60C
		lda ($66),y
		beq loc_CDF6
		bpl loc_CDE2
		jsr sub_CFAC
		sta byte_615
		ldy byte_60C
		inc byte_60C
		lda ($66),y
		beq loc_CDF6
loc_CDE2:
		jsr sub_CFE3
		ldx byte_615
		stx byte_616
		txa
		cmp #$12
		bcs loc_CDF4
		lda #$18
		bne loc_CDF6
loc_CDF4:
		lda #$FF
loc_CDF6:
		sta unk_4008
loc_CDF9:
		lda byte_61F
		bne loc_CE01
		jmp loc_CEBB
loc_CE01:
		lda byte_5F1
		cmp #2
		bne loc_CE0D
		lda #0
		sta SND_VOLENV_REG
loc_CE0D:
		dec byte_5F1
		bne loc_CE6E
		ldy byte_61F
		inc byte_61F
		lda ($66),y
		bpl loc_CE2A
		jsr sub_CFAC
		sta byte_5F2
		ldy byte_61F
		inc byte_61F
		lda ($66),y
loc_CE2A:
		jsr sub_CFE7
		tay
		bne loc_CE37
		ldx #$80
		stx SND_VOLENV_REG
		bne loc_CE3D
loc_CE37:
		jsr sub_CF5D
		ldy byte_5F7
loc_CE3D:
		sty byte_5F3
		ldy #0
		sty byte_5F9
		sty byte_5FB
		lda ($6A),y
		sta SND_VOLENV_REG
		lda ($6C),y
		sta unk_4084
		lda #0
		sta unk_4085
		iny
		lda ($6A),y
		sta byte_5F8
		lda ($6C),y
		sta byte_5FA
		sty byte_5F9
		sty byte_5FB
		lda byte_5F2
		sta byte_5F1
loc_CE6E:
		lda byte_5F3
		beq loc_CEBB
		dec byte_5F3
		dec byte_5F8
		bne loc_CE96
loc_CE7B:
		inc byte_5F9
		ldy byte_5F9
		lda ($6A),y
		bpl loc_CE8A
		sta SND_VOLENV_REG
		bne loc_CE7B
loc_CE8A:
		sta SND_VOLENV_REG
		iny
		lda ($6A),y
		sta byte_5F8
		sty byte_5F9
loc_CE96:
		dec byte_5FA
		bne loc_CEBB
		inc byte_5FB
		ldy byte_5FB
		lda ($6C),y
		sta unk_4084
		iny
		lda ($6C),y
		sta unk_4086
		iny
		lda ($6C),y
		sta unk_4087
		iny
		lda ($6C),y
		sta byte_5FA
		sty byte_5FB
loc_CEBB:
		dec byte_617
		bne locret_CEEC
loc_CEC0:
		ldy byte_60D
		inc byte_60D
		lda ($66),y
		bne loc_CED2
		lda byte_61B
		sta byte_60D
		bne loc_CEC0
loc_CED2:
		jsr sub_CFA6
		sta byte_617
		txa
		and #$3E
		beq loc_CEE3
		lda #$1C
		ldx #3
		ldy #$18
loc_CEE3:
		sta unk_400C
		stx unk_400E
		sty unk_400F
locret_CEEC:
		rts
sub_CEED:
		lda byte_1
		bne loc_CEF2
		rts
loc_CEF2:
		ldy #0
loc_CEF4:
		iny
		lsr
		bcc loc_CEF4
		lda unk_D24B,y
		tay
		lda unk_D24C,y
		sta byte_68
		lda unk_D24D,y
		sta byte_69
		lda unk_D24E,y
		sta byte_5F7
		lda unk_D24F,y
		sta byte_6A
		lda unk_D250,y
		sta byte_6B
		lda unk_D251,y
		sta byte_6C
		lda unk_D252,y
		sta Player_PageLoc
		lda unk_D253,y
		sta byte_5F6
		jsr sub_CF2F
		lda #2
		sta unk_4089
		rts
sub_CF2F:
		lda #$80
		sta unk_4089
		lda #0
		sta SND_FDS0_REG
		ldy #0
		ldx #$3F
loc_CF3D:
		lda ($68),y
		sta SND_FDS1_REG,y
		iny
		cpy #$20
		beq loc_CF4D
		sta SND_FDS0_REG,x
		dex
		bne loc_CF3D
loc_CF4D:
		lda byte_608
		and #$40
		beq loc_CF58
		lda #0
		beq loc_CF5A
loc_CF58:
		lda #3
loc_CF5A:
		sta unk_4089
sub_CF5D:
		lda #$80
		sta unk_4087
		lda #0
		sta unk_4085
		ldx #$20
		ldy byte_5F6
		sty byte_2
loc_CF6E:
		lda byte_2
		lsr
		tay
		lda unk_CF86,y
		bcs loc_CF7B
		lsr
		lsr
		lsr
		lsr
loc_CF7B:
		and #$F
		sta unk_4088
		inc byte_2
		dex
		bne loc_CF6E
		rts
unk_CF86:
		.byte 7
		.byte 7
		.byte 7
		.byte 7
		.byte 1
		.byte 1
		.byte 1
		.byte 1
		.byte 1
		.byte 1
		.byte 1
		.byte 1
		.byte 7
		.byte 7
		.byte 7
		.byte 7
		.byte $77
		.byte $77
		.byte $77
		.byte $77
		.byte $11
		.byte $11
		.byte $11
		.byte $11
		.byte $11
		.byte $11
		.byte $11
		.byte $11
		.byte $77
		.byte $77
		.byte $77
		.byte $77
sub_CFA6:
		tax
		ror
		txa
		rol
		rol
		rol
sub_CFAC:
		and #7
		clc
		adc byte_609
		tay
		lda unk_D28F,y
		rts
sub_CFB7:
		sty unk_4001
		stx unk_4000
		rts
		.byte $20
		.byte $B7
		.byte $CF
sub_CFC1:
		ldx #0
loc_CFC3:
		tay
		lda unk_DF01,y
		beq locret_CFD4
		sta SND_PULSE_4002_REG,x
		lda unk_DF00,y
		ora #8
		sta SND_PULSE_4003_REG,x
locret_CFD4:
		rts
sub_CFD5:
		stx SND_PULSE_4004_REG
		sty SND_PULSE_4005_REG
		rts
		.byte $20
		.byte $D5
		.byte $CF
sub_CFDF:
		ldx #4
		bne loc_CFC3
sub_CFE3:
		ldx #8
		bne loc_CFC3
sub_CFE7:
		ldx #$80
		stx unk_4083
		tay
		lda unk_D200,y
		sta unk_4083
		lda unk_D201,y
		sta unk_4082
locret_CFF9:
		rts
unk_CFFA:
		.byte $B
unk_CFFB:
		.byte $B
unk_CFFC:
		.byte $13
unk_CFFD:
		.byte $B
unk_CFFE:
		.byte $1B
unk_CFFF:
		.byte $33
unk_D000:
		.byte $1B
unk_D001:
		.byte $33
		.byte $23
		.byte $1B
		.byte $2B
		.byte 0
		.byte $38
		.byte $D0
		.byte $3E
		.byte $14
		.byte $B0
		.byte $24
		.byte 1
		.byte 0
		.byte $87
		.byte $D0
		.byte $50
		.byte $21
		.byte $61
		.byte $31
		.byte 2
		.byte 0
		.byte $EF
		.byte $D0
		.byte $43
		.byte $1C
		.byte $B5
		.byte $29
		.byte 1
		.byte 0
		.byte $43
		.byte $D1
		.byte $50
		.byte $20
		.byte $61
		.byte $31
		.byte 2
		.byte 8
		.byte $AB
		.byte $D1
		.byte 9
		.byte 4
		.byte $1E
		.byte 6
		.byte 1
		.byte 8
		.byte 6
		.byte $D1
		.byte $3A
		.byte $10
		.byte $9E
		.byte $28
		.byte 1
		.byte 0
		.byte $4B
		.byte $D0
		.byte $84
		.byte $12
		.byte $86
		.byte $C
		.byte $84
		.byte $62
		.byte $10
		.byte $86
		.byte $12
		.byte $84
		.byte $1C
		.byte $22
		.byte $1E
		.byte $22
		.byte $26
		.byte $18
		.byte $1E
		.byte 4
		.byte $1C
		.byte 0
		.byte $E2
		.byte $E0
		.byte $E2
		.byte $9D
		.byte $1F
		.byte $21
		.byte $A3
		.byte $2D
		.byte $74
		.byte $F4
		.byte $31
		.byte $35
		.byte $37
		.byte $2B
		.byte $B1
		.byte $2D
		.byte $83
		.byte $16
		.byte $14
		.byte $16
		.byte $86
		.byte $10
		.byte $84
		.byte $12
		.byte $14
		.byte $86
		.byte $16
		.byte $84
		.byte $20
		.byte $81
		.byte $28
		.byte $83
		.byte $28
		.byte $84
		.byte $24
		.byte $28
		.byte $2A
		.byte $1E
		.byte $86
		.byte $24
		.byte $84
		.byte $20
		.byte $84
		.byte $12
		.byte $14
		.byte 4
		.byte $18
		.byte $1A
		.byte $1C
		.byte $14
		.byte $26
		.byte $22
		.byte $1E
		.byte $1C
		.byte $18
		.byte $1E
		.byte $22
		.byte $C
		.byte $14
		.byte $81
		.byte $22
		.byte $83
		.byte $22
		.byte $86
		.byte $24
		.byte $85
		.byte $18
		.byte $82
		.byte $1E
		.byte $80
		.byte $1E
		.byte $83
		.byte $1C
		.byte $83
		.byte $18
		.byte $84
		.byte $1C
		.byte $81
		.byte $26
		.byte $83
		.byte $26
		.byte $86
		.byte $26
		.byte $85
		.byte $1E
		.byte $82
		.byte $24
		.byte $86
		.byte $22
		.byte $84
		.byte $1E
		.byte 0
		.byte $74
		.byte $F4
		.byte $B5
		.byte $6B
		.byte $B0
		.byte $30
		.byte $EC
		.byte $EA
		.byte $2D
		.byte $76
		.byte $F6
		.byte $B7
		.byte $6D
		.byte $B0
		.byte $B5
		.byte $31
		.byte $81
		.byte $10
		.byte $83
		.byte $10
		.byte $86
		.byte $10
word_D0BE:
		.word $885
		.byte $82
		.byte $C
		.byte $80
		.byte $C
		.byte $83
		.byte $A
		.byte 8
		.byte $84
		.byte $A
		.byte $81
		.byte $12
		.byte $83
		.byte $12
		.byte $86
		.byte $12
		.byte $85
		.byte $A
		.byte $82
		.byte $C
		.byte $86
		.byte $10
		.byte $84
		.byte $C
		.byte $84
		.byte $12
		.byte $1C
		.byte $20
		.byte $24
		.byte $2A
		.byte $26
		.byte $24
		.byte $26
		.byte $22
		.byte $1E
		.byte $22
		.byte $24
		.byte $1E
		.byte $22
		.byte $C
		.byte $1E
		.byte $11
		.byte $11
		.byte $D0
		.byte $D0
		.byte $D0
		.byte $11
		.byte 0
		.byte $83
		.byte $2C
		.byte $2A
		.byte $2C
		.byte $86
		.byte $26
		.byte $84
		.byte $28
		.byte $2A
		.byte $86
		.byte $2C
		.byte $84
		.byte $36
		.byte $81
		.byte $40
		.byte $83
		.byte $40
		.byte $84
		.byte $3A
		.byte $40
		.byte $3E
		.byte $34
		.byte 0
		.byte $86
		.byte $3A
		.byte $84
		.byte $36
		.byte 0
		.byte $1D
		.byte $95
		.byte $19
		.byte $1B
		.byte $9D
		.byte $27
		.byte $2D
		.byte $29
		.byte $2D
		.byte $31
		.byte $23
		.byte $A9
		.byte $27
		.byte $83
		.byte $20
		.byte $1E
		.byte $20
		.byte $86
		.byte $1A
		.byte $84
		.byte $1C
		.byte $1E
		.byte $86
		.byte $20
		.byte $84
		.byte $2A
		.byte $81
		.byte $32
		.byte $83
		.byte $32
		.byte $84
		.byte $2E
		.byte $32
		.byte $34
		.byte $28
		.byte $86
		.byte $2E
		.byte $84
		.byte $2A
		.byte $84
		.byte $1C
		.byte $1E
		.byte 4
		.byte $22
		.byte $24
		.byte $26
		.byte $1E
		.byte $30
		.byte $2C
		.byte $28
		.byte $26
		.byte $22
		.byte $28
		.byte $2C
		.byte $14
		.byte $1E
		.byte $81
		.byte $40
		.byte $83
		.byte $40
		.byte $86
		.byte $40
		.byte $85
		.byte $34
		.byte $82
		.byte $3A
		.byte $80
		.byte $3A
		.byte $83
		.byte $36
		.byte $34
		.byte $84
		.byte $36
		.byte $81
		.byte $3E
		.byte $83
		.byte $3E
		.byte $86
		.byte $3E
		.byte $85
		.byte $36
		.byte $82
		.byte $3A
		.byte $86
		.byte $40
		.byte $84
		.byte $3A
		.byte 0
		.byte $6C
		.byte $EC
		.byte $AF
		.byte $63
		.byte $A8
		.byte $29
		.byte $C4
		.byte $E6
		.byte $E2
		.byte $27
		.byte $70
		.byte $F0
		.byte $B1
		.byte $69
		.byte $AE
		.byte $AD
		.byte $29
		.byte $81
		.byte $1A
		.byte $83
		.byte $1A
		.byte $86
		.byte $1A
		.byte $85
		.byte $10
		.byte $82
		.byte $16
		.byte $80
		.byte $16
		.byte $83
		.byte $12
		.byte $10
		.byte $84
		.byte $12
		.byte $81
		.byte $1C
		.byte $83
		.byte $1C
		.byte $86
		.byte $1C
		.byte $85
		.byte $12
		.byte $82
		.byte $16
		.byte $86
		.byte $1A
		.byte $84
		.byte $16
		.byte $84
		.byte $1C
		.byte $26
		.byte $2A
		.byte $2E
		.byte $34
		.byte $30
		.byte $2E
		.byte $30
		.byte $2C
		.byte $28
		.byte $2C
		.byte $2E
		.byte $28
		.byte $2C
		.byte $14
		.byte $28
		.byte $11
		.byte $11
		.byte $D0
		.byte $D0
		.byte $D0
		.byte $11
		.byte 0
		.byte $87
		.byte $3A
		.byte $36
		.byte 0
		.byte $E9
		.byte $E7
		.byte $87
		.byte $2E
		.byte $2A
		.byte $83
		.byte $16
		.byte $1C
		.byte $22
		.byte $28
		.byte $2E
		.byte $34
		.byte $84
		.byte $3A
		.byte $83
		.byte $34
		.byte $22
		.byte $34
		.byte $84
		.byte $36
		.byte $83
		.byte $1E
		.byte $1E
		.byte $1E
		.byte $86
		.byte $1E
		.byte $11
		.byte $11
		.byte $D0
		.byte $D0
		.byte $D0
		.byte $11
		.byte 0
		.byte $10
		.byte $2C
		.byte $2E
		.byte $27
		.byte $29
		.byte $2B
		.byte $2A
		.byte $28
		.byte $25
		.byte $29
		.byte $2F
		.byte $2D
		.byte $2C
		.byte $2A
		.byte $22
		.byte $24
		.byte $34
		.byte $3F
		.byte $31
		.byte $2D
		.byte $3A
		.byte $3B
		.byte $27
		.byte $12
		.byte $A
		.byte $1F
		.byte $2C
		.byte $27
		.byte $23
		.byte $28
		.byte $22
		.byte $1E
		.byte $A0
		.byte 4
		.byte $18
		.byte $60
		.byte $94
		.byte 2
		.byte $44
		.byte $30
		.byte $A
		.byte $50
		.byte $A0
		.byte 2
		.byte $36
		.byte $35
		.byte $80
		.byte $34
unk_D200:
		.byte 1
unk_D201:
		.byte $44
		.byte 1
		.byte $58
		.byte 1
		.byte $99
		.byte 2
		.byte $22
		.byte 2
		.byte $42
		.byte 2
		.byte $65
		.byte 2
		.byte $B0
		.byte 2
		.byte $D9
		.byte 3
		.byte 4
		.byte 3
		.byte $32
		.byte 3
		.byte $63
		.byte 3
		.byte $96
		.byte 3
		.byte $CD
		.byte 4
		.byte 7
		.byte 4
		.byte $44
		.byte 4
		.byte $85
		.byte 4
		.byte $CA
		.byte 5
		.byte $13
		.byte 5
		.byte $60
		.byte 5
		.byte $B2
		.byte 6
		.byte 8
		.byte 6
		.byte $64
		.byte 6
		.byte $C6
		.byte 7
		.byte $2D
		.byte 7
		.byte $9A
		.byte 8
		.byte $E
		.byte 8
		.byte $88
		.byte 9
		.byte $95
		.byte $A
		.byte $26
		.byte 0
		.byte 0
unk_D23C:
		.byte $97
		.byte $98
		.byte $9A
		.byte $9B
		.byte $9B
		.byte $9A
		.byte $9A
		.byte $99
		.byte $99
		.byte $98
		.byte $98
		.byte $97
		.byte $97
		.byte $96
		.byte $96
unk_D24B:
		.byte $95
unk_D24C:
		.byte 2
unk_D24D:
		.byte $A
unk_D24E:
		.byte $5F
unk_D24F:
		.byte $D2
unk_D250:
		.byte $44
unk_D251:
		.byte $F4
unk_D252:
		.byte $D1
unk_D253:
		.byte $7F
		.byte $D2
		.byte $20
		.byte $D0
		.byte $D1
		.byte $60
		.byte $F0
		.byte $D1
		.byte $89
		.byte $D2
		.byte 0
		.byte 0
		.byte 1
		.byte 2
		.byte 3
		.byte 4
		.byte 6
		.byte 7
		.byte 9
		.byte $B
		.byte $E
		.byte $10
		.byte $13
		.byte $18
		.byte $20
		.byte $2B
		.byte $34
		.byte $3C
		.byte $3F
		.byte $3F
		.byte $3E
		.byte $3D
		.byte $3A
		.byte $36
		.byte $32
		.byte $2F
		.byte $2C
		.byte $29
		.byte $26
		.byte $24
		.byte $21
		.byte $1E
		.byte $18
		.byte $19
		.byte $80
		.byte $1B
		.byte $81
		.byte $A
		.byte 0
		.byte 4
		.byte $82
		.byte $10
		.byte 0
		.byte $60
		.byte $80
		.byte 2
		.byte $80
		.byte 0
		.byte 0
		.byte $60
unk_D28F:
		.byte $24
		.byte $12
		.byte $D
		.byte 9
		.byte $1B
		.byte $28
		.byte $36
		.byte $12
		.byte $24
		.byte $12
		.byte $D
		.byte 9
		.byte $1B
		.byte $28
		.byte $36
		.byte $6C
