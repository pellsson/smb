
	.include "shared.inc"
	.include "mario.inc"
	.include "macros.inc"

	.org $8000
	.segment "bank4"

Start:	; Dummy
NonMaskableInterrupt: ; Dummy

	.include "sound.asm"
	.include "practice.asm"

	.export PracticeOnFrame
	.export PracticeTitleMenu
	.export SoundEngine
	.export AdvanceToRule
	.export RedrawPosition
	.export RedrawAll
	.export UpdateFrameRule
	.export WritePracticeTop
	.export RedrawFrameNumbers


practice_callgate
control_bank
