
	.include "org.inc"
	.include "mario.inc"
	.include "shared.inc"
	.include "macros.inc"
	.segment "bank6"
	.org $8000

scen_1_2G_HI_load_area:
		lda #$08
		sta ScreenEdge_PageLoc
		lda #$09
		sta Player_PageLoc
		lda #$00
		sta WorldNumber
		lda #$02
		sta AreaNumber
		lda #$01
		sta LevelNumber
		lda #$D7
		sta FpgScrollTo
		rts
scen_1_2G_HI_Player_CollisionBits:
	.byte $FF, $00, $00, $00, $00, $00, $00
scen_1_2G_HI_Player_X_Speed:
	.byte $28, $F8, $F8, $F8, $F8, $08, $00
scen_1_2G_HI_Player_State:
	.byte $00, $00, $00, $00, $00, $04, $00
scen_1_2G_HI_Player_Rel_XPos:
	.byte $70, $37, $00, $00, $4F, $BF, $00
scen_1_2G_HI_Player_MovingDir:
	.byte $01, $02, $02, $02, $02, $01, $00
scen_1_2G_HI_PseudoRandomBitReg:
	.byte $A7, $98, $D7, $E6, $49, $85, $16
scen_1_2G_HI_YPlatformTopYPos:
	.byte $00, $80, $80, $80, $80, $00, $00
scen_1_2G_HI_SprObject_X_MoveForce:
	.byte $C0, $00, $80, $80, $80, $80, $00
scen_1_2G_HI_Player_X_Position:
	.byte $48, $AC, $AC, $BC, $BC, $0F, $E0
scen_1_2G_HI_Player_OffscreenBits:
	.byte $00, $00, $00, $00, $00, $00, $00
scen_1_2G_HI_Enemy_ID:
	.byte $26, $26, $27, $27, $03, $00, $00
scen_1_2G_HI_Player_Y_Position:
	.byte $60, $F2, $7A, $F1, $50, $B8, $E0
scen_1_2G_HI_Enemy_Flag:
	.byte $01, $01, $01, $01, $01, $00, $00
scen_1_2G_HI_EnemyOffscrBitsMasked:
	.byte $04, $04, $04, $04, $00, $00, $00
scen_1_2G_HI_Player_YMF_Dummy:
	.byte $78, $4C, $01, $51, $70, $78, $00
scen_1_2G_HI_YPlatformCenterYPos:
	.byte $F8, $F8, $F8, $F8, $08, $00, $00
scen_1_2G_HI_Player_Rel_YPos:
	.byte $B0, $B8, $00, $00, $90, $00, $00
scen_1_2G_HI_Player_Y_HighPos:
	.byte $01, $01, $01, $01, $01, $01, $01
scen_1_2G_HI_Player_Y_Speed:
	.byte $00, $FF, $FF, $00, $00, $00, $00
scen_1_2G_HI_Player_SprAttrib:
	.byte $00, $00, $00, $00, $00, $00, $00
scen_1_2G_HI_Player_Y_MoveForce:
	.byte $00, $10, $10, $F0, $F0, $00, $00
scen_1_2G_HI_PlatformCollisionFlag:
	.byte $FF, $FF, $FF, $FF, $00, $00, $00
scen_1_2G_HI_Player_BoundBoxCtrl:
	.byte $01, $06, $06, $06, $06, $03, $00
scen_1_2G_HI_SprObject_PageLoc:
	.byte $09, $09, $09, $08, $08, $09, $09
scen_1_2G_HI_Timers:
	.byte $00, $01, $00, $05, $00, $00, $00, $13, $00, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
scen_1_2G_HI_BoundingBox_UL_XPos:
	.byte $73, $C4, $7D, $D0, $D4, $F3, $FF, $00, $D4, $7A, $FF, $87, $00, $F0, $14, $FD, $00, $4F, $14, $5C, $39, $C1, $45, $CD, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

scen_1_2G_HI_reset:
		lda $2
		clc
		adc #$68
		sta EnemyDataLow
		lda $3
		adc #$03
		sta EnemyDataHigh
		ldx #$06
scen_1_2G_HI_init_len7_0:
		lda scen_1_2G_HI_Player_CollisionBits, x
		sta Player_CollisionBits, x
		lda scen_1_2G_HI_Player_X_Speed, x
		sta Player_X_Speed, x
		lda scen_1_2G_HI_Player_State, x
		sta Player_State, x
		lda scen_1_2G_HI_Player_Rel_XPos, x
		sta Player_Rel_XPos, x
		lda scen_1_2G_HI_Player_MovingDir, x
		sta Player_MovingDir, x
		lda scen_1_2G_HI_PseudoRandomBitReg, x
		sta PseudoRandomBitReg, x
		lda scen_1_2G_HI_YPlatformTopYPos, x
		sta YPlatformTopYPos, x
		lda scen_1_2G_HI_SprObject_X_MoveForce, x
		sta SprObject_X_MoveForce, x
		lda scen_1_2G_HI_Player_X_Position, x
		sta Player_X_Position, x
		lda scen_1_2G_HI_Player_OffscreenBits, x
		sta Player_OffscreenBits, x
		lda scen_1_2G_HI_Enemy_ID, x
		sta Enemy_ID, x
		lda scen_1_2G_HI_Player_Y_Position, x
		sta Player_Y_Position, x
		lda scen_1_2G_HI_Enemy_Flag, x
		sta Enemy_Flag, x
		lda scen_1_2G_HI_EnemyOffscrBitsMasked, x
		sta EnemyOffscrBitsMasked, x
		lda scen_1_2G_HI_Player_YMF_Dummy, x
		sta Player_YMF_Dummy, x
		lda scen_1_2G_HI_YPlatformCenterYPos, x
		sta YPlatformCenterYPos, x
		lda scen_1_2G_HI_Player_Rel_YPos, x
		sta Player_Rel_YPos, x
		lda scen_1_2G_HI_Player_Y_HighPos, x
		sta Player_Y_HighPos, x
		lda scen_1_2G_HI_Player_Y_Speed, x
		sta Player_Y_Speed, x
		lda scen_1_2G_HI_Player_SprAttrib, x
		sta Player_SprAttrib, x
		dex
		bpl scen_1_2G_HI_init_len7_0
		ldx #$06
