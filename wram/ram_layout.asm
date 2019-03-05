		.org $6000
		.include "text.inc"

WRAM_StartAddress:
WRAM_Magic:
	.res $04, $00

WRAM_MenuIndex:
	.byte $00
WRAM_PracticeFlags:
	.byte $00
WRAM_DelayFrames:
	.byte $00
WRAM_SaveStateBank:
	.byte $00

WRAM_ToSaveFile:
WRAM_LevelAreaPointer:
	.byte $00
WRAM_LevelAreaType:
	.byte $00
WRAM_LevelIntervalTimerControl:
	.byte $00
WRAM_LevelFrameCounter:
	.byte $00
WRAM_LevelPlayerStatus:
	.byte $00
WRAM_LevelPlayerSize:
	.byte $00
WRAM_EntrySockTimer:
	.byte $00
WRAM_LevelRandomData:
	.res $07, $00
WRAM_LevelFrameRuleData:
	.res $04, $00
WRAM_EnemyData:
	.res $80-(WRAM_EnemyData-WRAM_ToSaveFile), $00
WRAM_LevelData:
	.res $100, $00


WRAM_Temp:
	.res $64, $00

; Persistent

WRAM_OrgUser0:
	.word 0
WRAM_OrgUser1:
	.word 0
WRAM_LostUser0:
	.word 0
WRAM_LostUser1:
	.word 0

WRAM_OrgRules:
	.dword 0, 0, 0, 0 ; World 1
	.dword 0, 0, 0, 0 ; World 2
	.dword 0, 0, 0, 0 ; World 3
	.dword 0, 0, 0, 0 ; World 4
	.dword 0, 0, 0, 0 ; World 5
	.dword 0, 0, 0, 0 ; World 6
	.dword 0, 0, 0, 0 ; World 7
	.dword 0, 0, 0, 0 ; World 8

WRAM_LostRules:
	.dword 0, 0, 0, 0 ; World 1
	.dword 0, 0, 0, 0 ; World 2
	.dword 0, 0, 0, 0 ; World 3
	.dword 0, 0, 0, 0 ; World 4
	.dword 0, 0, 0, 0 ; World 5
	.dword 0, 0, 0, 0 ; World 6
	.dword 0, 0, 0, 0 ; World 7
	.dword 0, 0, 0, 0 ; World 8
	.dword 0, 0, 0, 0 ; World 9
	.dword 0, 0, 0, 0 ; World A
	.dword 0, 0, 0, 0 ; World B
	.dword 0, 0, 0, 0 ; World C
	.dword 0, 0, 0, 0 ; World D
;
; Number of stars collected
;
WRAM_LostStart:
WRAM_NumberOfStars:
		.byte $08

WRAM_LeafY:
		.byte $30
		.byte $70
		.byte $B8
		.byte $50
		.byte $98
		.byte $30
		.byte $70
		.byte $B8
		.byte $50
		.byte $98
		.byte $30
		.byte $70
WRAM_LeafX:
		.byte $30
		.byte $30
		.byte $30
		.byte $60
		.byte $60
		.byte $A0
		.byte $A0
		.byte $A0
		.byte $D0
		.byte $D0
		.byte $D0
		.byte $60

;
; Player palette colors
;
WRAM_PlayerColors:
		.byte $22, $16, $27, $18 ; Mario
		.byte $22, $37, $27, $16 ; Luigi (REMOVE ME)

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
WRAM_PatchMarioName1:
		.byte "MARIO"
		.byte $00

WRAM_LostEnd:

WRAM_SaveRAM:
		.res $800, $00

WRAM_SaveWRAM:
		.res $80, $00
WRAM_SaveLevel:
		.res $100, $00

WRAM_SaveNT:
		.res $800, $00

WRAM_SavePAL:
		.res $20, $00

