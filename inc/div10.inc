.ifndef __DIV10_INC_DEF__
.define __DIV10_INC_DEF__

DivByTen:
    ldx #$00
DivMore:
    cmp #$0a
    bcc DivByTenDone
    sbc #$0a
    inx
    sec
    bcs DivMore
DivByTenDone:
    rts

.endif
