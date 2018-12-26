
	.include "shared.inc"
	.include "org.inc"
	.include "macros.inc"

	.org $8000
	.segment "bank4"

Start:	; Dummy
NonMaskableInterrupt: ; Dummy

	.include "sound.asm"
	.include "practice.asm"

	.export SoundEngine
	.export AdvanceToRule
	.export RedrawPosition
	.export RedrawAll
	.export UpdateFrameRule
	.export WritePracticeTop
	.export RedrawFrameNumbers


practice_callgate
control_bank
