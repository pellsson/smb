;
; Bank for all sound-related stuff
;
LL_SoundEngine:
    lda OperMode
    bne @SndOn
    sta SND_MASTERCTRL_REG
    rts
@SndOn:
    lda #$FF
    sta JOYPAD_PORT2
    lda #$F
    sta SND_MASTERCTRL_REG
    lda PauseModeFlag
    bne @InPause
    lda PauseSoundQueue
    cmp #1
    bne LL_RunSoundSubroutines
@InPause:
    lda PauseSoundBuffer
    bne @ContPau
    lda PauseSoundQueue
    beq LL_SkipSoundSubroutines
    sta PauseSoundBuffer
    sta PauseModeFlag
    lda #0
    sta SND_MASTERCTRL_REG
    sta Square1SoundBuffer
    sta Square2SoundBuffer
    sta NoiseSoundBuffer
    lda #$F
    sta SND_MASTERCTRL_REG
    lda #$2A
    sta Squ1_SfxLenCounter
@loc_D2E2:
    lda #$44
    bne loc_D2F7
@ContPau:
    lda Squ1_SfxLenCounter
    cmp #$24
    beq loc_D2F5
    cmp #$1E
    beq @loc_D2E2
    cmp #$18
    bne loc_D2FE
loc_D2F5:

    lda #$64
loc_D2F7:

    ldx #$84
    ldy #$7F
    jsr sub_D358
loc_D2FE:

    dec Squ1_SfxLenCounter
    bne LL_SkipSoundSubroutines
    lda #0
    sta SND_MASTERCTRL_REG
    lda PauseSoundBuffer
    cmp #2
    bne loc_D314
    lda #0
    sta PauseModeFlag
loc_D314:

    lda #0
    sta PauseSoundBuffer
loc_D319:

    beq LL_SkipSoundSubroutines
LL_RunSoundSubroutines:
    lda WRAM_DisableSound
    bne @nosound
    jsr sub_D3EB
    jsr sub_D54C
    jsr sub_D677
@nosound:
    lda WRAM_DisableMusic
    bne @nomusic
    jsr LL_MusicHandler
@nomusic:
    lda #0
    sta AreaMusicQueue
    sta EventMusicQueue
LL_SkipSoundSubroutines:
    lda #0
    sta Square1SoundQueue
    sta Square2SoundQueue
    sta NoiseSoundQueue
    sta PauseSoundQueue
    ldy DAC_Counter
    lda AreaMusicBuffer
    and #3
    beq loc_D347
    inc DAC_Counter
    cpy #$30
    bcc loc_D34D
loc_D347:

    tya
    beq loc_D34D
    dec DAC_Counter
loc_D34D:

    sty SND_DELTA_REG+1
    rts
sub_D351:

    sty SND_SQUARE1_REG+1
    stx SND_SQUARE1_REG
    rts
sub_D358:

    jsr sub_D351
sub_D35B:

    ldx #0
loc_D35D:

    tay
    lda unk_DF01,y
    beq locret_D36E
    sta SND_PULSE_4002_REG,x
    lda unk_DF00,y
    ora #8
    sta SND_PULSE_4003_REG,x
locret_D36E:

    rts
sub_D36F:

    stx SND_SQUARE2_REG
    sty SND_PULSE_4005_REG
    rts
sub_D376:

    jsr sub_D36F
loc_D379:

    ldx #4
    bne loc_D35D
loc_D37D:

    ldx #8
loc_D37F:

    bne loc_D35D
LL_SwimStompEnvelopeData:
    .byte $9F
    .byte $9B
    .byte $98
    .byte $96
    .byte $95
    .byte $94
    .byte $92
    .byte $90
    .byte $90
    .byte $9A
    .byte $97
    .byte $95
    .byte $93
    .byte $92
loc_D38F:

    lda #$40
    sta Squ1_SfxLenCounter
    lda #$62
    jsr sub_D35B
    ldx #$99
    bne loc_D3C2
loc_D39D:

    lda #$26
    bne loc_D3A3
loc_D3A1:

    lda #$18
loc_D3A3:

    ldx #$82
    ldy #$A7
    jsr sub_D358
    lda #$28
    sta Squ1_SfxLenCounter
loc_D3AF:

    lda Squ1_SfxLenCounter
    cmp #$25
    bne loc_D3BC
    ldx #$5F
    ldy #$F6
    bne loc_D3C4
loc_D3BC:

    cmp #$20
    bne loc_D3E9
    ldx #$48
loc_D3C2:

    ldy #$BC
loc_D3C4:

    jsr sub_D351
    bne loc_D3E9
loc_D3C9:

    lda #5
    ldy #$99
    bne loc_D3D3
loc_D3CF:

    lda #$A
    ldy #$93
loc_D3D3:

    ldx #$9E
    sta Squ1_SfxLenCounter
    lda #$C
    jsr sub_D358
loc_D3DD:

    lda Squ1_SfxLenCounter
    cmp #6
    bne loc_D3E9
    lda #$BB
    sta SND_SQUARE1_REG+1
loc_D3E9:

    bne loc_D44B
sub_D3EB:

    ldy Square1SoundQueue
    beq loc_D40F
    sty Square1SoundBuffer
    bmi loc_D39D
    lsr Square1SoundQueue
    bcs loc_D3A1
    lsr Square1SoundQueue
    bcs loc_D3CF
    lsr Square1SoundQueue
    bcs loc_D42B
    lsr Square1SoundQueue
    bcs loc_D44D
    lsr Square1SoundQueue
    bcs loc_D486
    lsr Square1SoundQueue
    bcs loc_D3C9
    lsr Square1SoundQueue
    bcs loc_D38F
loc_D40F:

    lda Square1SoundBuffer
    beq locret_D42A
    bmi loc_D3AF
    lsr
    bcs loc_D3AF
    lsr
    bcs loc_D3DD
    lsr
    bcs loc_D439
    lsr
    bcs loc_D45D
    lsr
    bcs loc_D48B
    lsr
    bcs loc_D3DD
    lsr
    bcs loc_D472
locret_D42A:

    rts
loc_D42B:

    lda #$E
    sta Squ1_SfxLenCounter
    ldy #$9C
    ldx #$9E
    lda #$26
    jsr sub_D358
loc_D439:

    ldy Squ1_SfxLenCounter
    lda LL_SwimStompEnvelopeData-1,y
    sta SND_SQUARE1_REG
    cpy #6
    bne loc_D44B
    lda #$9E
    sta SND_PULSE_4002_REG
loc_D44B:

    bne loc_D472
loc_D44D:

    lda #$E
    ldy #$CB
    ldx #$9F
    sta Squ1_SfxLenCounter
    lda #$28
    jsr sub_D358
    bne loc_D472
loc_D45D:

    ldy Squ1_SfxLenCounter
    cpy #8
    bne loc_D46D
    lda #$A0
    sta SND_PULSE_4002_REG
    lda #$9F
    bne loc_D46F
loc_D46D:

    lda #$90
loc_D46F:

    sta SND_SQUARE1_REG
loc_D472:

    dec Squ1_SfxLenCounter
    bne locret_D485