scen_1_2G_HI_init_len7_1:
		lda scen_1_2G_HI_Player_Y_MoveForce, x
		sta Player_Y_MoveForce, x
		lda scen_1_2G_HI_PlatformCollisionFlag, x
		sta PlatformCollisionFlag, x
		lda scen_1_2G_HI_Player_BoundBoxCtrl, x
		sta Player_BoundBoxCtrl, x
		lda scen_1_2G_HI_SprObject_PageLoc, x
		sta SprObject_PageLoc, x
		dex
		bpl scen_1_2G_HI_init_len7_1
		ldx #$14
scen_1_2G_HI_init_len21_0:
		lda scen_1_2G_HI_Timers, x
		sta Timers, x
		dex
		bpl scen_1_2G_HI_init_len21_0
		ldx #$53
scen_1_2G_HI_init_len84_0:
		lda scen_1_2G_HI_BoundingBox_UL_XPos, x
		sta BoundingBox_UL_XPos, x
		dex
		bpl scen_1_2G_HI_init_len84_0
		lda #$00
		sta EnemyObjectPageSel
		lda #$D7
		sta ScreenRight_X_Pos
		lda #$05
		sta IntervalTimerControl
		lda #$00
		sta EnemyFrenzyBuffer
		lda #$90
		sta VerticalForceDown
		lda #$40
		sta Player_X_MoveForce
		lda #$00
		sta FrictionAdderHigh
		lda #$D8
		sta MaximumLeftSpeed
		lda #$00
		sta PlayerStatus
		lda #$D8
		sta HorizontalScroll
		lda #$02
		sta Player_X_Scroll
		lda #$00
		sta PlayerChangeSizeFlag
		lda #$01
		sta JumpOrigin_Y_HighPos
		lda #$00
		sta CrouchingFlag
		lda #$70
		sta Player_Pos_ForScroll
		lda #$01
		sta PlayerFacingDir
		lda #$EE
		sta FrameCounter
		lda #$02
		sta ScrollAmount
		lda #$90
		sta VerticalForce
		lda #$A4
		sta JumpOrigin_Y_Position
		lda #$E4
		sta FrictionAdderLow
		lda #$00
		sta TimerControl
		lda #$FF
		sta BalPlatformAlignment
		lda #$00
		sta ScrollFractional
		lda #$00
		sta VerticalScroll
		lda #$09
		sta EnemyObjectPageLoc
		lda #$00
		sta ScrollLock
		lda #$18
		sta ScrollThirtyTwo
		lda #$01
		sta PlayerSize
		lda #$09
		sta ScreenRight_PageLoc
		lda #$D8
		sta ScreenLeft_X_Pos
		lda #$28
		sta Player_XSpeedAbsolute
		lda #$2A
		sta EnemyDataOffset
		lda #$01
		sta PlayerAnimCtrl
		lda #$02
		sta PlayerAnimTimerSet
		lda #$00
		sta SwimmingFlag
		lda #$28
		sta RunningSpeed
		lda #$00
		sta Platform_X_Scroll
		lda #$28
		sta MaximumRightSpeed
		lda #$00
		sta EnemyFrenzyQueue
		lda #$01
		sta DiffToHaltJump
		rts
scen_1_2G_HI_ruleset0:
		ldy FrameCounter
		lda SavedJoypadBits
		and #$C3
scen_1_2G_HI_ruleset0_rule0:
		cpy #$23
		bne scen_1_2G_HI_ruleset0_rule1
		ldx Player_X_Position
		cpx #$CA
		beq scen_1_2G_HI_ruleset0_rule0_y
		jmp fpg_failed_pos_x
scen_1_2G_HI_ruleset0_rule0_y:
		ldx Player_Y_Position
		cpx #$A1
		beq scen_1_2G_HI_ruleset0_rule1
		jmp fpg_failed_pos_y
scen_1_2G_HI_ruleset0_rule1:
		cpy #$23
		bmi scen_1_2G_HI_ruleset0_rule33
		cpy #$43
		bpl scen_1_2G_HI_ruleset0_rule33
		cmp #$C1
		beq scen_1_2G_HI_ruleset0_rule33
		lda #$C1
		jmp fpg_failed_input
scen_1_2G_HI_ruleset0_rule33:
		cpy #$54
		bne scen_1_2G_HI_ruleset0_rule34
		cmp #$01
		beq scen_1_2G_HI_ruleset0_rule34
		lda #$01
		jmp fpg_failed_input
