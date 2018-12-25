	.include "org.inc"
	.include "shared.inc"
	.include "macros.inc"
	.org $8000
	.segment "bank8"
Start:
NonMaskableInterrupt:
	control_bank

