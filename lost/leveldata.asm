.ifdef ANN
.export ANN_LoadAreaPointer
.export ANN_GetAreaPointer
.export ANN_GetAreaDataAddrs
.export ANN_RestoreAreaAndEnemyRAMAfterLoad
.else
.export LL_LoadAreaPointer
.export LL_GetAreaPointer
.export LL_GetAreaDataAddrs
.export LL_RestoreAreaAndEnemyRAMAfterLoad
.endif
.include "wram.inc"

.ifdef ANN
ANN_LoadAreaPointer:
.else
LL_LoadAreaPointer:
.endif
LoadAreaPointer:
LoadAreaPointerLW:
  jsr FindAreaPointer ;find it and store it here
  sta AreaPointer
  sta WRAM_LevelAreaPointer
GetAreaType:
  and #%01100000
  asl a
  rol a
  rol a
  rol a
  sta AreaType
  sta WRAM_LevelAreaType
  rts


FindAreaPointer:
  lda HardWorldFlag
  bne @HardWorld
  ldy WorldNumber        ;load offset from world variable
  lda WorldAddrOffsets,y
  clc                    ;add area number used to find data
  adc AreaNumber
  tay
  lda AreaAddrOffsets,y  ;from there we have our area pointer
  rts
@HardWorld:
  ldy WorldNumber        ;load offset from world variable
  lda WorldAddrOffsetsLW,y
  clc                    ;add area number used to find data
  adc AreaNumber
  tay
  lda AreaAddrOffsetsLW,y  ;from there we have our area pointer
  rts

.ifdef ANN
ANN_GetAreaPointer:
.else
LL_GetAreaPointer:
.endif
GetAreaPointer:
  lda HardWorldFlag
  bne @HardWorld
  ldx WorldAddrOffsets,y    ;get offset to where this world's area offsets are
  ldy AreaAddrOffsets,x     ;get area offset based on world offset
  rts
@HardWorld:
  ldx WorldAddrOffsetsLW,y    ;get offset to where this world's area offsets are
  ldy AreaAddrOffsetsLW,x     ;get area offset based on world offset
  rts


.ifdef ANN
ANN_GetAreaDataAddrs:
.else
LL_GetAreaDataAddrs:
.endif
GetAreaDataAddrs:
  lda AreaPointer
  jsr GetAreaType
  tay
  lda AreaPointer
  and #%00011111
  sta AreaAddrsLOffset
  lda HardWorldFlag
  bne @HardWorld
  lda EnemyAddrHOffsets,y
  clc
  adc AreaAddrsLOffset
  asl a
  tay
  lda EnemyDataAddrs+1,y
  sta EnemyDataHigh
  sta WRAM_EnemyDataPtr+1
  lda EnemyDataAddrs+0,y
  sta EnemyDataLow
  sta WRAM_EnemyDataPtr+0
  ldy AreaType
  lda AreaDataHOffsets,y
  clc
  adc AreaAddrsLOffset
  asl a
  tay
  lda AreaDataAddrs+1,y
  sta AreaDataHigh
  sta WRAM_AreaDataPtr+1
  lda AreaDataAddrs+0,y
  sta AreaDataLow
  sta WRAM_AreaDataPtr+0
  clc
  bcc @Shared
@HardWorld:
  lda EnemyAddrHOffsetsLW,y
  clc
  adc AreaAddrsLOffset
  asl a
  tay
  lda EnemyDataAddrsLW+1,y
  sta EnemyDataHigh
  sta WRAM_EnemyDataPtr+1
  lda EnemyDataAddrsLW+0,y
  sta EnemyDataLow
  sta WRAM_EnemyDataPtr+0
  ldy AreaType
  lda AreaDataHOffsetsLW,y
  clc
  adc AreaAddrsLOffset
  asl a
  tay
  lda AreaDataAddrsLW+1,y
  sta AreaDataHigh
  sta WRAM_AreaDataPtr+1
  lda AreaDataAddrsLW+0,y
  sta AreaDataLow
  sta WRAM_AreaDataPtr+0
@Shared:


            ldy #$00                 ;load first byte of header
            lda (AreaData),y     
            pha                      ;save it to the stack for now
            and #%00000111           ;save 3 LSB for foreground scenery or bg color control
            cmp #$04
            bcc StoreFore
            sta BackgroundColorCtrl  ;if 4 or greater, save value here as bg color control
            lda #$00
StoreFore:  sta ForegroundScenery    ;if less, save value here as foreground scenery
            pla                      ;pull byte from stack and push it back
            pha
            and #%00111000           ;save player entrance control bits
            lsr                      ;shift bits over to LSBs
            lsr
            lsr
            sta PlayerEntranceCtrl       ;save value here as player entrance control
            pla                      ;pull byte again but do not push it back
            and #%11000000           ;save 2 MSB for game timer setting
            clc
            rol                      ;rotate bits over to LSBs
            rol
            rol
            sta GameTimerSetting     ;save value here as game timer setting
            iny
            lda (AreaData),y         ;load second byte of header
            pha                      ;save to stack
            and #%00001111           ;mask out all but lower nybble
            sta TerrainControl
            pla                      ;pull and push byte to copy it to A
            pha
            and #%00110000           ;save 2 MSB for background scenery type
            lsr
            lsr                      ;shift bits to LSBs
            lsr
            lsr
            sta BackgroundScenery    ;save as background scenery
            pla           
            and #%11000000
            clc
            rol                      ;rotate bits over to LSBs
            rol
            rol
            cmp #%00000011           ;if set to 3, store here
            bne StoreStyle           ;and nullify other value
            sta CloudTypeOverride    ;otherwise store value in other place
            lda #$00
StoreStyle: sta AreaStyle
            jsr CopyAreaAndEnemyData
            lda AreaDataLow          ;increment area data address by 2 bytes
            clc
            adc #$02
            sta AreaDataLow
            lda AreaDataHigh
            adc #$00
            sta AreaDataHigh
            rts

CopyAreaAndEnemyData:
  ldy #0                  ; copy current area data to PRG-RAM
: lda (AreaData),y        ; so we don't need to bank as much
  sta AreaDataRAM,y       ;
  iny                     ;
  cmp #$FD                ; area data EOF is $FD
  bne :-                  ;
  lda #>AreaDataRAM       ; and move the areadata pointers to ram.
  sta AreaDataHigh        ;
  lda #<AreaDataRAM       ;
  sta AreaDataLow         ;
  ldy #0                  ; then copy enemy data..
: lda (EnemyData),y       ;
  sta EnemyDataRAM,y      ;
  iny                     ;
  cmp #$FF                ; enemy data EOF is $FF
  bne :-                  ;
  lda #>EnemyDataRAM      ; and move the enemydata pointers to ram.
  sta EnemyDataHigh       ;
  lda #<EnemyDataRAM      ;
  sta EnemyDataLow        ;
  rts                     ; there we are.

.ifdef ANN
ANN_RestoreAreaAndEnemyRAMAfterLoad:
.else
LL_RestoreAreaAndEnemyRAMAfterLoad:
.endif
  ldy #0                  ; copy current area data to PRG-RAM
  lda WRAM_AreaDataPtr+1
  sta $1
  lda WRAM_AreaDataPtr+0
  sta $0
: lda ($0),y              ; so we don't need to bank as much
  sta AreaDataRAM,y       ;
  iny                     ;
  cmp #$FD                ; area data EOF is $FD
  bne :-                  ;
  ldy #0                  ; then copy enemy data..
  lda WRAM_EnemyDataPtr+1
  sta $1
  lda WRAM_EnemyDataPtr+0
  sta $0
: lda ($0),y       ;
  sta EnemyDataRAM,y      ;
  iny                     ;
  cmp #$FF                ; enemy data EOF is $FF
  bne :-                  ;
  rts


; Letter worlds

WorldAddrOffsetsLW:
  .byte WorldAAreas-AreaAddrOffsetsLW, WorldBAreas-AreaAddrOffsetsLW
  .byte WorldCAreas-AreaAddrOffsetsLW, WorldDAreas-AreaAddrOffsetsLW

AreaAddrOffsetsLW:
WorldAAreas: .byte $20, $2c, $40, $21, $60
WorldBAreas: .byte $22, $2c, $00, $23, $61
WorldCAreas: .byte $24, $25, $26, $62
WorldDAreas: .byte $27, $28, $29, $63

EnemyAddrHOffsetsLW:
     .byte $14, $04, $12, $00

EnemyDataAddrsLW:
.ifdef ANN
     .addr E_HArea00,E_HArea01,E_HArea02,E_HArea03,E_HArea04,E_HArea05,E_HArea06,E_HArea07
     .addr E_HArea08,E_HArea09,E_HArea0A,E_HArea0B,E_HArea0C,E_HArea0D,E_HArea0E,E_HArea0F
     .addr E_HArea10,E_HArea11,E_HArea12,E_HArea13,E_HArea14
.else
     .word E_CastleArea11, E_CastleArea12, E_CastleArea13, E_CastleArea14, E_GroundArea30, E_GroundArea31
     .word E_GroundArea32, E_GroundArea33, E_GroundArea34, E_GroundArea35, E_GroundArea36, E_GroundArea37
     .word E_GroundArea38, E_GroundArea39, E_GroundArea40, E_GroundArea41, E_GroundArea21, E_GroundArea28
     .word E_UndergroundArea6, E_UndergroundArea7, E_WaterArea9
.endif

AreaDataHOffsetsLW:
     .byte $14, $04, $12, $00

AreaDataAddrsLW:
.ifdef ANN
     .addr L_HArea00,L_HArea01,L_HArea02,L_HArea03,L_HArea04,L_HArea05,L_HArea06,L_HArea07
     .addr L_HArea08,L_HArea09,L_HArea0A,L_HArea0B,L_HArea0C,L_HArea0D,L_HArea0E,L_HArea0F
     .addr L_HArea10,L_HArea11,L_HArea12,L_HArea13,L_HArea14
.else
     .word L_CastleArea11, L_CastleArea12, L_CastleArea13, L_CastleArea14, L_GroundArea30, L_GroundArea31
     .word L_GroundArea32, L_GroundArea33, L_GroundArea34, L_GroundArea35, L_GroundArea36, L_GroundArea37
     .word L_GroundArea38, L_GroundArea39, L_GroundArea40, L_GroundArea41, L_GroundArea10, L_GroundArea28
     .word L_UndergroundArea6, L_UndergroundArea7, L_WaterArea9
.endif







;-------------------------------------------------------------------------------------

WorldAddrOffsets:
  .byte World1Areas-AreaAddrOffsets, World2Areas-AreaAddrOffsets
  .byte World3Areas-AreaAddrOffsets, World4Areas-AreaAddrOffsets
  .byte World5Areas-AreaAddrOffsets, World6Areas-AreaAddrOffsets
  .byte World7Areas-AreaAddrOffsets, World8Areas-AreaAddrOffsets
.ifndef ANN
  .byte World9Areas-AreaAddrOffsets
.endif

AreaAddrOffsets:
.ifdef ANN
World1Areas: .byte $25, $3B, $C0, $26, $60
World2Areas: .byte $28, $29, $01, $27, $62
World3Areas: .byte $24, $35, $20, $63
World4Areas: .byte $22, $29, $41, $2C, $61
World5Areas: .byte $2A, $31, $36, $67
World6Areas: .byte $2E, $23, $2D, $66
World7Areas: .byte $33, $29, $03, $37, $64
World8Areas: .byte $30, $32, $21, $65
.else
World1Areas: .byte $20, $29, $40, $21, $60
World2Areas: .byte $22, $23, $24, $61
World3Areas: .byte $25, $29, $00, $26, $62
World4Areas: .byte $27, $28, $2a, $63
World5Areas: .byte $2b, $29, $43, $2c, $64
World6Areas: .byte $2d, $29, $01, $2e, $65
World7Areas: .byte $2f, $30, $31, $66
World8Areas: .byte $32, $35, $36, $67
World9Areas: .byte $38, $06, $68, $07
.endif

AreaDataOfsLoopback:
.ifdef ANN
  .byte $12, $36, $0E, $0E, $0E, $32, $32, $32, $0C, $54 
.else
  .byte $0c, $0c, $42, $42, $10, $10, $30, $30, $06, $0c, $54, $06
.endif

EnemyAddrHOffsets:
.ifdef ANN
  .byte $28, $08, $24, $00
.else
  .byte $2c, $0a, $27, $00
.endif

EnemyDataAddrs:
.ifdef ANN
.addr E_Area00, E_Area01, E_Area02, E_Area03, E_Area04, E_Area05, E_Area06, E_Area07
.addr E_Area08, E_Area09, E_Area0A, E_Area0B, E_Area0C, E_Area0D, E_Area0E, E_Area0F
.addr E_Area10, E_Area11, E_Area12, E_Area13, E_Area14, E_Area15, E_Area16, E_Area17
.addr E_Area18, E_Area19, E_Area1A, E_Area1B, E_Area1C, E_Area1D, E_Area1E, E_Area1F
.addr E_Area20, E_Area21, E_Area22, E_Area23, E_Area24, E_Area25, E_Area26, E_Area27
.addr E_Area28, E_Area29, E_Area2A, E_Area2B, E_Area11
.else
  .word E_CastleArea1, E_CastleArea2, E_CastleArea3, E_CastleArea4, E_CastleArea5, E_CastleArea6
  .word E_CastleArea7, E_CastleArea8, E_CastleArea9, E_CastleArea10, E_GroundArea1, E_GroundArea2
  .word E_GroundArea3, E_GroundArea4, E_GroundArea5, E_GroundArea6, E_GroundArea7, E_GroundArea8
  .word E_GroundArea9, E_GroundArea10, E_GroundArea11, E_GroundArea12, E_GroundArea13, E_GroundArea14
  .word E_GroundArea15, E_GroundArea16, E_GroundArea17, E_GroundArea18, E_GroundArea19, E_GroundArea20
  .word E_GroundArea21, E_GroundArea22, E_GroundArea23, E_GroundArea24, E_GroundArea25, E_GroundArea26
  .word E_GroundArea27, E_GroundArea28, E_GroundArea29, E_UndergroundArea1, E_UndergroundArea2
  .word E_UndergroundArea3, E_UndergroundArea4, E_UndergroundArea5, E_WaterArea1, E_WaterArea2
  .word E_WaterArea3, E_WaterArea4, E_WaterArea5, E_WaterArea6, E_WaterArea7, E_WaterArea8
.endif

AreaDataHOffsets:
.ifdef ANN
  .byte $28, $08, $24, $00
.else
  .byte $2c, $0a, $27, $00
.endif

AreaDataAddrs:
.ifdef ANN
.addr L_Area00, L_Area01, L_Area02, L_Area03, L_Area04, L_Area05, L_Area06, L_Area07
.addr L_Area08, L_Area09, L_Area0A, L_Area0B, L_Area0C, L_Area0D, L_Area0E, L_Area0F
.addr L_Area10, L_Area11, L_Area12, L_Area13, L_Area14, L_Area15, L_Area16, L_Area17
.addr L_Area18, L_Area19, L_Area1A, L_Area1B, L_Area1C, L_Area1D, L_Area1E, L_Area1F
.addr L_Area20, L_Area21, L_Area22, L_Area23, L_Area24, L_Area25, L_Area26, L_Area27
.addr L_Area28, L_Area29, L_Area2A, L_Area2B, L_Area2C
.else
  .word L_CastleArea1, L_CastleArea2, L_CastleArea3, L_CastleArea4, L_CastleArea5, L_CastleArea6
  .word L_CastleArea7, L_CastleArea8, L_CastleArea9, L_CastleArea10, L_GroundArea1, L_GroundArea2
  .word L_GroundArea3, L_GroundArea4, L_GroundArea5, L_GroundArea6, L_GroundArea7, L_GroundArea8
  .word L_GroundArea9, L_GroundArea10, L_GroundArea11, L_GroundArea12, L_GroundArea13, L_GroundArea14
  .word L_GroundArea15, L_GroundArea16, L_GroundArea17, L_GroundArea18, L_GroundArea19, L_GroundArea20
  .word L_GroundArea21, L_GroundArea22, L_GroundArea23, L_GroundArea24, L_GroundArea25, L_GroundArea26
  .word L_GroundArea27, L_GroundArea28, L_GroundArea29, L_UndergroundArea1, L_UndergroundArea2
  .word L_UndergroundArea3, L_UndergroundArea4, L_UndergroundArea5, L_WaterArea1, L_WaterArea2
  .word L_WaterArea3, L_WaterArea4, L_WaterArea5, L_WaterArea6, L_WaterArea7, L_WaterArea8
.endif

;-------------------------------------------------------------------------------------

;GAME LEVELS DATA


.ifndef ANN

;-------------------------------------------------------------------------------------

;enemy data used by pipe intro area, warp zone area and exit area
E_GroundArea10:
E_GroundArea21:
E_GroundArea28:
  .byte $ff

;exit area used in levels 1-2, 3-2, 5-2, 6-2, A-2 and B-2
L_GroundArea28:
  .byte $90, $31, $39, $f1, $bf, $37, $33, $e7, $a3, $03, $a7, $03, $cd, $41, $0f, $a6
  .byte $ed, $47, $fd

;pipe intro area
L_GroundArea10:
  .byte $38, $11, $0f, $26, $ad, $40, $3d, $c7, $fd

;warp zone area used in levels 1-2 and 5-2
L_GroundArea21:
  .byte $10, $00, $0b, $13, $5b, $14, $6a, $42, $c7, $12, $c6, $42, $1b, $94, $2a, $42
  .byte $53, $13, $62, $41, $97, $17, $a6, $45, $6e, $81, $8f, $37, $02, $e8, $12, $3a
  .byte $68, $7a, $de, $0f, $6d, $c5, $fd
.else
E_Area11:
E_Area20:
E_Area2C:
E_HArea10:
E_HArea11:
.byte $FF

L_Area11:
L_HArea10:
.byte $38,$11,$0F,$26,$AD,$40,$3D,$C7,$FD

L_Area20:
L_HArea11:
.byte $90,$31,$39,$F1,$5F,$38,$6D,$C1,$AF,$26,$8D,$C7
L_Area2C:
.byte $FD
.endif