scen_1_2G_HI_ruleset0_rule34:
		cpy #$54
		bne scen_1_2G_HI_ruleset0_rule35
		ldx Player_X_Position
		cpx #$45
		beq scen_1_2G_HI_ruleset0_rule34_y
		jmp fpg_failed_pos_x
scen_1_2G_HI_ruleset0_rule34_y:
		ldx Player_Y_Position
		cpx #$80
		beq scen_1_2G_HI_ruleset0_rule35
		jmp fpg_failed_pos_y
scen_1_2G_HI_ruleset0_rule35:
		cpy #$55
		bne scen_1_2G_HI_ruleset0_rule36
		and #$FE
		cmp #$80
		beq scen_1_2G_HI_ruleset0_rule36_restore_input
		lda #$80
		jmp fpg_failed_input
scen_1_2G_HI_ruleset0_rule36_restore_input:
		lda SavedJoypadBits
scen_1_2G_HI_ruleset0_rule36:
		cpy #$56
		bmi scen_1_2G_HI_ruleset0_rule44
		cpy #$5E
		bpl scen_1_2G_HI_ruleset0_rule44
		and #$FE
		cmp #$00
		beq scen_1_2G_HI_ruleset0_rule44_restore_input
		lda #$00
		jmp fpg_failed_input
scen_1_2G_HI_ruleset0_rule44_restore_input:
		lda SavedJoypadBits
scen_1_2G_HI_ruleset0_rule44:
		cpy #$5E
		bmi scen_1_2G_HI_ruleset0_rule49
		cpy #$63
		bpl scen_1_2G_HI_ruleset0_rule49
		cmp #$02
		beq scen_1_2G_HI_ruleset0_rule49
		lda #$02
		jmp fpg_failed_input
scen_1_2G_HI_ruleset0_rule49:
		cpy #$86
		bne scen_1_2G_HI_ruleset0_rule50
		ldx Player_Y_Position
		cpx #$70
		beq scen_1_2G_HI_ruleset0_rule50
		jmp fpg_failed_pos_y
scen_1_2G_HI_ruleset0_rule50:
		cpy #$86
		bne scen_1_2G_HI_ruleset0_rule51
		ldx Player_X_Position
		cpx #$69
		bpl scen_1_2G_HI_ruleset0_rule51
		jmp fpg_failed_pos_x
scen_1_2G_HI_ruleset0_rule51:
		cpy #$87
		bne scen_1_2G_HI_ruleset0_rule52
		jmp fpg_win
scen_1_2G_HI_ruleset0_rule52:
		rts
scen_1_2G_HI_rulesets:
	.word scen_1_2G_HI_ruleset0
scen_1_2G_HI_validate:
		lda FpgRuleset
		asl
		tay
		lda scen_1_2G_HI_rulesets, y
		sta $0
		lda scen_1_2G_HI_rulesets+1, y
		sta $1
		jmp ($0)
	
scen_1_2G_LO_load_area:
		lda #$08
		sta ScreenEdge_PageLoc
		lda #$09
		sta Player_PageLoc
		lda #$00
		sta WorldNumber
		lda #$02
		sta AreaNumber
		lda #$01
		sta LevelNumber
		lda #$D7
		sta FpgScrollTo
		rts
scen_1_2G_LO_Player_CollisionBits:
	.byte $FF, $00, $00, $00, $00, $00, $00
scen_1_2G_LO_Player_X_Speed:
	.byte $28, $F8, $F8, $F8, $F8, $08, $00
scen_1_2G_LO_Player_State:
	.byte $00, $00, $00, $00, $00, $04, $00
scen_1_2G_LO_Player_Rel_XPos:
	.byte $70, $37, $00, $00, $4F, $BF, $00
scen_1_2G_LO_Player_MovingDir:
	.byte $01, $02, $02, $02, $02, $01, $00
scen_1_2G_LO_PseudoRandomBitReg:
	.byte $A7, $98, $D7, $E6, $49, $85, $16
scen_1_2G_LO_YPlatformTopYPos:
	.byte $00, $80, $80, $80, $80, $00, $00
scen_1_2G_LO_SprObject_X_MoveForce:
	.byte $C0, $00, $80, $80, $80, $80, $00
scen_1_2G_LO_Player_X_Position:
	.byte $48, $AC, $AC, $BC, $BC, $0F, $E0
scen_1_2G_LO_Player_OffscreenBits:
	.byte $00, $00, $00, $00, $00, $00, $00
scen_1_2G_LO_Enemy_ID:
	.byte $26, $26, $27, $27, $03, $00, $00
scen_1_2G_LO_Player_Y_Position:
	.byte $B0, $F2, $7A, $F1, $50, $B8, $E0
scen_1_2G_LO_Enemy_Flag:
	.byte $01, $01, $01, $01, $01, $00, $00
scen_1_2G_LO_EnemyOffscrBitsMasked:
	.byte $04, $04, $04, $04, $00, $00, $00
scen_1_2G_LO_Player_YMF_Dummy:
	.byte $78, $4C, $01, $51, $70, $78, $00
scen_1_2G_LO_YPlatformCenterYPos:
	.byte $F8, $F8, $F8, $F8, $08, $00, $00
scen_1_2G_LO_Player_Rel_YPos:
	.byte $B0, $B8, $00, $00, $90, $00, $00
scen_1_2G_LO_Player_Y_HighPos:
	.byte $01, $01, $01, $01, $01, $01, $01
scen_1_2G_LO_Player_Y_Speed:
	.byte $00, $FF, $FF, $00, $00, $00, $00