sub_D477:

    ldx #0
    stx Square1SoundBuffer
    ldx #$E
    stx SND_MASTERCTRL_REG
    ldx #$F
    stx SND_MASTERCTRL_REG
locret_D485:

    rts
loc_D486:

    lda #$2F
    sta Squ1_SfxLenCounter
loc_D48B:

    lda Squ1_SfxLenCounter
    lsr
    bcs loc_D4A1
    lsr
    bcs loc_D4A1
    and #2
    beq loc_D4A1
    ldy #$91
    ldx #$9A
    lda #$44
    jsr sub_D358
loc_D4A1:

    jmp loc_D472
LL_ExtraLifeFreqData:
    .byte $58
    .byte 2
    .byte $54
    .byte $56
    .byte $4E
    .byte $44
LL_PowerUpGrabFreqData:
    .byte $4C
    .byte $52
    .byte $4C
    .byte $48
    .byte $3E
    .byte $36
    .byte $3E
    .byte $36
    .byte $30
    .byte $28
    .byte $4A
    .byte $50
    .byte $4A
    .byte $64
    .byte $3C
    .byte $32
    .byte $3C
    .byte $32
    .byte $2C
    .byte $24
    .byte $3A
    .byte $64
    .byte $3A
    .byte $34
    .byte $2C
    .byte $22
    .byte $2C
    .byte $22
    .byte $1C
    .byte $14
LL_PUp_VGrow_FreqData:
    .byte $14
    .byte 4
    .byte $22
    .byte $24
    .byte $16
    .byte 4
    .byte $24
    .byte $26
    .byte $18
    .byte 4
    .byte $26
    .byte $28
    .byte $1A
    .byte 4
    .byte $28
    .byte $2A
    .byte $1C
    .byte 4
    .byte $2A
    .byte $2C
    .byte $1E
    .byte 4
    .byte $2C
    .byte $2E
    .byte $20
    .byte 4
    .byte $2E
    .byte $30
    .byte $22
    .byte 4
    .byte $30
    .byte $32

LL_PlayCoinGrab:
    lda #$35
    ldx #$8D
    bne loc_D4F2
LL_PlayTimerTick:
    lda #6
    ldx #$98
loc_D4F2:
    sta Squ2_SfxLenCounter
    ldy #$7F
    lda #$42
    jsr sub_D376
loc_D4FC:
    lda Squ2_SfxLenCounter
    cmp #$30
    bne loc_D508
    lda #$54
    sta SND_PULSE_4006_REG
loc_D508:
    bne LL_DecrementSfx2Length
loc_D50A:
    lda #$20
    sta Squ2_SfxLenCounter
    ldy #$94
    lda #$5E
    bne LL_SBlasJ
LL_ContinueBlast:
    lda Squ2_SfxLenCounter
    cmp #$18
    bne LL_DecrementSfx2Length
    ldy #$93
    lda #$18
LL_SBlasJ:
    bne loc_D5A1
LL_PlayPowerUpGrab:
    lda #$36
    sta Squ2_SfxLenCounter
LL_ContinuePowerUpGrab:
    lda Squ2_SfxLenCounter
    lsr
    bcs LL_DecrementSfx2Length
    tay
    lda LL_PowerUpGrabFreqData-1,y
    ldx #$5D
    ldy #$7F
loc_D535:

    jsr sub_D376
LL_DecrementSfx2Length:

    dec Squ2_SfxLenCounter
    bne locret_D54B
LL_EmptySfx2Buffer:

    ldx #0
    stx Square2SoundBuffer
sub_D541:

    ldx #$D
    stx SND_MASTERCTRL_REG
    ldx #$F
    stx SND_MASTERCTRL_REG
locret_D54B:

    rts
sub_D54C:

    lda Square2SoundBuffer
    and #$40
    bne loc_D5B7
    ldy Square2SoundQueue
    beq loc_D576
    sty Square2SoundBuffer
    bmi loc_D598
    lsr Square2SoundQueue
    bcs LL_PlayCoinGrab
    lsr Square2SoundQueue
    bcs loc_D5CC
    lsr Square2SoundQueue
    bcs loc_D5D0
    lsr Square2SoundQueue
    bcs loc_D50A
    lsr Square2SoundQueue
    bcs LL_PlayTimerTick
    lsr Square2SoundQueue
    bcs LL_PlayPowerUpGrab
    lsr Square2SoundQueue
    bcs loc_D5B2
loc_D576:

    lda Square2SoundBuffer
    beq locret_D591
    bmi loc_D5A3
    lsr
    bcs loc_D592
    lsr
    bcs loc_D5DF
    lsr
    bcs loc_D5DF
    lsr
    bcs LL_ContinueBlast
    lsr
    bcs loc_D592
    lsr
    bcs LL_ContinuePowerUpGrab
    lsr
    bcs loc_D5B7
locret_D591:

    rts
loc_D592:

    jmp loc_D4FC
loc_D595:

    jmp LL_DecrementSfx2Length
loc_D598:

    lda #$38
    sta Squ2_SfxLenCounter
    ldy #$C4
    lda #$18
loc_D5A1:

    bne loc_D5AE
loc_D5A3:

    lda Squ2_SfxLenCounter
    cmp #8
    bne LL_DecrementSfx2Length
    ldy #$A4
    lda #$5A
loc_D5AE:

    ldx #$9F
loc_D5B0:

    bne loc_D535
loc_D5B2:

    lda #$30
    sta Squ2_SfxLenCounter
loc_D5B7:

    lda Squ2_SfxLenCounter
    ldx #3
loc_D5BC:

    lsr
    bcs loc_D595
    dex
    bne loc_D5BC
    tay
    lda LL_ExtraLifeFreqData-1,y
    ldx #$82
    ldy #$7F
    bne loc_D5B0
loc_D5CC:

    lda #$10
    bne loc_D5D2
loc_D5D0:

    lda #$20
loc_D5D2:

    sta Squ2_SfxLenCounter
    lda #$7F
    sta SND_PULSE_4005_REG
    lda #0
    sta Sfx_SecondaryCounter
loc_D5DF:

    inc Sfx_SecondaryCounter
    lda Sfx_SecondaryCounter
    lsr
    tay
    cpy Squ2_SfxLenCounter
    beq loc_D5F8
    lda #$9D
    sta SND_SQUARE2_REG
    lda LL_PUp_VGrow_FreqData,y
    jsr loc_D379
    rts
loc_D5F8:

    jmp LL_EmptySfx2Buffer
byte_D5FB:
    .byte $37
    .byte $46
    .byte $55
    .byte $64
    .byte $74
    .byte $83
    .byte $93
    .byte $A2
    .byte $B1
    .byte $C0
    .byte $D0
    .byte $E0
    .byte $F1
    .byte $F1
    .byte $F2
    .byte $E2
    .byte $E2
    .byte $C3
    .byte $A3
    .byte $84
    .byte $64
    .byte $44
    .byte $35
    .byte $25
unk_D613:
    .byte 1
    .byte $E
    .byte $E
    .byte $D
    .byte $B
    .byte 6
    .byte $C
    .byte $F
    .byte $A
    .byte 9
    .byte 3
    .byte $D
    .byte 8
    .byte $D
    .byte 6
unk_D622:
    .byte $C
    .byte $47
    .byte $49
    .byte $42
    .byte $4A
    .byte $43
    .byte $4B
