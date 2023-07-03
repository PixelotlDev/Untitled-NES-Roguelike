.segment "CODE"

nmi:
    pha             ; make sure we don't clobber the A register

    lda nmi_ready   ; check the nmi_ready flag
    bne nmi_go      ; if nmi_ready set to 1 we can execute the nmi code
        pla
        rti
    nmi_go:

    lda PPU_STATUS ; $2002

    ; initialise render
    jsr oam_dma

    lda #$0
    sta nmi_ready

    pla
    rti