scen_1_2G_LO_Player_SprAttrib:
	.byte $00, $00, $00, $00, $00, $00, $00
scen_1_2G_LO_Player_Y_MoveForce:
	.byte $00, $10, $10, $F0, $F0, $00, $00
scen_1_2G_LO_PlatformCollisionFlag:
	.byte $FF, $FF, $FF, $FF, $00, $00, $00
scen_1_2G_LO_Player_BoundBoxCtrl:
	.byte $01, $06, $06, $06, $06, $03, $00
scen_1_2G_LO_SprObject_PageLoc:
	.byte $09, $09, $09, $08, $08, $09, $09
scen_1_2G_LO_Timers:
	.byte $00, $01, $00, $05, $00, $00, $00, $13, $00, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
scen_1_2G_LO_BoundingBox_UL_XPos:
	.byte $73, $C4, $7D, $D0, $D4, $F3, $FF, $00, $D4, $7A, $FF, $87, $00, $F0, $14, $FD, $00, $4F, $14, $5C, $39, $C1, $45, $CD, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

scen_1_2G_LO_reset:
		lda $2
		clc
		adc #$68
		sta EnemyDataLow
		lda $3
		adc #$03
		sta EnemyDataHigh
		ldx #$06
scen_1_2G_LO_init_len7_0:
		lda scen_1_2G_LO_Player_CollisionBits, x
		sta Player_CollisionBits, x
		lda scen_1_2G_LO_Player_X_Speed, x
		sta Player_X_Speed, x
		lda scen_1_2G_LO_Player_State, x
		sta Player_State, x
		lda scen_1_2G_LO_Player_Rel_XPos, x
		sta Player_Rel_XPos, x
		lda scen_1_2G_LO_Player_MovingDir, x
		sta Player_MovingDir, x
		lda scen_1_2G_LO_PseudoRandomBitReg, x
		sta PseudoRandomBitReg, x
		lda scen_1_2G_LO_YPlatformTopYPos, x
		sta YPlatformTopYPos, x
		lda scen_1_2G_LO_SprObject_X_MoveForce, x
		sta SprObject_X_MoveForce, x
		lda scen_1_2G_LO_Player_X_Position, x
		sta Player_X_Position, x
		lda scen_1_2G_LO_Player_OffscreenBits, x
		sta Player_OffscreenBits, x
		lda scen_1_2G_LO_Enemy_ID, x
		sta Enemy_ID, x
		lda scen_1_2G_LO_Player_Y_Position, x
		sta Player_Y_Position, x
		lda scen_1_2G_LO_Enemy_Flag, x
		sta Enemy_Flag, x
		lda scen_1_2G_LO_EnemyOffscrBitsMasked, x
		sta EnemyOffscrBitsMasked, x
		lda scen_1_2G_LO_Player_YMF_Dummy, x
		sta Player_YMF_Dummy, x
		lda scen_1_2G_LO_YPlatformCenterYPos, x
		sta YPlatformCenterYPos, x
		lda scen_1_2G_LO_Player_Rel_YPos, x
		sta Player_Rel_YPos, x
		lda scen_1_2G_LO_Player_Y_HighPos, x
		sta Player_Y_HighPos, x
		lda scen_1_2G_LO_Player_Y_Speed, x
		sta Player_Y_Speed, x
		lda scen_1_2G_LO_Player_SprAttrib, x
		sta Player_SprAttrib, x
		dex
		bpl scen_1_2G_LO_init_len7_0
		ldx #$06
scen_1_2G_LO_init_len7_1:
		lda scen_1_2G_LO_Player_Y_MoveForce, x
		sta Player_Y_MoveForce, x
		lda scen_1_2G_LO_PlatformCollisionFlag, x
		sta PlatformCollisionFlag, x
		lda scen_1_2G_LO_Player_BoundBoxCtrl, x
		sta Player_BoundBoxCtrl, x
		lda scen_1_2G_LO_SprObject_PageLoc, x
		sta SprObject_PageLoc, x
		dex
		bpl scen_1_2G_LO_init_len7_1
		ldx #$14
scen_1_2G_LO_init_len21_0:
		lda scen_1_2G_LO_Timers, x
		sta Timers, x
		dex
		bpl scen_1_2G_LO_init_len21_0
		ldx #$53