loc_D629:

    sty NoiseSoundBuffer
    lda #6
    sta Noise_SfxLenCounter
loc_D630:

    lda Noise_SfxLenCounter
    tay
    lda unk_D622,y
    sta SND_TRIANGLE_400A_REG
    lda #$18
    sta SND_TRIANGLE_REG
    sta SND_TRIANGLE_400B_REG
    bne loc_D663
loc_D644:

    sty NoiseSoundBuffer
    lda #$20
    sta Noise_SfxLenCounter
loc_D64B:

    lda Noise_SfxLenCounter
    lsr
    bcc loc_D663
    tay
    ldx unk_D613,y
    lda unk_DFEA,y
loc_D658:

    sta SND_NOISE_REG
    stx $400E
    lda #$18
    sta $400F
loc_D663:

    dec Noise_SfxLenCounter
    bne locret_D676
    lda #$F0
    sta SND_NOISE_REG
    lda #0
    sta SND_TRIANGLE_REG
    lda #0
    sta NoiseSoundBuffer
locret_D676:

    rts
sub_D677:

    lda NoiseSoundBuffer
    bmi loc_D630
    ldy NoiseSoundQueue
    bmi loc_D629
    lsr NoiseSoundQueue
    bcs loc_D644
    lsr
    bcs loc_D64B
    lsr NoiseSoundQueue
    bcs loc_D695
    lsr
    bcs loc_D69C
    lsr
    bcs loc_D6AF
    lsr NoiseSoundQueue
    bcs loc_D6A8
    rts
loc_D695:

    sty NoiseSoundBuffer
    lda #$40
    sta Noise_SfxLenCounter
loc_D69C:

    lda Noise_SfxLenCounter
    lsr
    tay
    ldx #$F
    lda unk_DFC9,y
loc_D6A6:

    bne loc_D658
loc_D6A8:

    sty NoiseSoundBuffer
    lda #$C0
    sta Noise_SfxLenCounter
loc_D6AF:

    lsr NoiseSoundQueue
    bcc locret_D676
    lda Noise_SfxLenCounter
    lsr
    lsr
    lsr
    tay
    lda byte_D5FB,y
    and #$F
    ora #$10
    tax
    lda byte_D5FB,y
    lsr
    lsr
    lsr
    lsr
    ora #$10
    bne loc_D6A6
loc_D6CD:
    jmp loc_D776

LL_MusicHandler:
    lda EventMusicQueue
    bne LL_LoadEventMusic
    lda AreaMusicQueue
    bne loc_D704
    lda EventMusicBuffer
    ora AreaMusicBuffer
    bne loc_D6CD
    rts
LL_LoadEventMusic:
    sta EventMusicBuffer
    cmp #1
    bne loc_D6ED
    jsr sub_D477
    jsr sub_D541
loc_D6ED:

    ldx AreaMusicBuffer
    stx AreaMusicBuffer_Alt
    ldy #0
    sty NoteLengthTblAdder
    sty AreaMusicBuffer
    cmp #$40
    bne LL_FindEventMusicHeader
    ldx #8
    stx NoteLengthTblAdder
    bne LL_FindEventMusicHeader
loc_D704:

    cmp #4
    bne loc_D70B
    jsr sub_D477
loc_D70B:

    ldy #$10
loc_D70D:

    sty GroundMusicHeaderOfs
loc_D710:

    ldy #0
    sty EventMusicBuffer
    sta AreaMusicBuffer
    cmp #1
    bne LL_FindAreaMusicHeader
    inc GroundMusicHeaderOfs
    ldy GroundMusicHeaderOfs
    cpy #$32
    bne LL_LoadHeader
    ldy #$11
    bne loc_D70D
LL_FindAreaMusicHeader:
    ldy #8
    sty MusicOffset_Square2
LL_FindEventMusicHeader:
    iny
    lsr
    bcc LL_FindEventMusicHeader
LL_LoadHeader:
    lda LL_MusicHeaderData-1,y
    tay
    lda LL_MusicHeaderData,y
    sta NoteLenLookupTblOfs
    lda LL_MusicHeaderData+1,y
    sta MusicDataLow
    lda LL_MusicHeaderData+2,y
    sta MusicDataHigh
    lda LL_MusicHeaderData+3,y
    sta MusicOffset_Triangle
    lda LL_MusicHeaderData+4,y
    sta MusicOffset_Square1
    lda LL_MusicHeaderData+5,y
    sta MusicOffset_Noise
    sta NoiseDataLoopbackOfs
    lda #1
    sta Squ2_NoteLenCounter
    sta Squ1_NoteLenCounter
    sta Tri_NoteLenCounter
    sta Noise_BeatLenCounter
    lda #0
    sta MusicOffset_Square2
    sta AltRegContentFlag
    lda #$B
    sta SND_MASTERCTRL_REG
    lda #$F
    sta SND_MASTERCTRL_REG
loc_D776:

    dec Squ2_NoteLenCounter
    bne loc_D7DA
    ldy MusicOffset_Square2
    inc MusicOffset_Square2
    lda ($F5),y
    beq loc_D787
    bpl loc_D7C2
    bne loc_D7B6
loc_D787:

    lda EventMusicBuffer
    cmp #$40
    bne loc_D793
    lda AreaMusicBuffer_Alt
    bne loc_D7B0
loc_D793:

    and #VictoryMusic
    bne LL_VictoryMLoopBack
    lda AreaMusicBuffer
    and #$5F
    bne loc_D7B0
    lda #0
    sta AreaMusicBuffer
    sta EventMusicBuffer
    sta SND_TRIANGLE_REG
    lda #$90
    sta SND_SQUARE1_REG
    sta SND_SQUARE2_REG
    rts
loc_D7B0:

    jmp loc_D710
LL_VictoryMLoopBack:
    jmp LL_LoadEventMusic
loc_D7B6:

    jsr LL_ProcessLengthData
    sta Squ2_NoteLenBuffer
    ldy MusicOffset_Square2
    inc MusicOffset_Square2
    lda ($F5),y
loc_D7C2:

    ldx Square2SoundBuffer
    bne loc_D7D4
    jsr loc_D379
    beq loc_D7CE
    jsr LL_LoadControlRegs
loc_D7CE:

    sta Squ2_EnvelopeDataCtrl
    jsr sub_D36F
loc_D7D4:

    lda Squ2_NoteLenBuffer
    sta Squ2_NoteLenCounter
loc_D7DA:

    lda Square2SoundBuffer
    bne loc_D7F8
    lda EventMusicBuffer
    and #$91
    bne loc_D7F8
    ldy Squ2_EnvelopeDataCtrl
    beq loc_D7ED
    dec Squ2_EnvelopeDataCtrl
loc_D7ED:

    jsr LL_LoadEnvelopeData
    sta SND_SQUARE2_REG
    ldx #$7F
    stx SND_PULSE_4005_REG
loc_D7F8:

    ldy MusicOffset_Square1
    beq loc_D856
    dec Squ1_NoteLenCounter
    bne loc_D833
