.ifndef __UTILS_INC_DEF__
.define __UTILS_INC_DEF__

AdvanceRandom:
    lda PseudoRandomBitReg    ;get first memory location of LSFR bytes
    and #%00000010            ;mask out all but d1
    sta $00                   ;save here
    lda PseudoRandomBitReg+1  ;get second memory location
    and #%00000010            ;mask out all but d1
    eor $00                   ;perform exclusive-OR on d1 from first and second bytes
    clc                       ;if neither or both are set, carry will be clear
    beq RotPRandomBit
    sec                       ;if one or the other is set, carry will be set
RotPRandomBit:
    ror PseudoRandomBitReg+0  ;rotate carry into d7, and rotate last bit into carry
    ror PseudoRandomBitReg+1  ;rotate carry into d7, and rotate last bit into carry
    ror PseudoRandomBitReg+2  ;rotate carry into d7, and rotate last bit into carry
    ror PseudoRandomBitReg+3  ;rotate carry into d7, and rotate last bit into carry
    ror PseudoRandomBitReg+4  ;rotate carry into d7, and rotate last bit into carry
    ror PseudoRandomBitReg+5  ;rotate carry into d7, and rotate last bit into carry
    ror PseudoRandomBitReg+6  ;rotate carry into d7, and rotate last bit into carry
    rts

MulByTen:
    asl
    sta $0
    asl
    asl
    clc
    adc $0
    rts

.include "div10.inc"

.endif