.ifdef ANN
E_Area00:
.byte $ea,$9d,$0f,$03,$16,$1d,$c6,$1d,$36,$9d,$c9,$1d,$49,$9d,$84,$1b
.byte $c9,$1d,$88,$95,$0f,$08,$78,$2d,$a6,$28,$90,$b5,$ff
E_Area01:
.byte $0f,$03,$56,$1b,$c9,$1b,$0f,$07,$36,$1b,$aa,$1b,$48,$95,$0f,$0a
.byte $2a,$1b,$5b,$0c,$78,$2d,$90,$b5,$ff
E_Area02:
.byte $0b,$8c,$77,$1b,$eb,$0c,$0f,$03,$19,$1d,$75,$1d,$d9,$1d,$99,$9d
.byte $26,$9d,$5a,$2b,$8a,$2c,$ca,$1b,$20,$95,$0f,$08,$78,$2d,$a6,$28
.byte $90,$b5,$ff
E_Area03:
.byte $0b,$8c,$3b,$1d,$8b,$1d,$ab,$0c,$db,$1d,$b5,$9b,$65,$9d,$6b,$1b
.byte $0b,$9b,$05,$9d,$0b,$1b,$8b,$0c,$1b,$8c,$70,$15,$7b,$0c,$db,$0c
.byte $0f,$08,$78,$2d,$a6,$28,$90,$b5,$ff
E_Area08:
.byte $a5,$86,$e4,$28,$18,$a8,$45,$83,$69,$03,$c6,$29,$9b,$83,$16,$a9
.byte $88,$29,$7b,$a8,$24,$8f,$c8,$03,$e8,$03,$46,$a8,$85,$24,$c8,$24
.byte $ff
E_Area0A:
.byte $2e,$c2,$66,$e2,$11,$0f,$07,$02,$11,$0f,$0c,$12,$11,$18,$10,$ff
E_Area0C:
.byte $9b,$8e,$ca,$0e,$ee,$42,$44,$5b,$86,$80,$b8,$1b,$80,$50,$ba,$10
.byte $b7,$5b,$00,$17,$85,$4b,$05,$fe,$34,$40,$b7,$86,$c6,$06,$5b,$80
.byte $83,$00,$d0,$38,$5b,$8e,$8a,$0e,$a6,$00,$bb,$0e,$c5,$80,$f3,$00
.byte $ff
E_Area0D:
.byte $1e,$c2,$00,$6b,$06,$8b,$86,$63,$b7,$0f,$05,$03,$06,$23,$06,$4b
.byte $b7,$bb,$00,$5b,$b7,$fb,$37,$3b,$b7,$0f,$0b,$1b,$37,$ff
E_Area0E:
.byte $e3,$83,$c2,$86,$e2,$06,$76,$a5,$a3,$8f,$03,$86,$68,$28,$e9,$28
.byte $e5,$83,$24,$8f,$36,$a8,$5b,$03,$ff
E_Area0F:
.byte $b8,$80,$0f,$03,$08,$0e,$ff
E_Area10:
.byte $85,$86,$0b,$80,$1b,$00,$db,$37,$77,$80,$eb,$37,$fe,$2b,$20,$2b
.byte $80,$7b,$38,$ab,$b8,$77,$86,$fe,$42,$20,$49,$86,$8b,$06,$53,$8f
.byte $9b,$03,$07,$90,$5b,$03,$5b,$b7,$9b,$0e,$bb,$0e,$9b,$80,$ff
E_Area13:
.byte $0a,$aa,$0e,$28,$2a,$ff
E_Area14:
.byte $c7,$83,$d7,$03,$42,$8f,$7a,$03,$05,$a4,$78,$24,$a6,$25,$e4,$25
.byte $4b,$83,$e3,$03,$06,$a9,$89,$29,$b6,$29,$09,$a9,$66,$29,$c9,$29
.byte $0f,$08,$85,$25
E_Area17:
.byte $ff
E_Area1C:
.byte $0a,$aa,$0e,$24,$4a,$ff
E_Area1D:
.byte $1b,$80,$bb,$38,$4b,$bc,$eb,$3b,$0f,$04,$2b,$00,$ab,$38,$eb,$00
.byte $cb,$8e,$fb,$80,$9b,$b8,$6b,$80,$fb,$3c,$9b,$bb,$5b,$bc,$fb,$00
.byte $6b,$b8,$fb,$38
E_Area23:
.byte $ff
E_Area24:
.byte $0b,$86,$1a,$06,$db,$06,$de,$c2,$02,$f0,$3b,$bb,$80,$eb,$06,$0b
.byte $86,$93,$06,$f0,$39,$0f,$06,$60,$b8,$1b,$86,$a0,$b9,$b7,$27,$bd
.byte $27,$2b,$83,$a1,$26,$a9,$26,$ee,$25,$0b,$27,$b4,$ff
E_Area25:
.byte $f7,$80,$1e,$af,$60,$e0,$3a,$a5,$a7,$db,$80,$3b,$82,$8b,$02,$fe
.byte $42,$68,$70,$bb,$25,$a7,$2c,$27,$b2,$26,$b9,$26,$9b,$80,$a8,$82
.byte $b5,$27,$bc,$27,$bb,$83,$3b,$82,$87,$34,$ee,$38,$61,$ff
E_Area26:
.byte $1e,$a5,$0a,$2e,$28,$27,$0f,$03,$1e,$40,$07,$0f,$05,$1e,$24,$44
.byte $0f,$07,$1e,$22,$6a,$0f,$09,$1e,$41,$68,$ff
E_Area29:
.byte $2e,$b8,$21,$2e,$38,$41,$6b,$07,$97,$47,$e9,$87,$7a,$87,$0f,$05
.byte $78,$07,$38,$87,$e3,$07,$9b,$87,$ff
L_Area00:
.byte $9b,$07,$05,$32,$06,$33,$07,$34,$ce,$03,$dc,$51,$ee,$07,$7e,$86
.byte $9e,$0a,$ce,$06,$e4,$00,$e8,$0b,$fe,$0a,$2e,$89,$4e,$0b,$14,$8b
.byte $c4,$0b,$34,$8b,$7e,$06,$c7,$0b,$47,$8b,$81,$60,$82,$0b,$c7,$0b
.byte $0e,$87,$7e,$02,$a7,$02,$b3,$02,$d7,$02,$e3,$02,$07,$82,$13,$02
.byte $3e,$06,$7e,$02,$ae,$07,$fe,$0a,$0d,$c4,$cd,$43,$ce,$09,$de,$0b
.byte $dd,$42,$fe,$02,$5d,$c7,$fd
L_Area01:
.byte $5b,$07,$05,$32,$06,$33,$07,$34,$5e,$0a,$68,$64,$98,$64,$a8,$64
.byte $ce,$06,$fe,$02,$0d,$01,$1e,$0e,$7e,$02,$94,$63,$b4,$63,$d4,$63
.byte $f4,$63,$14,$e3,$2e,$0e,$5e,$02,$64,$35,$88,$72,$be,$0e,$0d,$04
.byte $ae,$02,$ce,$08,$cd,$4b,$fe,$02,$0d,$05,$68,$31,$7e,$0a,$96,$31
.byte $a9,$63,$a8,$33,$d5,$30,$ee,$02,$e6,$62,$f4,$61,$04,$b0,$54,$32
.byte $78,$02,$93,$64,$98,$36,$a4,$31,$e4,$31,$04,$bf,$08,$3f,$04,$bf
.byte $08,$3f,$cd,$4b,$04,$e3,$0e,$03,$2e,$01,$7e,$06,$be,$02,$de,$06
.byte $fe,$0a,$0d,$c4,$cd,$43,$ce,$09,$de,$0b,$dd,$42,$fe,$02,$5d,$c7
.byte $fd
L_Area02:
.byte $9b,$07,$05,$32,$06,$33,$07,$34,$fe,$00,$27,$b1,$65,$32,$75,$0b
.byte $71,$00,$b7,$31,$08,$e4,$18,$64,$1e,$04,$57,$3b,$17,$8b,$27,$3a
.byte $73,$0b,$d7,$0b,$e7,$3a,$97,$8b,$fe,$08,$24,$8b,$2e,$00,$3e,$40
.byte $38,$64,$6f,$00,$9f,$00,$be,$43,$c8,$0b,$c9,$63,$ce,$07,$fe,$07
.byte $2e,$81,$66,$42,$6a,$42,$79,$08,$be,$00,$c8,$64,$f8,$64,$08,$e4
.byte $2e,$07,$7e,$03,$9e,$07,$be,$03,$de,$07,$fe,$0a,$03,$88,$0d,$44
.byte $13,$24,$cd,$43,$ce,$09,$dd,$42,$de,$0b,$fe,$02,$5d,$c7,$fd
L_Area03:
.byte $9b,$07,$05,$32,$06,$33,$07,$34,$fe,$06,$0c,$81,$39,$0b,$5c,$01
.byte $89,$0b,$ac,$01,$d9,$0b,$fc,$01,$2e,$83,$a6,$42,$a7,$01,$b3,$0b
.byte $b7,$00,$c7,$01,$de,$0a,$fe,$02,$4e,$83,$5a,$32,$63,$0b,$69,$0b
.byte $7e,$02,$ee,$03,$fa,$32,$09,$8b,$1e,$02,$ee,$03,$fa,$32,$03,$8b
.byte $09,$0b,$14,$42,$1e,$02,$7e,$0a,$9e,$07,$fe,$0a,$2e,$86,$5e,$0a
.byte $8e,$06,$be,$0a,$ee,$07,$fe,$8a,$0d,$c4,$41,$52,$51,$52,$cd,$43
.byte $ce,$09,$de,$0b,$dd,$42,$fe,$02,$5d,$c7,$fd
L_Area08:
.byte $94,$11,$0f,$26,$fe,$10,$28,$94,$65,$15,$eb,$12,$fa,$41,$4a,$96
.byte $54,$40,$a4,$42,$b7,$13,$e9,$19,$f5,$15,$11,$80,$47,$42,$71,$13
.byte $15,$92,$1b,$1f,$24,$40,$55,$12,$64,$40,$95,$12,$a4,$40,$d2,$12
.byte $e1,$40,$13,$c0,$49,$13,$83,$40,$a3,$40,$17,$92,$83,$13,$92,$41
.byte $b9,$14,$c5,$12,$c8,$40,$d4,$40,$4b,$92,$78,$1b,$9c,$94,$9f,$11
.byte $df,$14,$fe,$11,$7d,$c1,$9e,$42,$cf,$20,$9d,$c7,$fd
L_Area0A:
.byte $52,$21,$0f,$20,$6e,$40,$58,$f2,$93,$00,$97,$01,$0c,$81,$97,$40
.byte $a6,$41,$c7,$40,$0d,$04,$03,$01,$07,$01,$23,$01,$27,$01,$ec,$03
.byte $ac,$f3,$c3,$03,$78,$e2,$94,$43,$47,$f3,$74,$43,$47,$fb,$74,$43
.byte $2c,$f1,$4c,$63,$47,$00,$57,$21,$5c,$01,$7c,$72,$39,$f1,$ec,$02
.byte $4c,$81,$ec,$01,$0d,$0d,$0f,$38,$c7,$08,$ed,$4a,$1d,$c1,$5f,$26
.byte $3d,$c7,$fd
L_Area0C:
.byte $52,$31,$0f,$20,$6e,$66,$07,$81,$36,$01,$66,$00,$a7,$21,$c7,$08
.byte $c9,$20,$ec,$01,$08,$f2,$67,$7b,$98,$f2,$39,$f1,$9f,$33,$dc,$27
.byte $dc,$57,$23,$83,$57,$63,$6c,$51,$87,$63,$99,$61,$a3,$07,$b3,$21
.byte $77,$f3,$f3,$29,$f7,$2a,$13,$81,$53,$00,$e9,$0c,$0c,$83,$13,$21
.byte $16,$22,$33,$06,$8f,$35,$ec,$01,$63,$a2,$67,$20,$73,$01,$77,$01
.byte $87,$20,$b3,$22,$b7,$20,$c3,$00,$c7,$01,$d7,$20,$67,$a0,$77,$08
.byte $87,$22,$e8,$62,$f5,$65,$1c,$82,$7f,$38,$8d,$c1,$cf,$26,$ad,$c7
.byte $fd
L_Area0D:
.byte $54,$21,$07,$81,$47,$24,$57,$01,$63,$00,$77,$01,$c9,$71,$68,$f2
.byte $e7,$73,$97,$fb,$06,$83,$5c,$01,$d7,$22,$03,$80,$13,$26,$6c,$02
.byte $b3,$22,$e3,$01,$e7,$08,$47,$a1,$a7,$01,$d3,$07,$d7,$01,$07,$80
.byte $67,$20,$93,$22,$03,$a3,$1c,$61,$17,$21,$6f,$33,$c7,$63,$d8,$62
.byte $e9,$61,$fa,$60,$4f,$b3,$87,$63,$9c,$01,$b7,$63,$c8,$62,$d9,$61
.byte $ea,$60,$39,$f1,$87,$21,$a7,$01,$b7,$20,$39,$f1,$5f,$38,$6d,$c1
.byte $af,$26,$8d,$c7,$fd
L_Area0E:
.byte $94,$11,$0f,$26,$fe,$10,$2a,$93,$87,$17,$a3,$14,$b2,$42,$0a,$92
.byte $36,$14,$50,$41,$82,$16,$2b,$93,$24,$41,$bb,$14,$b8,$00,$c3,$13
.byte $d2,$41,$1b,$94,$67,$12,$c4,$15,$53,$c1,$d2,$41,$12,$c1,$29,$13
.byte $85,$17,$1b,$92,$1a,$42,$47,$13,$83,$41,$a7,$13,$0e,$91,$a7,$63
.byte $b7,$63,$c5,$65,$d5,$65,$dd,$4a,$e3,$67,$f3,$67,$8d,$c1,$ae,$42
.byte $df,$20,$ad,$c7,$fd
L_Area0F:
.byte $90,$11,$0f,$26,$6e,$10,$8b,$17,$af,$32,$d8,$62,$e8,$62,$fc,$3f
.byte $ad,$c8,$f8,$64,$0c,$be,$43,$43,$f8,$64,$0c,$bf,$f8,$64,$48,$e4
.byte $5c,$39,$83,$40,$92,$41,$b3,$40,$f8,$64,$48,$e4,$5c,$39,$f8,$64
.byte $13,$c2,$37,$65,$4c,$24,$63,$00,$97,$65,$c3,$42,$0b,$97,$ac,$32
.byte $f8,$64,$0c,$be,$53,$45,$9d,$48,$f8,$64,$2a,$e2,$3c,$47,$56,$43
.byte $ba,$62,$f8,$64,$0c,$b7,$88,$64,$bc,$31,$d4,$45,$fc,$31,$3c,$b1
.byte $78,$64,$8c,$38,$0b,$9c,$1a,$33,$18,$61,$28,$61,$39,$60,$5d,$4a
.byte $ee,$11,$0f,$b8,$1d,$c1,$3e,$42,$6f,$20,$3d,$c7,$fd
L_Area10:
.byte $52,$31,$0f,$20,$6e,$40,$f7,$20,$07,$85,$17,$20,$4f,$34,$c3,$03
.byte $c7,$02,$d3,$22,$27,$e3,$39,$61,$e7,$73,$5c,$f4,$53,$00,$6c,$63
.byte $47,$a0,$53,$06,$63,$22,$a7,$73,$fc,$73,$13,$a1,$33,$07,$43,$21
.byte $5c,$72,$c3,$23,$cc,$03,$77,$fb,$39,$f1,$a7,$73,$d3,$05,$e8,$72
.byte $e3,$22,$26,$f4,$bc,$02,$00,$89,$09,$0c,$17,$88,$43,$24,$a7,$01
.byte $c3,$05,$08,$f2,$97,$31,$a3,$02,$e1,$69,$f1,$69,$8d,$c1,$cf,$26
.byte $ad,$c7,$fd
L_Area13:
.byte $00,$c1,$4c,$00,$f4,$4f,$0d,$02,$02,$42,$43,$4f,$52,$c2,$de,$00
.byte $5a,$c2,$4d,$c7,$fd
L_Area14:
.byte $90,$51,$0f,$26,$ee,$10,$0b,$94,$33,$14,$42,$42,$77,$16,$86,$44
.byte $02,$92,$4a,$16,$69,$42,$73,$14,$b0,$00,$c7,$12,$05,$c0,$1c,$17
.byte $1f,$11,$36,$12,$8f,$14,$91,$40,$1b,$94,$35,$12,$34,$42,$60,$42
.byte $61,$12,$87,$12,$96,$40,$a3,$14,$47,$92,$05,$c0,$39,$12,$82,$40
.byte $98,$12,$16,$c4,$17,$14,$54,$12,$9b,$16,$28,$94,$ce,$01,$3d,$c1
.byte $5e,$42,$8f,$20,$5d,$c7,$fd
L_Area17:
.byte $10,$51,$4c,$00,$c7,$12,$c6,$42,$03,$92,$02,$42,$29,$12,$63,$12
.byte $62,$42,$69,$14,$a5,$12,$a4,$42,$e2,$14,$e1,$44,$f8,$16,$37,$c1
.byte $8f,$38,$02,$bb,$28,$7a,$68,$7a,$a8,$7a,$e0,$6a,$f0,$6a,$6d,$c5
.byte $fd
L_Area1C:
.byte $06,$c1,$4c,$00,$f4,$4f,$0d,$02,$06,$20,$24,$4f,$35,$a0,$36,$20
.byte $53,$46,$d5,$20,$d6,$20,$34,$a1,$73,$49,$74,$20,$94,$20,$b4,$20
.byte $d4,$20,$f4,$20,$2e,$80,$59,$42,$4d,$c7,$fd
L_Area1D:
.byte $96,$31,$0f,$26,$0d,$03,$1a,$60,$77,$42,$c4,$00,$c8,$62,$b9,$e1
.byte $d3,$07,$d7,$08,$f9,$61,$0c,$81,$4e,$b1,$8e,$b1,$aa,$30,$bc,$01
.byte $e4,$50,$e9,$61,$0c,$81,$0d,$0a,$84,$43,$98,$72,$0d,$0c,$0f,$38
.byte $1d,$c1,$5f,$26,$3d,$c7,$fd
L_Area23:
.byte $3c,$11,$0f,$26,$ad,$40,$3d,$c7,$fd
L_Area24:
.byte $48,$0f,$0e,$01,$5e,$02,$a7,$00,$bc,$73,$1a,$e0,$39,$61,$58,$62
.byte $77,$63,$97,$63,$b8,$62,$d6,$08,$f8,$62,$19,$e1,$75,$52,$86,$40
.byte $87,$07,$95,$52,$93,$43,$a5,$21,$c5,$52,$d6,$40,$d7,$20,$e5,$52
.byte $3e,$8d,$5e,$03,$67,$52,$77,$52,$7e,$02,$9e,$03,$a6,$43,$a7,$23
.byte $de,$05,$fe,$02,$1e,$83,$33,$54,$46,$40,$47,$21,$56,$05,$5e,$02
.byte $83,$54,$93,$54,$96,$08,$90,$09,$be,$03,$c7,$23,$fe,$02,$0c,$82
.byte $43,$45,$45,$24,$46,$24,$90,$05,$95,$51,$78,$fa,$d7,$73,$39,$f1
.byte $8c,$01,$a8,$52,$b8,$52,$cc,$01,$5f,$b3,$97,$63,$9e,$00,$0e,$81
.byte $16,$24,$66,$05,$8e,$00,$fe,$01,$08,$d2,$0e,$06,$6f,$47,$9e,$0f
.byte $0e,$82,$2d,$47,$28,$7a,$68,$7a,$a8,$7a,$ae,$01,$de,$0f,$6d,$c5
.byte $fd
L_Area25:
.byte $48,$0f,$0e,$01,$5e,$02,$bc,$01,$fc,$01,$2c,$82,$41,$52,$4e,$04
.byte $67,$25,$68,$24,$69,$21,$89,$08,$99,$21,$ba,$42,$c7,$05,$de,$0b
.byte $b2,$88,$fe,$02,$2c,$e1,$2c,$71,$67,$01,$77,$00,$87,$01,$8e,$00
.byte $ee,$01,$f6,$02,$03,$86,$05,$02,$13,$21,$16,$02,$27,$02,$2e,$02
.byte $88,$72,$c7,$20,$d7,$08,$e4,$76,$07,$a0,$17,$07,$48,$7a,$76,$20
.byte $98,$72,$79,$e1,$88,$62,$9c,$01,$b7,$73,$dc,$01,$f8,$62,$fe,$01
.byte $08,$e2,$0e,$00,$6e,$02,$73,$20,$77,$23,$83,$05,$93,$20,$ae,$00
.byte $fe,$0a,$0e,$82,$39,$71,$a8,$72,$e7,$73,$0c,$81,$8f,$32,$ae,$00
.byte $fe,$04,$04,$d1,$17,$05,$26,$49,$27,$29,$df,$33,$fe,$02,$44,$f6
.byte $7c,$01,$8e,$06,$bf,$47,$ee,$0f,$4d,$c7,$0e,$82,$68,$7a,$ae,$01
.byte $de,$0f,$6d,$c5,$fd
L_Area26:
.byte $48,$01,$0e,$01,$00,$5a,$3e,$06,$45,$46,$47,$46,$53,$44,$ae,$01
.byte $df,$4a,$4d,$c7,$0e,$81,$00,$5a,$2e,$04,$37,$28,$3a,$48,$46,$47
.byte $c7,$08,$ce,$0f,$df,$4a,$4d,$c7,$0e,$81,$00,$5a,$33,$53,$43,$51
.byte $46,$40,$47,$50,$53,$05,$55,$40,$56,$50,$62,$43,$64,$40,$65,$50
.byte $71,$41,$73,$51,$83,$51,$94,$40,$95,$50,$a3,$50,$a5,$40,$a6,$50
.byte $b3,$51,$b6,$40,$b7,$50,$c3,$53,$df,$4a,$4d,$c7,$0e,$81,$00,$5a
.byte $2e,$02,$36,$47,$37,$52,$3a,$49,$47,$25,$a7,$52,$d7,$05,$df,$4a
.byte $4d,$c7,$0e,$81,$00,$5a,$3e,$02,$44,$51,$53,$44,$54,$44,$55,$24
.byte $a1,$54,$ae,$01,$b4,$21,$df,$4a,$e5,$08,$4d,$c7,$fd
L_Area29:
.byte $41,$01,$b8,$52,$ea,$41,$27,$b2,$b3,$42,$16,$d4,$4a,$42,$a5,$51
.byte $a7,$31,$27,$d3,$08,$e2,$16,$64,$2c,$04,$38,$42,$76,$64,$88,$62
.byte $de,$07,$fe,$01,$0d,$c9,$23,$32,$31,$51,$98,$52,$0d,$c9,$59,$42
.byte $63,$53,$67,$31,$14,$c2,$36,$31,$87,$53,$17,$e3,$29,$61,$30,$62
.byte $3c,$08,$42,$37,$59,$40,$6a,$42,$99,$40,$c9,$61,$d7,$63,$58,$d2
.byte $c3,$67,$d3,$31,$dc,$06,$f7,$42,$fa,$42,$23,$b1,$43,$67,$c3,$34
.byte $c7,$34,$d1,$51,$43,$b3,$47,$33,$9a,$30,$a9,$61,$b8,$62,$be,$0b
.byte $c4,$31,$d5,$0a,$de,$0f,$0d,$ca,$7d,$47,$fd
.else

;level 1-4
E_CastleArea1:
  .byte $35, $9d, $55, $9b, $c9, $1b, $59, $9d, $45, $9b, $c5, $1b, $26, $80, $45, $1b
  .byte $b9, $1d, $f0, $15, $59, $9d, $0f, $08, $78, $2d, $96, $28, $90, $b5, $ff

;level 2-4
E_CastleArea2:
  .byte $74, $80, $f0, $38, $a0, $bb, $40, $bc, $8c, $1d, $c9, $9d, $05, $9b, $1c, $0c
  .byte $59, $1b, $b5, $1d, $2c, $8c, $40, $15, $7c, $1b, $dc, $1d, $6c, $8c, $bc, $0c
  .byte $78, $ad, $a5, $28, $90, $b5, $ff

;level 3-4
E_CastleArea3:
  .byte $0f, $04, $9c, $0c, $0f, $07, $c5, $1b, $65, $9d, $49, $9d, $5c, $8c, $78, $2d
  .byte $90, $b5, $ff

;level 4-4
E_CastleArea4:
  .byte $49, $9f, $67, $03, $79, $9d, $a0, $3a, $57, $9f, $bb, $1d, $d5, $25, $0f, $05
  .byte $18, $1d, $74, $00, $84, $00, $94, $00, $c6, $29, $49, $9d, $db, $05, $0f, $08
  .byte $05, $9b, $09, $1d, $b0, $38, $80, $95, $c0, $3c, $ec, $a8, $cc, $8c, $4a, $9b
  .byte $78, $2d, $90, $b5, $ff

;level 1-1
E_GroundArea1:
  .byte $07, $8e, $47, $03, $0f, $03, $10, $38, $1b, $80, $53, $06, $77, $0e, $83, $83
  .byte $a0, $3d, $90, $3b, $90, $b7, $60, $bc, $b7, $0e, $ee, $42, $00, $f7, $80, $6b
  .byte $83, $1b, $83, $ab, $06, $ff

;level 1-3
E_GroundArea2:
  .byte $96, $a4, $f9, $24, $d3, $83, $3a, $83, $5a, $03, $95, $07, $f4, $0f, $69, $a8
  .byte $33, $87, $86, $24, $c9, $24, $4b, $83, $67, $83, $17, $83, $56, $28, $95, $24
  .byte $0a, $a4, $ff

;level 2-1
E_GroundArea3:
  .byte $0f, $02, $47, $0e, $87, $0e, $c7, $0e, $f7, $0e, $27, $8e, $ee, $42, $25, $0f
  .byte $06, $ac, $28, $8c, $a8, $4e, $b3, $20, $8b, $8e, $f7, $90, $36, $90, $e5, $8e
  .byte $32, $8e, $c2, $06, $d2, $06, $e2, $06, $ff

;level 2-2
E_GroundArea4:
  .byte $15, $8e, $9b, $06, $e0, $37, $80, $bc, $0f, $04, $2b, $3b, $ab, $0e, $eb, $0e
  .byte $0f, $06, $f0, $37, $4b, $8e, $6b, $80, $bb, $3c, $4b, $bb, $ee, $42, $20, $1b
  .byte $bc, $cb, $00, $ab, $83, $eb, $bb, $0f, $0e, $1b, $03, $9b, $37, $d4, $0e, $a3
  .byte $86, $b3, $06, $c3, $06, $ff

;level 2-3
E_GroundArea5:
  .byte $c0, $be, $0f, $03, $38, $0e, $15, $8f, $aa, $83, $f8, $07, $0f, $07, $96, $10
  .byte $0f, $09, $48, $10, $ba, $03, $ff

;level 3-1
E_GroundArea6:
  .byte $87, $85, $a3, $05, $db, $83, $fb, $03, $93, $8f, $bb, $03, $ce, $42, $42, $9b
  .byte $83, $ae, $b3, $40, $db, $00, $f4, $0f, $33, $8f, $74, $0f, $10, $bc, $f5, $0f
  .byte $2e, $c2, $45, $b7, $03, $f7, $03, $c8, $90, $ff

;level 3-3
E_GroundArea7:
  .byte $80, $be, $83, $03, $92, $10, $4b, $80, $b0, $3c, $07, $80, $b7, $24, $0c, $a4
  .byte $96, $a9, $1b, $83, $7b, $24, $b7, $24, $97, $83, $e2, $0f, $a9, $a9, $38, $a9
  .byte $0f, $0b, $74, $8f, $ff

