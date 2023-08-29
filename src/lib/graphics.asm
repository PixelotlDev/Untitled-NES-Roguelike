; graphics and rendering library

.segment "CODE"

.proc load_scene_metatiles
    lda #>display_buffer
    sta display_buffer_address+1
    ldy #$0
    sty metatile_screen_pointer

    @load_loop:

        @load_chunk:
            ; push y onto the stack to save it, since we'll be using the y register in the next loop
            tya
            pha

            ; load MSB of METATILES::start into metatile_pointer
            lda #>METATILES::start
            sta metatile_pointer+1

            ; load metatile ID
            lda (scene_metatiles_address), y

            ; multiply it by 4 and add the LSB of METATILES::start to get our offset
            asl
            asl
            clc
            adc #<METATILES::start
            sta metatile_pointer

            bcc :+
                ; if carry is set, we've overflowed and need to increment metatile_pointer+1
                inc metatile_pointer+1
            :

            ldx #$0

            @metatile_loop:
                ; load accumulator with tile from metatile
                txa
                tay
                lda (metatile_pointer), y
                ldy metatile_screen_pointer
                sta (display_buffer_address), y

                ; update metatile_screen_pointer to the next location
                txa
                and #%00000011
                cmp #%00000001 ; check if we've finished with the bottom of the metatile
                bne :+
                    ; if we have, we're going to have to add #$1F to metatile_screen_pointer
                    lda metatile_screen_pointer
                    clc
                    adc #$1E
                    sta metatile_screen_pointer
                :

                ; after, we just increment metatile_screen_pointer and x
                inc metatile_screen_pointer
                inx

                ; when x has reached 4, we've loaded the whole metatile and can leave the loop
                txa
                cmp #$04
                bne @metatile_loop
            
            ; if metatile_screen_pointer is on a row not divisible by 32, we don't need to subtract anything
            lda metatile_screen_pointer
            and #%00100000
            beq @skip_normal_row_subtract

            ; set metatile_screen_pointer back to the start of the next 4-tile chunk
            lda metatile_screen_pointer
            sec
            sbc #$20
            sta metatile_screen_pointer

            @skip_normal_row_subtract:

            ; pull y back from stack and increment it
            pla
            tay
            iny

            tya
            cmp #$F0
            beq @end_loading

            ; if metatile_screen_pointer is 0, we've finished this chunk and can move onto the next
            lda metatile_screen_pointer
            bne @load_chunk

        ; increment display_buffer_address MSB
        inc display_buffer_address+1

        ; always loop back to @load_loop, we escape out of it further up when we're done
        jmp @load_loop

    @end_loading:
    rts
.endproc

; copies everything from whatever is loaded from display_buffer_address onwards to ppu memory
; clobbers x ($00) and y ($c0)
.proc load_scene_tiles
    lda #<display_buffer
    sta display_buffer_address
    lda #>display_buffer
    sta display_buffer_address+1

    ; bytes 0-255
    ldy #$20
    ldx #$00

    lda PPU_STATUS        ; PPU_STATUS = $2002

    sty PPU_ADDR          ; High byte
    stx PPU_ADDR          ; Low byte

    ldy #$0

    load_scene_tiles_loop_1:
        lda (display_buffer_address), y
        sta PPU_DATA

        iny
        bne load_scene_tiles_loop_1

    inc display_buffer_address+1

    load_scene_tiles_loop_2:
        lda (display_buffer_address), y
        sta PPU_DATA

        iny
        bne load_scene_tiles_loop_2

    inc display_buffer_address+1

    load_scene_tiles_loop_3:
        lda (display_buffer_address), y
        sta PPU_DATA

        iny
        bne load_scene_tiles_loop_3
    
    inc display_buffer_address+1

    ; the final loop has a few less bytes to load
    load_scene_tiles_loop_4:
        lda (display_buffer_address), y
        sta PPU_DATA

        iny
        cpy #$c0
        bne load_scene_tiles_loop_4
    rts
.endproc

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