loc_D801:

    ldy MusicOffset_Square1
    inc MusicOffset_Square1
    lda ($F5),y
    bne loc_D818
    lda #$83
    sta SND_SQUARE1_REG
    lda #$94
    sta SND_SQUARE1_REG+1
    sta AltRegContentFlag
    bne loc_D801
loc_D818:

    jsr sub_D901
    sta Squ1_NoteLenCounter
    ldy Square1SoundBuffer
    bne loc_D856
    txa
    and #$3E
    jsr sub_D35B
    beq loc_D82D
    jsr LL_LoadControlRegs
loc_D82D:

    sta Squ1_EnvelopeDataCtrl
    jsr sub_D351
loc_D833:

    lda Square1SoundBuffer
    bne loc_D856
    lda EventMusicBuffer
    and #$91
    bne loc_D84C
    ldy Squ1_EnvelopeDataCtrl
    beq loc_D846
    dec Squ1_EnvelopeDataCtrl
loc_D846:

    jsr LL_LoadEnvelopeData
    sta SND_SQUARE1_REG
loc_D84C:

    lda AltRegContentFlag
    bne loc_D853
    lda #$7F
loc_D853:

    sta SND_SQUARE1_REG+1
loc_D856:

    lda MusicOffset_Triangle
    dec Tri_NoteLenCounter
    bne loc_D8A9
    ldy MusicOffset_Triangle
    inc MusicOffset_Triangle
    lda ($F5),y
    beq loc_D8A6
    bpl loc_D87A
    jsr LL_ProcessLengthData
    sta Tri_NoteLenBuffer
    lda #$1F
    sta SND_TRIANGLE_REG
    ldy MusicOffset_Triangle
    inc MusicOffset_Triangle
    lda ($F5),y
    beq loc_D8A6
loc_D87A:

    jsr loc_D37D
    ldx Tri_NoteLenBuffer
    stx Tri_NoteLenCounter
    lda EventMusicBuffer
    and #$6E
    bne loc_D890
    lda AreaMusicBuffer
    and #$A
    beq loc_D8A9
loc_D890:

    txa
    cmp #$12
    bcs loc_D8A4
    lda EventMusicBuffer
    and #8
    beq loc_D8A0
    lda #$F
    bne loc_D8A6
loc_D8A0:

    lda #$1F
    bne loc_D8A6
loc_D8A4:

    lda #$FF
loc_D8A6:

    sta SND_TRIANGLE_REG
loc_D8A9:

    lda AreaMusicBuffer
    and #$F3
    beq locret_D900
    dec Noise_BeatLenCounter
    bne locret_D900
loc_D8B4:

    ldy MusicOffset_Noise
    inc MusicOffset_Noise
    lda ($F5),y
    bne loc_D8C6
    lda NoiseDataLoopbackOfs
    sta MusicOffset_Noise
    bne loc_D8B4
loc_D8C6:

    jsr sub_D901
    sta Noise_BeatLenCounter
    txa
    and #$3E
    beq loc_D8F5
    cmp #$30
    beq loc_D8ED
    cmp #$20
    beq loc_D8E5
    and #$10
    beq loc_D8F5
    lda #$1C
    ldx #3
    ldy #$18
    bne loc_D8F7
loc_D8E5:

    lda #$1C
    ldx #$C
    ldy #$18
    bne loc_D8F7
loc_D8ED:

    lda #$1C
    ldx #3
    ldy #$58
    bne loc_D8F7
loc_D8F5:

    lda #$10
loc_D8F7:

    sta SND_NOISE_REG
    stx $400E
    sty $400F
locret_D900:

    rts
sub_D901:

    tax
    ror
    txa
    rol
    rol
    rol
LL_ProcessLengthData:

    and #7
    clc
    adc NoteLenLookupTblOfs
    adc NoteLengthTblAdder
    tay
    lda LL_MusicLengthLookupTbl,y
    rts
LL_LoadControlRegs:

    lda EventMusicBuffer
    and #8
    beq loc_D91F
    lda #4
    bne loc_D92B
loc_D91F:
    lda AreaMusicBuffer
    and #$7D
    beq loc_D929
    lda #8
    bne loc_D92B
loc_D929:
    lda #$28
loc_D92B:
    ldx #$82
    ldy #$7F
    rts

LL_LoadEnvelopeData:
    lda EventMusicBuffer
    and #8
    beq LL_LoadUsualEnvData
    lda LL_EndOfCastleMusicEnvData,y
    rts

LL_LoadUsualEnvData:
    lda AreaMusicBuffer
    and #$7D
    beq LL_LoadWaterEventMusEnvData
    lda LL_AreaMusicEnvData,y
    rts

LL_LoadWaterEventMusEnvData:
    lda LL_WaterEventMusEnvData,y
    rts
LL_MusicHeaderData:
    .byte $A0
    .byte $54
    .byte $54
    .byte $5F
    .byte $54
    .byte $3C
    .byte $31
    .byte $4B
    .byte $64
    .byte $59
    .byte $46
    .byte $4F
    .byte $36
    .byte $88
    .byte $36
    .byte $4B
    .byte $88
    .byte $64
    .byte $64
    .byte $6A
    .byte $70
    .byte $6A
    .byte $76
    .byte $6A
    .byte $70
    .byte $6A
    .byte $76
    .byte $7C
    .byte $82
    .byte $7C
    .byte $88
    .byte $64
    .byte $64
    .byte $8E
    .byte $94
    .byte $8E
    .byte $9A
    .byte $8E
    .byte $94
    .byte $8E
    .byte $9A
    .byte $7C
    .byte $82
    .byte $7C
    .byte $88
    .byte $8E
    .byte $94
    .byte $8E
    .byte $9A
    .byte 8
    .word unk_DCA9
    .byte $27
    .byte $18
    .byte $20
    .word byte_D9EF
    .byte $2E
    .byte $1A
    .byte $40
    .byte $20
    .word byte_DCE7
    .byte $3D
    .byte $21
    .byte $20
    .word unk_DCFB
    .byte $3F
    .byte $1D
    .byte $18
    .word unk_DD48
    .byte 0
    .byte 0
    .byte 8
    .word unk_DA53
    .byte 0
    .byte 0
    .word unk_DBDB
    .byte $93
    .byte $62
    .byte $18
    .word unk_DC7C
    .byte $1E
    .byte $14
    .byte 8
    .word unk_DD89
    .byte $A0
    .byte $70
    .byte $68
    .byte 8
    .word unk_DE88
    .byte $4C
    .byte $24
    .byte $18
    .word unk_DA38
    .byte $2D
    .byte $1C
    .byte $B8
    .byte $18
    .word unk_DA80
    .byte $20
    .byte $12
    .byte $70
    .byte $18
    .word unk_DAAC
    .byte $1B
    .byte $10
    .byte $44
    .byte $18
    .word unk_DAD4
    .byte $11
    .byte $A
    .byte $1C
    .byte $18
    .word unk_DAF9
    .byte $2D
    .byte $10
    .byte $58
    .byte $18
    .word unk_DB12
    .byte $14
    .byte $D
    .byte $3F
    .byte $18
    .word unk_DB30
    .byte $15
    .byte $D
    .byte $21
    .byte $18
    .word unk_DB5C
    .byte $18
    .byte $10
    .byte $7A
    .byte $18
    .word unk_DB82
    .byte $19
    .byte $F
    .byte $54
    .byte $18
    .word unk_DBAB
    .byte $1E
    .byte $12
    .byte $2B
    .byte $18
    .word unk_DBA9
    .byte $1E
    .byte $F
    .byte $2D