;level 4-1
E_GroundArea8:
  .byte $e2, $91, $0f, $03, $42, $11, $0f, $06, $72, $11, $0f, $08, $ee, $02, $60, $02
  .byte $91, $ee, $b3, $60, $d3, $86, $ff

;level 4-2
E_GroundArea9:
  .byte $0f, $02, $9b, $02, $ab, $02, $0f, $04, $13, $03, $92, $11, $60, $b7, $00, $bc
  .byte $00, $bb, $0b, $83, $cb, $03, $7b, $85, $9e, $c2, $60, $e6, $05, $0f, $0c, $62
  .byte $10, $ff

;level 4-3
E_GroundArea11:
  .byte $e6, $a9, $57, $a8, $b5, $24, $19, $a4, $76, $28, $a2, $0f, $95, $8f, $9d, $a8
  .byte $0f, $07, $09, $29, $55, $24, $8b, $17, $a9, $24, $db, $83, $04, $a9, $24, $8f
  .byte $65, $0f, $ff

;cloud level used in levels 2-1, 3-1 and 4-1
E_GroundArea20:
  .byte $0a, $aa, $1e, $22, $29, $1e, $25, $49, $2e, $27, $66, $ff

;level 1-2
E_UndergroundArea1:
  .byte $0a, $8e, $de, $b4, $00, $e0, $37, $5b, $82, $2b, $a9, $aa, $29, $29, $a9, $a8
  .byte $29, $0f, $08, $f0, $3c, $79, $a9, $c5, $26, $cd, $26, $ee, $3b, $01, $67, $b4
  .byte $0f, $0c, $2e, $c1, $00, $ff

;warp zone area used by level 1-2
E_UndergroundArea2:
  .byte $09, $a9, $19, $a9, $de, $42, $02, $7b, $83, $ff

;underground bonus rooms used in many levels
E_UndergroundArea3:
  .byte $1e, $a0, $0a, $1e, $23, $2b, $1e, $28, $6b, $0f, $03, $1e, $40, $08, $1e, $25
  .byte $4e, $0f, $06, $1e, $22, $25, $1e, $25, $45, $ff

;level 3-2
E_WaterArea1:
  .byte $0f, $01, $2a, $07, $2e, $3b, $41, $e9, $07, $0f, $03, $6b, $07, $f9, $07, $b8
  .byte $80, $2a, $87, $4a, $87, $b3, $0f, $84, $87, $47, $83, $87, $07, $0a, $87, $42
  .byte $87, $1b, $87, $6b, $03, $ff

;water area used by level 4-1
E_WaterArea3:
  .byte $1e, $a7, $6a, $5b, $82, $74, $07, $d8, $07, $e8, $02, $0f, $04, $26, $07, $ff

;level 1-4
L_CastleArea1:
  .byte $9b, $07, $05, $32, $06, $33, $07, $34, $33, $8e, $4e, $0a, $7e, $06, $9e, $0a
  .byte $ce, $06, $e3, $00, $ee, $0a, $1e, $87, $53, $0e, $8e, $02, $9c, $00, $c7, $0e
  .byte $d7, $37, $57, $8e, $6c, $05, $da, $60, $e9, $61, $f8, $62, $fe, $0b, $43, $8e
  .byte $c3, $0e, $43, $8e, $b7, $0e, $ee, $09, $fe, $0a, $3e, $86, $57, $0e, $6e, $0a
  .byte $7e, $06, $ae, $0a, $be, $06, $fe, $07, $15, $e2, $55, $62, $95, $62, $fe, $0a
  .byte $0d, $c4, $cd, $43, $ce, $09, $de, $0b, $dd, $42, $fe, $02, $5d, $c7, $fd

;level 2-4
L_CastleArea2:
  .byte $9b, $07, $05, $32, $06, $33, $07, $34, $03, $e2, $0e, $06, $1e, $0c, $7e, $0a
  .byte $8e, $05, $8e, $82, $8a, $8e, $8e, $0a, $ee, $02, $0a, $e0, $19, $61, $23, $06
  .byte $28, $62, $2e, $0b, $7e, $0a, $81, $62, $87, $30, $8e, $04, $a7, $31, $c7, $0e
  .byte $d7, $33, $fe, $03, $03, $8e, $0e, $0a, $11, $62, $1e, $04, $27, $32, $4e, $0a
  .byte $51, $62, $57, $0e, $5e, $04, $67, $34, $9e, $0a, $a1, $62, $ae, $03, $b3, $0e
  .byte $be, $0b, $ee, $09, $fe, $0a, $2e, $82, $7a, $0e, $7e, $0a, $97, $31, $be, $04
  .byte $da, $0e, $ee, $0a, $f1, $62, $fe, $02, $3e, $8a, $7e, $06, $ae, $0a, $ce, $06
  .byte $fe, $0a, $0d, $c4, $11, $53, $21, $52, $24, $0b, $51, $52, $61, $52, $cd, $43
  .byte $ce, $09, $dd, $42, $de, $0b, $fe, $02, $5d, $c7, $fd

;level 3-4
L_CastleArea3:
  .byte $5b, $09, $05, $34, $06, $35, $6e, $06, $7e, $0a, $ae, $02, $fe, $02, $0d, $01
  .byte $0e, $0e, $2e, $0a, $6e, $09, $be, $0a, $ed, $4b, $e4, $60, $ee, $0d, $5e, $82
  .byte $78, $72, $a4, $3d, $a5, $3e, $a6, $3f, $a3, $be, $a6, $3e, $a9, $32, $e9, $3a
  .byte $9c, $80, $a3, $33, $a6, $33, $a9, $33, $e5, $06, $ed, $4b, $f3, $30, $f6, $30
  .byte $f9, $30, $fe, $02, $0d, $05, $3c, $01, $57, $73, $7c, $02, $93, $30, $a7, $73
  .byte $b3, $37, $cc, $01, $07, $83, $17, $03, $27, $03, $37, $03, $64, $3b, $77, $3a
  .byte $0c, $80, $2e, $0e, $9e, $02, $a5, $62, $b6, $61, $cc, $02, $c3, $33, $ed, $4b
  .byte $03, $b7, $07, $37, $83, $37, $87, $37, $dd, $4b, $03, $b5, $07, $35, $5e, $0a
  .byte $8e, $02, $ae, $0a, $de, $06, $fe, $0a, $0d, $c4, $cd, $43, $ce, $09, $dd, $42
  .byte $de, $0b, $fe, $02, $5d, $c7, $fd

;level 4-4
L_CastleArea4:
  .byte $9b, $07, $05, $32, $06, $33, $07, $34, $4e, $03, $5c, $02, $0c, $f1, $27, $00
  .byte $3c, $74, $47, $0e, $fc, $00, $fe, $0b, $77, $8e, $ee, $09, $fe, $0a, $45, $b2
  .byte $55, $0e, $99, $32, $b9, $0e, $fe, $02, $0e, $85, $fe, $02, $16, $8e, $2e, $0c
  .byte $ae, $0a, $ee, $05, $1e, $82, $47, $0e, $07, $bd, $c4, $72, $de, $0a, $fe, $02
  .byte $03, $8e, $07, $0e, $13, $3c, $17, $3d, $e3, $03, $ee, $0a, $f3, $06, $f7, $03
  .byte $fe, $0e, $fe, $8a, $38, $e4, $4a, $72, $68, $64, $37, $b0, $98, $64, $a8, $64
  .byte $e8, $64, $f8, $64, $0d, $c4, $71, $64, $cd, $43, $ce, $09, $dd, $42, $de, $0b
  .byte $fe, $02, $5d, $c7, $fd

;level 1-1
L_GroundArea1:
  .byte $50, $31, $0f, $26, $13, $e4, $23, $24, $27, $23, $37, $07, $66, $61, $ac, $74
  .byte $c7, $01, $0b, $f1, $77, $73, $b6, $04, $db, $71, $5c, $82, $83, $2d, $a2, $47
  .byte $a7, $0a, $b7, $29, $4f, $b3, $87, $0b, $93, $23, $cc, $06, $e3, $2c, $3a, $e0
  .byte $7c, $71, $97, $01, $ac, $73, $e6, $61, $0e, $b1, $b7, $f3, $dc, $02, $d3, $25
  .byte $07, $fb, $2c, $01, $e7, $73, $2c, $f2, $34, $72, $57, $00, $7c, $02, $39, $f1
  .byte $bf, $37, $33, $e7, $cd, $41, $0f, $a6, $ed, $47, $fd

;level 1-3
L_GroundArea2:
  .byte $50, $11, $0f, $26, $fe, $10, $47, $92, $56, $40, $ac, $16, $af, $12, $0f, $95
  .byte $73, $16, $82, $44, $ec, $48, $bc, $c2, $1c, $b1, $b3, $16, $c2, $44, $86, $c0
  .byte $9c, $14, $9f, $12, $a6, $40, $df, $15, $0b, $96, $43, $12, $97, $31, $d3, $12
  .byte $03, $92, $27, $14, $63, $00, $c7, $15, $d6, $43, $ac, $97, $af, $11, $1f, $96
  .byte $64, $13, $e3, $12, $2e, $91, $9d, $41, $ae, $42, $df, $20, $cd, $c7, $fd

;level 2-1
L_GroundArea3:
  .byte $52, $21, $0f, $20, $6e, $64, $4f, $b2, $7c, $5f, $7c, $3f, $7c, $d8, $7c, $38
  .byte $83, $02, $a3, $00, $c3, $02, $f7, $16, $5c, $d6, $cf, $35, $d3, $20, $e3, $0a
  .byte $f3, $20, $25, $b5, $2c, $53, $6a, $7a, $8c, $54, $da, $72, $fc, $50, $0c, $d2
  .byte $39, $73, $5c, $54, $aa, $72, $cc, $53, $f7, $16, $33, $83, $40, $06, $5c, $5b
  .byte $09, $93, $27, $0f, $3c, $5c, $0a, $b0, $63, $27, $78, $72, $93, $09, $97, $03
  .byte $a7, $03, $b7, $22, $47, $81, $5c, $72, $2a, $b0, $28, $0f, $3c, $5f, $58, $31
  .byte $b8, $31, $28, $b1, $3c, $5b, $98, $31, $fa, $30, $03, $b2, $20, $04, $7f, $b7
  .byte $f3, $67, $8d, $c1, $bf, $26, $ad, $c7, $fd

;level 2-2
L_GroundArea4:
  .byte $54, $11, $0f, $26, $38, $f2, $ab, $71, $0b, $f1, $96, $42, $ce, $10, $1e, $91
  .byte $29, $61, $3a, $60, $4e, $10, $78, $74, $8e, $11, $06, $c3, $1a, $e0, $1e, $10
  .byte $5e, $11, $67, $63, $77, $63, $88, $62, $99, $61, $aa, $60, $be, $10, $0a, $f2
  .byte $15, $45, $7e, $11, $7a, $31, $9a, $e0, $ac, $02, $d9, $61, $d4, $0a, $ec, $01
  .byte $d6, $c2, $84, $c3, $98, $fa, $d3, $07, $d7, $0b, $e9, $61, $ee, $10, $2e, $91
  .byte $39, $71, $93, $03, $a6, $03, $be, $10, $e1, $71, $e3, $31, $5e, $91, $69, $61
  .byte $e6, $41, $28, $e2, $99, $71, $ae, $10, $ce, $11, $be, $90, $d6, $32, $3e, $91
  .byte $5f, $37, $66, $60, $d3, $67, $6d, $c1, $af, $26, $9d, $c7, $fd

;level 2-3
L_GroundArea5:
  .byte $54, $11, $0f, $26, $af, $32, $d8, $62, $e8, $62, $f8, $62, $fe, $10, $0c, $be
  .byte $f8, $64, $0d, $c8, $2c, $43, $98, $64, $ac, $39, $48, $e4, $6a, $62, $7c, $47
  .byte $fa, $62, $3c, $b7, $ea, $62, $fc, $4d, $f6, $02, $03, $80, $06, $02, $13, $02
  .byte $da, $62, $0d, $c8, $0b, $17, $97, $16, $2c, $b1, $33, $43, $6c, $31, $ac, $31
  .byte $17, $93, $73, $12, $cc, $31, $1a, $e2, $2c, $4b, $67, $48, $ea, $62, $0d, $ca
  .byte $17, $12, $53, $12, $be, $11, $1d, $c1, $3e, $42, $6f, $20, $4d, $c7, $fd

;level 3-1
L_GroundArea6:
  .byte $52, $b1, $0f, $20, $6e, $75, $53, $aa, $57, $25, $b7, $0a, $c7, $23, $0c, $83
  .byte $5c, $72, $87, $01, $c3, $00, $c7, $20, $dc, $65, $0c, $87, $c3, $22, $f3, $03
  .byte $03, $a2, $27, $7b, $33, $03, $43, $23, $52, $42, $9c, $06, $a7, $20, $c3, $23
  .byte $03, $a2, $0c, $02, $33, $09, $39, $71, $43, $23, $77, $06, $83, $67, $a7, $73
  .byte $5c, $82, $c9, $11, $07, $80, $1c, $71, $98, $11, $9a, $10, $f3, $04, $16, $f4
  .byte $3c, $02, $68, $7a, $8c, $01, $a7, $73, $e7, $73, $ac, $83, $09, $8f, $1c, $03
  .byte $9f, $37, $13, $e7, $7c, $02, $ad, $41, $ef, $26, $0d, $0e, $39, $71, $7f, $37
  .byte $f2, $68, $02, $e8, $12, $3a, $1c, $00, $68, $7a, $de, $3f, $6d, $c5, $fd

;level 3-3
L_GroundArea7:
  .byte $55, $10, $0b, $1f, $0f, $26, $d6, $12, $07, $9f, $33, $1a, $fb, $1f, $f7, $94
  .byte $53, $94, $71, $71, $cc, $15, $cf, $13, $1f, $98, $63, $12, $9b, $13, $a9, $71
  .byte $fb, $17, $09, $f1, $13, $13, $21, $42, $59, $0f, $eb, $13, $33, $93, $40, $06
  .byte $8c, $14, $8f, $17, $93, $40, $cf, $13, $0b, $94, $57, $15, $07, $93, $19, $f3
  .byte $c6, $43, $c7, $13, $d3, $03, $e3, $03, $33, $b0, $4a, $72, $55, $46, $73, $31
  .byte $a8, $74, $e3, $12, $8e, $91, $ad, $41, $ce, $42, $ef, $20, $dd, $c7, $fd

;level 4-1
L_GroundArea8:
  .byte $52, $21, $0f, $20, $6e, $63, $a9, $f1, $fb, $71, $22, $83, $37, $0b, $36, $50
  .byte $39, $51, $b8, $62, $57, $f3, $e8, $02, $f8, $02, $08, $82, $18, $02, $2d, $4a
  .byte $28, $02, $38, $02, $48, $00, $a8, $0f, $aa, $30, $bc, $5a, $6a, $b0, $4f, $b6
  .byte $b7, $04, $9a, $b0, $ac, $71, $c7, $01, $e6, $74, $0d, $09, $46, $02, $56, $00
  .byte $6c, $01, $84, $79, $86, $02, $96, $02, $a4, $71, $a6, $02, $b6, $02, $c4, $71
  .byte $c6, $02, $d6, $02, $39, $f1, $6c, $00, $77, $02, $a3, $09, $ac, $00, $b8, $72
  .byte $dc, $01, $07, $f3, $4c, $00, $6f, $37, $e3, $03, $e6, $03, $5d, $ca, $6c, $00
  .byte $7d, $41, $cf, $26, $9d, $c7, $fd

;level 4-2
L_GroundArea9:
  .byte $50, $a1, $0f, $26, $17, $91, $19, $11, $48, $00, $68, $11, $6a, $10, $96, $14
  .byte $d8, $0a, $e8, $02, $f8, $02, $dc, $81, $6c, $81, $89, $0f, $9c, $00, $c3, $29
  .byte $f8, $62, $47, $a7, $c6, $61, $0d, $07, $56, $74, $b7, $00, $b9, $11, $cc, $76
  .byte $ed, $4a, $1c, $80, $37, $01, $3a, $10, $de, $20, $e9, $0b, $ee, $21, $c8, $bc
  .byte $9c, $f6, $bc, $00, $cb, $7a, $eb, $72, $0c, $82, $39, $71, $b7, $63, $cc, $03
  .byte $e6, $60, $26, $e0, $4a, $30, $53, $31, $5c, $58, $ed, $41, $2f, $a6, $1d, $c7
  .byte $fd

;level 4-3
L_GroundArea11:
  .byte $50, $11, $0f, $26, $fe, $10, $8b, $93, $a9, $0f, $14, $c1, $cc, $16, $cf, $11
  .byte $2f, $95, $b7, $14, $c7, $96, $d6, $44, $2b, $92, $39, $0f, $72, $41, $a7, $00
  .byte $1b, $95, $97, $13, $6c, $95, $6f, $11, $a2, $40, $bf, $15, $c2, $40, $0b, $9f
  .byte $53, $16, $62, $44, $72, $c2, $9b, $1d, $b7, $e0, $ed, $4a, $03, $e0, $8e, $11
  .byte $9d, $41, $be, $42, $ef, $20, $cd, $c7, $fd

;cloud level used in levels 2-1, 3-1 and 4-1
L_GroundArea20:
  .byte $00, $c1, $4c, $00, $03, $cf, $00, $d7, $23, $4d, $07, $af, $2a, $4c, $03, $cf
  .byte $3e, $80, $f3, $4a, $bb, $c2, $bd, $c7, $fd

;level 1-2
L_UndergroundArea1:
  .byte $48, $0f, $0e, $01, $5e, $02, $0a, $b0, $1c, $54, $6a, $30, $7f, $34, $c6, $64
  .byte $d6, $64, $e6, $64, $f6, $64, $fe, $00, $f0, $07, $00, $a1, $1e, $02, $47, $73
  .byte $7e, $04, $84, $52, $94, $50, $95, $0b, $96, $50, $a4, $52, $ae, $05, $b8, $51
  .byte $c8, $51, $ce, $01, $17, $f3, $45, $03, $52, $09, $62, $21, $6f, $34, $81, $21
  .byte $9e, $02, $b6, $64, $c6, $64, $c0, $0c, $d6, $64, $d0, $07, $e6, $64, $e0, $0c
  .byte $f0, $07, $fe, $0a, $0d, $06, $0e, $01, $4e, $04, $67, $73, $8e, $02, $b7, $0a
  .byte $bc, $03, $c4, $72, $c7, $22, $08, $f2, $2c, $02, $59, $71, $7c, $01, $96, $74
  .byte $bc, $01, $d8, $72, $fc, $01, $39, $f1, $4e, $01, $9e, $04, $a7, $52, $b7, $0b
  .byte $b8, $51, $c7, $51, $d7, $50, $de, $02, $3a, $e0, $3e, $0a, $9e, $00, $08, $d4
  .byte $18, $54, $28, $54, $48, $54, $6e, $06, $9e, $01, $a8, $52, $af, $47, $b8, $52
  .byte $c8, $52, $d8, $52, $de, $0f, $4d, $c7, $ce, $01, $dc, $01, $f9, $79, $1c, $82
  .byte $48, $72, $7f, $37, $f2, $68, $01, $e9, $11, $3a, $68, $7a, $de, $0f, $6d, $c5
  .byte $fd

;warp zone area used by level 1-2
L_UndergroundArea2:
  .byte $0b, $0f, $0e, $01, $9c, $71, $b7, $00, $be, $00, $3e, $81, $47, $73, $5e, $00
  .byte $63, $42, $8e, $01, $a7, $73, $be, $00, $7e, $81, $88, $72, $f0, $59, $fe, $00
  .byte $00, $d9, $0e, $01, $39, $79, $a7, $03, $ae, $00, $b4, $03, $de, $0f, $0d, $05
  .byte $0e, $02, $68, $7a, $be, $01, $de, $0f, $6d, $c5, $fd

;underground bonus rooms used with worlds 1-4
L_UndergroundArea3:
  .byte $08, $8f, $0e, $01, $17, $05, $2e, $02, $30, $07, $37, $03, $3a, $49, $44, $03
  .byte $58, $47, $df, $4a, $6d, $c7, $0e, $81, $00, $5a, $2e, $02, $87, $52, $97, $2f
  .byte $99, $4f, $0a, $90, $93, $56, $a3, $0b, $a7, $50, $b3, $55, $df, $4a, $6d, $c7
  .byte $0e, $81, $00, $5a, $2e, $00, $3e, $02, $41, $56, $57, $25, $56, $45, $68, $51
  .byte $7a, $43, $b7, $0b, $b8, $51, $df, $4a, $6d, $c7, $fd

;level 3-2
L_WaterArea1:
  .byte $41, $01, $03, $b4, $04, $34, $05, $34, $5c, $02, $83, $37, $84, $37, $85, $37
  .byte $09, $c2, $0c, $02, $1d, $49, $fa, $60, $09, $e1, $18, $62, $20, $63, $27, $63
  .byte $33, $37, $37, $63, $47, $63, $5c, $05, $79, $43, $fe, $06, $35, $d2, $46, $48
  .byte $91, $53, $d6, $51, $fe, $01, $0c, $83, $6c, $04, $b4, $62, $c4, $62, $d4, $62
  .byte $e4, $62, $f4, $62, $18, $d2, $79, $51, $f4, $66, $fe, $02, $0c, $8a, $1d, $49
  .byte $31, $55, $56, $41, $77, $41, $98, $41, $c5, $55, $fe, $01, $07, $e3, $17, $63
  .byte $27, $63, $37, $63, $47, $63, $57, $63, $67, $63, $78, $62, $89, $61, $9a, $60
  .byte $bc, $07, $ca, $42, $3a, $b3, $46, $53, $63, $34, $66, $44, $7c, $01, $9a, $33
  .byte $b7, $52, $dc, $01, $fa, $32, $05, $d4, $2c, $0d, $43, $37, $47, $35, $b7, $30
  .byte $c3, $64, $23, $e4, $29, $45, $33, $64, $43, $64, $53, $64, $63, $64, $73, $64
  .byte $9a, $60, $a9, $61, $b8, $62, $be, $0b, $d4, $31, $d5, $0d, $de, $0f, $0d, $ca
  .byte $7d, $47, $fd

;water area used by level 4-1
L_WaterArea3:
  .byte $01, $01, $78, $52, $b5, $55, $da, $60, $e9, $61, $f8, $62, $fe, $0b, $fe, $81
  .byte $0a, $cf, $36, $49, $62, $43, $fe, $07, $36, $c9, $fe, $01, $0c, $84, $65, $55
  .byte $97, $52, $9a, $32, $a9, $31, $b8, $30, $c7, $63, $ce, $0f, $d5, $0d, $7d, $c7
  .byte $fd
.endif

;-------------------------------------------------------------------------------------


.ifdef ANN

E_Area06:
.byte $49,$9F,$67,$03,$79,$9D,$A0,$3A,$57,$9F,$BB,$1D,$D5,$25,$0F,$05
.byte $18,$1D,$74,$00,$84,$00,$94,$00,$C6,$29,$49,$9D,$DB,$05,$0F,$08
.byte $05,$1B,$09,$1D,$B0,$38,$80,$95,$C0,$3C,$EC,$A8,$CC,$8C,$4A,$9B
.byte $78,$2D,$90,$B5,$FF

