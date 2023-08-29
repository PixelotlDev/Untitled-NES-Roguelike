.segment "ROMDATA"
.scope METATILES
    start:

    ; ID #$00
    null:
        .byte $00, $00
        .byte $00, $00

    ; ID #$01
    leftEnd:
        .byte $84, $85
        .byte $a4, $a5

    ; ID #$02
    middle:
        .byte $85, $85
        .byte $a5, $a5

    ; ID #$03
    rightEnd:
        .byte $85, $86
        .byte $a5, $a6

    ; ID #$04
    test:
        .byte $54, $45
        .byte $53, $54

.endscope