byte_D9EF:
    .byte $84
    .byte $2C
    .byte $2C
    .byte $2C
    .byte $82
    .byte 4
    .byte $2C
    .byte 4
    .byte $85
    .byte $2C
    .byte $84
    .byte $2C
    .byte $2C
    .byte $2A
    .byte $2A
    .byte $2A
    .byte $82
    .byte 4
    .byte $2A
    .byte 4
    .byte $85
    .byte $2A
    .byte $84
    .byte $2A
    .byte $2A
    .byte 0
    .byte $1F
    .byte $1F
    .byte $1F
    .byte $98
    .byte $1F
    .byte $1F
    .byte $98
    .byte $9E
    .byte $98
    .byte $1F
    .byte $1D
    .byte $1D
    .byte $1D
    .byte $94
    .byte $1D
    .byte $1D
    .byte $94
    .byte $9C
    .byte $94
    .byte $1D
    .byte $86
    .byte $18
    .byte $85
    .byte $26
    .byte $30
    .byte $84
    .byte 4
    .byte $26
    .byte $30
    .byte $86
    .byte $14
    .byte $85
    .byte $22
    .byte $2C
    .byte $84
    .byte 4
    .byte $22
    .byte $2C
    .byte $21
    .byte $D0
    .byte $C4
    .byte $D0
    .byte $31
    .byte $D0
    .byte $C4
    .byte $D0
    .byte 0
unk_DA38:
    .byte $85
    .byte $2C
    .byte $22
    .byte $1C
    .byte $84
    .byte $26
    .byte $2A
    .byte $82
    .byte $28
    .byte $26
    .byte 4
    .byte $87
    .byte $22
    .byte $34
    .byte $3A
    .byte $82
    .byte $40
    .byte 4
    .byte $36
    .byte $84
    .byte $3A
    .byte $34
    .byte $82
    .byte $2C
    .byte $30
    .byte $85
    .byte $2A
unk_DA53:
    .byte 0
    .byte $5D
    .byte $55
    .byte $4D
    .byte $15
    .byte $19
    .byte $96
    .byte $15
    .byte $D5
    .byte $E3
    .byte $EB
    .byte $2D
    .byte $A6
    .byte $2B
    .byte $27
    .byte $9C
    .byte $9E
    .byte $59
    .byte $85
    .byte $22
    .byte $1C
    .byte $14
    .byte $84
    .byte $1E
    .byte $22
    .byte $82
    .byte $20
    .byte $1E
    .byte 4
    .byte $87
    .byte $1C
    .byte $2C
    .byte $34
    .byte $82
    .byte $36
    .byte 4
    .byte $30
    .byte $34
    .byte 4
    .byte $2C
    .byte 4
    .byte $26
    .byte $2A
    .byte $85
    .byte $22
unk_DA80:
    .byte $84
    .byte 4
    .byte $82
    .byte $3A
    .byte $38
    .byte $36
    .byte $32
    .byte 4
    .byte $34
    .byte 4
    .byte $24
    .byte $26
    .byte $2C
    .byte 4
    .byte $26
    .byte $2C
    .byte $30
    .byte 0
    .byte 5
    .byte $B4
    .byte $B2
    .byte $B0
    .byte $2B
    .byte $AC
    .byte $84
    .byte $9C
    .byte $9E
    .byte $A2
    .byte $84
    .byte $94
    .byte $9C
    .byte $9E
    .byte $85
    .byte $14
    .byte $22
    .byte $84
    .byte $2C
    .byte $85
    .byte $1E
    .byte $82
    .byte $2C
    .byte $84
    .byte $2C
    .byte $1E
unk_DAAC:
    .byte $84
    .byte 4
    .byte $82
    .byte $3A
    .byte $38
    .byte $36
    .byte $32
    .byte 4
    .byte $34
    .byte 4
    .byte $64
    .byte 4
    .byte $64
    .byte $86
    .byte $64
    .byte 0
    .byte 5
    .byte $B4
    .byte $B2
    .byte $B0
    .byte $2B
    .byte $AC
    .byte $84
    .byte $37
    .byte $B6
    .byte $B6
    .byte $45
    .byte $85
    .byte $14
    .byte $1C
    .byte $82
    .byte $22
    .byte $84
    .byte $2C
    .byte $4E
    .byte $82
    .byte $4E
    .byte $84
    .byte $4E
    .byte $22
unk_DAD4:
    .byte $84
    .byte 4
    .byte $85
    .byte $32
    .byte $85
    .byte $30
    .byte $86
    .byte $2C
    .byte 4
    .byte 0
    .byte 5
    .byte $A4
    .byte 5
    .byte $9E
    .byte 5
    .byte $9D
    .byte $85
    .byte $84
    .byte $14
    .byte $85
    .byte $24
    .byte $28
    .byte $2C
    .byte $82
    .byte $22
    .byte $84
    .byte $22
    .byte $14
    .byte $21
    .byte $D0
    .byte $C4
    .byte $D0
    .byte $31
    .byte $D0
    .byte $C4
    .byte $D0
    .byte 0
unk_DAF9:
    .byte $82
    .byte $2C
    .byte $84
    .byte $2C
    .byte $2C
    .byte $82
    .byte $2C
    .byte $30
    .byte 4
    .byte $34
    .byte $2C
    .byte 4
    .byte $26
    .byte $86
    .byte $22
    .byte 0
    .byte $A4
    .byte $25
    .byte $25
    .byte $A4
    .byte $29
    .byte $A2
    .byte $1D
    .byte $9C
    .byte $95
unk_DB12:
    .byte $82
    .byte $2C
    .byte $2C
    .byte 4
    .byte $2C
    .byte 4
    .byte $2C
    .byte $30
    .byte $85
    .byte $34
    .byte 4
    .byte 4
    .byte 0
    .byte $A4
    .byte $25
    .byte $25
    .byte $A4
    .byte $A8
    .byte $63
    .byte 4
    .byte $85
    .byte $E
    .byte $1A
    .byte $84
    .byte $24
    .byte $85
    .byte $22
    .byte $14
    .byte $84
    .byte $C
unk_DB30:
    .byte $82
    .byte $34
    .byte $84
    .byte $34
    .byte $34
    .byte $82
    .byte $2C
    .byte $84
    .byte $34
    .byte $86
    .byte $3A
    .byte 4
    .byte 0
    .byte $A0
    .byte $21
    .byte $21
    .byte $A0
    .byte $21
    .byte $2B
    .byte 5
    .byte $A3
    .byte $82
    .byte $18
    .byte $84
    .byte $18
    .byte $18
    .byte $82
    .byte $18
    .byte $18
    .byte 4
    .byte $86
    .byte $3A
    .byte $22
    .byte $31
    .byte $90
    .byte $31
    .byte $90
    .byte $31
    .byte $71
    .byte $31
    .byte $90
    .byte $90
    .byte $90
    .byte 0