E_Area07:
.byte $74,$80,$F0,$38,$A0,$BB,$40,$BC,$8C,$1D,$C9,$9D,$05,$9B,$1C,$0C
.byte $59,$1B,$B5,$1D,$2C,$8C,$40,$15,$7C,$1B,$DC,$1D,$6C,$8C,$BC,$0C
.byte $78,$AD,$A5,$28,$90,$B5,$FF

E_Area04:
.byte $27,$A9,$4B,$0C,$68,$29,$0F,$06,$77,$1B,$0F,$0B,$60,$15,$4B,$8C
.byte $78,$2D,$90,$B5,$FF

E_Area05:
.byte $19,$9B,$99,$1B,$2C,$8C,$59,$1B,$C5,$0F,$0E,$82,$E0,$0F,$06,$2E
.byte $65,$E7,$0F,$08,$9B,$07,$0E,$82,$E0,$39,$0E,$87,$10,$BD,$28,$59
.byte $9F,$0F,$0F,$34,$0F,$77,$10,$9E,$65,$F1,$0F,$12,$0E,$65,$E3,$78
.byte $2D,$0F,$15,$3B,$29,$57,$82,$0F,$18,$55,$1D,$78,$2D,$90,$B5,$FF

E_Area09:
.byte $EB,$8E,$0F,$03,$FB,$05,$17,$85,$DB,$8E,$0F,$07,$57,$05,$7B,$05
.byte $9B,$80,$2B,$85,$FB,$05,$0F,$0B,$1B,$05,$9B,$05,$FF

E_Area0B:
.byte $0E,$C3,$A6,$AB,$00,$BB,$8E,$6B,$82,$DE,$00,$A0,$33,$86,$43,$06
.byte $3E,$BA,$A0,$CB,$02,$0F,$07,$7E,$43,$A4,$83,$02,$0F,$0A,$3B,$02
.byte $CB,$37,$0F,$0C,$E3,$0E,$FF

E_Area1E:
.byte $E6,$A9,$57,$A8,$B5,$24,$19,$A4,$76,$28,$A2,$0F,$95,$8F,$9D,$A8
.byte $0F,$07,$09,$29,$55,$24,$8B,$17,$A9,$24,$DB,$83,$04,$A9,$24,$8F
.byte $65,$0F,$FF

E_Area1F:
.byte $0F,$02,$28,$10,$E6,$03,$D8,$90,$0F,$05,$85,$0F,$78,$83,$C8,$10
.byte $18,$83,$58,$83,$F7,$90,$0F,$0C,$43,$0F,$73,$8F,$FF

E_Area12:
.byte $0B,$80,$60,$38,$10,$B8,$C0,$3B,$DB,$8E,$40,$B8,$F0,$38,$7B,$8E
.byte $A0,$B8,$C0,$B8,$FB,$00,$A0,$B8,$30,$BB,$EE,$43,$86,$0F,$0B,$2B
.byte $0E,$67,$0E,$FF

E_Area21:
.byte $0A,$AA,$0E,$31,$88,$FF

E_Area15:
.byte $CD,$A5,$B5,$A8,$07,$A8,$76,$28,$CC,$25,$65,$A4,$A9,$24,$E5,$24
.byte $19,$A4,$64,$8F,$95,$A8,$E6,$24,$19,$A4,$D7,$29,$16,$A9,$58,$29
.byte $97,$29,$FF

E_Area16:
.byte $0F,$02,$02,$11,$0F,$07,$02,$11,$FF

E_Area18:
.byte $2B,$82,$AB,$38,$DE,$43,$E2,$1B,$B8,$EB,$3B,$DB,$80,$8B,$B8,$1B
.byte $82,$FB,$B8,$7B,$80,$FB,$3C,$5B,$BC,$7B,$B8,$1B,$8E,$CB,$0E,$1B
.byte $8E,$0F,$0D,$2B,$3B,$BB,$B8,$EB,$82,$4B,$B8,$BB,$38,$3B,$B7,$BB
.byte $02,$0F,$13,$1B,$00,$CB,$80,$6B,$BC,$FF

E_Area19:
.byte $7B,$80,$AE,$00,$80,$8B,$8E,$E8,$05,$F9,$86,$17,$86,$16,$85,$4E
.byte $39,$80,$AB,$8E,$87,$85,$C3,$05,$8B,$82,$9B,$02,$AB,$02,$BB,$86
.byte $CB,$06,$D3,$03,$3B,$8E,$6B,$0E,$A7,$8E,$FF

E_Area1A:
.byte $29,$8E,$52,$11,$83,$0E,$0F,$03,$3B,$0E,$9B,$0E,$2B,$8E,$5B,$0E
.byte $CB,$8E,$FB,$0E,$FB,$82,$9B,$82,$BB,$02,$FE,$43,$E6,$BB,$8E,$0F
.byte $0A,$AB,$0E,$CB,$0E,$F9,$0E,$88,$86,$A6,$06,$DB,$02,$B6,$8E,$FF

E_Area1B:
.byte $AB,$CE,$DE,$43,$C0,$CB,$CE,$5B,$8E,$1B,$CE,$4B,$85,$67,$45,$0F
.byte $07,$2B,$00,$7B,$85,$97,$05,$0F,$0A,$92,$02,$FF

E_Area22:
.byte $0A,$AA,$1E,$23,$AA,$FF

E_Area27:
.byte $1E,$B3,$C7,$0F,$03,$1E,$30,$E7,$0F,$05,$1E,$23,$AB,$0F,$07,$1E
.byte $2A,$8A,$2E,$23,$A2,$2E,$32,$EA,$FF

E_Area28:
.byte $3B,$87,$66,$27,$CC,$27,$EE,$31,$87,$EE,$23,$A7,$3B,$87,$DB,$07
.byte $FF

E_Area2B:
.byte $2E,$B8,$C1,$5B,$07,$AB,$07,$69,$87,$BA,$07,$FB,$87,$65,$A7,$6A
.byte $27,$A6,$A7,$AC,$27,$1B,$87,$88,$07,$2B,$83,$7B,$07,$A7,$90,$E5
.byte $83,$14,$A7,$19,$27,$77,$07,$F8,$07,$47,$8F,$B9,$07,$FF

E_Area2A:
.byte $07,$9B,$0A,$07,$B9,$1B,$66,$9B,$78,$07,$AE,$65,$E5,$FF

L_Area06:
.byte $9B,$07,$05,$32,$06,$33,$07,$34,$4E,$03,$5C,$02,$0C,$F1,$27,$00
.byte $3C,$74,$47,$0B,$FC,$00,$FE,$0B,$77,$8B,$EE,$09,$FE,$0A,$45,$B2
.byte $55,$0B,$99,$32,$B9,$0B,$FE,$02,$0E,$85,$FE,$02,$16,$8B,$2E,$0C
.byte $AE,$0A,$EE,$05,$1E,$82,$47,$0B,$07,$BD,$C4,$72,$DE,$0A,$FE,$02
.byte $03,$8B,$07,$0B,$13,$3C,$17,$3D,$E3,$02,$EE,$0A,$F3,$04,$F7,$02
.byte $FE,$0E,$FE,$8A,$38,$E4,$4A,$72,$68,$64,$37,$B0,$98,$64,$A8,$64
.byte $E8,$64,$F8,$64,$0D,$C4,$71,$64,$CD,$43,$CE,$09,$DD,$42,$DE,$0B
.byte $FE,$02,$5D,$C7,$FD

L_Area07:
.byte $9B,$87,$05,$32,$06,$33,$07,$34,$03,$E2,$0E,$06,$1E,$0C,$7E,$0A
.byte $8E,$05,$8E,$82,$8A,$8B,$8E,$0A,$EE,$02,$0A,$E0,$19,$61,$23,$04
.byte $28,$62,$2E,$0B,$7E,$0A,$81,$62,$87,$30,$8E,$04,$A7,$31,$C7,$0B
.byte $D7,$33,$FE,$03,$03,$8B,$0E,$0A,$11,$62,$1E,$04,$27,$32,$4E,$0A
.byte $51,$62,$57,$0B,$5E,$04,$67,$34,$9E,$0A,$A1,$62,$AE,$03,$B3,$0B
.byte $BE,$0B,$EE,$09,$FE,$0A,$2E,$82,$7A,$0B,$7E,$0A,$97,$31,$A6,$10
.byte $BE,$04,$DA,$0B,$EE,$0A,$F1,$62,$FE,$02,$3E,$8A,$7E,$06,$AE,$0A
.byte $CE,$06,$FE,$0A,$0D,$C4,$11,$53,$21,$52,$24,$08,$51,$52,$61,$52
.byte $CD,$43,$CE,$09,$DD,$42,$DE,$0B,$FE,$02,$5D,$C7,$FD

L_Area04:
.byte $5B,$07,$05,$32,$06,$33,$07,$34,$FE,$0A,$AE,$86,$BE,$07,$FE,$02
.byte $0D,$02,$27,$32,$46,$61,$55,$62,$5E,$0E,$1E,$82,$68,$3C,$74,$3A
.byte $7D,$4B,$5E,$8E,$7D,$4B,$7E,$82,$84,$62,$94,$61,$A4,$31,$BD,$4B
.byte $CE,$06,$FE,$02,$0D,$06,$34,$31,$3E,$0A,$64,$32,$75,$0B,$7B,$61
.byte $A4,$33,$AE,$02,$DE,$0E,$3E,$82,$64,$32,$78,$32,$B4,$36,$C8,$36
.byte $DD,$4B,$44,$B2,$58,$32,$94,$63,$A4,$3E,$BA,$30,$C9,$61,$CE,$06
.byte $DD,$4B,$CE,$86,$DD,$4B,$FE,$0A,$2E,$86,$5E,$0A,$7E,$06,$FE,$02
.byte $1E,$86,$3E,$0A,$5E,$06,$7E,$02,$9E,$06,$FE,$0A,$0D,$C4,$CD,$43
.byte $CE,$09,$DE,$0B,$DD,$42,$FE,$02,$5D,$C7,$FD

L_Area05:
.byte $5B,$03,$05,$34,$06,$35,$07,$36,$6E,$0A,$EE,$02,$FE,$05,$0D,$01
.byte $17,$0B,$97,$0B,$9E,$02,$C6,$04,$FA,$30,$FE,$0A,$4E,$82,$57,$0B
.byte $58,$62,$68,$62,$79,$61,$8A,$60,$8E,$0A,$F5,$31,$F9,$7B,$39,$F3
.byte $97,$33,$B5,$71,$39,$F3,$4D,$48,$9E,$02,$AE,$05,$CD,$4A,$ED,$4B
.byte $0E,$81,$17,$04,$39,$73,$5C,$02,$85,$65,$95,$32,$A9,$7B,$CC,$03
.byte $5E,$8F,$6D,$47,$FE,$02,$0D,$07,$39,$73,$4E,$0A,$AE,$02,$E7,$23
.byte $07,$88,$39,$73,$E6,$04,$39,$FB,$4E,$0A,$C4,$31,$EB,$61,$FE,$02
.byte $07,$B0,$1E,$0A,$4E,$06,$57,$0B,$BE,$02,$C9,$61,$DA,$60,$ED,$4B
.byte $0E,$85,$0D,$0E,$FE,$0A,$78,$E4,$8E,$06,$BF,$47,$EE,$0F,$6D,$C7
.byte $0E,$82,$39,$73,$9A,$60,$A9,$61,$AE,$06,$DE,$0A,$E7,$02,$EB,$79
.byte $F7,$02,$FE,$06,$0D,$14,$FE,$0A,$5E,$82,$78,$74,$9E,$0A,$F8,$64
.byte $FE,$0B,$9E,$84,$BE,$05,$BE,$82,$DA,$60,$E9,$61,$F8,$62,$FE,$0A
.byte $0D,$C4,$11,$64,$51,$62,$CD,$43,$CE,$09,$DD,$42,$DE,$0B,$FE,$02
.byte $5D,$C7,$FD

L_Area09:
.byte $90,$B1,$0F,$26,$29,$91,$7E,$42,$FE,$40,$28,$92,$4E,$42,$2E,$C0
.byte $57,$73,$C3,$27,$C7,$27,$D3,$05,$5C,$81,$77,$63,$88,$62,$99,$61
.byte $AA,$60,$BC,$01,$EE,$42,$4E,$C0,$69,$11,$7E,$42,$DE,$40,$F8,$62
.byte $0E,$C2,$AE,$40,$D7,$63,$E7,$63,$33,$A5,$37,$27,$82,$42,$93,$05
.byte $A3,$20,$CC,$01,$E7,$73,$0C,$81,$3E,$42,$0D,$0A,$5E,$40,$88,$72
.byte $BE,$42,$E7,$88,$FE,$40,$39,$E1,$4E,$00,$69,$60,$87,$60,$A5,$60
.byte $C3,$31,$FE,$31,$6D,$C1,$BE,$42,$EF,$20,$8D,$C7,$FD

L_Area0B:
.byte $54,$21,$0F,$26,$A7,$22,$37,$FB,$73,$05,$83,$08,$87,$02,$93,$20
.byte $C7,$73,$04,$F1,$06,$31,$39,$71,$59,$71,$E7,$73,$37,$A0,$47,$08
.byte $86,$7C,$E5,$71,$E7,$31,$33,$A4,$39,$71,$A9,$71,$D3,$23,$08,$F2
.byte $13,$06,$27,$02,$49,$71,$75,$75,$E8,$72,$67,$F3,$99,$71,$E7,$20
.byte $F4,$72,$F7,$31,$17,$A0,$33,$20,$39,$71,$73,$28,$BC,$05,$39,$F1
.byte $79,$71,$A6,$21,$C3,$21,$DC,$00,$FC,$00,$07,$A2,$13,$20,$23,$07
.byte $5F,$32,$8C,$00,$98,$7A,$C7,$63,$D9,$61,$03,$A2,$07,$22,$74,$72
.byte $77,$31,$E7,$73,$39,$F1,$58,$72,$77,$73,$D8,$72,$7F,$B1,$97,$73
.byte $B6,$64,$C5,$65,$D4,$66,$E3,$67,$F3,$67,$8D,$C1,$CF,$26,$AD,$C7
.byte $FD

L_Area1E:
.byte $50,$11,$0F,$26,$FE,$10,$8B,$93,$A9,$0C,$14,$C1,$CC,$16,$CF,$11
.byte $2F,$95,$B7,$14,$C7,$96,$D6,$44,$2B,$92,$39,$0C,$72,$41,$A7,$00
.byte $1B,$95,$97,$13,$6C,$95,$6F,$11,$A2,$40,$BF,$15,$C2,$40,$0B,$9F
.byte $53,$16,$62,$44,$72,$C2,$9B,$1D,$B7,$E0,$ED,$4A,$03,$E0,$8E,$11
.byte $9D,$41,$BE,$42,$EF,$20,$CD,$C7,$FD

L_Area1F:
.byte $50,$11,$0F,$26,$AF,$32,$D8,$62,$DE,$10,$08,$E4,$5A,$62,$6C,$4C
.byte $86,$43,$AD,$48,$3A,$E2,$53,$42,$88,$64,$9C,$36,$08,$E4,$4A,$62
.byte $5C,$4D,$3A,$E2,$9C,$32,$FC,$41,$3C,$B1,$83,$00,$AC,$42,$2A,$E2
.byte $3C,$46,$AA,$62,$BC,$4E,$C6,$43,$46,$C3,$AA,$62,$BD,$48,$0B,$96
.byte $47,$05,$C7,$12,$3C,$C2,$9C,$41,$CD,$48,$DC,$32,$4C,$C2,$BC,$32
.byte $1C,$B1,$5A,$62,$6C,$44,$76,$43,$BA,$62,$DC,$32,$5D,$CA,$73,$12
.byte $E3,$12,$8E,$91,$9D,$41,$BE,$42,$EF,$20,$CD,$C7,$FD

L_Area12:
.byte $95,$B1,$0F,$26,$0D,$02,$C8,$72,$1C,$81,$38,$72,$0D,$05,$97,$34
.byte $98,$62,$A3,$20,$B3,$07,$C3,$20,$CC,$03,$F9,$91,$2C,$81,$48,$62
.byte $0D,$09,$37,$63,$47,$03,$57,$02,$8C,$02,$C5,$79,$C7,$31,$F9,$11
.byte $39,$F1,$A9,$11,$6F,$B4,$D3,$65,$E3,$65,$7D,$C1,$BF,$26,$9D,$C7
.byte $FD

L_Area21:
.byte $00,$C1,$4C,$00,$F4,$4F,$0D,$02,$02,$42,$43,$4F,$52,$C2,$DE,$00
.byte $5A,$C2,$4D,$C7,$FD

L_Area15:
.byte $97,$11,$0F,$26,$FE,$10,$2B,$92,$57,$12,$8B,$12,$C0,$41,$F7,$13
.byte $5B,$92,$69,$0C,$BB,$12,$B2,$46,$19,$93,$71,$00,$17,$94,$7C,$14
.byte $7F,$11,$93,$41,$BF,$15,$FC,$13,$FF,$11,$2F,$95,$50,$42,$51,$12
.byte $58,$14,$A6,$12,$DB,$12,$1B,$93,$46,$43,$7B,$12,$8D,$49,$B7,$14
.byte $1B,$94,$49,$0C,$BB,$12,$FC,$13,$FF,$12,$03,$C1,$2F,$15,$43,$12
.byte $4B,$13,$77,$13,$9D,$4A,$15,$C1,$A1,$41,$C3,$12,$FE,$01,$7D,$C1
.byte $9E,$42,$CF,$20,$9D,$C7,$FD

L_Area16:
.byte $52,$21,$0F,$20,$6E,$44,$0C,$F1,$4C,$01,$AA,$35,$D9,$34,$EE,$20
.byte $08,$B3,$37,$32,$43,$08,$4E,$21,$53,$20,$7C,$01,$97,$21,$B7,$05
.byte $9C,$81,$E7,$42,$5F,$B3,$97,$63,$AC,$02,$C5,$41,$49,$E0,$58,$61
.byte $76,$64,$85,$65,$94,$66,$A4,$22,$A6,$03,$C8,$22,$DC,$02,$68,$F2
.byte $96,$42,$13,$82,$17,$02,$AF,$34,$F6,$21,$FC,$06,$26,$80,$2A,$24
.byte $36,$01,$8C,$00,$FF,$35,$4E,$A0,$55,$21,$77,$20,$87,$08,$89,$22
.byte $AE,$21,$4C,$82,$9F,$34,$EC,$01,$03,$E7,$13,$67,$8D,$4A,$AD,$41
.byte $0F,$A6,$CD,$47,$FD

L_Area18:
.byte $92,$31,$0F,$20,$6E,$40,$0D,$02,$37,$73,$EC,$00,$0C,$80,$3C,$00
.byte $6C,$00,$9C,$00,$06,$C0,$C7,$73,$06,$84,$28,$72,$96,$40,$E7,$73
.byte $26,$C0,$87,$7B,$D2,$41,$39,$F1,$C8,$F2,$97,$E3,$A3,$23,$E7,$02
.byte $E3,$08,$F3,$22,$37,$E3,$9C,$00,$BC,$00,$EC,$00,$0C,$80,$3C,$00
.byte $86,$27,$5C,$80,$7C,$00,$9C,$00,$29,$E1,$DC,$05,$F6,$41,$DC,$80
.byte $E8,$72,$0C,$81,$27,$73,$4C,$01,$66,$74,$A6,$07,$0D,$11,$3F,$35
.byte $B6,$41,$2C,$82,$36,$40,$7C,$02,$86,$40,$F9,$61,$16,$83,$39,$61
.byte $AC,$04,$C6,$41,$0C,$83,$16,$41,$88,$F2,$39,$F1,$7C,$00,$89,$61
.byte $9C,$00,$A7,$63,$BC,$00,$C5,$65,$DC,$00,$E3,$67,$F3,$67,$8D,$C1
.byte $CF,$26,$AD,$C7,$FD

L_Area19:
.byte $55,$B1,$0F,$26,$CF,$33,$07,$B2,$15,$11,$52,$42,$99,$0C,$AC,$02
.byte $D3,$24,$D6,$42,$D7,$25,$23,$85,$CF,$33,$07,$E3,$19,$61,$78,$7A
.byte $EF,$33,$2C,$81,$46,$64,$55,$65,$65,$65,$0C,$F4,$53,$05,$62,$41
.byte $63,$21,$96,$22,$9A,$41,$CC,$03,$B9,$91,$C3,$06,$E6,$02,$39,$F1
.byte $63,$26,$67,$27,$D3,$07,$FC,$01,$18,$E2,$D9,$08,$E9,$05,$0C,$86
.byte $37,$22,$93,$24,$87,$85,$AC,$02,$C2,$41,$C3,$23,$D9,$71,$FC,$01
.byte $7F,$B1,$9C,$00,$A7,$63,$B6,$64,$CC,$00,$D4,$66,$E3,$67,$F3,$67
.byte $8D,$C1,$CF,$26,$AD,$C7,$FD

L_Area1A:
.byte $50,$B1,$0F,$26,$FC,$00,$1F,$B3,$5C,$00,$65,$65,$74,$66,$83,$67
.byte $93,$67,$DC,$73,$4C,$80,$B3,$20,$C3,$09,$C9,$0C,$D3,$2F,$DC,$00
.byte $2C,$80,$4C,$00,$8C,$00,$D3,$2E,$ED,$4A,$FC,$00,$93,$85,$97,$02
.byte $EC,$01,$4C,$80,$59,$11,$D8,$11,$DA,$10,$37,$A0,$47,$08,$99,$11
.byte $E7,$21,$3A,$90,$67,$20,$76,$10,$77,$60,$87,$20,$D8,$12,$39,$F1
.byte $AC,$00,$E9,$71,$0C,$80,$2C,$00,$4C,$05,$C7,$7B,$39,$F1,$EC,$00
.byte $F9,$11,$0C,$82,$6F,$34,$F8,$11,$FA,$10,$7F,$B2,$AC,$00,$B6,$64
.byte $CC,$01,$E3,$67,$F3,$67,$8D,$C1,$CF,$26,$AD,$C7,$FD

L_Area1B:
.byte $52,$B1,$0F,$20,$6E,$45,$39,$91,$B3,$08,$C3,$21,$C8,$11,$CA,$10
.byte $49,$91,$7C,$71,$97,$00,$A7,$01,$E8,$12,$88,$91,$8A,$10,$E7,$20
.byte $F7,$08,$05,$91,$07,$30,$17,$21,$49,$11,$9C,$01,$C8,$72,$2C,$E6
.byte $2C,$76,$D3,$03,$D8,$7A,$89,$91,$D8,$72,$39,$F1,$A9,$11,$09,$F1
.byte $33,$26,$37,$27,$A3,$08,$D8,$62,$28,$91,$2A,$10,$56,$21,$70,$05
.byte $79,$0C,$8C,$00,$94,$21,$9F,$35,$2F,$B8,$3D,$C1,$7F,$26,$5D,$C7
.byte $FD