scen_1_2G_LO_init_len84_0:
		lda scen_1_2G_LO_BoundingBox_UL_XPos, x
		sta BoundingBox_UL_XPos, x
		dex
		bpl scen_1_2G_LO_init_len84_0
		lda #$00
		sta EnemyObjectPageSel
		lda #$D7
		sta ScreenRight_X_Pos
		lda #$05
		sta IntervalTimerControl
		lda #$00
		sta EnemyFrenzyBuffer
		lda #$90
		sta VerticalForceDown
		lda #$40
		sta Player_X_MoveForce
		lda #$00
		sta FrictionAdderHigh
		lda #$D8
		sta MaximumLeftSpeed
		lda #$00
		sta PlayerStatus
		lda #$D8
		sta HorizontalScroll
		lda #$02
		sta Player_X_Scroll
		lda #$00
		sta PlayerChangeSizeFlag
		lda #$01
		sta JumpOrigin_Y_HighPos
		lda #$00
		sta CrouchingFlag
		lda #$70
		sta Player_Pos_ForScroll
		lda #$01
		sta PlayerFacingDir
		lda #$EE
		sta FrameCounter
		lda #$02
		sta ScrollAmount
		lda #$90
		sta VerticalForce
		lda #$A4
		sta JumpOrigin_Y_Position
		lda #$E4
		sta FrictionAdderLow
		lda #$00
		sta TimerControl
		lda #$FF
		sta BalPlatformAlignment
		lda #$00
		sta ScrollFractional
		lda #$00
		sta VerticalScroll
		lda #$09
		sta EnemyObjectPageLoc
		lda #$00
		sta ScrollLock
		lda #$18
		sta ScrollThirtyTwo
		lda #$01
		sta PlayerSize
		lda #$09
		sta ScreenRight_PageLoc
		lda #$D8
		sta ScreenLeft_X_Pos
		lda #$28
		sta Player_XSpeedAbsolute
		lda #$2A
		sta EnemyDataOffset
		lda #$01
		sta PlayerAnimCtrl
		lda #$02
		sta PlayerAnimTimerSet
		lda #$00
		sta SwimmingFlag
		lda #$28
		sta RunningSpeed
		lda #$00
		sta Platform_X_Scroll
		lda #$28
		sta MaximumRightSpeed
		lda #$00
		sta EnemyFrenzyQueue
		lda #$01
		sta DiffToHaltJump
		rts
scen_1_2G_LO_ruleset0:
		ldy FrameCounter
		lda SavedJoypadBits
		and #$C3
scen_1_2G_LO_ruleset0_rule0:
		cpy #$23
		bne scen_1_2G_LO_ruleset0_rule1
		ldx Player_X_Position
		cpx #$CA
		beq scen_1_2G_LO_ruleset0_rule0_y
		jmp fpg_failed_pos_x
scen_1_2G_LO_ruleset0_rule0_y:
		ldx Player_Y_Position
		cpx #$A1
		beq scen_1_2G_LO_ruleset0_rule1
		jmp fpg_failed_pos_y
scen_1_2G_LO_ruleset0_rule1:
		cpy #$23
		bmi scen_1_2G_LO_ruleset0_rule33
		cpy #$43
		bpl scen_1_2G_LO_ruleset0_rule33
		cmp #$C1
		beq scen_1_2G_LO_ruleset0_rule33
		lda #$C1
		jmp fpg_failed_input
scen_1_2G_LO_ruleset0_rule33:
		cpy #$54
		bne scen_1_2G_LO_ruleset0_rule34
		cmp #$01
		beq scen_1_2G_LO_ruleset0_rule34
		lda #$01
		jmp fpg_failed_input
scen_1_2G_LO_ruleset0_rule34:
		cpy #$54
		bne scen_1_2G_LO_ruleset0_rule35
		ldx Player_X_Position
		cpx #$45
		beq scen_1_2G_LO_ruleset0_rule34_y
		jmp fpg_failed_pos_x
scen_1_2G_LO_ruleset0_rule34_y:
		ldx Player_Y_Position
		cpx #$80
		beq scen_1_2G_LO_ruleset0_rule35
		jmp fpg_failed_pos_y
scen_1_2G_LO_ruleset0_rule35:
		cpy #$55
		bne scen_1_2G_LO_ruleset0_rule36
		and #$FE
		cmp #$80
		beq scen_1_2G_LO_ruleset0_rule36_restore_input
		lda #$80
		jmp fpg_failed_input
scen_1_2G_LO_ruleset0_rule36_restore_input:
		lda SavedJoypadBits
scen_1_2G_LO_ruleset0_rule36:
		cpy #$56
		bmi scen_1_2G_LO_ruleset0_rule44
		cpy #$5E
		bpl scen_1_2G_LO_ruleset0_rule44
		and #$FE
		cmp #$00
		beq scen_1_2G_LO_ruleset0_rule44_restore_input
		lda #$00
		jmp fpg_failed_input
scen_1_2G_LO_ruleset0_rule44_restore_input:
		lda SavedJoypadBits
scen_1_2G_LO_ruleset0_rule44:
		cpy #$5E
		bmi scen_1_2G_LO_ruleset0_rule49
		cpy #$63
		bpl scen_1_2G_LO_ruleset0_rule49
		cmp #$02
		beq scen_1_2G_LO_ruleset0_rule49
		lda #$02
		jmp fpg_failed_input
scen_1_2G_LO_ruleset0_rule49:
		cpy #$86
		bne scen_1_2G_LO_ruleset0_rule50
		ldx Player_Y_Position
		cpx #$70
		beq scen_1_2G_LO_ruleset0_rule50
		jmp fpg_failed_pos_y
scen_1_2G_LO_ruleset0_rule50:
		cpy #$86
		bne scen_1_2G_LO_ruleset0_rule51
		ldx Player_X_Position
		cpx #$69
		bpl scen_1_2G_LO_ruleset0_rule51
		jmp fpg_failed_pos_x
scen_1_2G_LO_ruleset0_rule51:
		cpy #$87
		bne scen_1_2G_LO_ruleset0_rule52
		jmp fpg_win
scen_1_2G_LO_ruleset0_rule52:
		rts
scen_1_2G_LO_rulesets:
	.word scen_1_2G_LO_ruleset0
scen_1_2G_LO_validate:
		lda FpgRuleset
		asl
		tay
		lda scen_1_2G_LO_rulesets, y
		sta $0
		lda scen_1_2G_LO_rulesets+1, y
		sta $1
		jmp ($0)
	