unk_DB5C:
    .byte $82
    .byte $34
    .byte $84
    .byte $2C
    .byte $85
    .byte $22
    .byte $84
    .byte $24
    .byte $82
    .byte $26
    .byte $36
    .byte 4
    .byte $36
    .byte $86
    .byte $26
    .byte 0
    .byte $AC
    .byte $27
    .byte $5D
    .byte $1D
    .byte $9E
    .byte $2D
    .byte $AC
    .byte $9F
    .byte $85
    .byte $14
    .byte $82
    .byte $20
    .byte $84
    .byte $22
    .byte $2C
    .byte $1E
    .byte $1E
    .byte $82
    .byte $2C
    .byte $2C
    .byte $1E
    .byte 4
unk_DB82:
    .byte $87
    .byte $2A
    .byte $40
    .byte $40
    .byte $40
    .byte $3A
    .byte $36
    .byte $82
    .byte $34
    .byte $2C
    .byte 4
    .byte $26
    .byte $86
    .byte $22
    .byte 0
    .byte $E3
    .byte $F7
    .byte $F7
    .byte $F7
    .byte $F5
    .byte $F1
    .byte $AC
    .byte $27
    .byte $9E
    .byte $9D
    .byte $85
    .byte $18
    .byte $82
    .byte $1E
    .byte $84
    .byte $22
    .byte $2A
    .byte $22
    .byte $22
    .byte $82
    .byte $2C
    .byte $2C
    .byte $22
    .byte 4
unk_DBA9:
    .byte $86
    .byte 4
unk_DBAB:
    .byte $82
    .byte $2A
    .byte $36
    .byte 4
    .byte $36
    .byte $87
    .byte $36
    .byte $34
    .byte $30
    .byte $86
    .byte $2C
    .byte 4
    .byte 0
    .byte 0
    .byte $68
    .byte $6A
    .byte $6C
    .byte $45
    .byte $A2
    .byte $31
    .byte $B0
    .byte $F1
    .byte $ED
    .byte $EB
    .byte $A2
    .byte $1D
    .byte $9C
    .byte $95
    .byte $86
    .byte 4
    .byte $85
    .byte $22
    .byte $82
    .byte $22
    .byte $87
    .byte $22
    .byte $26
    .byte $2A
    .byte $84
    .byte $2C
    .byte $22
    .byte $86
    .byte $14
    .byte $51
    .byte $90
    .byte $31
    .byte $11
    .byte 0
unk_DBDB:
    .byte $80
    .byte $22
    .byte $28
    .byte $22
    .byte $26
    .byte $22
    .byte $24
    .byte $22
    .byte $26
    .byte $22
    .byte $28
    .byte $22
    .byte $2A
    .byte $22
    .byte $28
    .byte $22
    .byte $26
    .byte $22
    .byte $28
    .byte $22
    .byte $26
    .byte $22
    .byte $24
    .byte $22
    .byte $26
    .byte $22
    .byte $28
    .byte $22
    .byte $2A
    .byte $22
    .byte $28
    .byte $22
    .byte $26
    .byte $20
    .byte $26
    .byte $20
    .byte $24
    .byte $20
    .byte $26
    .byte $20
    .byte $28
    .byte $20
    .byte $26
    .byte $20
    .byte $28
    .byte $20
    .byte $26
    .byte $20
    .byte $24
    .byte $20
    .byte $26
    .byte $20
    .byte $24
    .byte $20
    .byte $26
    .byte $20
    .byte $28
    .byte $20
    .byte $26
    .byte $20
    .byte $28
    .byte $20
    .byte $26
    .byte $20
    .byte $24
    .byte $28
    .byte $30
    .byte $28
    .byte $32
    .byte $28
    .byte $30
    .byte $28
    .byte $2E
    .byte $28
    .byte $30
    .byte $28
    .byte $2E
    .byte $28
    .byte $2C
    .byte $28
    .byte $2E
    .byte $28
    .byte $30
    .byte $28
    .byte $32
    .byte $28
    .byte $30
    .byte $28
    .byte $2E
    .byte $28
    .byte $30
    .byte $28
    .byte $2E
    .byte $28
    .byte $2C
    .byte $28
    .byte $2E
    .byte 0
    .byte 4
    .byte $70
    .byte $6E
    .byte $6C
    .byte $6E
    .byte $70
byte_DC43:
    .byte $72
    .byte $70
    .byte $6E
    .byte $70
    .byte $6E
    .byte $6C
    .byte $6E
    .byte $70
    .byte $72
    .byte $70
    .byte $6E
    .byte $6E
    .byte $6C
    .byte $6E
    .byte $70
    .byte $6E
    .byte $70
    .byte $6E
    .byte $6C
    .byte $6E
    .byte $6C
    .byte $6E
    .byte $70
    .byte $6E
    .byte $70
    .byte $6E
    .byte $6C
    .byte $76
    .byte $78
    .byte $76
    .byte $74
    .byte $76
    .byte $74
    .byte $72
    .byte $74
    .byte $76
    .byte $78
    .byte $76
    .byte $74
    .byte $76
    .byte $74
    .byte $72
    .byte $74
    .byte $84
    .byte $1A
    .byte $83
    .byte $18
    .byte $20
    .byte $84
    .byte $1E
    .byte $83
    .byte $1C
    .byte $28
    .byte $26
    .byte $1C
    .byte $1A
    .byte $1C
unk_DC7C:
    .byte $82
    .byte $2C
    .byte 4
    .byte 4
    .byte $22
    .byte 4
    .byte 4
    .byte $84
    .byte $1C
    .byte $87
    .byte $26
    .byte $2A
    .byte $26
    .byte $84
    .byte $24
    .byte $28
    .byte $24
    .byte $80
    .byte $22
    .byte 0
    .byte $9C
    .byte 5
    .byte $94
    .byte 5
    .byte $D
    .byte $9F
    .byte $1E
    .byte $9C
    .byte $98
    .byte $9D
    .byte $82
    .byte $22
    .byte 4
    .byte 4
    .byte $1C
    .byte 4
    .byte 4
    .byte $84
    .byte $14
    .byte $86
    .byte $1E
    .byte $80
    .byte $16
    .byte $80
    .byte $14
unk_DCA9:
    .byte $81
    .byte $1C
    .byte $30
    .byte 4
    .byte $30
    .byte $30
    .byte 4
    .byte $1E
    .byte $32
    .byte 4
    .byte $32
    .byte $32
    .byte 4
    .byte $20
    .byte $34
    .byte 4
    .byte $34
    .byte $34
    .byte 4
    .byte $36
    .byte 4
    .byte $84
    .byte $36
    .byte 0
    .byte $46
    .byte $A4
    .byte $64
    .byte $A4
    .byte $48
    .byte $A6
    .byte $66
    .byte $A6
    .byte $4A
    .byte $A8
    .byte $68
    .byte $A8
    .byte $6A
    .byte $44
    .byte $2B
    .byte $81
    .byte $2A
    .byte $42
    .byte 4
    .byte $42
    .byte $42
    .byte 4
    .byte $2C
    .byte $64
    .byte 4
    .byte $64
    .byte $64
    .byte 4
    .byte $2E
    .byte $46
    .byte 4
    .byte $46
    .byte $46
    .byte 4
    .byte $22
    .byte 4
    .byte $84
    .byte $22