L_Area22:
.byte $06,$C1,$4C,$00,$F4,$4F,$0D,$02,$06,$20,$24,$4F,$35,$A0,$36,$20
.byte $53,$46,$D5,$20,$D6,$20,$34,$A1,$73,$49,$74,$20,$94,$20,$B4,$20
.byte $D4,$20,$F4,$20,$2E,$80,$59,$42,$4D,$C7,$FD

L_Area27:
.byte $48,$01,$0E,$01,$00,$5A,$3E,$06,$45,$46,$47,$46,$53,$44,$AE,$01
.byte $DF,$4A,$4D,$C7,$0E,$81,$00,$5A,$2E,$04,$37,$28,$3A,$48,$46,$47
.byte $C7,$08,$CE,$0F,$DF,$4A,$4D,$C7,$0E,$81,$00,$5A,$2E,$02,$36,$47
.byte $37,$52,$3A,$49,$47,$25,$A7,$52,$D7,$05,$DF,$4A,$4D,$C7,$0E,$81
.byte $00,$5A,$3E,$02,$44,$51,$53,$44,$54,$44,$55,$24,$A1,$54,$AE,$01
.byte $B4,$21,$DF,$4A,$E5,$08,$4D,$C7,$FD

L_Area28:
.byte $41,$01,$B4,$34,$C8,$52,$F2,$51,$47,$D3,$6C,$03,$65,$49,$9E,$07
.byte $BE,$01,$CC,$03,$FE,$07,$0D,$C9,$1E,$01,$6C,$01,$62,$35,$63,$53
.byte $8A,$41,$AC,$01,$B3,$53,$E9,$51,$26,$C3,$27,$33,$63,$43,$64,$33
.byte $BA,$60,$C9,$61,$CE,$0B,$D4,$31,$E5,$0A,$EE,$0F,$7D,$CA,$7D,$47
.byte $FD

L_Area2B:
.byte $41,$01,$27,$D3,$79,$51,$C4,$56,$00,$E2,$03,$53,$0C,$0F,$12,$3B
.byte $1A,$42,$43,$54,$6D,$49,$83,$53,$99,$53,$C3,$54,$DA,$52,$0C,$84
.byte $09,$53,$53,$64,$63,$31,$67,$34,$86,$41,$8C,$01,$A3,$30,$B3,$64
.byte $CC,$03,$D9,$42,$5C,$84,$A0,$62,$A8,$62,$B0,$62,$B8,$62,$C0,$62
.byte $C8,$62,$D0,$62,$D8,$62,$E0,$62,$E8,$62,$16,$C2,$58,$52,$8C,$04
.byte $A7,$55,$D0,$63,$D7,$65,$E2,$61,$E7,$65,$F2,$61,$F7,$65,$13,$B8
.byte $17,$38,$8C,$03,$1D,$C9,$50,$62,$5C,$0B,$62,$3E,$63,$52,$8A,$52
.byte $93,$54,$AA,$42,$D3,$51,$EA,$41,$03,$D3,$1C,$04,$1A,$52,$33,$55
.byte $73,$44,$77,$44,$16,$D2,$19,$31,$1A,$32,$5C,$0F,$9A,$47,$95,$64
.byte $A5,$64,$B5,$64,$C5,$64,$D5,$64,$E5,$64,$F5,$64,$05,$E4,$40,$61
.byte $42,$35,$56,$34,$5C,$09,$A2,$61,$A6,$61,$B3,$34,$B7,$34,$FC,$08
.byte $0C,$87,$28,$54,$59,$53,$9A,$30,$A9,$61,$B8,$62,$BE,$0B,$C4,$31
.byte $D5,$0A,$DE,$0F,$0D,$CA,$7D,$47,$FD

L_Area2A:
.byte $07,$0F,$0E,$02,$39,$73,$05,$8B,$2E,$0B,$B7,$0B,$64,$8B,$6E,$02
.byte $CE,$06,$DE,$0F,$E6,$0A,$7D,$C7,$FD

.else
;level 5-4
E_CastleArea5:
  .byte $2a, $a9, $6b, $0c, $cb, $0c, $15, $9c, $89, $1c, $cc, $1d, $09, $9d, $f5, $1c
  .byte $6b, $a9, $ab, $0c, $db, $29, $48, $9d, $9b, $0c, $5b, $8c, $a5, $1c, $49, $9d
  .byte $79, $1d, $09, $9d, $6b, $0c, $c9, $1f, $3b, $8c, $88, $95, $b9, $1c, $19, $9d
  .byte $30, $cc, $78, $2d, $a6, $28, $90, $b5, $ff

;level 6-4
E_CastleArea6:
  .byte $0f, $02, $09, $1f, $8b, $85, $2b, $8c, $e9, $1b, $25, $9d, $0f, $07, $09, $1d
  .byte $6d, $28, $99, $1b, $b5, $2c, $4b, $8c, $09, $9f, $fb, $15, $9d, $a8, $0f, $0c
  .byte $2b, $0c, $78, $2d, $90, $b5, $ff

;level 7-4
E_CastleArea7:
  .byte $05, $9d, $0d, $a8, $dd, $1d, $07, $ac, $54, $2c, $a2, $2c, $f4, $2c, $42, $ac
  .byte $26, $9d, $d4, $03, $24, $83, $64, $03, $2b, $82, $4b, $02, $7b, $02, $9b, $02
  .byte $5b, $82, $7b, $02, $0b, $82, $2b, $02, $c6, $1b, $28, $82, $48, $02, $a6, $1b
  .byte $7b, $95, $85, $0c, $9d, $9b, $0f, $0e, $78, $2d, $7a, $1d, $90, $b5, $ff

;level 8-4
E_CastleArea8:
  .byte $19, $9b, $99, $1b, $2c, $8c, $59, $1b, $c5, $0f, $0e, $83, $e0, $0f, $06, $2e
  .byte $67, $e7, $0f, $08, $9b, $07, $0e, $83, $e0, $39, $0e, $87, $10, $bd, $28, $59
  .byte $9f, $0f, $0f, $34, $0f, $77, $10, $9e, $67, $f1, $0f, $12, $0e, $67, $e3, $78
  .byte $2d, $0f, $15, $3b, $29, $57, $82, $0f, $18, $55, $1d, $78, $2d, $90, $b5, $ff

;level 5-1
E_GroundArea12:
  .byte $1b, $82, $4b, $02, $7b, $02, $ab, $02, $0f, $03, $f9, $0e, $d0, $be, $8e, $c4
  .byte $86, $f8, $0e, $c0, $ba, $0f, $0d, $3a, $0e, $bb, $02, $30, $b7, $80, $bc, $c0
  .byte $bc, $0f, $12, $24, $0f, $54, $0f, $ce, $3c, $80, $d3, $0f, $cb, $8e, $f9, $0e
  .byte $ff

;level 5-3
E_GroundArea13:
  .byte $0a, $aa, $15, $8f, $44, $0f, $4e, $44, $80, $d8, $07, $57, $90, $0f, $06, $67
  .byte $24, $8b, $17, $b9, $24, $ab, $97, $16, $87, $2a, $28, $84, $0f, $57, $a9, $a5
  .byte $29, $f5, $29, $a7, $a4, $0a, $a4, $ff

;level 6-1
E_GroundArea14:
  .byte $07, $82, $67, $0e, $40, $bd, $e0, $38, $d0, $bc, $6e, $84, $a0, $9b, $05, $0f
  .byte $06, $bb, $05, $0f, $08, $0b, $0e, $4b, $0e, $0f, $0a, $05, $29, $85, $29, $0f
  .byte $0c, $dd, $28, $ff

;level 6-3
E_GroundArea15:
  .byte $0f, $02, $28, $10, $e6, $03, $d8, $90, $0f, $05, $85, $0f, $78, $83, $c8, $10
  .byte $18, $83, $58, $83, $f7, $90, $0f, $0c, $43, $0f, $73, $8f, $ff

;level 7-1
E_GroundArea16:
  .byte $a7, $83, $d7, $03, $0f, $03, $6b, $00, $0f, $06, $e3, $0f, $14, $8f, $3e, $44
  .byte $c3, $0b, $80, $87, $05, $ab, $05, $db, $83, $0f, $0b, $07, $05, $13, $0e, $2b
  .byte $02, $4b, $02, $0f, $10, $0b, $0e, $b0, $37, $90, $bc, $80, $bc, $ae, $44, $c0
  .byte $ff

;level 7-2
E_GroundArea17:
  .byte $0a, $aa, $d5, $8f, $03, $8f, $3e, $44, $c6, $d8, $83, $0f, $06, $a6, $11, $b9
  .byte $0e, $39, $9d, $79, $1b, $a6, $11, $e8, $03, $87, $83, $16, $90, $a6, $11, $b9
  .byte $1d, $05, $8f, $38, $29, $89, $29, $26, $8f, $46, $29, $ff

;level 7-3
E_GroundArea18:
  .byte $0f, $04, $a3, $10, $0f, $09, $e3, $29, $0f, $0d, $55, $24, $a9, $24, $0f, $11
  .byte $59, $1d, $a9, $1b, $23, $8f, $15, $9b, $ff

;level 8-1
E_GroundArea19:
  .byte $0f, $01, $db, $02, $30, $b7, $80, $3b, $1b, $8e, $4a, $0e, $eb, $03, $3b, $82
  .byte $5b, $02, $e5, $0f, $14, $8f, $44, $0f, $5b, $82, $0c, $85, $35, $8f, $06, $85
  .byte $e3, $05, $db, $83, $3e, $84, $e0, $ff

;level 8-2
E_GroundArea22:
  .byte $0f, $02, $0a, $29, $f7, $02, $80, $bc, $6b, $82, $7b, $02, $9b, $02, $ab, $02
  .byte $39, $8e, $0f, $07, $ce, $35, $ec, $f5, $0f, $fb, $85, $fb, $85, $3e, $c4, $e3
  .byte $a7, $02, $ff

;level 8-3
E_GroundArea23:
  .byte $09, $a9, $86, $11, $d5, $10, $a3, $8f, $d5, $29, $86, $91, $2b, $83, $58, $03
  .byte $5b, $85, $eb, $05, $3e, $bc, $e0, $0f, $09, $43, $0f, $74, $0f, $6b, $85, $db
  .byte $05, $c6, $a4, $19, $a4, $12, $8f
;another unused area
E_GroundArea24:
  .byte $ff

;cloud level used with level 5-1
E_GroundArea29:
  .byte $0a, $aa, $2e, $2b, $98, $2e, $36, $e7, $ff

;level 5-2
E_UndergroundArea4:
  .byte $0b, $83, $b7, $03, $d7, $03, $0f, $05, $67, $03, $7b, $02, $9b, $02, $80, $b9
  .byte $3b, $83, $4e, $b4, $80, $86, $2b, $c9, $2c, $16, $ac, $67, $b4, $de, $3b, $81
  .byte $ff

;underground bonus rooms used with worlds 5-8
E_UndergroundArea5:
  .byte $1e, $af, $ca, $1e, $2c, $85, $0f, $04, $1e, $2d, $a7, $1e, $2f, $ce, $1e, $35
  .byte $e5, $0f, $07, $1e, $2b, $87, $1e, $30, $c5, $ff

;level 6-2
E_WaterArea2:
  .byte $0f, $01, $2e, $3b, $a1, $5b, $07, $ab, $07, $69, $87, $ba, $07, $fb, $87, $65
  .byte $a7, $6a, $27, $a6, $a7, $ac, $27, $1b, $87, $88, $07, $2b, $83, $7b, $07, $a7
  .byte $90, $e5, $83, $14, $a7, $19, $27, $77, $07, $f8, $07, $47, $8f, $b9, $07, $ff

;water area used in level 8-4
E_WaterArea4:
  .byte $07, $9b, $0a, $07, $b9, $1b, $66, $9b, $78, $07, $ae, $67, $e5, $ff

;water area used in level 6-1
E_WaterArea5:
  .byte $97, $87, $cb, $00, $ee, $2b, $f8, $fe, $2d, $ad, $75, $87, $d3, $27, $d9, $27
  .byte $0f, $04, $56, $0f, $ff

;level 5-4
L_CastleArea5:
  .byte $9b, $07, $05, $32, $06, $33, $07, $33, $3e, $03, $4c, $50, $4e, $07, $57, $31
  .byte $6e, $03, $7c, $52, $9e, $07, $fe, $0a, $7e, $89, $9e, $0a, $ee, $09, $fe, $0b
  .byte $13, $8e, $1e, $09, $3e, $0a, $6e, $09, $87, $0e, $9e, $02, $c6, $07, $ca, $0e
  .byte $f7, $62, $07, $8e, $08, $61, $17, $62, $1e, $0a, $4e, $06, $5e, $0a, $7e, $06
  .byte $8e, $0a, $ae, $06, $be, $07, $f3, $0e, $1e, $86, $2e, $0a, $84, $37, $93, $36
  .byte $a2, $45, $1e, $89, $46, $0e, $6e, $0a, $a7, $31, $db, $60, $f7, $60, $1b, $e0
  .byte $37, $31, $7e, $09, $8e, $0b, $a3, $0e, $fe, $04, $17, $bb, $47, $0e, $77, $0e
  .byte $be, $02, $ce, $0a, $07, $8e, $17, $31, $63, $31, $a7, $34, $c7, $0e, $13, $b1
  .byte $4e, $09, $1e, $8a, $7e, $02, $97, $34, $b7, $0e, $ce, $0a, $de, $02, $d8, $61
  .byte $f7, $62, $fe, $03, $07, $b4, $17, $0e, $47, $62, $4e, $0a, $5e, $03, $51, $61
  .byte $67, $62, $77, $34, $b7, $62, $c1, $61, $da, $60, $e9, $61, $f8, $62, $fe, $0a
  .byte $0d, $c4, $01, $52, $11, $52, $21, $52, $31, $52, $41, $52, $51, $52, $61, $52
  .byte $cd, $43, $ce, $09, $de, $0b, $dd, $42, $fe, $02, $5d, $c7, $fd

;level 6-4
L_CastleArea6:
  .byte $5b, $09, $05, $32, $06, $33, $4e, $0a, $87, $31, $fe, $02, $88, $f2, $c7, $33
  .byte $0d, $02, $07, $0e, $17, $34, $6e, $0a, $8e, $02, $bf, $67, $ed, $4b, $b7, $b6
  .byte $c3, $35, $1e, $8a, $2e, $02, $33, $3f, $37, $3f, $88, $f2, $c7, $33, $ed, $4b
  .byte $0d, $06, $03, $33, $0f, $74, $47, $73, $67, $73, $7e, $09, $9e, $0a, $ed, $4b
  .byte $f7, $32, $07, $8e, $97, $0e, $ae, $00, $de, $02, $e3, $35, $e7, $35, $3e, $8a
  .byte $4e, $02, $53, $3e, $57, $3e, $07, $8e, $a7, $34, $bf, $63, $ed, $4b, $2e, $8a
  .byte $fe, $06, $2e, $88, $34, $33, $35, $33, $6e, $06, $8e, $0c, $be, $06, $fe, $0a
  .byte $01, $d2, $0d, $44, $11, $52, $21, $52, $31, $52, $41, $52, $42, $0b, $51, $52
  .byte $61, $52, $cd, $43, $ce, $09, $dd, $42, $de, $0b, $fe, $02, $5d, $c7, $fd

;level 7-4
L_CastleArea7:
  .byte $58, $07, $05, $35, $06, $3d, $07, $3d, $be, $06, $de, $0c, $f3, $3d, $03, $8e
  .byte $6e, $43, $ce, $0a, $e1, $67, $f1, $67, $01, $e7, $11, $67, $1e, $05, $28, $39
  .byte $6e, $40, $be, $01, $c7, $06, $db, $0e, $de, $00, $1f, $80, $6f, $00, $bf, $00
  .byte $0f, $80, $5f, $00, $7e, $05, $a8, $37, $fe, $02, $24, $8e, $34, $30, $3e, $0c
  .byte $4e, $43, $ae, $0a, $be, $0c, $ee, $0a, $fe, $0c, $2e, $8a, $3e, $0c, $7e, $02
  .byte $8e, $0e, $98, $36, $b9, $34, $08, $bf, $09, $3f, $0e, $82, $2e, $86, $4e, $0c
  .byte $9e, $09, $c1, $62, $c4, $0e, $ee, $0c, $0e, $86, $5e, $0c, $7e, $09, $a1, $62
  .byte $a4, $0e, $ce, $0c, $fe, $0a, $28, $b4, $a6, $31, $e8, $34, $8b, $b2, $9b, $0e
  .byte $fe, $07, $fe, $8a, $0d, $c4, $cd, $43, $ce, $09, $dd, $42, $de, $0b, $fe, $02
  .byte $5d, $c7, $fd

;level 8-4
L_CastleArea8:
  .byte $5b, $03, $05, $34, $06, $35, $07, $36, $6e, $0a, $ee, $02, $fe, $05, $0d, $01
  .byte $17, $0e, $97, $0e, $9e, $02, $c6, $05, $fa, $30, $fe, $0a, $4e, $82, $57, $0e
  .byte $58, $62, $68, $62, $79, $61, $8a, $60, $8e, $0a, $f5, $31, $f9, $7b, $39, $f3
  .byte $97, $33, $b5, $71, $39, $f3, $4d, $48, $9e, $02, $ae, $05, $cd, $4a, $ed, $4b
  .byte $0e, $81, $17, $06, $39, $73, $5c, $02, $85, $65, $95, $32, $a9, $7b, $cc, $03
  .byte $5e, $8f, $6d, $47, $fe, $02, $0d, $07, $39, $73, $4e, $0a, $ae, $02, $ec, $71
  .byte $07, $81, $17, $02, $39, $73, $e6, $05, $39, $fb, $4e, $0a, $c4, $31, $eb, $61
  .byte $fe, $02, $07, $b0, $1e, $0a, $4e, $06, $57, $0e, $be, $02, $c9, $61, $da, $60
  .byte $ed, $4b, $0e, $85, $0d, $0e, $fe, $0a, $78, $e4, $8e, $06, $b3, $06, $bf, $47
  .byte $ee, $0f, $6d, $c7, $0e, $82, $39, $73, $9a, $60, $a9, $61, $ae, $06, $de, $0a
  .byte $e7, $03, $eb, $79, $f7, $03, $fe, $06, $0d, $14, $fe, $0a, $5e, $82, $7f, $66
  .byte $9e, $0a, $f8, $64, $fe, $0b, $9e, $84, $be, $05, $be, $82, $da, $60, $e9, $61
  .byte $f8, $62, $fe, $0a, $0d, $c4, $11, $64, $51, $62, $cd, $43, $ce, $09, $dd, $42
  .byte $de, $0b, $fe, $02, $5d, $c7, $fd

;level 5-1
L_GroundArea12:
  .byte $52, $b1, $0f, $20, $6e, $75, $cc, $73, $a3, $b3, $bf, $74, $0c, $84, $83, $3f
  .byte $9f, $74, $ef, $71, $ec, $01, $2f, $f1, $2c, $01, $6f, $71, $6c, $01, $a8, $91
  .byte $aa, $10, $77, $fb, $56, $f4, $39, $f1, $bf, $37, $33, $e7, $43, $04, $47, $03
  .byte $6c, $05, $c3, $67, $d3, $67, $e3, $67, $ed, $4c, $fc, $07, $73, $e7, $83, $67
  .byte $93, $67, $a3, $67, $bc, $08, $43, $e7, $53, $67, $dc, $02, $59, $91, $c3, $33
  .byte $d9, $71, $df, $72, $2d, $cd, $5b, $71, $9b, $71, $3b, $f1, $a7, $c2, $db, $71
  .byte $0d, $10, $9b, $71, $0a, $b0, $1c, $04, $67, $63, $76, $64, $85, $65, $94, $66
  .byte $a3, $67, $b3, $67, $cc, $09, $73, $a3, $87, $22, $b3, $09, $d6, $83, $e3, $03
  .byte $fe, $3f, $0d, $15, $de, $31, $ec, $01, $03, $f7, $9d, $41, $df, $26, $0d, $18
  .byte $39, $71, $7f, $37, $f2, $68, $01, $e9, $11, $39, $68, $7a, $de, $3f, $6d, $c5
  .byte $fd

;level 5-3
L_GroundArea13:
  .byte $50, $11, $0f, $26, $df, $32, $fe, $10, $0d, $01, $98, $74, $c8, $13, $52, $e1
  .byte $63, $31, $61, $79, $c6, $61, $06, $e1, $8b, $71, $ab, $71, $e4, $19, $eb, $19
  .byte $60, $86, $c8, $13, $cd, $4b, $39, $f3, $98, $13, $17, $f5, $7c, $15, $7f, $13
  .byte $cf, $15, $d4, $40, $0b, $9a, $23, $16, $32, $44, $a3, $95, $b2, $43, $0d, $0a
  .byte $27, $14, $3d, $4a, $a4, $40, $bc, $16, $bf, $13, $c4, $40, $04, $c0, $1f, $16
  .byte $24, $40, $43, $31, $ce, $11, $dd, $41, $0e, $d2, $3f, $20, $3d, $c7, $fd
 
;level 6-1
L_GroundArea14:
  .byte $52, $a1, $0f, $20, $6e, $40, $d6, $61, $e7, $07, $f7, $21, $16, $e1, $34, $63
  .byte $47, $21, $54, $04, $67, $0a, $74, $63, $dc, $01, $06, $e1, $17, $26, $86, $61
  .byte $66, $c2, $58, $c1, $f7, $03, $04, $f6, $8a, $10, $9c, $04, $e8, $62, $f9, $61
  .byte $0a, $e0, $53, $31, $5f, $73, $7b, $71, $77, $25, $fc, $e2, $17, $aa, $23, $00
  .byte $3c, $67, $b3, $01, $cc, $63, $db, $71, $df, $73, $fc, $00, $4f, $b7, $ca, $7a
  .byte $c5, $31, $ec, $54, $3c, $dc, $5d, $4c, $0f, $b3, $47, $63, $6b, $f1, $8c, $0a
  .byte $39, $f1, $ec, $03, $f0, $33, $0f, $e2, $29, $73, $49, $61, $58, $62, $67, $73
  .byte $85, $65, $94, $66, $a3, $77, $ad, $4d, $4d, $c1, $6f, $26, $5d, $c7, $fd

;level 6-3
L_GroundArea15:
  .byte $50, $11, $0f, $26, $af, $32, $d8, $62, $de, $10, $08, $e4, $5a, $62, $6c, $4c
  .byte $86, $43, $ad, $48, $3a, $e2, $53, $42, $88, $64, $9c, $36, $08, $e4, $4a, $62
  .byte $5c, $4d, $3a, $e2, $9c, $32, $fc, $41, $3c, $b1, $83, $00, $ac, $42, $2a, $e2
  .byte $3c, $46, $aa, $62, $bc, $4e, $c6, $43, $46, $c3, $aa, $62, $bd, $48, $0b, $96
  .byte $47, $07, $c7, $12, $3c, $c2, $9c, $41, $cd, $48, $dc, $32, $4c, $c2, $bc, $32
  .byte $1c, $b1, $5a, $62, $6c, $44, $76, $43, $ba, $62, $dc, $32, $5d, $ca, $73, $12
  .byte $e3, $12, $8e, $91, $9d, $41, $be, $42, $ef, $20, $cd, $c7, $fd