scen_1_1_D70_load_area:
		lda #$0A
		sta ScreenEdge_PageLoc
		lda #$0A
		sta Player_PageLoc
		lda #$00
		sta WorldNumber
		lda #$00
		sta AreaNumber
		lda #$00
		sta LevelNumber
		lda #$48
		sta FpgScrollTo
		rts
scen_1_1_D70_Player_CollisionBits:
	.byte $FF, $00, $00, $00, $00, $00, $00
scen_1_1_D70_Player_X_Speed:
	.byte $28, $F8, $F8, $00, $00, $00, $00
scen_1_1_D70_Player_State:
	.byte $01, $00, $00, $00, $00, $00, $00
scen_1_1_D70_Player_Rel_XPos:
	.byte $70, $7A, $00, $00, $67, $B7, $00
scen_1_1_D70_Player_MovingDir:
	.byte $01, $02, $02, $00, $00, $00, $00
scen_1_1_D70_PseudoRandomBitReg:
	.byte $21, $15, $57, $7D, $D3, $28, $8E
scen_1_1_D70_YPlatformTopYPos:
	.byte $00, $00, $00, $00, $00, $00, $00
scen_1_1_D70_SprObject_X_MoveForce:
	.byte $90, $00, $00, $00, $00, $00, $00
scen_1_1_D70_Player_X_Position:
	.byte $B9, $AB, $C3, $B0, $50, $F0, $00
scen_1_1_D70_Player_OffscreenBits:
	.byte $00, $00, $00, $00, $00, $00, $00
scen_1_1_D70_Enemy_ID:
	.byte $06, $06, $00, $00, $00, $00, $00
scen_1_1_D70_Player_Y_Position:
	.byte $95, $B8, $B8, $00, $00, $00, $00
scen_1_1_D70_Enemy_Flag:
	.byte $01, $01, $00, $00, $00, $00, $00
scen_1_1_D70_EnemyOffscrBitsMasked:
	.byte $00, $00, $00, $00, $00, $00, $00
scen_1_1_D70_Player_YMF_Dummy:
	.byte $38, $00, $00, $00, $00, $00, $00
scen_1_1_D70_YPlatformCenterYPos:
	.byte $F8, $F8, $00, $00, $00, $00, $00
scen_1_1_D70_Player_Rel_YPos:
	.byte $95, $B8, $00, $00, $88, $00, $00
scen_1_1_D70_Player_Y_HighPos:
	.byte $01, $01, $01, $00, $00, $00, $00
scen_1_1_D70_Player_Y_Speed:
	.byte $03, $00, $00, $00, $00, $00, $00
scen_1_1_D70_Player_SprAttrib:
	.byte $00, $00, $00, $00, $00, $00, $00
scen_1_1_D70_Player_Y_MoveForce:
	.byte $38, $00, $00, $00, $00, $00, $00
scen_1_1_D70_PlatformCollisionFlag:
	.byte $00, $00, $00, $00, $00, $00, $00
scen_1_1_D70_Player_BoundBoxCtrl:
	.byte $01, $09, $09, $00, $00, $00, $00
scen_1_1_D70_SprObject_PageLoc:
	.byte $0A, $0A, $0A, $06, $07, $07, $00
scen_1_1_D70_BoundingBox_UL_XPos:
	.byte $73, $A9, $7D, $B5, $65, $C6, $6F, $CC, $7D, $C6, $87, $CC, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
scen_1_1_D70_Timers:
	.byte $00, $00, $12, $00, $0B, $00, $00, $16, $00, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

scen_1_1_D70_reset:
		lda $2
		clc
		adc #$91
		sta EnemyDataLow
		lda $3
		adc #$01
		sta EnemyDataHigh
		ldx #$06
scen_1_1_D70_init_len7_0:
		lda scen_1_1_D70_Player_CollisionBits, x
		sta Player_CollisionBits, x
		lda scen_1_1_D70_Player_X_Speed, x
		sta Player_X_Speed, x
		lda scen_1_1_D70_Player_State, x
		sta Player_State, x
		lda scen_1_1_D70_Player_Rel_XPos, x
		sta Player_Rel_XPos, x
		lda scen_1_1_D70_Player_MovingDir, x
		sta Player_MovingDir, x
		lda scen_1_1_D70_PseudoRandomBitReg, x
		sta PseudoRandomBitReg, x
		lda scen_1_1_D70_YPlatformTopYPos, x
		sta YPlatformTopYPos, x
		lda scen_1_1_D70_SprObject_X_MoveForce, x
		sta SprObject_X_MoveForce, x
		lda scen_1_1_D70_Player_X_Position, x
		sta Player_X_Position, x
		lda scen_1_1_D70_Player_OffscreenBits, x
		sta Player_OffscreenBits, x
		lda scen_1_1_D70_Enemy_ID, x
		sta Enemy_ID, x
		lda scen_1_1_D70_Player_Y_Position, x
		sta Player_Y_Position, x
		lda scen_1_1_D70_Enemy_Flag, x
		sta Enemy_Flag, x
		lda scen_1_1_D70_EnemyOffscrBitsMasked, x
		sta EnemyOffscrBitsMasked, x
		lda scen_1_1_D70_Player_YMF_Dummy, x
		sta Player_YMF_Dummy, x
		lda scen_1_1_D70_YPlatformCenterYPos, x
		sta YPlatformCenterYPos, x
		lda scen_1_1_D70_Player_Rel_YPos, x
		sta Player_Rel_YPos, x
		lda scen_1_1_D70_Player_Y_HighPos, x
		sta Player_Y_HighPos, x
		lda scen_1_1_D70_Player_Y_Speed, x
		sta Player_Y_Speed, x
		lda scen_1_1_D70_Player_SprAttrib, x
		sta Player_SprAttrib, x
		dex
		bpl scen_1_1_D70_init_len7_0
		ldx #$06