byte_DCE7:
    .byte $87
    .byte 4
    .byte 6
    .byte $C
    .byte $14
    .byte $1C
byte_DCED:
    .byte $22
    .byte $86
    .byte $2C
    .byte $22
    .byte $87
    .byte 4
    .byte $60
    .byte $E
    .byte $14
    .byte $1A
    .byte $24
    .byte $86
    .byte $2C
    .byte $24
unk_DCFB:
    .byte $87
    .byte 4
    .byte 8
    .byte $10
    .byte $18
    .byte $1E
    .byte $28
    .byte $86
    .byte $30
    .byte $30
    .byte $80
    .byte $64
    .byte 0
    .byte $CD
    .byte $D5
    .byte $DD
    .byte $E3
    .byte $ED
    .byte $F5
    .byte $BB
    .byte $B5
    .byte $CF
    .byte $D5
    .byte $DB
    .byte $E5
    .byte $ED
    .byte $F3
    .byte $BD
    .byte $B3
    .byte $D1
    .byte $D9
    .byte $DF
    .byte $E9
    .byte $F1
    .byte $F7
    .byte $BF
    .byte $FF
    .byte $FF
    .byte $FF
    .byte $34
    .byte 0
    .byte $86
    .byte 4
    .byte $87
    .byte $14
    .byte $1C
    .byte $22
    .byte $86
    .byte $34
    .byte $84
    .byte $2C
    .byte 4
    .byte 4
    .byte 4
    .byte $87
    .byte $14
    .byte $1A
    .byte $24
    .byte $86
    .byte $32
    .byte $84
    .byte $2C
    .byte 4
    .byte $86
    .byte 4
    .byte $87
    .byte $18
    .byte $1E
    .byte $28
    .byte $86
    .byte $36
    .byte $87
    .byte $30
    .byte $30
    .byte $30
    .byte $80
    .byte $2C
unk_DD48:
    .byte $82
    .byte $14
    .byte $2C
    .byte $62
    .byte $26
    .byte $10
    .byte $28
    .byte $80
    .byte 4
    .byte $82
    .byte $14
    .byte $2C
    .byte $62
    .byte $26
    .byte $10
    .byte $28
    .byte $80
    .byte 4
    .byte $82
    .byte 8
    .byte $1E
    .byte $5E
    .byte $18
    .byte $60
    .byte $1A
    .byte $80
    .byte 4
    .byte $82
    .byte 8
    .byte $1E
    .byte $5E
    .byte $18
    .byte $60
    .byte $1A
    .byte $86
    .byte 4
    .byte $83
    .byte $1A
    .byte $18
    .byte $16
    .byte $84
    .byte $14
    .byte $1A
    .byte $18
    .byte $E
    .byte $C
    .byte $16
    .byte $83
    .byte $14
    .byte $20
    .byte $1E
    .byte $1C
    .byte $28
    .byte $26
    .byte $87
    .byte $24
    .byte $1A
    .byte $12
    .byte $10
    .byte $62
    .byte $E
    .byte $80
    .byte 4
    .byte 4
    .byte 0
unk_DD89:
    .byte $82
    .byte $18
    .byte $1C
    .byte $20
    .byte $22
    .byte $26
    .byte $28
    .byte $81
    .byte $2A
    .byte $2A
    .byte $2A
    .byte 4
    .byte $2A
    .byte 4
    .byte $83
    .byte $2A
    .byte $82
    .byte $22
    .byte $86
    .byte $34
    .byte $32
    .byte $34
    .byte $81
    .byte 4
    .byte $22
    .byte $26
    .byte $2A
    .byte $2C
    .byte $30
    .byte $86
    .byte $34
    .byte $83
    .byte $32
    .byte $82
    .byte $36
    .byte $84
    .byte $34
    .byte $85
    .byte 4
    .byte $81
    .byte $22
    .byte $86
    .byte $30
    .byte $2E
    .byte $30
    .byte $81
    .byte 4
    .byte $22
    .byte $26
    .byte $2A
    .byte $2C
    .byte $2E
    .byte $86
    .byte $30
    .byte $83
    .byte $22
    .byte $82
    .byte $36
    .byte $84
    .byte $34
    .byte $85
    .byte 4
    .byte $81
    .byte $22
    .byte $86
    .byte $3A
    .byte $3A
    .byte $3A
    .byte $82
    .byte $3A
    .byte $81
    .byte $40
    .byte $82
    .byte 4
    .byte $81
    .byte $3A
    .byte $86
    .byte $36
    .byte $36
    .byte $36
    .byte $82
    .byte $36
    .byte $81
    .byte $3A
    .byte $82
    .byte 4
    .byte $81
    .byte $36
    .byte $86
    .byte $34
    .byte $82
    .byte $26
    .byte $2A
    .byte $36
    .byte $81
    .byte $34
    .byte $34
    .byte $85
    .byte $34
    .byte $81
    .byte $2A
    .byte $86
    .byte $2C
    .byte 0
    .byte $84
    .byte $90
    .byte $B0
    .byte $84
    .byte $50
    .byte $50
    .byte $B0
    .byte 0
    .byte $98
    .byte $96
    .byte $94
    .byte $92
    .byte $94
    .byte $96
    .byte $58
    .byte $58
    .byte $58
    .byte $44
    .byte $5C
    .byte $44
    .byte $9F
    .byte $A3
    .byte $A1
    .byte $A3
    .byte $85
    .byte $A3
    .byte $E0
    .byte $A6
    .byte $23
    .byte $C4
    .byte $9F
    .byte $9D
    .byte $9F
    .byte $85
    .byte $9F
    .byte $D2
    .byte $A6
    .byte $23
    .byte $C4
    .byte $B5
    .byte $B1
    .byte $AF
    .byte $85
    .byte $B1
    .byte $AF
    .byte $AD
    .byte $85
    .byte $95
    .byte $9E
    .byte $A2
    .byte $AA
    .byte $6A
    .byte $6A
    .byte $6B
    .byte $5E
    .byte $9D
    .byte $84
    .byte 4
    .byte 4
    .byte $82
    .byte $22
    .byte $86
    .byte $22
    .byte $82
    .byte $14
    .byte $22
    .byte $2C
    .byte $12
    .byte $22
    .byte $2A
    .byte $14
    .byte $22
    .byte $2C
    .byte $1C
    .byte $22
    .byte $2C
    .byte $14
    .byte $22
    .byte $2C
    .byte $12
    .byte $22
    .byte $2A
    .byte $14
    .byte $22
    .byte $2C
    .byte $1C
    .byte $22
    .byte $2C
    .byte $18
    .byte $22
    .byte $2A
    .byte $16
    .byte $20
    .byte $28
    .byte $18
    .byte $22
    .byte $2A
    .byte $12
    .byte $22
    .byte $2A
    .byte $18
    .byte $22
    .byte $2A
    .byte $12
    .byte $22
    .byte $2A
    .byte $14
    .byte $22
    .byte $2C
    .byte $C
    .byte $22
    .byte $2C
    .byte $14
    .byte $22
    .byte $34
    .byte $12
    .byte $22
    .byte $30
    .byte $10
    .byte $22
    .byte $2E
    .byte $16
    .byte $22
    .byte $34
    .byte $18
    .byte $26
    .byte $36
    .byte $16
    .byte $26
    .byte $36
    .byte $14
    .byte $26
    .byte $36
    .byte $12
    .byte $22
    .byte $36
    .byte $5C
    .byte $22
    .byte $34
    .byte $C
    .byte $22
    .byte $22
    .byte $81
    .byte $1E
    .byte $1E
    .byte $85
    .byte $1E
    .byte $81
    .byte $12
    .byte $86
    .byte $14