;level 7-1
L_GroundArea16:
  .byte $52, $b1, $0f, $20, $6e, $76, $03, $b1, $09, $71, $0f, $71, $6f, $33, $a7, $63
  .byte $b7, $34, $bc, $0e, $4d, $cc, $03, $a6, $08, $72, $3f, $72, $6d, $4c, $73, $07
  .byte $77, $73, $83, $27, $ac, $00, $bf, $73, $3c, $80, $9a, $30, $ac, $5b, $c6, $3c
  .byte $6a, $b0, $75, $10, $96, $74, $b6, $0a, $da, $30, $e3, $28, $ec, $5b, $ed, $48
  .byte $aa, $b0, $33, $b4, $51, $79, $ad, $4a, $dd, $4d, $e3, $2c, $0c, $fa, $73, $07
  .byte $b3, $04, $cb, $71, $ec, $07, $0d, $0a, $39, $71, $df, $33, $ca, $b0, $d6, $10
  .byte $d7, $30, $dc, $0c, $03, $b1, $ad, $41, $ef, $26, $ed, $c7, $39, $f1, $0d, $10
  .byte $7d, $4c, $0d, $13, $a8, $11, $aa, $10, $1c, $83, $d7, $7b, $f3, $67, $5d, $cd
  .byte $6d, $47, $fd

;level 7-2
L_GroundArea17:
  .byte $56, $11, $0f, $26, $df, $32, $fe, $11, $0d, $01, $0c, $5f, $03, $80, $0c, $52
  .byte $29, $15, $7c, $5b, $23, $b2, $29, $1f, $31, $79, $1c, $de, $48, $3b, $ed, $4b
  .byte $39, $f1, $cf, $b3, $fe, $10, $37, $8e, $77, $0e, $9e, $11, $a8, $34, $a9, $34
  .byte $aa, $34, $f8, $62, $fe, $10, $37, $b6, $de, $11, $e7, $63, $f8, $62, $09, $e1
  .byte $0e, $10, $47, $36, $b7, $0e, $be, $91, $ca, $32, $ee, $10, $1d, $ca, $7e, $11
  .byte $83, $77, $9e, $10, $1e, $91, $2d, $41, $4f, $26, $4d, $c7, $fd

;level 7-3
L_GroundArea18:
  .byte $57, $11, $0f, $26, $fe, $10, $4b, $92, $59, $0f, $ad, $4c, $d3, $93, $0b, $94
  .byte $29, $0f, $7b, $93, $99, $0f, $0d, $06, $27, $12, $35, $0f, $23, $b1, $57, $75
  .byte $a3, $31, $ab, $71, $f7, $75, $23, $b1, $87, $13, $95, $0f, $0d, $0a, $23, $35
  .byte $38, $13, $55, $00, $9b, $16, $0b, $96, $c7, $75, $3b, $92, $49, $0f, $ad, $4c
  .byte $29, $92, $52, $40, $6c, $15, $6f, $11, $72, $40, $bf, $15, $03, $93, $0a, $13
  .byte $12, $41, $8b, $12, $99, $0f, $0d, $10, $47, $16, $46, $45, $b3, $32, $13, $b1
  .byte $57, $0e, $a7, $0e, $d3, $31, $53, $b1, $a6, $31, $03, $b2, $13, $0e, $8d, $4d
  .byte $ae, $11, $bd, $41, $ee, $52, $0f, $a0, $dd, $47, $fd

;level 8-1
L_GroundArea19:
  .byte $52, $a1, $0f, $20, $6e, $65, $57, $f3, $60, $21, $6f, $62, $ac, $75, $07, $80
  .byte $1c, $76, $87, $01, $9c, $70, $b0, $33, $cf, $66, $57, $e3, $6c, $04, $cd, $4c
  .byte $9a, $b0, $ac, $0c, $83, $b1, $8f, $74, $bd, $4d, $f8, $11, $fa, $10, $83, $87
  .byte $93, $22, $9f, $74, $59, $f1, $89, $61, $a9, $61, $bc, $0c, $67, $a0, $eb, $71
  .byte $77, $87, $7a, $10, $86, $51, $95, $52, $a4, $53, $b6, $04, $b3, $24, $26, $85
  .byte $4a, $10, $53, $23, $5c, $00, $6f, $73, $93, $08, $07, $fb, $2c, $04, $33, $30
  .byte $74, $76, $eb, $71, $57, $8b, $6c, $02, $96, $74, $e3, $30, $0c, $86, $7d, $41
  .byte $bf, $26, $bd, $c7, $fd

;level 8-2
L_GroundArea22:
  .byte $50, $61, $0f, $26, $bb, $f1, $dc, $06, $23, $87, $b5, $71, $b7, $31, $d7, $28
  .byte $06, $c5, $67, $08, $0d, $05, $39, $71, $7c, $00, $9e, $62, $b6, $0b, $e6, $08
  .byte $4e, $e0, $5d, $4c, $59, $0f, $6c, $02, $93, $67, $ac, $56, $ad, $4c, $1f, $b1
  .byte $3c, $01, $98, $0a, $9e, $20, $a8, $21, $f3, $09, $0e, $a1, $27, $20, $3e, $62
  .byte $56, $08, $7d, $4d, $c6, $08, $3e, $e0, $9e, $62, $b6, $08, $1e, $e0, $4c, $00
  .byte $6c, $00, $a7, $7b, $de, $2f, $6d, $c7, $fe, $10, $0b, $93, $5b, $15, $b7, $12
  .byte $03, $91, $ab, $1f, $bd, $41, $ef, $26, $ad, $c7, $fd

;level 8-3
L_GroundArea23:
  .byte $50, $50, $0f, $26, $0b, $1f, $57, $92, $8b, $12, $d2, $14, $4b, $92, $59, $0f
  .byte $0b, $95, $bb, $1f, $be, $52, $58, $e2, $9e, $50, $97, $08, $bb, $1f, $ae, $d2
  .byte $b6, $08, $bb, $1f, $dd, $4a, $f6, $07, $26, $89, $8e, $50, $98, $62, $eb, $11
  .byte $07, $f3, $0b, $1d, $2e, $52, $47, $0a, $ce, $50, $eb, $1f, $ee, $52, $5e, $d0
  .byte $d9, $0f, $ab, $9f, $be, $52, $8e, $d0, $ab, $1d, $ae, $52, $36, $8b, $56, $08
  .byte $5e, $50, $dc, $15, $df, $12, $2f, $95, $c3, $31, $5b, $9f, $6d, $41, $8e, $52
  .byte $af, $20, $ad, $c7
;another unused area
L_GroundArea24:
  .byte $fd

;cloud level used with level 5-1
L_GroundArea29:
  .byte $00, $c1, $4c, $00, $f3, $4f, $fa, $c6, $68, $a0, $69, $20, $6a, $20, $7a, $47
  .byte $f8, $20, $f9, $20, $fa, $20, $0a, $cf, $b4, $49, $55, $a0, $56, $20, $73, $47
  .byte $f5, $20, $f6, $20, $22, $a1, $41, $48, $52, $20, $72, $20, $92, $20, $b2, $20
  .byte $fe, $00, $9b, $c2, $ad, $c7, $fd

;level 5-2
L_UndergroundArea4:
  .byte $48, $0f, $1e, $01, $27, $06, $5e, $02, $8f, $63, $8c, $01, $ef, $67, $1c, $81
  .byte $2e, $09, $3c, $63, $73, $01, $8c, $60, $fe, $02, $1e, $8e, $3e, $02, $44, $07
  .byte $45, $52, $4e, $0e, $8e, $02, $99, $71, $b5, $24, $b6, $24, $b7, $24, $fe, $02
  .byte $07, $87, $17, $22, $37, $52, $37, $0b, $47, $52, $4e, $0a, $57, $52, $5e, $02
  .byte $67, $52, $77, $52, $7e, $0a, $87, $52, $8e, $02, $96, $46, $97, $52, $a7, $52
  .byte $b7, $52, $c7, $52, $d7, $52, $e7, $52, $f7, $52, $fe, $04, $07, $a3, $47, $08
  .byte $57, $26, $c7, $0a, $e9, $71, $17, $a7, $97, $08, $9e, $01, $a0, $24, $c6, $74
  .byte $f0, $0c, $fe, $04, $0c, $80, $6f, $32, $98, $62, $a8, $62, $bc, $00, $c7, $73
  .byte $e7, $73, $fe, $02, $7f, $e7, $8e, $01, $9e, $00, $de, $02, $f7, $0b, $fe, $0e
  .byte $4e, $82, $54, $52, $64, $51, $6e, $00, $74, $09, $9f, $00, $df, $00, $2f, $80
  .byte $4e, $02, $59, $47, $ce, $0a, $07, $f5, $68, $54, $7f, $64, $88, $54, $a8, $54
  .byte $ae, $01, $b8, $52, $bf, $47, $c8, $52, $d8, $52, $e8, $52, $ee, $0f, $4d, $c7
  .byte $0d, $0d, $0e, $02, $68, $7a, $be, $01, $ee, $0f, $6d, $c5, $fd

;underground bonus rooms used with worlds 5-8
L_UndergroundArea5:
  .byte $08, $0f, $0e, $01, $2e, $05, $38, $2c, $3a, $4f, $08, $ac, $c7, $0b, $ce, $01
  .byte $df, $4a, $6d, $c7, $0e, $81, $00, $5a, $2e, $02, $b8, $4f, $cf, $65, $0f, $e5
  .byte $4f, $65, $8f, $65, $df, $4a, $6d, $c7, $0e, $81, $00, $5a, $30, $07, $34, $52
  .byte $3e, $02, $42, $47, $44, $47, $46, $27, $c0, $0b, $c4, $52, $df, $4a, $6d, $c7
  .byte $fd

;level 6-2
L_WaterArea2:
  .byte $41, $01, $27, $d3, $79, $51, $c4, $56, $00, $e2, $03, $53, $0c, $0f, $12, $3b
  .byte $1a, $42, $43, $54, $6d, $49, $83, $53, $99, $53, $c3, $54, $da, $52, $0c, $84
  .byte $09, $53, $53, $64, $63, $31, $67, $34, $86, $41, $8c, $01, $a3, $30, $b3, $64
  .byte $cc, $03, $d9, $42, $5c, $84, $a0, $62, $a8, $62, $b0, $62, $b8, $62, $c0, $62
  .byte $c8, $62, $d0, $62, $d8, $62, $e0, $62, $e8, $62, $16, $c2, $58, $52, $8c, $04
  .byte $a7, $55, $d0, $63, $d7, $65, $e2, $61, $e7, $65, $f2, $61, $f7, $65, $13, $b8
  .byte $17, $38, $8c, $03, $1d, $c9, $50, $62, $5c, $0b, $62, $3e, $63, $52, $8a, $52
  .byte $93, $54, $aa, $42, $d3, $51, $ea, $41, $03, $d3, $1c, $04, $1a, $52, $33, $55
  .byte $73, $44, $77, $44, $16, $d2, $19, $31, $1a, $32, $5c, $0f, $9a, $47, $95, $64
  .byte $a5, $64, $b5, $64, $c5, $64, $d5, $64, $e5, $64, $f5, $64, $05, $e4, $40, $61
  .byte $42, $35, $56, $34, $5c, $09, $a2, $61, $a6, $61, $b3, $34, $b7, $34, $fc, $08
  .byte $0c, $87, $28, $54, $59, $53, $9a, $30, $a9, $61, $b8, $62, $be, $0b, $d4, $60
  .byte $d5, $0d, $de, $0f, $0d, $ca, $7d, $47, $fd

;water area used in level 8-4
L_WaterArea4:
  .byte $07, $0f, $0e, $02, $39, $73, $05, $8e, $2e, $0b, $b7, $0e, $64, $8e, $6e, $02
  .byte $ce, $06, $de, $0f, $e6, $0d, $7d, $c7, $fd

;water area used in level 6-1
L_WaterArea5:
  .byte $01, $01, $77, $39, $a3, $43, $00, $bf, $29, $51, $39, $48, $61, $55, $d6, $54
  .byte $d2, $44, $0c, $82, $2e, $02, $31, $66, $44, $47, $47, $32, $4a, $47, $97, $32
  .byte $c1, $66, $ce, $01, $dc, $02, $fe, $0e, $0c, $8f, $08, $4f, $fe, $01, $27, $d3
  .byte $5c, $02, $9a, $60, $a9, $61, $b8, $62, $c7, $63, $ce, $0f, $d5, $0d, $7d, $c7
  .byte $fd


;level 9-3
E_CastleArea9:
    .byte $1f, $01, $0e, $69, $00, $1f, $0b, $78, $2d, $ff

;cloud level used in level 9-3
E_CastleArea10:
    .byte $1f, $01, $1e, $68, $06, $ff

;level 9-1 starting area
E_GroundArea25:
    .byte $1e, $05, $00, $ff

;two unused levels that have the same enemy data address as a used level
E_GroundArea26:
E_GroundArea27:

;level 9-1 water area
E_WaterArea6:
    .byte $26, $8f, $05, $ac, $46, $0f, $1f, $04, $e8, $10, $38, $90, $66, $11, $fb, $3c
    .byte $9b, $b7, $cb, $85, $29, $87, $95, $07, $eb, $02, $0b, $82, $96, $0e, $c3, $0e
    .byte $ff

;level 9-2
E_WaterArea7:
    .byte $1f, $01, $e6, $11, $ff

;level 9-4
E_WaterArea8:
    .byte $3b, $86, $7b, $00, $bb, $02, $2b, $8e, $7a, $05, $57, $87, $27, $8f, $9a, $0c
    .byte $ff

;level 9-3
L_CastleArea9:
    .byte $55, $31, $0d, $01, $cf, $33, $fe, $39, $fe, $b2, $2e, $be, $fe, $31, $29, $8f
    .byte $9e, $43, $fe, $30, $16, $b1, $23, $09, $4e, $31, $4e, $40, $d7, $e0, $e6, $61
    .byte $fe, $3e, $f5, $62, $fa, $60, $0c, $df, $0c, $df, $0c, $d1, $1e, $3c, $2d, $40
    .byte $4e, $32, $5e, $36, $5e, $42, $ce, $38, $0d, $0b, $8e, $36, $8e, $40, $87, $37
    .byte $96, $36, $be, $3a, $cc, $5d, $06, $bd, $07, $3e, $a8, $64, $b8, $64, $c8, $64
    .byte $d8, $64, $e8, $64, $f8, $64, $fe, $31, $09, $e1, $1a, $60, $6d, $41, $9f, $26
    .byte $7d, $c7, $fd

;cloud level used by level 9-3
L_CastleArea10:
    .byte $00, $f1, $fe, $b5, $0d, $02, $fe, $34, $07, $cf, $ce, $00, $0d, $05, $8d, $47
    .byte $fd

;level 9-1 starting area
L_GroundArea25:
    .byte $50, $02, $9f, $38, $ee, $01, $12, $b9, $77, $7b, $de, $0f, $6d, $c7, $fd

;two unused levels
L_GroundArea26:
    .byte $fd
L_GroundArea27:
    .byte $fd

;level 9-1 water area
L_WaterArea6:
    .byte $00, $a1, $0a, $60, $19, $61, $28, $62, $39, $71, $58, $62, $69, $61, $7a, $60
    .byte $7c, $f5, $a5, $11, $fe, $20, $1f, $80, $5e, $21, $80, $3f, $8f, $65, $d6, $74
    .byte $5e, $a0, $6f, $66, $9e, $21, $c3, $37, $47, $f3, $9e, $20, $fe, $21, $0d, $06
    .byte $57, $32, $64, $11, $66, $10, $83, $a7, $87, $27, $0d, $09, $1d, $4a, $5f, $38
    .byte $6d, $c1, $af, $26, $6d, $c7, $fd

;level 9-2
L_WaterArea7:
    .byte $50, $11, $d7, $73, $fe, $1a, $6f, $e2, $1f, $e5, $bf, $63, $c7, $a8, $df, $61
    .byte $15, $f1, $7f, $62, $9b, $2f, $a8, $72, $fe, $10, $69, $f1, $b7, $25, $c5, $71
    .byte $33, $ac, $5f, $71, $8d, $4a, $aa, $14, $d1, $71, $17, $95, $26, $42, $72, $42
    .byte $73, $12, $7a, $14, $c6, $14, $d5, $42, $fe, $11, $7f, $b8, $8d, $c1, $cf, $26
    .byte $6d, $c7, $fd

;level 9-4
L_WaterArea8:
    .byte $57, $00, $0b, $3f, $0b, $bf, $0b, $bf, $73, $36, $9a, $30, $a5, $64, $b6, $31
    .byte $d4, $61, $0b, $bf, $13, $63, $4a, $60, $53, $66, $a5, $34, $b3, $67, $e5, $65
    .byte $f4, $60, $0b, $bf, $14, $60, $53, $67, $67, $32, $c4, $62, $d4, $31, $f3, $61
    .byte $fa, $60, $0b, $bf, $04, $30, $09, $61, $14, $65, $63, $65, $6a, $60, $0b, $bf
    .byte $0f, $38, $0b, $bf, $1d, $41, $3e, $42, $5f, $20, $ce, $40, $0b, $bf, $3d, $47
    .byte $fd

;-------------------------------------------------------------------------------------
.endif

.ifdef ANN
E_HArea00:
.byte $2A, $9E, $6B, $0C, $8D, $1C, $EA, $1F, $1B, $8C, $E6, $1C, $8C, $9C, $BB, $0C
.byte $F3, $83, $9B, $8C, $DB, $0C, $1B, $8C, $6B, $0C, $BB, $0C, $0F, $09, $40, $15
.byte $78, $AD, $90, $B5, $FF

E_HArea01:
.byte $0F, $02, $38, $1D, $D9, $1B, $6E, $E1, $21, $3A, $A8, $18, $9D, $0F, $07, $18
.byte $1D, $0F, $09, $18, $1D, $0F, $0B, $18, $1D, $7B, $15, $8E, $21, $2E, $B9, $9D
.byte $0F, $0E, $78, $2D, $90, $B5, $FF

E_HArea02:
.byte $05, $9D, $0D, $A8, $DD, $1D, $07, $AC, $54, $2C, $A2, $2C, $F4, $2C, $42, $AC
.byte $26, $9D, $D4, $03, $24, $83, $64, $03, $2B, $82, $4B, $02, $7B, $02, $9B, $02
.byte $5B, $82, $7B, $02, $0B, $82, $2B, $02, $C6, $1B, $28, $82, $48, $02, $A6, $1B
.byte $7B, $95, $85, $0C, $9D, $9B, $0F, $0E, $78, $2D, $7A, $1D, $90, $B5, $FF

E_HArea03:
.byte $19, $9F, $99, $1B, $2C, $8C, $59, $1B, $C5, $0F, $0F, $04, $09, $29, $BD, $1D
.byte $0F, $06, $6E, $2A, $61, $0F, $09, $48, $2D, $46, $87, $79, $07, $8E, $63, $60
.byte $A5, $07, $B8, $85, $57, $A5, $8C, $8C, $76, $9D, $78, $2D, $90, $B5, $FF

E_HArea04:
.byte $07, $83, $37, $03, $6B, $0E, $E0, $3D, $20, $BE, $6E, $2B, $00, $A7, $85, $D3
.byte $05, $E7, $83, $24, $83, $27, $03, $49, $00, $59, $00, $10, $BB, $B0, $3B, $6E
.byte $C1, $00, $17, $85, $53, $05, $36, $8E, $76, $0E, $B6, $0E, $E7, $83, $63, $83
.byte $68, $03, $29, $83, $57, $03, $85, $03, $B5, $29, $FF

E_HArea05:
.byte $56, $87, $44, $87, $0F, $04, $66, $87, $0F, $06, $86, $10, $0F, $08, $55, $0F
.byte $E5, $8F, $FF

E_HArea06:
.byte $1B, $82, $4B, $02, $7B, $02, $AB, $02, $0F, $03, $F9, $0E, $D0, $BE, $8E, $C1
.byte $24, $F8, $0E, $C0, $BA, $0F, $0D, $3A, $0E, $BB, $02, $30, $B7, $80, $BC, $C0
.byte $BC, $0F, $12, $24, $0F, $54, $0F, $CE, $2B, $20, $D3, $0F, $CB, $8E, $F9, $0E
.byte $FF

E_HArea07:
.byte $80, $BE, $83, $03, $92, $10, $4B, $80, $B0, $3C, $07, $80, $B7, $24, $0C, $A4
.byte $96, $A9, $1B, $83, $7B, $24, $B7, $24, $97, $83, $E2, $0F, $A9, $A9, $38, $A9
.byte $0F, $0B, $74, $0F, $FF

E_HArea08:
.byte $3A, $8E, $5B, $0E, $C3, $8E, $CA, $8E, $0B, $8E, $4A, $0E, $DE, $C1, $44, $0F
.byte $08, $49, $0E, $EB, $0E, $8A, $90, $AB, $85, $0F, $0C, $03, $0F, $2E, $2B, $40
.byte $67, $86, $FF

E_HArea09:
.byte $15, $8F, $54, $07, $AA, $83, $F8, $07, $0F, $04, $14, $07, $96, $10, $0F, $07
.byte $95, $0F, $9D, $A8, $0B, $97, $09, $A9, $55, $24, $A9, $24, $BB, $17, $FF

E_HArea0A:
.byte $0F, $04, $A3, $10, $0F, $09, $E3, $29, $0F, $0D, $55, $24, $A9, $24, $0F, $11
.byte $59, $1D, $A9, $1B, $23, $8F, $15, $9B, $FF

E_HArea0B:
.byte $DB, $82, $30, $B7, $80, $3B, $1B, $8E, $4A, $0E, $EB, $03, $3B, $82, $5B, $02
.byte $E5, $0F, $14, $8F, $44, $0F, $5E, $41, $60, $5B, $82, $0C, $85, $35, $8F, $06
.byte $85, $E3, $05, $2E, $AB, $60, $DB, $03, $FF

E_HArea0C:
.byte $DB, $82, $F3, $03, $10, $B7, $80, $37, $1A, $8E, $4B, $0E, $7A, $0E, $AB, $0E
.byte $0F, $05, $F9, $0E, $D0, $BE, $2E, $C1, $62, $D4, $8F, $64, $8F, $7E, $2B, $60
.byte $FF

E_HArea0D:
.byte $0F, $03, $AB, $05, $1B, $85, $A3, $85, $D7, $05, $0F, $08, $33, $03, $0B, $85
.byte $FB, $85, $8B, $85, $3A, $8E, $FF

E_HArea0E:
.byte $0F, $02, $09, $05, $3E, $41, $64, $2B, $8E, $58, $0E, $CA, $07, $34, $87, $FF

