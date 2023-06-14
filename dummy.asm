	.include "mario.inc"
	.include "shared.inc"
	.include "macros.inc"
	.include "wram.inc"
	.include "text.inc"
	.org $8000
	.segment "bank2"

Start:
NonMaskableInterrupt:
	control_bank BANK_CHR

