
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
	.export Enter_SoundEngine
	.export AdvanceToRule
	.export Enter_AdvanceToRule

control_bank
