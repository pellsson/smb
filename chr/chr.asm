.segment "chr0"
.incbin "smb/smborg-sprites.chr"
.incbin "smb/smborg-back.chr"

.segment "chr1"
.incbin "smb/lost-back.chr", $0000, $02C0 ; lost charset
.incbin "smb/smborg-back.chr", $02C0      ; smb1 bg
.incbin "smb/lost-sprites.chr"

.segment "chr2"
.incbin "smb/lost-back.chr"
.incbin "smb/smborg-back.chr", $0000, $02C0 ; smb1 charset
.incbin "smb/lost-back.chr", $02C0          ; lost bg

.segment "chr3"
.incbin "smb/peach-sprites.chr"
.incbin "intro/intro-bg.chr"

.segment "chr4"
.incbin "intro-sprbank0.chr"
.incbin "statusbar-lost.chr"