E_HArea0F:
.byte $0A, $AA, $1E, $20, $03, $1E, $22, $30, $2E, $24, $48, $2E, $28, $67, $FF

E_HArea12:
.byte $BB, $A9, $1B, $A9, $69, $29, $B8, $29, $59, $A9, $8D, $A8, $0F, $07, $15, $29
.byte $55, $AC, $6B, $85, $0E, $AD, $01, $67, $34, $FF

E_HArea13:
.byte $1E, $A0, $09, $1E, $27, $61, $0F, $03, $1E, $28, $68, $1E, $22, $27, $0F, $05
.byte $1E, $24, $48, $1E, $63, $68, $FF

E_HArea14:
.byte $EE, $AD, $21, $26, $87, $F3, $0E, $66, $87, $CB, $00, $65, $87, $0F, $06, $06
.byte $0E, $97, $07, $CB, $00, $75, $87, $D3, $27, $D9, $27, $0F, $09, $77, $1F, $46
.byte $87, $B1, $0F, $FF




L_HArea00:
.byte $9B, $87, $05, $32, $06, $33, $07, $34, $EE, $0A, $0E, $86, $28, $0B, $3E, $0A
.byte $6E, $02, $8B, $0B, $97, $00, $9E, $0A, $CE, $06, $E8, $0B, $FE, $0A, $2E, $86
.byte $6E, $0A, $8E, $08, $E4, $0B, $1E, $82, $8A, $0B, $8E, $0A, $FE, $02, $1A, $E0
.byte $29, $61, $2E, $06, $3E, $09, $56, $60, $65, $61, $6E, $0C, $83, $60, $7E, $8A
.byte $BB, $61, $F9, $63, $27, $E5, $88, $64, $EB, $61, $FE, $05, $68, $90, $0A, $90
.byte $FE, $02, $3A, $90, $3E, $0A, $AE, $02, $DA, $60, $E9, $61, $F8, $62, $FE, $0A
.byte $0D, $C4, $A1, $62, $B1, $62, $CD, $43, $CE, $09, $DE, $0B, $DD, $42, $FE, $02
.byte $5D, $C7, $FD

L_HArea01:
.byte $9B, $07, $05, $32, $06, $33, $07, $33, $3E, $0A, $41, $3B, $42, $3B, $58, $64
.byte $7A, $62, $C8, $31, $18, $E4, $39, $73, $5E, $09, $66, $3C, $0E, $82, $28, $05
.byte $36, $0B, $3E, $0A, $AE, $02, $D7, $0B, $FE, $0C, $FE, $8A, $11, $E5, $21, $65
.byte $31, $65, $4E, $0C, $FE, $02, $16, $8B, $2E, $0E, $FE, $02, $18, $FA, $3E, $0E
.byte $FE, $02, $16, $8B, $2E, $0E, $FE, $02, $18, $FA, $3E, $0E, $FE, $02, $16, $8B
.byte $2E, $0E, $FE, $02, $18, $FA, $3E, $0E, $FE, $02, $16, $8B, $2E, $0E, $FE, $02
.byte $18, $FA, $5E, $0A, $6E, $02, $7E, $0A, $B7, $0B, $EE, $07, $FE, $8A, $0D, $C4
.byte $CD, $43, $CE, $09, $DD, $42, $DE, $0B, $FE, $02, $5D, $C7, $FD

L_HArea02:
.byte $58, $07, $05, $35, $06, $3D, $07, $3D, $BE, $06, $DE, $0C, $F3, $3D, $03, $8B
.byte $6E, $43, $CE, $0A, $E1, $67, $F1, $67, $01, $E7, $11, $67, $1E, $05, $28, $39
.byte $6E, $40, $BE, $01, $C7, $04, $DB, $0B, $DE, $00, $1F, $80, $6F, $00, $BF, $00
.byte $0F, $80, $5F, $00, $7E, $05, $A8, $37, $FE, $02, $24, $8B, $34, $30, $3E, $0C
.byte $4E, $43, $AE, $0A, $BE, $0C, $EE, $0A, $FE, $0C, $2E, $8A, $3E, $0C, $7E, $02
.byte $8E, $0E, $98, $36, $B9, $34, $08, $BF, $09, $3F, $0E, $82, $2E, $86, $4E, $0C
.byte $9E, $09, $C1, $62, $C4, $0B, $EE, $0C, $0E, $86, $5E, $0C, $7E, $09, $A1, $62
.byte $A4, $0B, $CE, $0C, $FE, $0A, $28, $B4, $A6, $31, $E8, $34, $8B, $B2, $9B, $0B
.byte $FE, $07, $FE, $8A, $0D, $C4, $CD, $43, $CE, $09, $DD, $42, $DE, $0B, $FE, $02
.byte $5D, $C7, $FD

L_HArea03:
.byte $5B, $03, $05, $34, $06, $35, $39, $71, $6E, $02, $AE, $0A, $FE, $05, $17, $8B
.byte $97, $0B, $9E, $02, $A6, $04, $FA, $30, $FE, $0A, $4E, $82, $57, $0B, $58, $62
.byte $68, $62, $79, $61, $8A, $60, $8E, $0A, $F5, $31, $F9, $73, $39, $F3, $B5, $71
.byte $B7, $31, $4D, $C8, $8A, $62, $9A, $62, $AE, $05, $BB, $0B, $CD, $4A, $FE, $82
.byte $77, $FB, $DE, $0F, $4E, $82, $6D, $47, $39, $F3, $0C, $EA, $08, $3F, $B3, $00
.byte $CC, $63, $F9, $30, $69, $F9, $EA, $60, $F9, $61, $FE, $07, $DE, $84, $E4, $62
.byte $E9, $61, $F4, $62, $FA, $60, $04, $E2, $14, $62, $24, $62, $34, $62, $3E, $0A
.byte $7E, $0C, $7E, $8A, $8E, $08, $94, $36, $FE, $0A, $0D, $C4, $61, $64, $71, $64
.byte $81, $64, $CD, $43, $CE, $09, $DD, $42, $DE, $0B, $FE, $02, $5D, $C7, $FD

L_HArea04:
.byte $52, $71, $0F, $20, $6E, $70, $E3, $64, $FC, $61, $FC, $71, $13, $84, $2C, $61
.byte $2C, $71, $43, $64, $B2, $22, $B5, $62, $C7, $28, $22, $A2, $52, $06, $56, $61
.byte $6C, $03, $DB, $71, $FC, $03, $F3, $20, $03, $A4, $0F, $71, $40, $09, $86, $47
.byte $8C, $74, $9C, $66, $D7, $00, $EC, $71, $89, $E1, $B6, $61, $B9, $2A, $C7, $26
.byte $F4, $23, $67, $E2, $E8, $F2, $7C, $F4, $03, $A6, $07, $26, $21, $79, $4B, $71
.byte $CF, $33, $06, $E4, $16, $2A, $39, $71, $58, $45, $5A, $45, $C6, $05, $DC, $04
.byte $3F, $E7, $3B, $71, $8C, $71, $AC, $01, $E7, $63, $39, $8C, $63, $20, $65, $08
.byte $68, $62, $8C, $00, $0C, $81, $29, $63, $3C, $01, $57, $65, $6C, $01, $85, $67
.byte $9C, $04, $1D, $C1, $5F, $26, $3D, $C7, $FD

L_HArea05:
.byte $50, $50, $0B, $1E, $0F, $26, $19, $96, $84, $43, $C7, $1E, $6D, $C8, $E3, $12
.byte $39, $9C, $56, $43, $47, $9A, $A4, $12, $C1, $04, $F4, $42, $1B, $98, $A7, $14
.byte $02, $C2, $03, $12, $57, $1E, $AD, $48, $63, $9C, $82, $48, $86, $92, $08, $94
.byte $8E, $11, $B0, $02, $C9, $0C, $1D, $C1, $2D, $4A, $4E, $42, $6F, $20, $0D, $0E
.byte $0E, $40, $39, $71, $7F, $37, $F2, $68, $01, $E9, $11, $39, $68, $7A, $DE, $1F
.byte $6D, $C5, $FD

L_HArea06:
.byte $52, $B1, $0F, $20, $6E, $75, $CC, $73, $A3, $B3, $BF, $74, $0C, $84, $83, $3F
.byte $9F, $74, $EF, $71, $EC, $01, $2F, $F1, $2C, $01, $6F, $71, $A8, $91, $AA, $10
.byte $77, $FB, $56, $F4, $39, $F1, $BF, $37, $33, $E7, $43, $03, $47, $02, $6C, $05
.byte $C3, $67, $D3, $67, $E3, $67, $FC, $07, $73, $E7, $83, $67, $93, $67, $A3, $67
.byte $BC, $08, $43, $E7, $53, $67, $DC, $02, $59, $91, $C3, $33, $D9, $71, $DF, $72
.byte $5B, $F1, $9B, $71, $3B, $F1, $A7, $C2, $DB, $71, $0D, $10, $9B, $71, $0A, $B0
.byte $1C, $04, $67, $63, $76, $64, $85, $65, $94, $66, $A3, $67, $B3, $67, $CC, $09
.byte $73, $A3, $87, $22, $B3, $06, $D6, $82, $E3, $02, $FE, $3F, $0D, $15, $DE, $31
.byte $EC, $01, $03, $F7, $9D, $41, $DF, $26, $BD, $C7, $FD

L_HArea07:
.byte $55, $10, $0B, $1F, $0F, $26, $D6, $12, $07, $9F, $33, $1A, $FB, $1F, $F7, $94
.byte $24, $88, $53, $14, $71, $71, $CC, $15, $CF, $13, $1F, $98, $63, $12, $9B, $13
.byte $A9, $71, $FB, $17, $09, $F1, $13, $13, $21, $42, $59, $0C, $EB, $13, $33, $93
.byte $40, $04, $8C, $14, $8F, $17, $93, $40, $CF, $13, $0B, $94, $57, $15, $07, $93
.byte $24, $08, $19, $F3, $C6, $43, $C7, $13, $D3, $02, $E3, $02, $33, $B0, $4A, $72
.byte $55, $46, $73, $31, $A8, $74, $E3, $12, $8E, $91, $AD, $41, $CE, $42, $EF, $20
.byte $DD, $C7, $FD

L_HArea08:
.byte $52, $31, $0F, $20, $6E, $74, $0D, $02, $03, $33, $1F, $72, $39, $71, $65, $03
.byte $6C, $70, $77, $00, $84, $72, $8C, $72, $B3, $34, $EC, $01, $EF, $72, $0D, $04
.byte $AC, $67, $CC, $01, $CF, $71, $E7, $2B, $23, $80, $3C, $62, $65, $71, $67, $33
.byte $8C, $61, $DC, $01, $08, $FA, $45, $75, $63, $07, $73, $23, $7C, $02, $8F, $72
.byte $73, $A9, $9F, $74, $BF, $74, $EF, $73, $39, $F1, $FC, $0A, $0D, $0B, $13, $25
.byte $4C, $01, $4F, $72, $73, $08, $77, $02, $DC, $08, $23, $A2, $53, $06, $56, $02
.byte $63, $24, $8C, $02, $3F, $B3, $77, $63, $96, $74, $B3, $77, $5D, $C1, $8F, $26
.byte $7D, $C7, $FD

L_HArea09:
.byte $54, $11, $0F, $26, $CF, $32, $F8, $62, $FE, $10, $3C, $B2, $BD, $48, $EA, $62
.byte $FC, $4D, $FC, $4D, $17, $C9, $DA, $62, $0B, $97, $B7, $12, $2C, $B1, $33, $43
.byte $6C, $31, $AC, $41, $0B, $98, $AD, $4A, $DB, $30, $27, $B0, $B7, $14, $C6, $42
.byte $C7, $96, $D6, $44, $2B, $92, $39, $0C, $72, $41, $A7, $00, $1B, $95, $97, $13
.byte $6C, $95, $6F, $11, $A2, $40, $BF, $15, $C2, $40, $0B, $9A, $62, $42, $63, $12
.byte $AD, $4A, $0E, $91, $1D, $41, $4F, $26, $4D, $C7, $FD

L_HArea0A:
.byte $57, $11, $0F, $26, $FE, $10, $4B, $92, $59, $0C, $D3, $93, $0B, $94, $29, $0C
.byte $7B, $93, $99, $0C, $0D, $06, $27, $12, $35, $0C, $23, $B1, $57, $75, $A3, $31
.byte $AB, $71, $F7, $75, $23, $B1, $87, $13, $95, $0C, $0D, $0A, $23, $35, $38, $13
.byte $55, $00, $9B, $16, $0B, $96, $C7, $75, $3B, $92, $49, $0C, $29, $92, $52, $40
.byte $6C, $15, $6F, $11, $72, $40, $BF, $15, $02, $C3, $03, $13, $0A, $13, $8B, $12
.byte $99, $0C, $0D, $10, $47, $16, $46, $45, $94, $08, $B3, $32, $13, $B1, $57, $0B
.byte $A7, $0B, $D3, $31, $53, $B1, $A6, $31, $03, $B2, $13, $0B, $AE, $11, $BD, $41
.byte $EE, $52, $0F, $A0, $DD, $47, $FD

L_HArea0B:
.byte $52, $A1, $0F, $20, $6E, $65, $39, $F1, $60, $21, $6F, $62, $AC, $75, $07, $80
.byte $1C, $78, $B0, $33, $CF, $66, $57, $E3, $6C, $04, $9A, $B0, $AC, $0C, $83, $B1
.byte $8F, $74, $F8, $11, $FA, $10, $83, $85, $93, $22, $9F, $74, $59, $F9, $89, $61
.byte $A9, $61, $BC, $0C, $67, $A0, $EB, $71, $77, $85, $7A, $10, $86, $51, $95, $52
.byte $A4, $53, $B6, $03, $B3, $06, $D3, $23, $26, $84, $4A, $10, $53, $23, $5C, $00
.byte $6F, $73, $93, $05, $07, $F3, $2C, $04, $33, $30, $74, $76, $EB, $71, $57, $88
.byte $6C, $02, $96, $74, $E3, $30, $0C, $86, $7D, $41, $BF, $26, $BD, $C7, $FD

L_HArea0C:
.byte $55, $A1, $0F, $26, $9C, $01, $4F, $B6, $B3, $34, $C9, $3F, $13, $BA, $A3, $B3
.byte $BF, $74, $0C, $84, $83, $3F, $9F, $74, $EF, $72, $EC, $01, $2F, $F2, $2C, $01
.byte $6F, $72, $6C, $01, $A8, $91, $AA, $10, $03, $B7, $10, $08, $61, $79, $6F, $75
.byte $39, $F1, $DB, $71, $03, $A2, $17, $22, $33, $06, $43, $20, $5B, $71, $48, $8C
.byte $4A, $30, $5C, $5C, $93, $31, $2D, $C1, $5F, $26, $3D, $C7, $FD

L_HArea0D:
.byte $55, $A1, $0F, $26, $39, $91, $68, $12, $A7, $12, $AA, $10, $C7, $05, $E8, $12
.byte $19, $91, $6C, $00, $78, $74, $0E, $C2, $76, $A8, $FE, $40, $29, $91, $73, $29
.byte $77, $53, $86, $47, $8C, $76, $F7, $00, $59, $91, $87, $13, $B6, $14, $BA, $10
.byte $E8, $12, $38, $92, $19, $8C, $2C, $00, $33, $67, $4E, $42, $68, $08, $2E, $C0
.byte $38, $72, $A8, $11, $AA, $10, $49, $91, $6E, $42, $DE, $40, $E7, $22, $0E, $C2
.byte $4E, $C0, $6C, $00, $79, $11, $8C, $01, $A7, $13, $BC, $01, $D5, $15, $EC, $01
.byte $03, $97, $0E, $00, $6E, $01, $9D, $41, $CE, $42, $FF, $20, $9D, $C7, $FD

L_HArea0E:
.byte $10, $21, $39, $F1, $09, $F1, $A8, $60, $7C, $83, $96, $30, $5B, $F1, $C8, $04
.byte $1F, $B7, $93, $67, $A3, $67, $B3, $67, $B8, $60, $CC, $08, $54, $FE, $6E, $2F
.byte $6D, $C7, $FD

L_HArea0F:
.byte $00, $C1, $4C, $00, $02, $C9, $BA, $49, $62, $C9, $A4, $20, $A5, $20, $1A, $C9
.byte $A3, $2C, $B2, $49, $56, $C2, $6E, $00, $95, $41, $AD, $C7, $FD

L_HArea12:
.byte $48, $8F, $1E, $01, $4E, $02, $00, $89, $09, $0C, $6E, $0A, $EE, $82, $2E, $80
.byte $30, $20, $7E, $01, $87, $27, $07, $85, $17, $23, $3E, $00, $9E, $05, $5B, $F1
.byte $8B, $71, $BB, $71, $EB, $71, $3E, $82, $7F, $38, $FE, $0A, $3E, $84, $47, $29
.byte $48, $2E, $AF, $71, $CB, $71, $E7, $07, $F7, $23, $2B, $F1, $37, $51, $3E, $00
.byte $6F, $00, $8E, $04, $DF, $32, $9C, $82, $CA, $12, $DC, $00, $E8, $14, $FC, $00
.byte $FE, $08, $4E, $8A, $88, $74, $9E, $01, $A8, $52, $BF, $47, $B8, $52, $C8, $52
.byte $D8, $52, $E8, $52, $EE, $0F, $4D, $C7, $0D, $0D, $0E, $02, $68, $7A, $BE, $01
.byte $EE, $0F, $6D, $C5, $FD

L_HArea13:
.byte $08, $0F, $0E, $01, $2E, $05, $38, $20, $3E, $04, $48, $05, $55, $45, $57, $45
.byte $58, $25, $B8, $05, $BE, $05, $C8, $20, $CE, $01, $DF, $4A, $6D, $C7, $0E, $81
.byte $00, $5A, $2E, $02, $34, $42, $36, $42, $37, $22, $73, $54, $83, $08, $87, $20
.byte $93, $54, $90, $05, $B4, $41, $B6, $41, $B7, $21, $DF, $4A, $6D, $C7, $0E, $81
.byte $00, $5A, $14, $56, $24, $56, $2E, $0C, $33, $43, $6E, $09, $8E, $0B, $96, $48
.byte $1E, $84, $3E, $05, $4A, $48, $47, $08, $CE, $01, $DF, $4A, $6D, $C7, $FD

L_HArea14:
.byte $41, $01, $DA, $60, $E9, $61, $F8, $62, $FE, $0B, $FE, $81, $47, $D3, $8A, $60
.byte $99, $61, $A8, $62, $B7, $63, $C6, $64, $D5, $65, $E4, $66, $ED, $49, $F3, $67
.byte $1A, $CB, $E3, $67, $F3, $67, $FE, $02, $31, $D6, $3C, $02, $77, $53, $AC, $02
.byte $B1, $56, $E7, $53, $FE, $01, $77, $B9, $A3, $43, $00, $BF, $29, $51, $39, $48
.byte $61, $55, $D2, $44, $D6, $54, $0C, $82, $2E, $02, $31, $66, $44, $47, $47, $32
.byte $4A, $47, $97, $32, $C1, $66, $CE, $01, $DC, $02, $FE, $0E, $0C, $8F, $08, $4F
.byte $FE, $02, $75, $E0, $FE, $01, $0C, $87, $9A, $60, $A9, $61, $B8, $62, $C7, $63
.byte $CE, $0F, $D5, $0A, $6D, $CA, $7D, $47, $FD

;unused bytes
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.else
;--------------------------------------------------

;level A-4
E_CastleArea11:
  .byte $2a, $9e, $6b, $0c, $8d, $1c, $ea, $1f, $1b, $8c, $e6, $1c, $8c, $9c, $bb, $0c
  .byte $f3, $83, $9b, $8c, $db, $0c, $1b, $8c, $6b, $0c, $bb, $0c, $0f, $09, $40, $15
  .byte $78, $ad, $90, $b5, $ff

;level B-4
E_CastleArea12:
  .byte $0f, $02, $38, $1d, $d9, $1b, $6e, $e1, $21, $3a, $a8, $18, $9d, $0f, $07, $18
  .byte $1d, $0f, $09, $18, $1d, $0f, $0b, $18, $1d, $7b, $15, $8e, $21, $2e, $b9, $9d
  .byte $0f, $0e, $78, $2d, $90, $b5, $ff

;level C-4
E_CastleArea13:
  .byte $05, $9d, $65, $1d, $0d, $a8, $dd, $1d, $07, $ac, $54, $2c, $a2, $2c, $f4, $2c
  .byte $42, $ac, $26, $9d, $d4, $03, $24, $83, $64, $03, $2b, $82, $4b, $02, $7b, $02
  .byte $9b, $02, $5b, $82, $7b, $02, $0b, $82, $2b, $02, $c6, $1b, $28, $82, $48, $02
  .byte $a6, $1b, $7b, $95, $85, $0c, $9d, $9b, $0f, $0e, $78, $2d, $7a, $1d, $90, $b5
  .byte $ff

;level D-4
E_CastleArea14:
  .byte $19, $9f, $99, $1b, $2c, $8c, $59, $1b, $c5, $0f, $0f, $04, $09, $29, $bd, $1d
  .byte $0f, $06, $6e, $2a, $61, $0f, $09, $48, $2d, $46, $87, $79, $07, $8e, $63, $60
  .byte $a5, $07, $b8, $85, $57, $a5, $8c, $8c, $76, $9d, $78, $2d, $90, $b5, $ff

;level A-1
E_GroundArea30:
  .byte $07, $83, $37, $03, $6b, $0e, $e0, $3d, $20, $be, $6e, $2b, $00, $a7, $85, $d3
  .byte $05, $e7, $83, $24, $83, $27, $03, $49, $00, $59, $00, $10, $bb, $b0, $3b, $6e
  .byte $c1, $00, $17, $85, $53, $05, $36, $8e, $76, $0e, $b6, $0e, $e7, $83, $63, $83
  .byte $68, $03, $29, $83, $57, $03, $85, $03, $b5, $29, $ff

;level A-3
E_GroundArea31:
  .byte $0f, $04, $66, $07, $0f, $06, $86, $10, $0f, $08, $55, $0f, $e5, $8f, $ff

;level B-1
E_GroundArea32:
  .byte $70, $b7, $ca, $00, $66, $80, $0f, $04, $79, $0e, $ab, $0e, $ee, $2b, $20, $eb
  .byte $80, $40, $bb, $fb, $00, $40, $b7, $cb, $0e, $0f, $09, $4b, $00, $76, $00, $d8
  .byte $00, $6b, $8e, $73, $06, $83, $06, $c7, $0e, $36, $90, $c5, $06, $ff

;level B-3
E_GroundArea33:
  .byte $84, $8f, $a7, $24, $d3, $0f, $ea, $24, $45, $a9, $d5, $28, $45, $a9, $84, $25
  .byte $b4, $8f, $09, $90, $b5, $a8, $5b, $97, $cd, $28, $b5, $a4, $09, $a4, $65, $28
  .byte $92, $90, $e3, $83, $ff