scen_1_1_D70_init_len7_1:
		lda scen_1_1_D70_Player_Y_MoveForce, x
		sta Player_Y_MoveForce, x
		lda scen_1_1_D70_PlatformCollisionFlag, x
		sta PlatformCollisionFlag, x
		lda scen_1_1_D70_Player_BoundBoxCtrl, x
		sta Player_BoundBoxCtrl, x
		lda scen_1_1_D70_SprObject_PageLoc, x
		sta SprObject_PageLoc, x
		dex
		bpl scen_1_1_D70_init_len7_1
		ldx #$53
scen_1_1_D70_init_len84_0:
		lda scen_1_1_D70_BoundingBox_UL_XPos, x
		sta BoundingBox_UL_XPos, x
		dex
		bpl scen_1_1_D70_init_len84_0
		ldx #$14
scen_1_1_D70_init_len21_0:
		lda scen_1_1_D70_Timers, x
		sta Timers, x
		dex
		bpl scen_1_1_D70_init_len21_0
		lda #$00
		sta EnemyObjectPageSel
		lda #$48
		sta ScreenRight_X_Pos
		lda #$10
		sta IntervalTimerControl
		lda #$00
		sta EnemyFrenzyBuffer
		lda #$90
		sta VerticalForceDown
		lda #$34
		sta Player_X_MoveForce
		lda #$00
		sta FrictionAdderHigh
		lda #$D8
		sta MaximumLeftSpeed
		lda #$00
		sta PlayerStatus
		lda #$49
		sta HorizontalScroll
		lda #$02
		sta Player_X_Scroll
		lda #$01
		sta JumpOrigin_Y_HighPos
		lda #$00
		sta CrouchingFlag
		lda #$70
		sta Player_Pos_ForScroll
		lda #$01
		sta PlayerFacingDir
		lda #$C2
		sta FrameCounter
		lda #$02
		sta ScrollAmount
		lda #$90
		sta VerticalForce
		lda #$B0
		sta JumpOrigin_Y_Position
		lda #$00
		sta TimerControl
		lda #$E4
		sta FrictionAdderLow
		lda #$FF
		sta BalPlatformAlignment
		lda #$00
		sta ScrollFractional
		lda #$09
		sta ScrollThirtyTwo
		lda #$00
		sta VerticalScroll
		lda #$0B
		sta EnemyObjectPageLoc
		lda #$00
		sta ScrollLock
		lda #$1D
		sta EnemyDataOffset
		lda #$0B
		sta ScreenRight_PageLoc
		lda #$01
		sta PlayerSize
		lda #$49
		sta ScreenLeft_X_Pos
		lda #$28
		sta Player_XSpeedAbsolute
		lda #$00
		sta PlayerAnimCtrl
		lda #$02
		sta PlayerAnimTimerSet
		lda #$00
		sta PlayerChangeSizeFlag
		lda #$00
		sta SwimmingFlag
		lda #$28
		sta RunningSpeed
		lda #$00
		sta Platform_X_Scroll
		lda #$28
		sta MaximumRightSpeed
		lda #$00
		sta EnemyFrenzyQueue
		lda #$01
		sta DiffToHaltJump
		rts
scen_1_1_D70_ruleset0:
		ldy FrameCounter
		lda SavedJoypadBits
		and #$C3
scen_1_1_D70_ruleset0_rule0:
		cpy #$1B
		bne scen_1_1_D70_ruleset0_rule1
		ldx Player_X_Position
		cpx #$95
		beq scen_1_1_D70_ruleset0_rule0_y
		jmp fpg_failed_pos_x
scen_1_1_D70_ruleset0_rule0_y:
		ldx Player_Y_Position
		cpx #$50
		beq scen_1_1_D70_ruleset0_rule1
		jmp fpg_failed_pos_y
scen_1_1_D70_ruleset0_rule1:
		cpy #$1B
		bne scen_1_1_D70_ruleset0_rule2
		cmp #$01
		beq scen_1_1_D70_ruleset0_rule2
		lda #$01
		jmp fpg_failed_input
scen_1_1_D70_ruleset0_rule2:
		cpy #$1C
		bne scen_1_1_D70_ruleset0_rule3
		pha
		lda FpgFlags
		ora #$20
		sta FpgFlags
		pla
scen_1_1_D70_ruleset0_rule3:
		cpy #$1C
		bmi scen_1_1_D70_ruleset0_rule5
		cpy #$1E
		bpl scen_1_1_D70_ruleset0_rule5
		cmp #$41
		beq scen_1_1_D70_ruleset0_rule5
		lda #$41
		jmp fpg_failed_input
scen_1_1_D70_ruleset0_rule5:
		cpy #$1E
		bmi scen_1_1_D70_ruleset0_rule37
		cpy #$3E
		bpl scen_1_1_D70_ruleset0_rule37
		cmp #$C1
		beq scen_1_1_D70_ruleset0_rule37
		lda #$C1
		jmp fpg_failed_input
