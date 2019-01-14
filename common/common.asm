
	.include "shared.inc"
	.include "mario.inc"
	.include "macros.inc"
	.include "text.inc"

	.org $8000
	.segment "bank4"

Start:	; Dummy
NonMaskableInterrupt: ; Dummy

	.include "utils.inc"
	.include "sound.asm"
	.include "game.asm"
	.include "pausemenu.asm"
	.include "practice.asm"

	.export PracticeInit
	.export ForceUpdateSockHash
	.export PracticeOnFrame
	.export PracticeTitleMenu
	.export SoundEngine
	.export ProcessLevelLoad
	.export RedrawUserVars
	.export RedrawAll
	.export UpdateFrameRule
	.export WritePracticeTop
	.export RedrawFrameNumbers


practice_callgate
control_bank