unk_DE88:
    .byte $81
    .byte $2C
    .byte $22
    .byte $1C
    .byte $2C
    .byte $22
    .byte $1C
    .byte $85
    .byte $2C
    .byte 4
    .byte $81
    .byte $2E
    .byte $24
    .byte $1E
    .byte $2E
    .byte $24
    .byte $1E
    .byte $85
    .byte $2E
    .byte 4
    .byte $81
    .byte $32
    .byte $28
    .byte $22
    .byte $32
    .byte $28
    .byte $22
    .byte $85
    .byte $32
    .byte $87
    .byte $36
    .byte $36
    .byte $36
    .byte $84
    .byte $3A
    .byte 0
    .byte $5C
    .byte $54
    .byte $4C
    .byte $5C
    .byte $54
    .byte $4C
    .byte $5C
    .byte $1C
    .byte $1C
    .byte $5C
    .byte $5C
    .byte $5C
    .byte $5C
    .byte $5E
    .byte $56
    .byte $4E
    .byte $5E
    .byte $56
    .byte $4E
    .byte $5E
    .byte $1E
    .byte $1E
    .byte $5E
    .byte $5E
    .byte $5E
    .byte $5E
    .byte $62
    .byte $5A
    .byte $50
    .byte $62
    .byte $5A
    .byte $50
    .byte $62
    .byte $22
    .byte $22
    .byte $62
    .byte $E7
    .byte $E7
    .byte $E7
    .byte $2B
    .byte $86
    .byte $14
    .byte $81
    .byte $14
    .byte $80
    .byte $14
    .byte $14
    .byte $81
    .byte $14
    .byte $14
    .byte $14
    .byte $14
    .byte $86
    .byte $16
    .byte $81
    .byte $16
    .byte $80
    .byte $16
    .byte $16
    .byte $81
    .byte $16
    .byte $16
    .byte $16
    .byte $16
    .byte $81
    .byte $28
    .byte $22
    .byte $1A
    .byte $28
    .byte $22
    .byte $1A
    .byte $28
    .byte $80
    .byte $28
    .byte $28
    .byte $81
    .byte $28
    .byte $87
    .byte $2C
    .byte $2C
    .byte $2C
    .byte $84
    .byte $30
    .byte $FF
unk_DF00:
    .byte 0
unk_DF01:
    .byte $88
    .byte 0
    .byte $2F
    .byte 0
    .byte 0
    .byte 2
    .byte $A6
    .byte 2
    .byte $80
    .byte 2
    .byte $5C
    .byte 2
    .byte $3A
    .byte 2
    .byte $1A
    .byte 1
    .byte $DF
    .byte 1
    .byte $C4
    .byte 1
    .byte $AB
    .byte 1
    .byte $93
    .byte 1
    .byte $7C
    .byte 1
    .byte $67
    .byte 1
    .byte $53
    .byte 1
    .byte $40
    .byte 1
    .byte $2E
    .byte 1
    .byte $1D
    .byte 1
    .byte $D
    .byte 0
    .byte $FE
    .byte 0
    .byte $EF
    .byte 0
    .byte $E2
    .byte 0
    .byte $D5
    .byte 0
    .byte $C9
    .byte 0
    .byte $BE
    .byte 0
    .byte $B3
    .byte 0
    .byte $A9
    .byte 0
    .byte $A0
    .byte 0
    .byte $97
    .byte 0
    .byte $8E
    .byte 0
    .byte $86
    .byte 0
    .byte $77
    .byte 0
    .byte $7E
    .byte 0
    .byte $71
    .byte 0
    .byte $54
    .byte 0
    .byte $64
    .byte 0
    .byte $5F
    .byte 0
    .byte $59
    .byte 0
    .byte $50
    .byte 0
    .byte $47
    .byte 0
    .byte $43
    .byte 0
    .byte $3B
    .byte 0
    .byte $35
    .byte 0
    .byte $2A
    .byte 0
    .byte $23
    .byte 4
    .byte $75
    .byte 3
    .byte $57
    .byte 2
    .byte $F9
    .byte 2
    .byte $CF
    .byte 1
    .byte $FC
    .byte 0
    .byte $6A
LL_MusicLengthLookupTbl:
    .byte 5
    .byte $A
    .byte $14
    .byte $28
    .byte $50
    .byte $1E
    .byte $3C
    .byte 2
    .byte 4
    .byte 8
    .byte $10
    .byte $20
    .byte $40
    .byte $18
    .byte $30
    .byte $C
    .byte 3
    .byte 6
    .byte $C
    .byte $18
    .byte $30
    .byte $12
    .byte $24
    .byte 8
    .byte $36
    .byte 3
    .byte 9
    .byte 6
    .byte $12
    .byte $1B
    .byte $24
    .byte $C
    .byte $24
    .byte 2
    .byte 6
    .byte 4
    .byte $C
    .byte $12
    .byte $18
    .byte 8
    .byte $12
    .byte 1
    .byte 3
    .byte 2
    .byte 6
    .byte 9
    .byte $C
    .byte 4
LL_EndOfCastleMusicEnvData:
    .byte $98
    .byte $99
    .byte $9A
    .byte $9B
LL_AreaMusicEnvData:
    .byte $90
    .byte $94
    .byte $94
    .byte $95
    .byte $95
    .byte $96
    .byte $97
    .byte $98
LL_WaterEventMusEnvData:
    .byte $90
    .byte $91
    .byte $92
    .byte $92
    .byte $93
    .byte $93
    .byte $93
    .byte $94
    .byte $94
    .byte $94
    .byte $94
    .byte $94
    .byte $94
    .byte $95
    .byte $95
    .byte $95
    .byte $95
    .byte $95
    .byte $95
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $96
    .byte $95
    .byte $95
    .byte $94
unk_DFC9:
    .byte $93
    .byte $15
    .byte $16
    .byte $16
    .byte $17
    .byte $17
    .byte $18
    .byte $19
    .byte $19
    .byte $1A
    .byte $1A
    .byte $1C
    .byte $1D
    .byte $1D
    .byte $1E
    .byte $1E
    .byte $1F
    .byte $1F
    .byte $1F
    .byte $1F
    .byte $1E
    .byte $1D
    .byte $1C
    .byte $1E
    .byte $1F
    .byte $1F
    .byte $1E
    .byte $1D
    .byte $1C
    .byte $1A
    .byte $18
    .byte $16
    .byte $14
unk_DFEA:
    .byte $15
    .byte $16
    .byte $16
    .byte $17
    .byte $17
    .byte $18
    .byte $19
    .byte $19
    .byte $1A
    .byte $1A
    .byte $1C
    .byte $1D
    .byte $1D
    .byte $1E
    .byte $1E
    .byte $1F
