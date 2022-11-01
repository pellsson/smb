.include "mario.inc"
.include "shared.inc"
.include "macros.inc"

; # Super Mario Bros 2J
.segment "bank7"
.scope SMB2J
.org $8000
.include "lost/lost.asm"
.endscope

.segment "bank8"
.scope SMB2JLVL
.org $8000
.include "lost/leveldata.asm"
.endscope

; # All Night Nippon
.segment "bank9"
.scope ANN
ANN = 1
.org $8000
.include "lost/lost.asm"
.endscope

.segment "bank10"
.scope ANNLVL
ANN = 1
.org $8000
.include "lost/leveldata.asm"
.endscope

; # Empty banks (for FCEUX...)
.segment "bank11"
.scope bank11
.org $8000
Start:
NonMaskableInterrupt: rti
control_bank 11*4
.endscope

.segment "bank12"
.scope bank12
.org $8000
Start:
NonMaskableInterrupt: rti
control_bank 12*4
.endscope

.segment "bank13"
.scope bank13
.org $8000
Start:
NonMaskableInterrupt: rti
control_bank 13*4
.endscope

.segment "bank14"
.scope bank14
.org $8000
Start:
NonMaskableInterrupt: rti
control_bank 14*4
.endscope

.segment "bank15"
.scope bank15
.org $8000
Start:
NonMaskableInterrupt: rti
control_bank 15*4
.endscope

.segment "bank16"
.scope bank16
.org $8000
Start:
NonMaskableInterrupt: rti
control_bank 16*4
.endscope

.segment "chr0"
.incbin "chr/smb/smborg-sprites.chr"
.incbin "chr/smb/smborg-back.chr"

.segment "chr1"
.incbin "chr/smb/SM2CHAR1.chr"

.segment "chr2"
.incbin "chr/smb/NSMCHAR1.chr"

.segment "chr3"
.incbin "chr/smb/peach-sprites.chr"
.incbin "chr/intro/intro-bg.chr"

.segment "chr4"
.incbin "chr/intro/intro-sprites.chr"
.incbin "chr/intro/andrewg.chr"
.incbin "chr/intro/darbian.chr"
.incbin "chr/intro/roylt.chr"
.incbin "chr/intro/tavenwebb2002.chr"
.incbin "chr/intro/kosmic.chr"
.incbin "chr/intro/leontoast.chr"

.segment "chr5"
.incbin "chr/statusbar.chr"
.incbin "chr/smb/SM2CHAR2.chr"
.incbin "chr/smb/NSMCHAR2.chr"