;level C-1
E_GroundArea34:
  .byte $3a, $8e, $5b, $0e, $c3, $8e, $ca, $8e, $0b, $8e, $4a, $0e, $de, $c1, $44, $0f
  .byte $08, $49, $0e, $eb, $0e, $8a, $90, $ab, $85, $0f, $0c, $03, $0f, $2e, $2b, $40
  .byte $67, $86, $ff

;level C-2
E_GroundArea35:
  .byte $15, $8f, $54, $07, $aa, $83, $f8, $07, $0f, $04, $14, $07, $96, $10, $0f, $07
  .byte $95, $0f, $9d, $a8, $0b, $97, $09, $a9, $55, $24, $a9, $24, $bb, $17, $ff

;level C-3
E_GroundArea36:
  .byte $0f, $03, $a6, $11, $a3, $90, $a6, $91, $0f, $08, $a6, $11, $e3, $a9, $0f, $0d
  .byte $55, $24, $a9, $24, $0f, $11, $59, $1d, $a9, $1b, $23, $8f, $15, $9b, $ff

;level D-1
E_GroundArea37:
  .byte $87, $85, $9b, $05, $18, $90, $a4, $8f, $6e, $c1, $60, $9b, $02, $d0, $3b, $80
  .byte $b8, $03, $8e, $1b, $02, $3b, $02, $0f, $08, $03, $10, $f7, $05, $6b, $85, $ff

;level D-2
E_GroundArea38:
  .byte $db, $82, $f3, $03, $10, $b7, $80, $37, $1a, $8e, $4b, $0e, $7a, $0e, $ab, $0e
  .byte $0f, $05, $f9, $0e, $d0, $be, $2e, $c1, $62, $d4, $8f, $64, $8f, $7e, $2b, $60
  .byte $ff

;level D-3
E_GroundArea39:
  .byte $0f, $03, $ab, $05, $1b, $85, $a3, $85, $d7, $05, $0f, $08, $33, $03, $0b, $85
  .byte $fb, $85, $8b, $85, $3a, $8e, $ff

;ground level area used with level D-4
E_GroundArea40:
  .byte $0f, $02, $09, $05, $3e, $41, $64, $2b, $8e, $58, $0e, $ca, $07, $34, $87, $ff

;cloud level used with levels A-1, B-1 and D-2
E_GroundArea41:
  .byte $0a, $aa, $1e, $20, $03, $1e, $22, $27, $2e, $24, $48, $2e, $28, $67, $ff

;level A-2
E_UndergroundArea6:
  .byte $bb, $a9, $1b, $a9, $69, $29, $b8, $29, $59, $a9, $8d, $a8, $0f, $07, $15, $29
  .byte $55, $ac, $6b, $85, $0e, $ad, $01, $67, $34, $ff

;underground bonus rooms used with worlds A-D
E_UndergroundArea7:
  .byte $1e, $a0, $09, $1e, $27, $67, $0f, $03, $1e, $28, $68, $0f, $05, $1e, $24, $48
  .byte $1e, $63, $68, $ff

;level B-2
E_WaterArea9:
  .byte $ee, $ad, $21, $26, $87, $f3, $0e, $66, $87, $cb, $00, $65, $87, $0f, $06, $06
  .byte $0e, $97, $07, $cb, $00, $75, $87, $d3, $27, $d9, $27, $0f, $09, $77, $1f, $46
  .byte $87, $b1, $0f, $ff

;level A-4
L_CastleArea11:
  .byte $9b, $87, $05, $32, $06, $33, $07, $34, $ee, $0a, $0e, $86, $28, $0e, $3e, $0a
  .byte $6e, $02, $8b, $0e, $97, $00, $9e, $0a, $ce, $06, $e8, $0e, $fe, $0a, $2e, $86
  .byte $6e, $0a, $8e, $08, $e4, $0e, $1e, $82, $8a, $0e, $8e, $0a, $fe, $02, $1a, $e0
  .byte $29, $61, $2e, $06, $3e, $09, $56, $60, $65, $61, $6e, $0c, $83, $60, $7e, $8a
  .byte $bb, $61, $f9, $63, $27, $e5, $88, $64, $eb, $61, $fe, $05, $68, $90, $0a, $90
  .byte $fe, $02, $3a, $90, $3e, $0a, $ae, $02, $da, $60, $e9, $61, $f8, $62, $fe, $0a
  .byte $0d, $c4, $a1, $62, $b1, $62, $cd, $43, $ce, $09, $de, $0b, $dd, $42, $fe, $02
  .byte $5d, $c7, $fd

;level B-4
L_CastleArea12:
  .byte $9b, $07, $05, $32, $06, $33, $07, $33, $3e, $0a, $41, $3b, $42, $3b, $58, $64
  .byte $7a, $62, $c8, $31, $18, $e4, $39, $73, $5e, $09, $66, $3c, $0e, $82, $28, $07
  .byte $36, $0e, $3e, $0a, $ae, $02, $d7, $0e, $fe, $0c, $fe, $8a, $11, $e5, $21, $65
  .byte $31, $65, $4e, $0c, $fe, $02, $16, $8e, $2e, $0e, $fe, $02, $18, $fa, $3e, $0e
  .byte $fe, $02, $16, $8e, $2e, $0e, $fe, $02, $18, $fa, $3e, $0e, $fe, $02, $16, $8e
  .byte $2e, $0e, $fe, $02, $18, $fa, $3e, $0e, $fe, $02, $16, $8e, $2e, $0e, $fe, $02
  .byte $18, $fa, $5e, $0a, $6e, $02, $7e, $0a, $b7, $0e, $ee, $07, $fe, $8a, $0d, $c4
  .byte $cd, $43, $ce, $09, $dd, $42, $de, $0b, $fe, $02, $5d, $c7, $fd

;level C-4
L_CastleArea13:
  .byte $98, $07, $05, $35, $06, $3d, $07, $3d, $be, $06, $de, $0c, $f3, $3d, $03, $8e
  .byte $63, $0e, $6e, $43, $ce, $0a, $e1, $67, $f1, $67, $01, $e7, $11, $67, $1e, $05
  .byte $28, $39, $6e, $40, $be, $01, $c7, $06, $db, $0e, $de, $00, $1f, $80, $6f, $00
  .byte $bf, $00, $0f, $80, $5f, $00, $7e, $05, $a8, $37, $fe, $02, $24, $8e, $34, $30
  .byte $3e, $0c, $4e, $43, $ae, $0a, $be, $0c, $ee, $0a, $fe, $0c, $2e, $8a, $3e, $0c
  .byte $7e, $02, $8e, $0e, $98, $36, $b9, $34, $08, $bf, $09, $3f, $0e, $82, $2e, $86
  .byte $4e, $0c, $9e, $09, $a6, $60, $c1, $62, $c4, $0e, $ee, $0c, $0e, $86, $5e, $0c
  .byte $7e, $09, $86, $60, $a1, $62, $a4, $0e, $c6, $60, $ce, $0c, $fe, $0a, $28, $b4
  .byte $a6, $31, $e8, $34, $8b, $b2, $9b, $0e, $fe, $07, $fe, $8a, $0d, $c4, $cd, $43
  .byte $ce, $09, $dd, $42, $de, $0b, $fe, $02, $5d, $c7, $fd

;level D-4
L_CastleArea14:
  .byte $5b, $03, $05, $34, $06, $35, $39, $71, $6e, $02, $ae, $0a, $fe, $05, $17, $8e
  .byte $97, $0e, $9e, $02, $a6, $06, $fa, $30, $fe, $0a, $4e, $82, $57, $0e, $58, $62
  .byte $68, $62, $79, $61, $8a, $60, $8e, $0a, $f5, $31, $f9, $73, $39, $f3, $b5, $71
  .byte $b7, $31, $4d, $c8, $8a, $62, $9a, $62, $ae, $05, $bb, $0e, $cd, $4a, $fe, $82
  .byte $77, $fb, $de, $0f, $4e, $82, $6d, $47, $39, $f3, $0c, $ea, $08, $3f, $b3, $00
  .byte $cc, $63, $f9, $30, $69, $f9, $ea, $60, $f9, $61, $fe, $07, $de, $84, $e4, $62
  .byte $e9, $61, $f4, $62, $fa, $60, $04, $e2, $14, $62, $24, $62, $34, $62, $3e, $0a
  .byte $7e, $0c, $7e, $8a, $8e, $08, $94, $36, $fe, $0a, $0d, $c4, $61, $64, $71, $64
  .byte $81, $64, $cd, $43, $ce, $09, $dd, $42, $de, $0b, $fe, $02, $5d, $c7, $fd

;level A-1
L_GroundArea30:
  .byte $52, $71, $0f, $20, $6e, $70, $e3, $64, $fc, $61, $fc, $71, $13, $86, $2c, $61
  .byte $2c, $71, $43, $64, $b2, $22, $b5, $62, $c7, $28, $22, $a2, $52, $09, $56, $61
  .byte $6c, $03, $db, $71, $fc, $03, $f3, $20, $03, $a4, $0f, $71, $40, $0c, $8c, $74
  .byte $9c, $66, $d7, $01, $ec, $71, $89, $e1, $b6, $61, $b9, $2a, $c7, $26, $f4, $23
  .byte $67, $e2, $e8, $f2, $78, $82, $88, $01, $98, $02, $a8, $02, $b8, $02, $03, $a6
  .byte $07, $26, $21, $79, $4b, $71, $cf, $33, $06, $e4, $16, $2a, $39, $71, $58, $45
  .byte $5a, $45, $c6, $07, $dc, $04, $3f, $e7, $3b, $71, $8c, $71, $ac, $01, $e7, $63
  .byte $39, $8f, $63, $20, $65, $0b, $68, $62, $8c, $00, $0c, $81, $29, $63, $3c, $01
  .byte $57, $65, $6c, $01, $85, $67, $9c, $04, $1d, $c1, $5f, $26, $3d, $c7, $fd

;level A-3
L_GroundArea31:
  .byte $50, $50, $0b, $1f, $0f, $26, $19, $96, $84, $43, $b7, $1f, $5d, $cc, $6d, $48
  .byte $e0, $42, $e3, $12, $39, $9c, $56, $43, $47, $9b, $a4, $12, $c1, $06, $ed, $4d
  .byte $f4, $42, $1b, $98, $b7, $13, $02, $c2, $03, $12, $47, $1f, $ad, $48, $63, $9c
  .byte $82, $48, $76, $93, $08, $94, $8e, $11, $b0, $03, $c9, $0f, $1d, $c1, $2d, $4a
  .byte $4e, $42, $6f, $20, $0d, $0e, $0e, $40, $39, $71, $7f, $37, $f2, $68, $01, $e9
  .byte $11, $39, $68, $7a, $de, $1f, $6d, $c5, $fd

;level B-1
L_GroundArea32:
  .byte $52, $21, $0f, $20, $6e, $60, $6c, $f6, $ca, $30, $dc, $02, $08, $f2, $37, $04
  .byte $56, $74, $7c, $00, $dc, $01, $e7, $25, $47, $8b, $49, $20, $6c, $02, $96, $74
  .byte $06, $82, $36, $02, $66, $00, $a7, $22, $dc, $02, $0a, $e0, $63, $22, $78, $72
  .byte $93, $09, $97, $03, $a3, $25, $a7, $03, $b6, $24, $03, $a2, $5c, $75, $65, $71
  .byte $7c, $00, $9c, $00, $63, $a2, $67, $20, $77, $03, $87, $20, $93, $0a, $97, $03
  .byte $a3, $22, $a7, $20, $b7, $03, $bc, $00, $c7, $20, $dc, $00, $fc, $01, $19, $8f
  .byte $1e, $20, $46, $22, $4c, $61, $63, $00, $8e, $21, $d7, $73, $46, $a6, $4c, $62
  .byte $68, $62, $73, $01, $8c, $62, $d8, $62, $43, $a9, $c7, $73, $ec, $06, $57, $f3
  .byte $7c, $00, $b5, $65, $c5, $65, $dc, $00, $e3, $67, $7d, $c1, $bf, $26, $ad, $c7
  .byte $fd

;level B-3
L_GroundArea33:
  .byte $90, $10, $0b, $1b, $0f, $26, $07, $94, $bc, $14, $bf, $13, $c7, $40, $ff, $16
  .byte $d1, $80, $c3, $94, $cb, $17, $c2, $44, $29, $8f, $77, $31, $0b, $96, $76, $32
  .byte $c7, $75, $13, $f7, $1b, $61, $2b, $61, $4b, $12, $59, $0f, $3b, $b0, $3a, $40
  .byte $43, $12, $7a, $40, $7b, $30, $b5, $41, $b6, $20, $c6, $07, $f3, $13, $03, $92
  .byte $6b, $12, $79, $0f, $cc, $15, $cf, $11, $1f, $95, $c3, $14, $b3, $95, $a3, $95
  .byte $4d, $ca, $6b, $61, $7e, $11, $8d, $41, $be, $42, $df, $20, $bd, $c7, $fd

;level C-1
L_GroundArea34:
  .byte $52, $31, $0f, $20, $6e, $74, $0d, $02, $03, $33, $1f, $72, $39, $71, $65, $04
  .byte $6c, $70, $77, $01, $84, $72, $8c, $72, $b3, $34, $ec, $01, $ef, $72, $0d, $04
  .byte $ac, $67, $cc, $01, $cf, $71, $e7, $22, $17, $88, $23, $00, $27, $23, $3c, $62
  .byte $65, $71, $67, $33, $8c, $61, $dc, $01, $08, $fa, $45, $75, $63, $0a, $73, $23
  .byte $7c, $02, $8f, $72, $73, $a9, $9f, $74, $bf, $74, $ef, $73, $39, $f1, $fc, $0a
  .byte $0d, $0b, $13, $25, $4c, $01, $4f, $72, $73, $0b, $77, $03, $dc, $08, $23, $a2
  .byte $53, $09, $56, $03, $63, $24, $8c, $02, $3f, $b3, $77, $63, $96, $74, $b3, $77
  .byte $5d, $c1, $8f, $26, $7d, $c7, $fd

;level C-2
L_GroundArea35:
  .byte $54, $11, $0f, $26, $cf, $32, $f8, $62, $fe, $10, $3c, $b2, $bd, $48, $ea, $62
  .byte $fc, $4d, $fc, $4d, $17, $c9, $da, $62, $0b, $97, $b7, $12, $2c, $b1, $33, $43
  .byte $6c, $31, $ac, $41, $0b, $98, $ad, $4a, $db, $30, $27, $b0, $b7, $14, $c6, $42
  .byte $c7, $96, $d6, $44, $2b, $92, $39, $0f, $72, $41, $a7, $00, $1b, $95, $97, $13
  .byte $6c, $95, $6f, $11, $a2, $40, $bf, $15, $c2, $40, $0b, $9a, $62, $42, $63, $12
  .byte $ad, $4a, $0e, $91, $1d, $41, $4f, $26, $4d, $c7, $fd

;level C-3
L_GroundArea36:
  .byte $57, $11, $0f, $26, $fe, $10, $4b, $92, $59, $0f, $ad, $4c, $d3, $93, $0b, $94
  .byte $29, $0f, $7b, $93, $99, $0f, $0d, $06, $27, $12, $35, $0f, $23, $b1, $57, $75
  .byte $a3, $31, $ab, $71, $f7, $75, $23, $b1, $87, $13, $95, $0f, $0d, $0a, $23, $35
  .byte $38, $13, $55, $00, $9b, $16, $0b, $96, $c7, $75, $dd, $4a, $3b, $92, $49, $0f
  .byte $ad, $4c, $29, $92, $52, $40, $6c, $15, $6f, $11, $72, $40, $bf, $15, $03, $93
  .byte $0a, $13, $12, $41, $8b, $12, $99, $0f, $0d, $10, $47, $16, $46, $45, $b3, $32
  .byte $13, $b1, $57, $0e, $a7, $0e, $d3, $31, $53, $b1, $a6, $31, $03, $b2, $13, $0e
  .byte $8d, $4d, $ae, $11, $bd, $41, $ee, $52, $0f, $a0, $dd, $47, $fd

;level D-1
L_GroundArea37:
  .byte $52, $a1, $0f, $20, $6e, $65, $04, $a0, $14, $07, $24, $2d, $57, $25, $bc, $09
  .byte $4c, $80, $6f, $33, $a5, $11, $a7, $63, $b7, $63, $e7, $20, $35, $a0, $59, $11
  .byte $b4, $08, $c0, $04, $05, $82, $15, $02, $25, $02, $3a, $10, $4c, $01, $6c, $79
  .byte $95, $79, $73, $a7, $8f, $74, $f3, $0a, $03, $a0, $93, $08, $97, $73, $e3, $20
  .byte $39, $f1, $94, $07, $aa, $30, $bc, $5c, $c7, $30, $24, $f2, $27, $31, $8f, $33
  .byte $c6, $10, $c7, $63, $d7, $63, $e7, $63, $f7, $63, $03, $a5, $07, $25, $aa, $10
  .byte $03, $bf, $4f, $74, $6c, $00, $df, $74, $fc, $00, $5c, $81, $77, $73, $9d, $4c
  .byte $c5, $30, $e3, $30, $7d, $c1, $bd, $4d, $bf, $26, $ad, $c7, $fd

;level D-2
L_GroundArea38:
  .byte $55, $a1, $0f, $26, $9c, $01, $4f, $b6, $b3, $34, $c9, $3f, $13, $ba, $a3, $b3
  .byte $bf, $74, $0c, $84, $83, $3f, $9f, $74, $ef, $72, $ec, $01, $2f, $f2, $2c, $01
  .byte $6f, $72, $6c, $01, $a8, $91, $aa, $10, $03, $b7, $61, $79, $6f, $75, $39, $f1
  .byte $db, $71, $03, $a2, $17, $22, $33, $09, $43, $20, $5b, $71, $48, $8f, $4a, $30
  .byte $5c, $5c, $a3, $30, $2d, $c1, $5f, $26, $3d, $c7, $fd

;level D-3
L_GroundArea39:
  .byte $55, $a1, $0f, $26, $39, $91, $68, $12, $a7, $12, $aa, $10, $c7, $07, $e8, $12
  .byte $19, $91, $6c, $00, $78, $74, $0e, $c2, $76, $a8, $fe, $40, $29, $91, $73, $29
  .byte $77, $53, $8c, $77, $59, $91, $87, $13, $b6, $14, $ba, $10, $e8, $12, $38, $92
  .byte $19, $8f, $2c, $00, $33, $67, $4e, $42, $68, $0b, $2e, $c0, $38, $72, $a8, $11
  .byte $aa, $10, $49, $91, $6e, $42, $de, $40, $e7, $22, $0e, $c2, $4e, $c0, $6c, $00
  .byte $79, $11, $8c, $01, $a7, $13, $bc, $01, $d5, $15, $ec, $01, $03, $97, $0e, $00
  .byte $6e, $01, $9d, $41, $ce, $42, $ff, $20, $9d, $c7, $fd

;ground level area used with level D-4
L_GroundArea40:
  .byte $10, $21, $39, $f1, $09, $f1, $ad, $4c, $7c, $83, $96, $30, $5b, $f1, $c8, $05
  .byte $1f, $b7, $93, $67, $a3, $67, $b3, $67, $bd, $4d, $cc, $08, $54, $fe, $6e, $2f
  .byte $6d, $c7, $fd

;cloud level used with levels A-1, B-1 and D-2
L_GroundArea41:
  .byte $00, $c1, $4c, $00, $02, $c9, $ba, $49, $62, $c9, $a4, $20, $a5, $20, $1a, $c9
  .byte $a3, $2c, $b2, $49, $56, $c2, $6e, $00, $95, $41, $ad, $c7, $fd

;level A-2
L_UndergroundArea6:
  .byte $48, $8f, $1e, $01, $4e, $02, $00, $8c, $09, $0f, $6e, $0a, $ee, $82, $2e, $80
  .byte $30, $20, $7e, $01, $87, $27, $07, $87, $17, $23, $3e, $00, $9e, $05, $5b, $f1
  .byte $8b, $71, $bb, $71, $eb, $71, $3e, $82, $7f, $38, $fe, $0a, $3e, $84, $47, $29
  .byte $48, $2e, $af, $71, $cb, $71, $e7, $0a, $f7, $23, $2b, $f1, $37, $51, $3e, $00
  .byte $6f, $00, $8e, $04, $df, $32, $9c, $82, $ca, $12, $dc, $00, $e8, $14, $fc, $00
  .byte $fe, $08, $4e, $8a, $88, $74, $9e, $01, $a8, $52, $bf, $47, $b8, $52, $c8, $52
  .byte $d8, $52, $e8, $52, $ee, $0f, $4d, $c7, $0d, $0d, $0e, $02, $68, $7a, $be, $01
  .byte $ee, $0f, $6d, $c5, $fd

;underground bonus rooms used with worlds A-D
L_UndergroundArea7:
  .byte $08, $0f, $0e, $01, $2e, $05, $38, $20, $3e, $04, $48, $07, $55, $45, $57, $45
  .byte $58, $25, $b8, $08, $be, $05, $c8, $20, $ce, $01, $df, $4a, $6d, $c7, $0e, $81
  .byte $00, $5a, $2e, $02, $34, $42, $36, $42, $37, $22, $73, $54, $83, $0b, $87, $20
  .byte $93, $54, $90, $07, $b4, $41, $b6, $41, $b7, $21, $df, $4a, $6d, $c7, $0e, $81
  .byte $00, $5a, $14, $56, $24, $56, $2e, $0c, $33, $43, $6e, $09, $8e, $0b, $96, $48
  .byte $1e, $84, $3e, $05, $4a, $48, $47, $0b, $ce, $01, $df, $4a, $6d, $c7, $fd

;level B-2
L_WaterArea9:
  .byte $41, $01, $da, $60, $e9, $61, $f8, $62, $fe, $0b, $fe, $81, $47, $d3, $8a, $60
  .byte $99, $61, $a8, $62, $b7, $63, $c6, $64, $d5, $65, $e4, $66, $ed, $49, $f3, $67
  .byte $1a, $cb, $e3, $67, $f3, $67, $fe, $02, $31, $d6, $3c, $02, $77, $53, $ac, $02
  .byte $b1, $56, $e7, $53, $fe, $01, $77, $b9, $a3, $43, $00, $bf, $29, $51, $39, $48
  .byte $61, $55, $d2, $44, $d6, $54, $0c, $82, $2e, $02, $31, $66, $44, $47, $47, $32
  .byte $4a, $47, $97, $32, $c1, $66, $ce, $01, $dc, $02, $fe, $0e, $0c, $8f, $08, $4f
  .byte $fe, $02, $75, $e0, $fe, $01, $0c, $87, $9a, $60, $a9, $61, $b8, $62, $c7, $63
  .byte $ce, $0f, $d5, $0d, $6d, $ca, $7d, $47, $fd
.endif
;

NonMaskableInterrupt: rti
Start: rti
.ifdef ANN
practice_callgate BANK_ANNDATA
control_bank BANK_ANNDATA
.else
practice_callgate BANK_LLDATA
control_bank BANK_LLDATA
.endif