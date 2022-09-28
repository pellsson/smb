.segment "ines"
.byte $4E,$45,$53,$1A ; INES header
.byte $10             ; PGR pages
.byte $00             ; CHR pages
.byte $10             ; MMC1
.byte $00             ; 
.byte $00             ; 
.ifdef PAL
.byte $01             ; PAL
.else
.byte $00             ; NTSC
.endif
.byte $00             ; 
.byte $00             ; 
.byte $00             ; 
.byte $00             ; 
.byte $00             ; 
.byte $00             ; 