scen_1_1_D70_ruleset0_rule37:
		cpy #$6C
		bmi scen_1_1_D70_ruleset0_rule40
		cpy #$6F
		bpl scen_1_1_D70_ruleset0_rule40
		cmp #$02
		beq scen_1_1_D70_ruleset0_rule40
		lda #$02
		jmp fpg_failed_input
scen_1_1_D70_ruleset0_rule40:
		cpy #$6F
		bne scen_1_1_D70_ruleset0_rule41
		cmp #$82
		beq scen_1_1_D70_ruleset0_rule41
		lda #$82
		jmp fpg_failed_input
scen_1_1_D70_ruleset0_rule41:
		cpy #$A5
		bne scen_1_1_D70_ruleset0_rule42
		ldx Player_X_Position
		cpx #$6B
		beq scen_1_1_D70_ruleset0_rule41_y
		jmp fpg_failed_pos_x
scen_1_1_D70_ruleset0_rule41_y:
		ldx Player_Y_Position
		cpx #$A0
		beq scen_1_1_D70_ruleset0_rule42
		jmp fpg_failed_pos_y
scen_1_1_D70_ruleset0_rule42:
		cpy #$A7
		bne scen_1_1_D70_ruleset0_rule43
		jmp fpg_win
scen_1_1_D70_ruleset0_rule43:
		rts
scen_1_1_D70_ruleset1:
		ldy FrameCounter
		lda SavedJoypadBits
		and #$C3
scen_1_1_D70_ruleset1_rule0:
		cpy #$1C
		bne scen_1_1_D70_ruleset1_rule1
		ldx Player_X_Position
		cpx #$98
		beq scen_1_1_D70_ruleset1_rule0_y
		jmp fpg_failed_pos_x
scen_1_1_D70_ruleset1_rule0_y:
		ldx Player_Y_Position
		cpx #$50
		beq scen_1_1_D70_ruleset1_rule1
		jmp fpg_failed_pos_y
scen_1_1_D70_ruleset1_rule1:
		cpy #$1C
		bne scen_1_1_D70_ruleset1_rule2
		cmp #$01
		beq scen_1_1_D70_ruleset1_rule2
		lda #$01
		jmp fpg_failed_input
scen_1_1_D70_ruleset1_rule2:
		cpy #$1D
		bne scen_1_1_D70_ruleset1_rule3
		cmp #$41
		beq scen_1_1_D70_ruleset1_rule3
		lda #$41
		jmp fpg_failed_input
scen_1_1_D70_ruleset1_rule3:
		cpy #$1E
		bmi scen_1_1_D70_ruleset1_rule35
		cpy #$3E
		bpl scen_1_1_D70_ruleset1_rule35
		cmp #$C1
		beq scen_1_1_D70_ruleset1_rule35
		lda #$C1
		jmp fpg_failed_input
scen_1_1_D70_ruleset1_rule35:
		cpy #$6C
		bmi scen_1_1_D70_ruleset1_rule38
		cpy #$6F
		bpl scen_1_1_D70_ruleset1_rule38
		cmp #$02
		beq scen_1_1_D70_ruleset1_rule38
		lda #$02
		jmp fpg_failed_input
scen_1_1_D70_ruleset1_rule38:
		cpy #$6F
		bne scen_1_1_D70_ruleset1_rule39
		cmp #$82
		beq scen_1_1_D70_ruleset1_rule39
		lda #$82
		jmp fpg_failed_input
scen_1_1_D70_ruleset1_rule39:
		cpy #$A5
		bne scen_1_1_D70_ruleset1_rule40
		ldx Player_X_Position
		cpx #$6B
		beq scen_1_1_D70_ruleset1_rule39_y
		jmp fpg_failed_pos_x
scen_1_1_D70_ruleset1_rule39_y:
		ldx Player_Y_Position
		cpx #$A0
		beq scen_1_1_D70_ruleset1_rule40
		jmp fpg_failed_pos_y
scen_1_1_D70_ruleset1_rule40:
		cpy #$A7
		bne scen_1_1_D70_ruleset1_rule41
		jmp fpg_win
scen_1_1_D70_ruleset1_rule41:
		rts
scen_1_1_D70_rulesets:
	.word scen_1_1_D70_ruleset0
	.word scen_1_1_D70_ruleset1
scen_1_1_D70_validate:
		lda FpgRuleset
		asl
		tay
		lda scen_1_1_D70_rulesets, y
		sta $0
		lda scen_1_1_D70_rulesets+1, y
		sta $1
		jmp ($0)
	
fpg_num_configs: .byte $03
fpg_configs:
		.byte $01, $28, $02, $10, $24, $11, $12, $24 ; 1-2G HI
fpg_load_area_func:
		.word scen_1_2G_HI_load_area
fpg_reset_func:
		.word scen_1_2G_HI_reset
fpg_validate_func:
		.word scen_1_2G_HI_validate
fpg_num_routes:
		.byte $01
		.byte 0
		.byte $01, $28, $02, $10, $24, $15, $18, $24 ; 1-2G LO
		.word scen_1_2G_LO_load_area
		.word scen_1_2G_LO_reset
		.word scen_1_2G_LO_validate
		.byte $01
		.byte 0
		.byte $01, $28, $01, $24, $0D, $07, $00, $24 ; 1-1 D70
		.word scen_1_1_D70_load_area
		.word scen_1_1_D70_reset
		.word scen_1_1_D70_validate
		.byte $02
		.byte 0
.include "scen_exports.asm"
