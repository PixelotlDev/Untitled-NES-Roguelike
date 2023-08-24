; graphics and rendering library

.segment "CODE"

.proc load_scene_metatiles
    ; TODO: turn metatiles into tiles in memory, so that they can be drawn to screen

    rts
.endproc

; copies everything from whatever is loaded from scene_data onwards to ppu memory
; clobbers x ($00) and y ($c0)
.proc load_scene_tiles
    ; bytes 0-255
    ldy #$20
    ldx #$00

    lda PPU_STATUS        ; PPU_STATUS = $2002

    sty PPU_ADDR          ; High byte
    stx PPU_ADDR          ; Low byte

    ldy #$0

    load_scene_tiles_loop_1:
        lda (scene_tiles_address), y
        sta PPU_DATA

        iny
        bne load_scene_tiles_loop_1

    inc scene_tiles_address+1

    load_scene_tiles_loop_2:
        lda (scene_tiles_address), y
        sta PPU_DATA

        iny
        bne load_scene_tiles_loop_2

    inc scene_tiles_address+1

    load_scene_tiles_loop_3:
        lda (scene_tiles_address), y
        sta PPU_DATA

        iny
        bne load_scene_tiles_loop_3
    
    inc scene_tiles_address+1

    ; the final loop has a few less bytes to load
    load_scene_tiles_loop_4:
        lda (scene_tiles_address), y
        sta PPU_DATA

        iny
        cpy #$c0
        bne load_scene_tiles_loop_4
    rts
.endproc

; like load_scene_tiles, but for the attribute table - much shorter, cos there's a lot less data to transfer
.proc load_initial_scene_attribute
    lda PPU_STATUS        ; PPU_STATUS = $2002

    lda #$23
    sta PPU_ADDR          ; High byte
    lda #$c0
    sta PPU_ADDR          ; Low byte

    ldy #$00

    attribute_loop_1:
        lda (scene_attribute_address), y
        sta PPU_DATA

        iny
        cpy #$40
        bne attribute_loop_1
    rts
.endproc

; load x with desired sprite ID
; load accumulator with x screen position
; load y with y screen position
.proc move_sprite
    ; save accumulator on the stack
    pha

    txa
    asl
    asl
    tax

    ; take the x position off of the stack and store
    pla
    sta $0203, x

    ; store y pos
    tya
    sta $0200, x

    rts
.endproc