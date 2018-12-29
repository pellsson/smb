		.org $6000
		.include "text.inc"

WRAM_StartAddress:
WRAM_MenuIndex:
	.byte $00

WRAM_PracticeFlags:
	.byte $00

WRAM_Temp:
	.res $64, $00

WRAM_OrgRules:
	.word 0, 0, 0, 0 ; World 1
	.word 0, 0, 0, 0 ; World 2
	.word 0, 0, 0, 0 ; World 3
	.word 0, 0, 0, 0 ; World 4
	.word 0, 0, 0, 0 ; World 5
	.word 0, 0, 0, 0 ; World 6
	.word 0, 0, 0, 0 ; World 7
	.word 0, 0, 0, 0 ; World 8

WRAM_LostRules:
	.word 0, 0, 0, 0 ; World 1
	.word 0, 0, 0, 0 ; World 2
	.word 0, 0, 0, 0 ; World 3
	.word 0, 0, 0, 0 ; World 4
	.word 0, 0, 0, 0 ; World 5
	.word 0, 0, 0, 0 ; World 6
	.word 0, 0, 0, 0 ; World 7
	.word 0, 0, 0, 0 ; World 8
	.word 0, 0, 0, 0 ; World 9
	.word 0, 0, 0, 0 ; World A
	.word 0, 0, 0, 0 ; World B
	.word 0, 0, 0, 0 ; World C
	.word 0, 0, 0, 0 ; World D

;
; Number of stars collected
;
WRAM_NumberOfStars:
		.byte $08

;
; Player palette colors
;
WRAM_PlayerColors:
		.byte $22, $16, $27, $18 ; Mario
		.byte $22, $37, $27, $16 ; Luigi

WRAM_JumpMForceData:
		.byte $20, $20, $1E, $28, $28, $0D, $04
WRAM_FallMForceData:
		.byte $70, $70, $60, $90, $90, $0A, $09
WRAM_FrictionData:
		.byte $E4, $98, $D0

WRAM_EnemyAttributeData:
		.byte $01, $02, $03, $02
		.byte $22, $01, $03, $03
		.byte $03, $01, $01, $02
		.byte $02
WRAM_PiranhaPlantAttributeData:
		.byte $21
		.byte $01, $02, $01, $01
		.byte $02, $FF, $02, $02
		.byte $01, $01
WRAM_UnknownAttributeData0:
		.byte $02
WRAM_UnknownAttributeData1:
		.byte $02
WRAM_UnknownAttributeData2:
		.byte $02

;
; Draw buffer for title screen with mushroom
;
WRAM_MushroomSelection:
		.byte $22
		.byte $4B
		.byte $83
WRAM_SelectMario:
		.byte $CE
		.byte $24
WRAM_SelectLuigi:
		.byte $24
		.byte $00

;
; Originally patched the immediate byte of the
; cmp instruction, but that was too much of a hack, so
; now we just store it here directly
;
WRAM_PiranhaPlantDist:
		.byte $21
;
; Halway stuff
;
WRAM_HalfwayPageNybbles:
		.byte $66, $60
		.byte $88, $60
		.byte $66, $70
		.byte $77, $60
		.byte $D6, $00
		.byte $77, $80
		.byte $70, $B0
		.byte $00, $00
		.byte $00, $00

;
; Thank you mario buffer
;
WRAM_ThankYouMario:
		text_block $2548, "THANK YOU "
WRAM_PatchMarioName1:
		.byte "MARIO"
		.byte $00
;
; Game texts (only really need to copy the one that is patched)
;
WRAM_GameText:
		.byte $20, $43
		.byte $05
WRAM_PatchMarioName0:
		.byte $16, $0A, $1B, $12, $18 ; "MARIO"
		.byte $20, $52
		.byte $0B
		.byte $20, $18, $1B, $15, $0D ; "WORLD"
		.byte $24, $24				; "  "
		.byte $1D, $12, $16, $0E		; "TIME"
		.byte $20, $68
		.byte $05
		.byte $00
		.byte $24
		.byte $24
		.byte $2E
		.byte $29
		.byte $23
		.byte $C0
		.byte $7F
		.byte $AA
		.byte $23
		.byte $C2
		.byte 1
		.byte $EA
		.byte $FF
		;
		; Display lifes left and mario screen
		;
		.byte $21
		.byte $CD
		.byte 7
		.byte $24
		.byte $24
		.byte $29
		.byte $24
		.byte $24
		.byte $24
		.byte $24
		.byte $21
		.byte $4B
		.byte 9
		.byte $20
		.byte $18
		.byte $1B
		.byte $15
		.byte $D
		.byte $24
		.byte $24
		.byte $28
		.byte $24
		.byte $22
		.byte $C
		.byte $47
		.byte $24
		.byte $23
		.byte $DC
		.byte 1
		.byte $BA
		.byte $FF
		.byte $22
		.byte $C
		.byte 7
		.byte $1D
		.byte $12
		.byte $16
		.byte $E
		.byte $24
		.byte $1E
		.byte $19
		.byte $FF
		.byte $21
		.byte $6B
		.byte 9
		.byte $10
		.byte $A
		.byte $16
		.byte $E
		.byte $24
		.byte $18
		.byte $1F
		.byte $E
		.byte $1B
		.byte $21
		.byte $EB
		.byte 8
		.byte $C
		.byte $18
		.byte $17
		.byte $1D
		.byte $12
		.byte $17
		.byte $1E
		.byte $E
		.byte $22
		.byte $C
		.byte $47
		.byte $24
		.byte $22
		.byte $4B
		.byte 5
		.byte $1B
		.byte $E
		.byte $1D
		.byte $1B
		.byte $22
		.byte $FF
